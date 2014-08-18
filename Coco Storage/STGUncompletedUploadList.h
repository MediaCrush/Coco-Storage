//
//  STGUncompletedUploadList.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STGAPIConfiguration.h"

@class STGPacketQueue;

@interface STGUncompletedUploadList : NSObject <NSCoding>

@property (nonatomic, retain) NSArray *list;

- (instancetype)initWithPacketQueue:(STGPacketQueue *)packetQueue;

- (void)queueAll:(STGPacketQueue *)packetQueue inConfiguration:(NSObject<STGAPIConfiguration> *)apiConfiguration withKey:(NSString *)apiKey;

@end
