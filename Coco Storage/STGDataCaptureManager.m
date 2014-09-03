//
//  STGDataCaptureManager.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 27.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGDataCaptureManager.h"

#import <AVFoundation/AVFoundation.h>

#import "STGDataCaptureEntry.h"

#import "STGFileHelper.h"

#import "STGMovieCaptureSession.h"

@interface STGDataCaptureManager ()

+ (NSString *)getDateAsString;

@end

@implementation STGDataCaptureManager

+ (NSArray *)getSupportedPasteboardContentTypes
{
    return [NSArray arrayWithObjects:NSFilenamesPboardType, NSURLPboardType, NSPasteboardTypePNG, NSPasteboardTypeTIFF, NSTIFFPboardType, NSPasteboardTypeRTF, NSPasteboardTypeString, NSPasteboardTypeColor, nil];
}

+ (NSArray *)getActionsFromPasteboard:(NSPasteboard *)pasteboard
{
    NSMutableSet *actionSet = [[NSMutableSet alloc] init];
    
    if ([[pasteboard types] containsObject:NSFilenamesPboardType])
    {
        NSData *data = [pasteboard dataForType:NSFilenamesPboardType];
        NSError *error;
        
        NSArray *filenames = [NSPropertyListSerialization propertyListWithData:data options:kCFPropertyListImmutable format:nil error:&error];
        
        if (error)
            NSLog(@"%@", error);
        else if (filenames && [filenames count] > 1)
        {
            [actionSet addObject:[NSNumber numberWithInteger:STGUploadActionUploadZip]];
        }
    }
    
    if ([pasteboard canReadObjectForClasses:[NSArray arrayWithObject:[NSImage class]] options:nil])
    {
        [actionSet addObject:[NSNumber numberWithInteger:STGUploadActionUploadImage]];
    }
    
    NSURL *url = [NSURL URLFromPasteboard:pasteboard];
    if (url)
        [self handleURLInterpretation:url forSet:actionSet];
    
    if ([[pasteboard types] containsObject:NSPasteboardTypeRTF])
    {
        [actionSet addObject:[NSNumber numberWithInteger:STGUploadActionUploadRtfText]];
    }
    
    NSArray *strings = [pasteboard readObjectsForClasses:[NSArray arrayWithObject:[NSString class]] options:nil];
    if (strings)
    {
        [actionSet addObject:[NSNumber numberWithInteger:STGUploadActionUploadText]];
        
        if ([strings count] == 1)
        {
            NSString *string = [strings firstObject];
            
            if ([string isAbsolutePath])
                [actionSet addObject:[NSNumber numberWithInteger:STGUploadActionUploadFile]];

            NSURL *url = [NSURL URLWithString:string];
            if (url)
                [self handleURLInterpretation:url forSet:actionSet];
        }
        else if ([strings count] > 1)
        {
            BOOL allStringsPaths = YES;
            for (NSString *string in strings)
            {
                if (![string isAbsolutePath] || ![[NSFileManager defaultManager] fileExistsAtPath:string])
                    allStringsPaths = NO;
            }
            
            if (allStringsPaths)
                [actionSet addObject:[NSNumber numberWithInteger:STGUploadActionUploadZip]];
        }
    }
    
    if ([[pasteboard types] containsObject:NSPasteboardTypeColor])
    {
        [actionSet addObject:[NSNumber numberWithInteger:STGUploadActionUploadColor]];
    }
    
    return [[actionSet allObjects] sortedArrayUsingSelector:@selector(integerValue)];
}

+ (void)handleURLInterpretation:(NSURL *)url forSet:(NSMutableSet *)actionSet
{
    if ([url isFileURL])
    {
        BOOL isDirectory;
        BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[url path] isDirectory:&isDirectory];
        
        if (exists)
        {
            if (isDirectory)
                [actionSet addObject:[NSNumber numberWithInteger:STGUploadActionUploadDirectoryZip]];
            else
                [actionSet addObject:[NSNumber numberWithInteger:STGUploadActionUploadFile]];
        }
    }
    else if ([[url scheme] isEqualToString:@"http"] || [[url scheme] isEqualToString:@"https"])
    {
        [actionSet addObject:[NSNumber numberWithInteger:STGUploadActionRedirectLink]];
        [actionSet addObject:[NSNumber numberWithInteger:STGUploadActionRehostFromLink]];
    }
}

+ (NSArray *)captureDataFromPasteboard:(NSPasteboard *)pasteboard withAction:(STGUploadAction)action
{
    if (action == STGUploadActionUploadFile)
    {
        NSURL *url = [self findURLInPasteboard:pasteboard];

        STGDataCaptureEntry *entry = [self captureFile:url tempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]];
        
        if (entry)
            return [NSArray arrayWithObject:entry];
    }
    else if (action == STGUploadActionUploadDirectoryZip)
    {
        NSURL *url = [self findURLInPasteboard:pasteboard];
        
        STGDataCaptureEntry *entry = [self captureFilesAsZip:[NSArray arrayWithObject:url] withTempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]];
        
        if (entry)
            return [NSArray arrayWithObject:entry];
    }
    else if (action == STGUploadActionUploadZip)
    {
        NSArray *filenames = [self findPathsInPasteboard:pasteboard];
        
        if (filenames && [filenames count] > 0)
        {
            NSMutableArray *validURLS = [[NSMutableArray alloc] initWithCapacity:[filenames count]];
            
            for (NSString *filename in filenames)
            {
                NSURL *url = [STGFileHelper urlFromStandardPath:filename];
                
                if (url && [url isFileURL])
                {
                    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[url path]];
                    
                    if (exists)
                        [validURLS addObject:url];
                }
            }
            
            STGDataCaptureEntry *entry = [self captureFilesAsZip:validURLS withTempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]];
            
            if (entry)
                return [NSArray arrayWithObject:entry];
        }
    }
    else if (action == STGUploadActionUploadRtfText)
    {
        STGDataCaptureEntry *entry = [self captureAttributedTextAsFile:[[NSAttributedString alloc] initWithRTF:[pasteboard dataForType:NSPasteboardTypeRTF] documentAttributes:nil] tempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]];
        
        if (entry)
            return [NSArray arrayWithObject:entry];
    }
    else if (action == STGUploadActionUploadText)
    {
        NSArray *strings = [pasteboard readObjectsForClasses:[NSArray arrayWithObject:[NSString class]] options:nil];
        STGDataCaptureEntry *entry = [self captureTextAsFile:[strings componentsJoinedByString:@", "] tempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]];
        
        if (entry)
            return [NSArray arrayWithObject:entry];
    }
    else if (action == STGUploadActionUploadImage)
    {
        NSArray *objectsToPaste = [pasteboard readObjectsForClasses:[NSArray arrayWithObject:[NSImage class]] options:nil];
        NSImage *image = [objectsToPaste objectAtIndex:0];
        
        STGDataCaptureEntry *entry = [self captureImageAsFile:image tempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]];
        
        if (entry)
            return [NSArray arrayWithObject:entry];
    }
    else if (action == STGUploadActionRedirectLink)
    {
        NSURL *url = [self findURLInPasteboard:pasteboard];
        
        STGDataCaptureEntry *entry = [self captureLinkAsRedirectFile:url tempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]];
        
        if (entry)
            return [NSArray arrayWithObject:entry];
    }
    else if (action == STGUploadActionRehostFromLink)
    {
        NSURL *url = [self findURLInPasteboard:pasteboard];
        
        STGDataCaptureEntry *entry = [self captureLinkAsRehostFile:url tempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]];
        
        if (entry)
            return [NSArray arrayWithObject:entry];
    }
    else if (action == STGUploadActionUploadColor)
    {
        STGDataCaptureEntry *entry = [self captureColorAsFile:[NSColor colorFromPasteboard:pasteboard] tempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]];
        
        if (entry)
            return [NSArray arrayWithObject:entry];
    }
    
    return nil;
}

+ (NSURL *)findURLInPasteboard:(NSPasteboard *)pasteboard
{
    NSURL *url = [NSURL URLFromPasteboard:pasteboard];
    
    if (!url)
    {
        NSArray *strings = [pasteboard readObjectsForClasses:[NSArray arrayWithObject:[NSString class]] options:nil];
        if (strings)
        {
            NSString *string = [strings firstObject];
            
            if ([string isAbsolutePath])
                url = [STGFileHelper urlFromStandardPath:string];
            else
                url = [NSURL URLWithString:string];
        }
    }
    
    return url;
}

+ (NSArray *)findPathsInPasteboard:(NSPasteboard *)pasteboard
{
    NSData *data = [pasteboard dataForType:NSFilenamesPboardType];
    NSError *error;
    
    NSArray *filenames = [NSPropertyListSerialization propertyListWithData:data options:kCFPropertyListImmutable format:nil error:&error];
    if (error)
    {
        NSArray *strings = [pasteboard readObjectsForClasses:[NSArray arrayWithObject:[NSString class]] options:nil];

        if (strings)
        {
            NSMutableArray *mutableFilenames = [[NSMutableArray alloc] init];
            for (NSString *string in strings)
            {
                if ([string isAbsolutePath])
                    [mutableFilenames addObject:string];
            }
            filenames = mutableFilenames;
        }
    }
    
    return filenames;
}

+ (NSString *)getNameForAction:(STGUploadAction)action
{
    if (action == STGUploadActionUploadFile)
        return @"Upload File";
    else if (action == STGUploadActionUploadDirectoryZip)
        return @"Upload as zip";
    else if (action == STGUploadActionUploadZip)
        return @"Upload as zip";
    else if (action == STGUploadActionUploadText)
        return @"Upload Text";
    else if (action == STGUploadActionUploadRtfText)
        return @"Upload Attributed Text";
    else if (action == STGUploadActionUploadImage)
        return @"Upload Image";
    else if (action == STGUploadActionRedirectLink)
        return @"Shorten Link";
    else if (action == STGUploadActionUploadColor)
        return @"Upload Color";
    else if (action == STGUploadActionRehostFromLink)
        return @"Fetch Media from URL";
    
    return nil;
}

+ (void)startScreenCapture:(BOOL)fullscreen tempFolder:(NSString *)tempFolder silent:(BOOL)silent delegate:(NSObject<STGDataCaptureDelegate> *)delegate
{
    NSString *fileName = [tempFolder stringByAppendingFormat:@"/Screenshot_%@.png", [self getDateAsString]];
    
    NSTask *task = [[NSTask alloc] init];
    
    NSMutableArray *args = [[NSMutableArray alloc] init];
    if(!fullscreen)
        [args addObject:@"-i"]; //Interactive
    else
        [args addObject:@"-C"]; //Capture mouse
    if(silent)
        [args addObject:@"-x"]; //Silent
    [args addObject:fileName];
    
    [task setArguments: args];

    [task setLaunchPath: @"/usr/sbin/screencapture"];

    dispatch_async(dispatch_get_current_queue(), ^{
        [task launch];
        [task waitUntilExit];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileName])
        {
            [delegate dataCaptureCompleted:[STGDataCaptureEntry entryWithAction:STGUploadActionUploadImage url:[STGFileHelper urlFromStandardPath:fileName] deleteOnCompletion:YES] sender:nil];
        }
    });
}

+ (STGDataCaptureEntry *)captureTextAsFile:(NSString *)text tempFolder:(NSString *)tempFolder
{
    NSString *fileName = [tempFolder stringByAppendingFormat:@"/Text_%@.txt", [self getDateAsString]];
    
    [[NSFileManager defaultManager] createFileAtPath:fileName contents:[text dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];

    if (![[NSFileManager defaultManager] fileExistsAtPath:fileName])
    {
        return nil;
    }
    
    return [STGDataCaptureEntry entryWithAction:STGUploadActionUploadText url:[STGFileHelper urlFromStandardPath:fileName] deleteOnCompletion:YES];
}

+ (STGDataCaptureEntry *)captureAttributedTextAsFile:(NSAttributedString *)text tempFolder:(NSString *)tempFolder
{
    NSString *fileName = [tempFolder stringByAppendingFormat:@"/Text_%@.html", [self getDateAsString]];
    
    NSDictionary *documentAttributes = [NSDictionary dictionaryWithObjectsAndKeys:NSHTMLTextDocumentType, NSDocumentTypeDocumentAttribute, nil];
    NSData *htmlData = [text dataFromRange:NSMakeRange(0, text.length) documentAttributes:documentAttributes error:NULL];

    [[NSFileManager defaultManager] createFileAtPath:fileName contents:htmlData attributes:nil];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileName])
    {
        return nil;
    }
    
    return [STGDataCaptureEntry entryWithAction:STGUploadActionUploadRtfText url:[STGFileHelper urlFromStandardPath:fileName] deleteOnCompletion:YES];
}

+ (STGDataCaptureEntry *)captureLinkAsRedirectFile:(NSURL *)link tempFolder:(NSString *)tempFolder
{
    NSString *fileName = [tempFolder stringByAppendingFormat:@"/Link_%@_%@.html", [link host], [self getDateAsString]];
    
    [[NSFileManager defaultManager] createFileAtPath:fileName contents:[[NSString stringWithFormat:@"<html>\n<head>\n<meta http-equiv=\"refresh\" content=\"0; url=%@\">\n</head>\n<body></body></html>", [link absoluteString]] dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileName])
        return nil;
    
    return [STGDataCaptureEntry entryWithAction:STGUploadActionRedirectLink url:[STGFileHelper urlFromStandardPath:fileName] deleteOnCompletion:YES];
}

+ (STGDataCaptureEntry *)captureLinkAsRehostFile:(NSURL *)link tempFolder:(NSString *)tempFolder
{
    NSString *fileName = [tempFolder stringByAppendingFormat:@"/Media_%@_%@.txt", [link host], [self getDateAsString]];
    
    [[NSFileManager defaultManager] createFileAtPath:fileName contents:[[link absoluteString] dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileName])
        return nil;
    
    return [STGDataCaptureEntry entryWithAction:STGUploadActionRehostFromLink url:[STGFileHelper urlFromStandardPath:fileName] deleteOnCompletion:YES];
}

+ (STGDataCaptureEntry *)captureImageAsFile:(NSImage *)image tempFolder:(NSString *)tempFolder
{
    NSString *fileName = [tempFolder stringByAppendingFormat:@"/Image_%@.png", [self getDateAsString]];

    NSBitmapImageRep *imgRep = [[image representations] objectAtIndex: 0];
    
    NSData *data = [imgRep representationUsingType:NSPNGFileType properties:nil];
    [data writeToFile:fileName atomically: NO];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileName])
    {
        return nil;
    }
    
    return [STGDataCaptureEntry entryWithAction:STGUploadActionUploadImage url:[STGFileHelper urlFromStandardPath:fileName] deleteOnCompletion:YES];
}

+ (STGDataCaptureEntry *)captureColorAsFile:(NSColor *)color tempFolder:(NSString *)tempFolder
{
    NSString *fileName = [tempFolder stringByAppendingFormat:@"/Color_%@.html", [self getDateAsString]];
    
    NSColor *convColor = [color colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
    
    [[NSFileManager defaultManager] createFileAtPath:fileName contents:[[NSString stringWithFormat:@"<html>\n<head></head>\n<body bgcolor=\"#%X%X%X\"></body></html>", (unsigned)([convColor redComponent] * 255.0), (unsigned)([convColor greenComponent] * 255.0), (unsigned)([convColor blueComponent] * 255.0)] dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileName])
    {
        return nil;
    }
    
    return [STGDataCaptureEntry entryWithAction:STGUploadActionUploadColor url:[STGFileHelper urlFromStandardPath:fileName] deleteOnCompletion:YES];
}

+ (STGDataCaptureEntry *)captureFile:(NSURL *)link tempFolder:(NSString *)tempFolder
{
    return [STGDataCaptureEntry entryWithAction:STGUploadActionUploadFile url:link deleteOnCompletion:NO];
}

+ (STGDataCaptureEntry *)captureFilesAsZip:(NSArray *)links withTempFolder:(NSString *)tempFolder
{
    if (links && [links count] > 0)
    {
        NSString *fileName = [tempFolder stringByAppendingFormat:@"/Archive_%@.zip", [self getDateAsString]];
                
        NSURL *baseURL = nil;
        for (NSURL *url in links)
        {
            if (!baseURL)
                baseURL = url;
            
            while ([[url path] rangeOfString:[baseURL path]].location == NSNotFound || [[url path] isEqualToString:[baseURL path]])
            {
                baseURL = [baseURL URLByDeletingLastPathComponent];
            }
        }
        
        NSMutableArray *relativeLinks = [[NSMutableArray alloc] initWithCapacity:[links count]];
        
        for (NSURL *link in links)
        {
            NSString *absolute = [link absoluteString];
            NSRange range = [absolute rangeOfString:[baseURL absoluteString]];
            NSString *relativePath = [absolute substringFromIndex:range.location + range.length];
            
            [relativeLinks addObject:[[NSURL alloc] initWithString:relativePath]];
        }

        NSTask *task = [[NSTask alloc] init];
        
        NSMutableArray *args = [[NSMutableArray alloc] init];

        [args addObject:@"-r"];
        
        [args addObject:fileName];
        
        for (NSURL *url in relativeLinks)
        {
            [args addObject:[url path]];
        }
        
        [task setArguments: args];
        
        [task setLaunchPath: @"/usr/bin/zip"];
        [task setCurrentDirectoryPath:[baseURL path]];
        [task launch];
        [task waitUntilExit];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:fileName])
        {
            return nil;
        }
        
        return [STGDataCaptureEntry entryWithAction:STGUploadActionUploadImage url:[STGFileHelper urlFromStandardPath:fileName] deleteOnCompletion:YES];
    }
    
    return nil;
}

+ (void)startFileCaptureWithTempFolder:(NSString *)tempFolder delegate:(NSObject<STGDataCaptureDelegate> *)delegate
{
    NSOpenPanel *filePanel = [[NSOpenPanel alloc] init];
    [filePanel setCanChooseDirectories:NO];
    [filePanel setCanChooseFiles:YES];
    [filePanel setAllowsMultipleSelection:YES];
    [filePanel setFloatingPanel:NO];
    [filePanel setTitle:@"Select files to upload"];
    [filePanel setPrompt:@"Upload"];

    dispatch_async(dispatch_get_current_queue(), ^{
        if ([filePanel runModal] == NSOKButton)
        {
            NSArray *urls = [filePanel URLs];
            
            for (NSURL *url in urls)
                [delegate dataCaptureCompleted:[STGDataCaptureEntry entryWithAction:STGUploadActionUploadFile url:url deleteOnCompletion:NO] sender:nil];
        }
    });
}

+ (STGMovieCaptureSession *)startScreenMovieCapture:(NSRect)capturedRect display:(CGDirectDisplayID)displayID length:(NSTimeInterval)length tempFolder:(NSString *)tempFolder recordVideo:(BOOL)recordVideo recordComputerAudio:(BOOL)recordComputerAudio recordMicrophoneAudio:(BOOL)recordMicrophoneAudio quality:(NSString *)qualityPreset delegate:(NSObject<STGMovieCaptureSessionDelegate> *)delegate
{
    STGMovieCaptureSession *session = [[STGMovieCaptureSession alloc] init];
    [session setDelegate:delegate];
    
    [session setDisplayID:displayID];
    [session setRecordRect:capturedRect];
    
    [session setRecordType:recordVideo ? STGMovieCaptureTypeScreenMovie : STGMovieCaptureTypeAudio];
    if (recordVideo)
        [session setDestURL:[STGFileHelper urlFromStandardPath:[tempFolder stringByAppendingFormat:@"/Movie_%@.mov", [self getDateAsString]]]];
    else
        [session setDestURL:[STGFileHelper urlFromStandardPath:[tempFolder stringByAppendingFormat:@"/Audio_%@.m4a", [self getDateAsString]]]];
    
    [session setQualityPreset:qualityPreset];

    [session setRecordComputerAudio:recordComputerAudio];
    [session setRecordMicrophoneAudio:recordMicrophoneAudio];
    
    [session setRecordTime:length];
    
    return [session beginRecording] ? session : nil;
}

+ (NSString *)getDateAsString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"yyyy-MM-dd'T'HH:mm:ss.SSS" options:0 locale:[NSLocale currentLocale]]];
    
    return [dateFormatter stringFromDate:[NSDate date]];
}

@end
