//
//  STGPacketQueue.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 11.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGPacketQueue.h"

#import "STGAPIConfiguration.h"

@implementation STGPacketQueue

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setUploadQueue:[[NSMutableArray alloc] init]];
        
        [self setConnectionManager:[[STGStorageConnectionManager alloc] init]];
        [_connectionManager setDelegate:self];
        
        [self setUploadsPaused:NO];
    }
    return self;
}

- (void)update
{
    if (![_connectionManager activeEntry] && !_uploadsPaused)
    {
        if ([_uploadQueue count] > 0)
        {
            BOOL reachingAPI = [[STGAPIConfiguration currentConfiguration] canReachServer];

            if (reachingAPI)
                [_connectionManager uploadEntry:[_uploadQueue objectAtIndex:0]];
        }
    }
}

- (void)setUploadsPaused:(BOOL)uploadsPaused
{
    _uploadsPaused = uploadsPaused;
    
    if (uploadsPaused)
    {
        if ([_connectionManager activeEntry])
            [_connectionManager cancelCurrentRequest];
    }
    
    [self update];
}

- (void)addEntry:(STGPacket *)entry
{
    if (entry)
        [_uploadQueue addObject:entry];
    
    [self update];
}

- (void)cancelEntryAtIndex:(int)index
{
    STGPacket *entry = [_uploadQueue objectAtIndex:index];
    
    [self cancelEntry:entry];
}

- (void)cancelEntry:(STGPacket *)entry
{
    [self deleteEntry:entry];
    
    if ([_delegate respondsToSelector:@selector(packetQueue:cancelledEntry:)])
        [_delegate packetQueue:self cancelledEntry:entry];
}

- (void)deleteEntry:(STGPacket *)entry
{
    [_uploadQueue removeObject:entry];
    
    if ([_connectionManager activeEntry] == entry)
    {
        [_connectionManager cancelCurrentRequest];
        [self setUploadedData:0.0];
    }
    
    [self update];
}

- (void)cancelAllEntries
{
    while ([_uploadQueue count] > 1)
    {
        [self cancelEntry:[_uploadQueue objectAtIndex:1]];
    }
    
    [self cancelEntry:[_uploadQueue objectAtIndex:0]];
}

- (void)startUploadingData:(STGStorageConnectionManager *)captureManager entry:(STGPacket *)entry
{
    [self setUploadedData:0.0];
    if ([_delegate respondsToSelector:@selector(startUploadingData:entry:)])
    {
        [_delegate startUploadingData:self entry:entry];
    }

    [self update];
}

- (void)updateUploadProgress:(STGStorageConnectionManager *)captureManager entry:(STGPacket *)entry sentData:(NSInteger)sentData totalData:(NSInteger)totalData
{
    [self setUploadedData:(double)sentData / (double)totalData];
    
    if ([_delegate respondsToSelector:@selector(updateUploadProgress:entry:sentData:totalData:)])
    {
        [_delegate updateUploadProgress:self entry:entry sentData:sentData totalData:totalData];
    }

    [self update];
}

- (void)finishUploadingData:(STGStorageConnectionManager *)captureManager entry:(STGPacket *)entry fullResponse:(NSData *)response urlResponse:(NSURLResponse *)urlResponse
{
    [self deleteEntry:entry];
    [self setUploadedData:0.0];
    
    if ([_delegate respondsToSelector:@selector(finishUploadingData:entry:fullResponse:urlResponse:)])
    {
        [_delegate finishUploadingData:self entry:entry fullResponse:response urlResponse:urlResponse];
    }

    [self update];
}

- (void)setUploadedData:(double)uploadedData
{
    if (_uploadedData != uploadedData)
    {
        _uploadedData = uploadedData;
        
        if ([_delegate respondsToSelector:@selector(packetQueueUpdatedProgress:)])
            [_delegate packetQueueUpdatedProgress:self];
    }
}

@end
