//
//  STGPacketGetObjectInfo.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 13.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGPacketGetObjectInfo.h"

@implementation STGPacketGetObjectInfo

- (id)initWithObjectID:(NSString *)objectID link:(NSString *)link key:(NSString *)key
{
    self = [super init];
    if (self)
    {
        [self setUrlRequest:[STGPacket defaultRequestWithUrl:[NSString stringWithFormat:link, objectID, key] httpMethod:@"GET" contentParts:nil]];
    }
    return self;
}

@end
