//
//  STGNetworkManager.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STGPacketQueue.h"
#import "STGAPIConfiguration.h"

@class STGCFSSyncCheck;
@class STGNetworkManager;

@protocol STGNetworkDelegate <NSObject>

@optional
- (void)serverStatusChanged:(STGNetworkManager *)networkManager;
- (void)fileUploadProgressChanged:(STGNetworkManager *)networkManager;
- (void)fileUploadQueueChanged:(STGNetworkManager *)networkManager;

- (void)fileUploadCompleted:(STGNetworkManager *)networkManager entry:(STGDataCaptureEntry *)entry successful:(BOOL)successful;
- (void)fileDeletionCompleted:(STGNetworkManager *)networkManager entry:(STGDataCaptureEntry *)entry;
@end

typedef NS_ENUM(NSUInteger, STGServerStatus)
{
    STGServerStatusOnline = 0,
    STGServerStatusServerOffline = 1,
    STGServerStatusClientOffline = 2,
    STGServerStatusUnknown = 3,
    STGServerStatusServerV1Busy = 4,
    STGServerStatusServerV2Busy = 5,
    STGServerStatusServerBusy = 6,
    STGServerStatusInvalidKey = 7
};

@interface STGNetworkManager : NSObject <STGPacketQueueDelegate, STGAPIConfigurationNetworkDelegate>

@property (nonatomic, assign) NSObject<STGNetworkDelegate> *delegate;

@property (nonatomic, retain) NSTimer *uploadTimer;
@property (nonatomic, retain) NSTimer *serverStatusTimer;

@property (nonatomic, assign) BOOL apiV1Alive;
@property (nonatomic, assign) BOOL apiV2Alive;

@property (nonatomic, retain) STGPacketQueue *packetUploadV1Queue;
@property (nonatomic, retain) STGPacketQueue *packetUploadV2Queue;
@property (nonatomic, retain) STGPacketQueue *packetSupportQueue;

@property (nonatomic, retain) STGCFSSyncCheck *cfsSyncCheck;

@property (nonatomic, assign) BOOL uploadsPaused;

@property (nonatomic, assign) NSString *apiKey;

@property (nonatomic, assign, readonly) STGServerStatus serverStatus;

- (BOOL)isAPIKeyValid:(BOOL)output;

- (void)checkServerStatus;

- (double)fileUploadProgress;

@end
