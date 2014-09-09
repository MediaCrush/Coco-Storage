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
+ (NSString *)getDownloadsDirectory;
+ (NSString *)getDesktopDirectory;
+ (BOOL)createFolderIfNonExistent:(NSString *)path;

+ (NSString *)storeStringsInString:(NSArray *)array;
+ (NSArray *)readStringsFromString:(NSString *)string;

BOOL AddBadgeToItem(NSString* path, NSData* tag);

@end
