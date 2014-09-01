//
//  STGUploadedEntryRehosted.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 28.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGUploadedEntrySimple.h"

@interface STGUploadedEntryRehosted : STGUploadedEntrySimple

@property (nonatomic, retain) NSURL *originalLink;

- (instancetype)initWithAPIConfigurationID:(NSString *)configID onlineID:(NSString *)onlineID onlineLink:(NSURL *)onlineLink originalLink:(NSURL *)originalLink;

@end
