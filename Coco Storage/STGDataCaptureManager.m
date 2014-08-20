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
    return [NSArray arrayWithObjects:NSURLPboardType, NSPasteboardTypeString, NSPasteboardTypeColor, NSPasteboardTypeRTF, NSPasteboardTypePNG, NSPasteboardTypeTIFF, NSTIFFPboardType, nil];
}

+ (NSArray *)captureDataFromPasteboard:(NSPasteboard *)pasteboard withAction:(STGDropAction)action
{
    if (action == STGDropActionUploadFile)
    {
        NSURL *url = [NSURL URLFromPasteboard:pasteboard];

        STGDataCaptureEntry *entry = [self captureFile:url tempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]];
        
        if (entry)
            return [NSArray arrayWithObject:entry];
    }
    else if (action == STGDropActionUploadDirectoryZip)
    {
        NSURL *url = [NSURL URLFromPasteboard:pasteboard];

        STGDataCaptureEntry *entry = [self captureFilesAsZip:[NSArray arrayWithObject:url] withTempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]];
        
        if (entry)
            return [NSArray arrayWithObject:entry];
    }
    else if (action == STGDropActionUploadZip)
    {
        NSData *data = [pasteboard dataForType:NSFilenamesPboardType];
        NSError *error;
        
        NSArray *filenames = [NSPropertyListSerialization propertyListWithData:data options:kCFPropertyListImmutable format:nil error:&error];
        
        if (error)
            NSLog(@"%@", error);
        else if (filenames && [filenames count] > 1)
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
    else if (action == STGDropActionUploadRtfText)
    {
        STGDataCaptureEntry *entry = [self captureAttributedTextAsFile:[[NSAttributedString alloc] initWithRTF:[pasteboard dataForType:NSPasteboardTypeRTF] documentAttributes:nil] tempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]];
        
        if (entry)
            return [NSArray arrayWithObject:entry];
    }
    else if (action == STGDropActionUploadText)
    {
        STGDataCaptureEntry *entry = [self captureTextAsFile:[pasteboard stringForType:NSPasteboardTypeString] tempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]];
        
        if (entry)
            return [NSArray arrayWithObject:entry];
    }
    else if (action == STGDropActionUploadImage)
    {
        NSArray *objectsToPaste = [pasteboard readObjectsForClasses:[NSArray arrayWithObject:[NSImage class]] options:nil];
        NSImage *image = [objectsToPaste objectAtIndex:0];
        
        STGDataCaptureEntry *entry = [self captureImageAsFile:image tempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]];
        
        if (entry)
            return [NSArray arrayWithObject:entry];
    }
    else if (action == STGDropActionUploadLinkRedirect)
    {
        NSURL *url = [NSURL URLFromPasteboard:pasteboard];
        
        STGDataCaptureEntry *entry = [self captureLinkAsRedirectFile:url tempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]];
        
        if (entry)
            return [NSArray arrayWithObject:entry];
    }
    else if (action == STGDropActionUploadColor)
    {
        STGDataCaptureEntry *entry = [self captureColorAsFile:[NSColor colorFromPasteboard:pasteboard] tempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]];
        
        if (entry)
            return [NSArray arrayWithObject:entry];
    }
    
    return nil;
}

+ (NSArray *)getActionsFromPasteboard:(NSPasteboard *)pasteboard
{
    NSMutableArray *array = [[NSMutableArray alloc] init];

    if ([[pasteboard types] containsObject:NSFilenamesPboardType])
    {
        NSData *data = [pasteboard dataForType:NSFilenamesPboardType];
        NSError *error;
        
        NSArray *filenames = [NSPropertyListSerialization propertyListWithData:data options:kCFPropertyListImmutable format:nil error:&error];
        
        if (error)
            NSLog(@"%@", error);
        else if (filenames && [filenames count] > 1)
        {
            [array addObject:[NSNumber numberWithInteger:STGDropActionUploadZip]];
        }
        else if (filenames && ![[pasteboard types] containsObject:NSURLPboardType])
        {
            NSURL *url = [NSURL URLFromPasteboard:pasteboard];
            
            if (url && [url isFileURL])
            {
                BOOL isDirectory;
                BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[url path] isDirectory:&isDirectory];
                
                if (exists && !isDirectory)
                    [array addObject:[NSNumber numberWithInteger:STGDropActionUploadFile]];
                else if (exists)
                    [array addObject:[NSNumber numberWithInteger:STGDropActionUploadDirectoryZip]];
            }
        }
    }
    if ([pasteboard canReadObjectForClasses:[NSArray arrayWithObject:[NSImage class]] options:nil])
    {
        [array addObject:[NSNumber numberWithInteger:STGDropActionUploadImage]];
    }
    if ([[pasteboard types] containsObject:NSURLPboardType])
    {
        NSURL *url = [NSURL URLFromPasteboard:pasteboard];
        
        if (url)
        {
            if ([url isFileURL])
            {
                BOOL isDirectory;
                BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[url path] isDirectory:&isDirectory];
                
                if (exists && !isDirectory)
                    [array addObject:[NSNumber numberWithInteger:STGDropActionUploadFile]];
                else if (exists)
                    [array addObject:[NSNumber numberWithInteger:STGDropActionUploadDirectoryZip]];
            }
            else if([[url scheme] isEqualToString:@"http"])
            {
                [array addObject:[NSNumber numberWithInteger:STGDropActionUploadLinkRedirect]];
            }
        }
    }
    if ([[pasteboard types] containsObject:NSPasteboardTypeRTF])
    {
        [array addObject:[NSNumber numberWithInteger:STGDropActionUploadRtfText]];
    }
    if ([[pasteboard types] containsObject:NSPasteboardTypeString])
    {
        [array addObject:[NSNumber numberWithInteger:STGDropActionUploadText]];
    }

    if ([[pasteboard types] containsObject:NSPasteboardTypeColor])
    {
        [array addObject:[NSNumber numberWithInteger:STGDropActionUploadColor]];
    }
    
    return array;
}

+ (NSString *)getNameForAction:(STGDropAction)action
{
    if (action == STGDropActionUploadFile)
        return @"Upload File";
    else if (action == STGDropActionUploadDirectoryZip)
        return @"Upload as zip";
    else if (action == STGDropActionUploadZip)
        return @"Upload as zip";
    else if (action == STGDropActionUploadText)
        return @"Upload Text";
    else if (action == STGDropActionUploadRtfText)
        return @"Upload Attributed Text";
    else if (action == STGDropActionUploadImage)
        return @"Upload Image";
    else if (action == STGDropActionUploadLinkRedirect)
        return @"Shorten Link";
    else if (action == STGDropActionUploadColor)
        return @"Upload Color";
    
    return nil;
}

+ (NSArray *)getReadableActionsFromPasteboard:(NSPasteboard *)pasteboard
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSArray *actions = [self getActionsFromPasteboard:pasteboard];

    for (NSNumber *number in actions)
    {
        NSString *name = [self getNameForAction:[number integerValue]];
        
        if (name)
            [array addObject:name];
    }
    
    return array;
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
            [delegate dataCaptureCompleted:[STGDataCaptureEntry entryWithURL:[STGFileHelper urlFromStandardPath:fileName] deleteOnCompletion:YES] sender:nil];
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
    
    return [STGDataCaptureEntry entryWithURL:[STGFileHelper urlFromStandardPath:fileName] deleteOnCompletion:YES];
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
    
    return [STGDataCaptureEntry entryWithURL:[STGFileHelper urlFromStandardPath:fileName] deleteOnCompletion:YES];
}

+ (STGDataCaptureEntry *)captureLinkAsRedirectFile:(NSURL *)link tempFolder:(NSString *)tempFolder
{
    NSString *fileName = [tempFolder stringByAppendingFormat:@"/Link_%@_%@", [link host], [self getDateAsString]];
    
    [[NSFileManager defaultManager] createFileAtPath:fileName contents:[[NSString stringWithFormat:@"<html>\n<head>\n<meta http-equiv=\"refresh\" content=\"0; url=%@\">\n</head>\n<body></body></html>", [link absoluteString]] dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileName])
    {
        return nil;
    }
    
    return [STGDataCaptureEntry entryWithURL:[STGFileHelper urlFromStandardPath:fileName] deleteOnCompletion:YES];
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
    
    return [STGDataCaptureEntry entryWithURL:[STGFileHelper urlFromStandardPath:fileName] deleteOnCompletion:YES];
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
    
    return [STGDataCaptureEntry entryWithURL:[STGFileHelper urlFromStandardPath:fileName] deleteOnCompletion:YES];
}

+ (STGDataCaptureEntry *)captureFile:(NSURL *)link tempFolder:(NSString *)tempFolder
{
    return [STGDataCaptureEntry entryWithURL:link deleteOnCompletion:NO];
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
        
        return [STGDataCaptureEntry entryWithURL:[STGFileHelper urlFromStandardPath:fileName] deleteOnCompletion:YES];
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
    [filePanel setTitle:@"Select file to upload"];
    [filePanel setPrompt:@"Upload"];

    dispatch_async(dispatch_get_current_queue(), ^{
        if ([filePanel runModal] == NSOKButton)
        {
            NSArray *urls = [filePanel URLs];
            
            for (NSURL *url in urls)
                [delegate dataCaptureCompleted:[STGDataCaptureEntry entryWithURL:url deleteOnCompletion:NO] sender:nil];
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
