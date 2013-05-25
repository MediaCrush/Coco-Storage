//
//  STGFileHelper.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 24.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STGFileHelper : NSObject

+ (NSString *)getApplicationSupportDirectory;
+ (NSString *)getDocumentsDirectory;
+ (BOOL)createFolderIfNonExistent:(NSString *)path;

+ (NSString *)storeStringsInString:(NSArray *)array;
+ (NSArray *)readStringsFromString:(NSString *)string;

+ (NSURL *)urlFromStandardPath:(NSString *)path;

BOOL AddBadgeToItem(NSString* path, NSData* tag);

@end
