//
//  STGUploadedEntryAlbum.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 27.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STGUploadedEntry.h"

@interface STGUploadedEntryAlbum : STGUploadedEntry

@property (nonatomic, retain) NSString *onlineID;
@property (nonatomic, retain) NSURL *onlineLink;

@property (nonatomic, assign) NSUInteger numberOfEntries;

- (instancetype)initWithID:(NSString *)onlineID link:(NSURL *)onlineLink numberOfEntries:(NSUInteger)numberOfEntries;

@end
