//
//  STGDataCaptureManager.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 23.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STGStorageConnectionManagerDelegate;

@class STGPacket;

@interface STGStorageConnectionManager : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, assign) id<STGStorageConnectionManagerDelegate> delegate;

@property (nonatomic, retain, readonly) NSURLConnection *activeUploadConnection;
@property (nonatomic, retain, readonly) STGPacket *activeEntry;

- (BOOL)uploadEntry:(STGPacket *)entry;
- (void)cancelCurrentRequest;

@end


@protocol STGStorageConnectionManagerDelegate <NSObject>

@optional

- (void)startUploadingData:(STGStorageConnectionManager *)captureManager entry:(STGPacket *)entry;
- (void)updateUploadProgress:(STGStorageConnectionManager *)captureManager entry:(STGPacket *)entry sentData:(NSInteger)sentData totalData:(NSInteger)totalData;
- (void)finishUploadingData:(STGStorageConnectionManager *)captureManager entry:(STGPacket *)entry fullResponse:(NSData *)response urlResponse:(NSURLResponse *)urlResponse;

@end