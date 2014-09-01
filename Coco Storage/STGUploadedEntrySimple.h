//
//  STGUploadedEntrySimple.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 01.09.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGUploadedEntry.h"

@interface STGUploadedEntrySimple : STGUploadedEntry

@property (nonatomic, retain) NSString *apiConfigurationID;
@property (nonatomic, retain) NSString *onlineID;
@property (nonatomic, retain) NSURL *onlineLink;

- (instancetype)initWithAPIConfigurationID:(NSString *)configID onlineID:(NSString *)onlineID onlineLink:(NSURL *)onlineLink;

@end
