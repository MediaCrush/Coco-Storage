//
//  STGPacketGetFileList.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGPacketGetFileList.h"

@implementation STGPacketGetFileList

- (id)initWithFilePath:(NSString *)filePath link:(NSString *)link key:(NSString *)key
{
    self = [super init];
    if (self)
    {
        [self setUrlRequest:[STGPacket defaultRequestWithUrl:[NSString stringWithFormat:link, filePath, key] httpMethod:@"GET" contentParts:nil]];
        
        [self setPacketType:@"cfs:getFileList"];
    }
    return self;
}

@end
