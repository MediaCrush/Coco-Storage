//
//  STGUploadedEntryRehosted.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 28.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGUploadedEntry.h"

@interface STGUploadedEntryRehosted : STGUploadedEntry

@property (nonatomic, retain) NSString *onlineID;
@property (nonatomic, retain) NSURL *onlineLink;

@property (nonatomic, retain) NSURL *originalLink;

- (instancetype)initWithID:(NSString *)onlineID link:(NSURL *)onlineLink originalLink:(NSURL *)originalLink;

@end
