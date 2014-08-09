//
//  STGAPIConfiguration.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STGPacket;
@class STGDataCaptureEntry;
@class STGPacketQueue;

@protocol STGAPIConfigurationDelegate

@optional
- (void)didUploadDataCaptureEntry:(STGDataCaptureEntry *)entry success:(BOOL)success;
- (void)updateAPIStatus:(BOOL)active validKey:(BOOL)validKey;

@end

@protocol STGAPIConfiguration

@property (nonatomic, assign) NSObject<STGAPIConfigurationDelegate> *delegate;

- (NSString *)apiHostName;
- (BOOL)hasAPIKeys;
- (NSString *)accountLinkTitle;
- (NSString *)fileListLinkTitle;

- (BOOL)canReachServer;
- (void)handlePacket:(STGPacket *)entry fullResponse:(NSData *)response urlResponse:(NSURLResponse *)urlResponse;
- (void)cancelPacketUpload:(STGPacket *)entry;

- (void)sendStatusPacket:(STGPacketQueue *)packetQueue apiKey:(NSString *)apiKey;
- (void)sendFileUploadPacket:(STGPacketQueue *)packetQueue apiKey:(NSString *)apiKey entry:(STGDataCaptureEntry *)entry public:(BOOL)publicFile;
- (void)sendFileDeletePacket:(STGPacketQueue *)packetQueue apiKey:(NSString *)apiKey entry:(STGDataCaptureEntry *)entry;

@optional
- (void)openAccountLink;
- (void)openFileListLink;
@end

@interface STGAPIConfiguration : NSObject

+ (void)setCurrentConfiguration:(NSObject<STGAPIConfiguration> *)configuration;
+ (NSObject<STGAPIConfiguration> *)currentConfiguration;

@end
