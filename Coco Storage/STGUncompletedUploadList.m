//
//  STGUncompletedUploadList.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGUncompletedUploadList.h"

#import "STGPacketQueue.h"
#import "STGPacket.h"

#import "STGDataCaptureEntry.h"

@implementation STGUncompletedUploadList

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setList:[aDecoder decodeObjectForKey:@"List"]];
    }
    return self;
}

- (instancetype)initWithPacketQueue:(STGPacketQueue *)packetQueue
{
    self = [super init];
    if (self) {
        NSMutableArray *uploadQueueStringArray = [[NSMutableArray alloc] init];
        for (STGPacket *entry in [packetQueue uploadQueue])
        {
            if ([[entry packetType] isEqualToString:@"uploadFile"])
                [uploadQueueStringArray addObject:[[entry userInfo] objectForKey:@"dataCaptureEntry"]];
        }
        [self setList:uploadQueueStringArray];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_list forKey:@"List"];
}

- (void)queueAll:(STGPacketQueue *)packetQueue inConfiguration:(NSObject<STGAPIConfiguration> *)apiConfiguration withKey:(NSString *)apiKey
{
    for (STGDataCaptureEntry *entry in _list)
    {
        [apiConfiguration sendFileUploadPacket:packetQueue apiKey:apiKey entry:entry public:YES];
    }
}

@end
