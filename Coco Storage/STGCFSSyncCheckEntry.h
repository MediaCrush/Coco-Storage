//
//  STGCFSSyncCheckEntry.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 22.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, STGCFSSyncCheckEntryType)
{
    STGSyncCheckEntryNoChange = 0,
    STGSyncCheckEntryClientCreate = 1,
    STGSyncCheckEntryClientUpdate = 2,
    STGSyncCheckEntryClientDelete = 3,
    STGSyncCheckEntryServerCreate = 4,
    STGSyncCheckEntryServerUpdate = 5,
    STGSyncCheckEntryServerDelete = 6
};

@interface STGCFSSyncCheckEntry : NSObject

@property (nonatomic, retain) NSString *innerPath;

@property (nonatomic, assign) STGCFSSyncCheckEntryType modificationType;

+ (id)syncCheckEntryWithPath:(NSString *)innerPath modificationType:(STGCFSSyncCheckEntryType)type;

@end
