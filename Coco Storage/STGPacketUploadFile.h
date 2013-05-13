//
//  STGPacketQueueEntryUploadFile.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 11.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGPacket.h"

@class STGDataCaptureEntry;

@interface STGPacketUploadFile : STGPacket

@property (nonatomic, retain) STGDataCaptureEntry *dataCaptureEntry;

- (id)initWithDataCaptureEntry:(STGDataCaptureEntry *)entry uploadLink:(NSString *)link key:(NSString *)key;

@end
