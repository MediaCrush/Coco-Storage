//
//  STGPacketQueueEntryUploadFile.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 11.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGPacketUploadFile.h"

#import "STGDataCaptureEntry.h"

@implementation STGPacketUploadFile

@synthesize dataCaptureEntry = _dataCaptureEntry;

- (id)initWithDataCaptureEntry:(STGDataCaptureEntry *)entry uploadLink:(NSString *)link key:(NSString *)key
{
    self = [super init];
    if (self)
    {
        [self setDataCaptureEntry:entry];
        
        [self setUrlRequest:[STGPacket defaultRequestWithUrl:[NSString stringWithFormat:link, key] httpMethod:@"POST" fileName:[[entry fileURL] lastPathComponent] mainBodyString:[NSData dataWithContentsOfURL:[entry fileURL]]]];
    }
    return self;
}

@end
