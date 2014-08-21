//
//  STGAPIConfiguration.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STGDataCaptureManager.h"

@class STGPacket;
@class STGPacketQueue;

@protocol STGAPIConfigurationNetworkDelegate

@optional
- (void)didUploadDataCaptureEntry:(STGDataCaptureEntry *)entry success:(BOOL)success;
- (void)updateAPIStatus:(BOOL)active validKey:(BOOL)validKey;
- (void)openPreferences;
@end

@protocol STGAPIConfigurationDelegate

@optional
- (void)openPreferences;
@end

@protocol STGAPIConfiguration

@property (nonatomic, assign) NSObject<STGAPIConfigurationDelegate> *delegate;
@property (nonatomic, assign) NSObject<STGAPIConfigurationNetworkDelegate> *networkDelegate;

- (NSString *)apiHostName;
- (BOOL)hasAPIKeys;
- (BOOL)hasCFS;
- (BOOL)hasAlbums;
- (NSString *)accountLinkTitle;
- (NSString *)fileListLinkTitle;
- (NSSet *)supportedUploadTypes;

- (BOOL)hasWelcomeWindow;

- (NSString *)objectIDFromString:(NSString *)string;

- (BOOL)canReachServer;
- (void)handlePacket:(STGPacket *)entry fullResponse:(NSData *)response urlResponse:(NSURLResponse *)urlResponse;
- (void)cancelPacketUpload:(STGPacket *)entry;

- (void)sendStatusPacket:(STGPacketQueue *)packetQueue apiKey:(NSString *)apiKey;
- (void)sendFileUploadPacket:(STGPacketQueue *)packetQueue apiKey:(NSString *)apiKey entry:(STGDataCaptureEntry *)entry public:(BOOL)publicFile;
- (void)sendFileDeletePacket:(STGPacketQueue *)packetQueue apiKey:(NSString *)apiKey entry:(STGDataCaptureEntry *)entry;

@optional
- (NSString *)cfsLinkTitle;
- (void)openCFSLink;
- (void)openAccountLink;
- (void)openFileListLink;

- (void)sendAlbumCreatePacket:(STGPacketQueue *)packetQueue apiKey:(NSString *)apiKey entries:(NSArray *)entries;

- (void)openWelcomeWindow;
@end

@interface STGAPIConfiguration : NSObject

+ (void)setCurrentConfiguration:(NSObject<STGAPIConfiguration> *)configuration;
+ (NSObject<STGAPIConfiguration> *)currentConfiguration;

+ (NSArray *)validUploadActions:(NSArray *)actions forConfiguration:(id<STGAPIConfiguration>) configuration;

@end
