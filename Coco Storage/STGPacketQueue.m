//
//  STGPacketQueue.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 11.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGPacketQueue.h"

#import "STGNetworkHelper.h"

@implementation STGPacketQueue

@synthesize delegate = _delegate;

@synthesize uploadQueue = _uploadQueue;
@synthesize connectionManager = _connectionManager;

@synthesize uploadsPaused = _uploadsPaused;

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
            BOOL reachingStorage = [STGNetworkHelper isWebsiteReachable:@"stor.ag"];

            if (reachingStorage)
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
    [_uploadQueue removeObject:entry];
    
    if ([_connectionManager activeEntry] == entry)
        [_connectionManager cancelCurrentRequest];
    
    [self update];
}

- (void)cancelAllEntries
{
    [_uploadQueue removeAllObjects];
    
    if ([_connectionManager activeEntry])
        [_connectionManager cancelCurrentRequest];
    
    [self update];
}

- (void)startUploadingData:(STGStorageConnectionManager *)captureManager entry:(STGPacket *)entry
{
    if ([_delegate respondsToSelector:@selector(startUploadingData:entry:)])
    {
        [_delegate startUploadingData:self entry:entry];
    }

    [self update];
}

- (void)updateUploadProgress:(STGStorageConnectionManager *)captureManager entry:(STGPacket *)entry sentData:(NSInteger)sentData totalData:(NSInteger)totalData
{
    if ([_delegate respondsToSelector:@selector(updateUploadProgress:entry:sentData:totalData:)])
    {
        [_delegate updateUploadProgress:self entry:entry sentData:sentData totalData:totalData];
    }

    [self update];
}

- (void)finishUploadingData:(STGStorageConnectionManager *)captureManager entry:(STGPacket *)entry fullResponse:(NSData *)response urlResponse:(NSURLResponse *)urlResponse
{
    [self cancelEntry:entry];
    
    if ([_delegate respondsToSelector:@selector(finishUploadingData:entry:fullResponse:urlResponse:)])
    {
        [_delegate finishUploadingData:self entry:entry fullResponse:response urlResponse:urlResponse];
    }

    [self update];
}

@end
