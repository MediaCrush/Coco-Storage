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

+ (NSString *)getCurrentFileName;
+ (NSString *)getDateAsString;

@end

@implementation STGDataCaptureManager

+ (STGDataCaptureEntry *)startScreenCapture:(BOOL)fullscreen tempFolder:(NSString *)tempFolder silent:(BOOL)silent
{
    NSString *fileName = [tempFolder stringByAppendingFormat:@"/%@", [self getCurrentFileName]];
    
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

+ (NSString *)getCurrentFileName
{
    return [NSString stringWithFormat:@"Screenshot_%@.png", [self getDateAsString]];
}

+ (NSString *)getDateAsString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"yyyy-MM-dd'T'HH:mm:ss.SSS" options:0 locale:[NSLocale currentLocale]]];
    
    return [dateFormatter stringFromDate:[NSDate date]];
}

@end
