//
//  STGCFSSyncCheck.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 19.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGCFSSyncCheck.h"

@implementation STGCFSSyncCheck

@synthesize serverFileDict = _serverFileDict;
@synthesize basePath = _basePath;

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setServerFileDict:[NSMutableDictionary dictionary]];
    }
    return self;
}

- (STGCFSSyncCheckEntry *)getFirstModifiedFile:(NSString *)file
{
    /*
    NSMutableArray *modifiedDirectories = [[NSMutableArray alloc] init];
    NSMutableArray *modifiedFiles = [[NSMutableArray alloc] init];
    
    if ([self wasFileModified:path])
    {
        NSString *fullPath = path ? [_basePath stringByAppendingPathComponent:path] : _basePath;

        [modifiedDirectories addObject:fullPath];
        
        BOOL directory;
        BOOL exists;
        NSError *error;
        
        while ([modifiedDirectories count] > 0)
        {
            NSString *filePath = [modifiedDirectories objectAtIndex:0];
            NSString *filePathFull = filePath ? [_basePath stringByAppendingPathComponent:filePath] : _basePath;
            
            NSArray *newFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePathFull error:&error];
            
            if (!error)
            {
                for (NSString *newFile in newFiles)
                {
                    NSString *newFilePath = [filePath stringByAppendingPathComponent:newFile];
                    
                    if ([self wasFileModified:newFilePath])
                    {
                        NSString *newFilePathFull = [_basePath stringByAppendingPathComponent:filePath];

                        exists = [[NSFileManager defaultManager] fileExistsAtPath:newFilePath isDirectory:&directory];
                        
                        if (directory)
                            [modifiedDirectories addObject:newFilePathFull];
                        else
                            [modifiedFiles addObject:[STGCFSSyncCheckEntry syncCheckEntryWithPath:newFilePathFull innerPath:newFilePath modificationType:STGSyncCheckEntryStatusUpdate : STGSyncCheckEntryCreate]];
                    }
                }
            }
            
            [modifiedFiles addObject:[STGCFSSyncCheckEntry syncCheckEntryWithPath:filePathFull innerPath:filePath modificationType:directoryExists ? STGSyncCheckEntryStatusUpdate : STGSyncCheckEntryCreate]];
            [modifiedDirectories removeObjectAtIndex:0];
        }
    }
    
    return modifiedFiles;*/
    
    return nil;
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

- (STGCFSSyncCheckEntryType)getFileModification:(NSString *)path
{
    NSString *fullPath = path ? [_basePath stringByAppendingPathComponent:path] : _basePath;
    
    NSTimeInterval serverInterval = [self getServerModificationDate:path];
    NSTimeInterval fileSystemInterval = [self getFileModificationDate:fullPath];
    
    if ((serverInterval - fileSystemInterval) * (serverInterval - fileSystemInterval) > 2.0 * 2.0)
    {
        if (serverInterval > fileSystemInterval)
        {
            if (fileSystemInterval < 0)
                return STGSyncCheckEntryServerCreate;

            return STGSyncCheckEntryServerUpdate;
        }
        else
        {
            if (serverInterval < 0)
                return STGSyncCheckEntryServerCreate;
            
            return STGSyncCheckEntryClientUpdate;
        }
    }
    
    return 0;
}

- (void)updateServerModificationDate:(NSString *)path
{
    BOOL isFile;
    NSMutableDictionary *pathDictionary = [self getFolderRepresentation:path file:&isFile];
    
    if (isFile)
        return [pathDictionary setObject:[NSNumber numberWithDouble:[self getFileModificationDate:path]] forKey:[path lastPathComponent]];
    else
        return [pathDictionary setObject:[NSNumber numberWithDouble:[self getFileModificationDate:path]] forKey:[NSNumber numberWithInt:0]];
}

- (NSMutableDictionary *)getFolderRepresentation:(NSString *)path file:(BOOL *)isFile
{
    NSArray *components = [path pathComponents];
    
    NSMutableDictionary *lastDict = _serverFileDict;
    
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

- (NSTimeInterval)getServerModificationDate:(NSString *)path
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

@end
