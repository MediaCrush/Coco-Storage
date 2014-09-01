//
//  STGUploadedEntryAlbum.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 27.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STGUploadedEntrySimple.h"

@interface STGUploadedEntryAlbum : STGUploadedEntrySimple

@property (nonatomic, assign) NSUInteger numberOfEntries;

- (instancetype)initWithAPIConfigurationID:(NSString *)configID onlineID:(NSString *)onlineID onlineLink:(NSURL *)onlineLink entries:(NSArray *)objectIDs;

@end
