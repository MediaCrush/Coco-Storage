//
//  STGDataCaptureManager.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 27.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGDataCaptureManager.h"

#import "STGDataCaptureEntry.h"

#import "STGFileHelper.h"

@interface STGDataCaptureManager ()

+ (NSString *)getDateAsString;

@end

@implementation STGDataCaptureManager

+ (NSArray *)getSupportedPasteboardContentTypes
{
    return [NSArray arrayWithObjects:NSURLPboardType, NSPasteboardTypeString, nil];
}

+ (NSArray *)captureDataFromPasteboard:(NSPasteboard *)pasteboard
{
    STGDropAction action = [self getActionFromPasteboard:pasteboard];
    
    if (action == STGDropActionUploadFile)
    {
        NSURL *url = [NSURL URLFromPasteboard:pasteboard];

        return [NSArray arrayWithObject:[self captureFile:url tempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]]];
    }
    else if (action == STGDropActionUploadDirectoryZip)
    {
        NSURL *url = [NSURL URLFromPasteboard:pasteboard];

        return [NSArray arrayWithObject:[self captureFilesAsZip:[NSArray arrayWithObject:url] withTempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]]];
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
            
            return [NSArray arrayWithObject:[self captureFilesAsZip:validURLS withTempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]]];
        }
    }
    else if (action == STGDropActionUploadRtfdText || action == STGDropActionUploadRtfText)
    {
        NSString *type = action == STGDropActionUploadRtfdText ? NSRTFDPboardType : NSRTFPboardType;
        
        return [NSArray arrayWithObject:[self captureAttributedTextAsFile:[[NSAttributedString alloc] initWithRTF:[pasteboard dataForType:type] documentAttributes:nil] tempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]]];
    }
    else if (action == STGDropActionUploadText)
    {
        return [NSArray arrayWithObject:[self captureTextAsFile:[pasteboard stringForType:NSPasteboardTypeString] tempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]]];
    }
    else if (action == STGDropActionUploadLinkRedirect)
    {
        NSURL *url = [NSURL URLFromPasteboard:pasteboard];

        return [NSArray arrayWithObject:[self captureLinkAsRedirectFile:url tempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]]];
    }
    
    return nil;
}

+ (STGDropAction)getActionFromPasteboard:(NSPasteboard *)pasteboard
{
    if ([[pasteboard types] containsObject:NSFilenamesPboardType])
    {
        NSData *data = [pasteboard dataForType:NSFilenamesPboardType];
        NSError *error;
        
        NSArray *filenames = [NSPropertyListSerialization propertyListWithData:data options:kCFPropertyListImmutable format:nil error:&error];
        
        if (error)
            NSLog(@"%@", error);
        else if (filenames && [filenames count] > 1)
        {
            return STGDropActionUploadZip;
        }
        else if (filenames)
        {
            NSURL *url = [NSURL URLFromPasteboard:pasteboard];
            
            if (url && [url isFileURL])
            {
                BOOL isDirectory;
                BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[url path] isDirectory:&isDirectory];
                
                if (exists && !isDirectory)
                    return STGDropActionUploadFile;
                else if (exists)
                    return STGDropActionUploadDirectoryZip;
            }
        }
    }
    else if ([[pasteboard types] containsObject:NSURLPboardType])
    {
        NSURL *url = [NSURL URLFromPasteboard:pasteboard];
        
        if (url)
        {
            if ([url isFileURL])
            {
                BOOL isDirectory;
                BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[url path] isDirectory:&isDirectory];
                
                if (exists && !isDirectory)
                    return STGDropActionUploadFile;
                else if (exists)
                    return STGDropActionUploadDirectoryZip;
            }
            else if([[url scheme] isEqualToString:@"http"])
            {
                return STGDropActionUploadLinkRedirect;
            }
        }
    }
    else if ([[pasteboard types] containsObject:NSRTFDPboardType])
    {
        return STGDropActionUploadRtfdText;
    }
    else if ([[pasteboard types] containsObject:NSRTFPboardType])
    {
        return STGDropActionUploadRtfText;
    }
    else if ([[pasteboard types] containsObject:NSPasteboardTypeString])
    {
        return STGDropActionUploadText;
    }
    
    return STGDropActionNone;
}

+ (NSString *)getReadableActionFromPasteboard:(NSPasteboard *)pasteboard
{
    STGDropAction action = [self getActionFromPasteboard:pasteboard];
    
    if (action == STGDropActionUploadFile)
        return @"Upload File";
    else if (action == STGDropActionUploadDirectoryZip)
        return @"Upload as zip";
    else if (action == STGDropActionUploadZip)
        return @"Upload as zip";
    else if (action == STGDropActionUploadText)
        return @"Upload Text";
    else if (action == STGDropActionUploadRtfdText)
        return @"Upload Attributed Text";
    else if (action == STGDropActionUploadRtfText)
        return @"Upload Attributed Text";
    else if (action == STGDropActionUploadLinkRedirect)
        return @"Shorten Link";
    
    return nil;
}

+ (STGDataCaptureEntry *)startScreenCapture:(BOOL)fullscreen tempFolder:(NSString *)tempFolder silent:(BOOL)silent
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
    [task launch];
    [task waitUntilExit];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileName])
    {
        return nil;
    }
    
    return [STGDataCaptureEntry entryWithURL:[STGFileHelper urlFromStandardPath:fileName] deleteOnCompletion:YES];
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
    NSString *fileName = [tempFolder stringByAppendingFormat:@"/%@", [NSString stringWithFormat:@"Link_%@_%@.html", [link host], [self getDateAsString]]];
    
    [[NSFileManager defaultManager] createFileAtPath:fileName contents:[[NSString stringWithFormat:@"<html>\n<head>\n<meta http-equiv=\"refresh\" content=\"0; url=%@\">\n</head>\n<body></body></html>", [link absoluteString]] dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    
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
        
        NSLog(@"%@", baseURL);
        for (NSURL *link in links)
        {
            NSString *absolute = [link absoluteString];
            NSRange range = [absolute rangeOfString:[baseURL absoluteString]];
            NSString *relativePath = [absolute substringFromIndex:range.location + range.length];
            
            [relativeLinks addObject:[[NSURL alloc] initWithString:relativePath]];
        }
        NSLog(@"%@", relativeLinks);

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

+ (NSArray *)startFileCaptureWithTempFolder:(NSString *)tempFolder
{
    NSOpenPanel *filePanel = [[NSOpenPanel alloc] init];
    [filePanel setCanChooseDirectories:NO];
    [filePanel setCanChooseFiles:YES];
    [filePanel setAllowsMultipleSelection:YES];
    [filePanel setFloatingPanel:NO];
    [filePanel setTitle:@"Select file to upload"];
    [filePanel setPrompt:@"Upload"];
    
    if ([filePanel runModal] == NSOKButton)
    {
        NSArray *urls = [filePanel URLs];
        
        NSMutableArray *returnArray = [[NSMutableArray alloc] initWithCapacity:[urls count]];
        
        for (NSURL *url in urls)
            [returnArray addObject:[STGDataCaptureEntry entryWithURL:url deleteOnCompletion:NO]];
        
        return returnArray;
    }
    
    return nil;
}

+ (NSString *)getDateAsString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"yyyy-MM-dd'T'HH:mm:ss.SSS" options:0 locale:[NSLocale currentLocale]]];
    
    return [dateFormatter stringFromDate:[NSDate date]];
}

@end
