//
//  STGCFSSyncCheck.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 19.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STGCFSSyncCheckEntry.h"

@interface STGCFSSyncCheck : NSObject

@property (nonatomic, retain) NSMutableDictionary *serverFileDict;

@property (nonatomic, retain) NSString *basePath;

- (STGCFSSyncCheckEntry *)getFirstModifiedFile:(NSString *)file;

- (NSTimeInterval)getFileModificationDate:(NSString *)path;
- (STGCFSSyncCheckEntryType)getFileModification:(NSString *)path;
- (void)updateServerModificationDate:(NSString *)path;

- (NSMutableDictionary *)getFolderRepresentation:(NSString *)path file:(BOOL *)isFile;
- (NSTimeInterval)getServerModificationDate:(NSString *)path;

@end
