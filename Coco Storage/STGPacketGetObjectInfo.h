//
//  STGPacketGetObjectInfo.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 13.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGPacket.h"

@interface STGPacketGetObjectInfo : STGPacket

- (id)initWithObjectID:(NSString *)objectID link:(NSString *)link key:(NSString *)key;

@end
