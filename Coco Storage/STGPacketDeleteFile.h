//
//  STGPacketQueueEntryDeleteFile.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 12.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGPacket.h"

@class STGDataCaptureEntry;

@interface STGPacketDeleteFile : STGPacket

- (id)initWithDataCaptureEntry:(STGDataCaptureEntry *)entry deletionLink:(NSString *)link key:(NSString *)key;

@end
