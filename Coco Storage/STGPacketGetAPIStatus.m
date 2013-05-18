//
//  STGPacketGetAPIStatus.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 13.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGPacketGetAPIStatus.h"

@implementation STGPacketGetAPIStatus

- (id)initWithLink:(NSString *)link apiInfo:(int)apiInfo key:(NSString *)key
{
    self = [super init];
    if (self)
    {
        [self setUrlRequest:[STGPacket defaultRequestWithUrl:[NSString stringWithFormat:link, key] httpMethod:@"GET" contentParts:nil]];
        
        [[self userInfo] setObject:[NSNumber numberWithInt:apiInfo] forKey:@"apiVersion"];
        
        [self setPacketType:@"getAPIStatus"];
    }
    return self;
}
@end
