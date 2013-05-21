//
//  STGCFSSyncCheck.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 19.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGCFSSyncCheck.h"

@implementation STGCFSSyncCheck

@synthesize lastModifiedDict = _lastModifiedDict;

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setLastModifiedDict:[[NSMutableDictionary alloc] init]];
    }
    return self;
}

- (NSArray *)getModifiedFiles:(NSString *)path
{
    NSMutableArray *modifiedDirectories = [[NSMutableArray alloc] init];
    NSMutableArray *modifiedFiles = [[NSMutableArray alloc] init];
    
    if ([self wasFileModified:path])
    {
        [modifiedDirectories addObject:path];
        BOOL directory;
        BOOL exists;
        NSError *error;
        
        while ([modifiedDirectories count] > 0)
        {
            NSString *filePath = [modifiedDirectories objectAtIndex:0];
            
            NSArray *newFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:&error];
            
            if (!error)
            {
                for (NSString *newFile in newFiles)
                {
                    NSString *newFileFullPath = [filePath stringByAppendingPathComponent:newFile];
                    
                    if ([self wasFileModified:newFileFullPath])
                    {
                        exists = [[NSFileManager defaultManager] fileExistsAtPath:newFileFullPath isDirectory:&directory];
                        
                        if (directory)
                            [modifiedDirectories addObject:newFileFullPath];
                        else
                            [modifiedFiles addObject:newFileFullPath];
                    }
                }
            }
            
            [modifiedFiles addObject:filePath];
            [modifiedDirectories removeObjectAtIndex:0];
        }
    }
    
    return modifiedFiles;
}

- (NSTimeInterval)getFileModificationDate:(NSString *)path
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])
        return -1;
    
    NSError *error;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
    
    if (error)
    {
        NSLog(@"%@", error);
        
        return -1;
    }
    
    NSDate *date = [attributes fileModificationDate];
    
    return [date timeIntervalSince1970];
}

- (BOOL)wasFileModified:(NSString *)path
{
    return [self getFileModificationDate:path] > [self getCachedModificationDate:path];
}

- (void)saveToFolder:(NSString *)folder
{
    [_lastModifiedDict writeToFile:[folder stringByAppendingPathComponent:@".cocoStorageCache.plist"] atomically:YES];
}

- (void)readFromFolder:(NSString *)folder
{
    NSString *filePath = [folder stringByAppendingPathComponent:@".cocoStorageCache.plist"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    [self setLastModifiedDict:[NSMutableDictionary dictionaryWithContentsOfFile:filePath]];
}

- (NSMutableDictionary *)getFolderRepresentation:(NSString *)path file:(BOOL *)isFile
{
    NSArray *components = [path pathComponents];
    
    NSMutableDictionary *lastDict = _lastModifiedDict;
    
    for (NSString *string in components)
    {
        id nextObject = [lastDict objectForKey:string];
        
        if ([nextObject isKindOfClass:[NSDictionary class]])
            lastDict = [lastDict objectForKey:string];
        else
        {
            *isFile = YES;
            
            return lastDict;
        }
    }
    
    *isFile = NO;
    
    return lastDict;
}

- (NSTimeInterval)getCachedModificationDate:(NSString *)path
{
    BOOL isFile;
    NSMutableDictionary *pathDictionary = [self getFolderRepresentation:path file:&isFile];
    
    id object;
    
    if (isFile)
        object = [pathDictionary objectForKey:[path lastPathComponent]];
    else
        object = [pathDictionary objectForKey:[NSNumber numberWithInt:0]];
    
    if (object)
        return [object doubleValue];
    
    return -1.0;
}

- (void)updateModificationDate:(NSString *)path
{
    BOOL isFile;
    NSMutableDictionary *pathDictionary = [self getFolderRepresentation:path file:&isFile];
    
    if (isFile)
        return [pathDictionary setObject:[NSNumber numberWithDouble:[self getFileModificationDate:path]] forKey:[path lastPathComponent]];
    else
        return [pathDictionary setObject:[NSNumber numberWithDouble:[self getFileModificationDate:path]] forKey:[NSNumber numberWithInt:0]];
}

@end
