//
//  STGPacketQueue.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 11.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STGStorageConnectionManager.h"

@class STGPacket;
@class STGPacketQueue;

@protocol STGPacketQueueDelegate <NSObject>

@optional

- (void)startUploadingData:(STGPacketQueue *)queue entry:(STGPacket *)entry;
- (void)updateUploadProgress:(STGPacketQueue *)queue entry:(STGPacket *)entry sentData:(NSInteger)sentData totalData:(NSInteger)totalData;
- (void)finishUploadingData:(STGPacketQueue *)queue entry:(STGPacket *)entry fullResponse:(NSData *)response urlResponse:(NSURLResponse *)urlResponse;

- (void)packetQueue:(STGPacketQueue *)queue cancelledEntry:(STGPacket *)entry;

- (void)packetQueueUpdatedProgress:(STGPacketQueue *)queue;
- (void)packetQueueUpdatedEntries:(STGPacketQueue *)queue;

@end

@interface STGPacketQueue : NSObject <STGStorageConnectionManagerDelegate>

@property (nonatomic, assign) id<STGPacketQueueDelegate> delegate;

@property (nonatomic, retain) NSMutableArray *uploadQueue;
@property (nonatomic, retain) STGStorageConnectionManager *connectionManager;

@property (nonatomic, assign) BOOL uploadsPaused;
@property (nonatomic, assign, readonly) double uploadedData;

- (void)update;

- (void)addEntry:(STGPacket *)entry;

- (void)cancelEntry:(STGPacket *)entry;
- (void)cancelEntryAtIndex:(int)index;
- (void)cancelAllEntries;

@end
