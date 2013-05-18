//
//  STGPacketGetFileList.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGPacket.h"

@interface STGPacketGetFileList : STGPacket

- (id)initWithFilePath:(NSString *)filePath link:(NSString *)link key:(NSString *)key;

@end
