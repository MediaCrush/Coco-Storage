//
//  STGCFSSyncCheck.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 19.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STGCFSSyncCheck : NSObject

@property (nonatomic, retain) NSMutableDictionary *lastModifiedDict;

- (NSArray *)getModifiedFiles:(NSString *)path;

- (NSTimeInterval)getFileModificationDate:(NSString *)path;
- (BOOL)wasFileModified:(NSString *)path;

- (void)saveToFolder:(NSString *)path;
- (void)readFromFolder:(NSString *)path;

- (NSMutableDictionary *)getFolderRepresentation:(NSString *)path file:(BOOL *)isFile;
- (NSTimeInterval)getCachedModificationDate:(NSString *)path;
- (void)updateModificationDate:(NSString *)path;

@end
