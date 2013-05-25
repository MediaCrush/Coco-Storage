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

+ (NSString *)getCurrentScreenshotFileName;
+ (NSString *)getCurrentTextFileName;
+ (NSString *)getDateAsString;

@end

@implementation STGDataCaptureManager

+ (NSArray *)getSupportedPasteboardContentTypes
{
    return [NSArray arrayWithObjects:NSURLPboardType, NSPasteboardTypeString, nil];
}

+ (NSArray *)captureDataFromPasteboard:(NSPasteboard *)pasteboard
{
    if ([[pasteboard types] containsObject:NSURLPboardType])
    {
        NSURL *url = [NSURL URLFromPasteboard:pasteboard];
        
        if (url)
        {
            if ([url isFileURL])
            {
                return [NSArray arrayWithObject:[STGDataCaptureEntry entryWithURL:url deleteOnCompletion:NO]];
            }
            else if([[url scheme] isEqualToString:@"http"])
            {
                return [NSArray arrayWithObject:[self captureLinkAsRedirectFile:url tempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]]];
            }
        }
    }
    else if ([[pasteboard types] containsObject:NSPasteboardTypeString])
    {
        return [NSArray arrayWithObject:[self captureTextAsFile:[pasteboard stringForType:NSPasteboardTypeString] tempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]]];
    }
    
    return nil;
}

+ (STGDataCaptureEntry *)startScreenCapture:(BOOL)fullscreen tempFolder:(NSString *)tempFolder silent:(BOOL)silent
{
    NSString *fileName = [tempFolder stringByAppendingFormat:@"/%@", [self getCurrentScreenshotFileName]];
    
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
    NSString *fileName = [tempFolder stringByAppendingFormat:@"/%@", [self getCurrentTextFileName]];
    
    [[NSFileManager defaultManager] createFileAtPath:fileName contents:[text dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    
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
    
    NSLog(@"%@", fileName);
    return [STGDataCaptureEntry entryWithURL:[STGFileHelper urlFromStandardPath:fileName] deleteOnCompletion:YES];
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

+ (NSString *)getCurrentScreenshotFileName
{
    return [NSString stringWithFormat:@"Screenshot_%@.png", [self getDateAsString]];
}

+ (NSString *)getCurrentTextFileName
{
    return [NSString stringWithFormat:@"Text_%@.png", [self getDateAsString]];
}

+ (NSString *)getDateAsString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"yyyy-MM-dd'T'HH:mm:ss.SSS" options:0 locale:[NSLocale currentLocale]]];
    
    return [dateFormatter stringFromDate:[NSDate date]];
}

@end
