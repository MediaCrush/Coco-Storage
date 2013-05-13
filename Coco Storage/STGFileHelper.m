//
//  STGFileHelper.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 24.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGFileHelper.h"

@implementation STGFileHelper

+ (NSString *)getApplicationSupportDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportDirectory = [paths objectAtIndex:0];
    NSString *finalPath = [NSString stringWithFormat:@"%@/Coco Storage", applicationSupportDirectory];
    
    [self createFolderIfNonExistent:finalPath];
    
    return finalPath;
}

+ (BOOL)createFolderIfNonExistent:(NSString *)path
{
    if(![[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error != nil)
        {
            NSLog(@"%@", error);
            return NO;
        }
    }
    
    return YES;
}

+ (NSString *)storeStringsInString:(NSArray *)array
{
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    
    for (NSString *string in array)
    {
        [mutableString appendFormat:@"%li;%@", [string length], string];
    }
    
    return mutableString;
}

+ (NSArray *)readStringsFromString:(NSString *)string
{
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];

    NSString *currentString = string;
    
    while (true)
    {
        NSRange semicolonRange = [currentString rangeOfString:@";"];

        if ([currentString length] <= semicolonRange.location || semicolonRange.location == NSNotFound)
            break;

        unsigned long length = [[currentString substringToIndex:semicolonRange.location] integerValue];
        
        if ([currentString length] < length + semicolonRange.location + semicolonRange.length)
            break;
        
        [mutableArray addObject:[currentString substringWithRange:NSMakeRange(semicolonRange.location + semicolonRange.length, length)]];
        
        currentString = [currentString substringFromIndex:semicolonRange.location + semicolonRange.length + length];
    }
    
    return mutableArray;
}

@end
