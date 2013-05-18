//
//  STGPacketGetAPIStatus.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 13.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGPacket.h"

@interface STGPacketGetAPIStatus : STGPacket

- (id)initWithLink:(NSString *)link apiInfo:(int)apiInfo key:(NSString *)key;

@end
