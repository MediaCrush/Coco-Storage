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

@protocol STGAPIConfigurationDelegate

@optional
- (void)didUploadDataCaptureEntry:(STGDataCaptureEntry *)entry success:(BOOL)success;
- (void)updateAPIStatus:(BOOL)active validKey:(BOOL)validKey;

@end

@protocol STGAPIConfiguration

@property (nonatomic, assign) NSObject<STGAPIConfigurationDelegate> *delegate;

- (NSString *)apiHostName;
- (BOOL)hasAPIKeys;
- (BOOL)hasCFS;
- (BOOL)hasAlbums;
- (NSString *)accountLinkTitle;
- (NSString *)fileListLinkTitle;
- (NSSet *)supportedUploadTypes;

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
@end

@interface STGAPIConfiguration : NSObject

+ (void)setCurrentConfiguration:(NSObject<STGAPIConfiguration> *)configuration;
+ (NSObject<STGAPIConfiguration> *)currentConfiguration;

+ (NSArray *)validUploadActions:(NSArray *)actions forConfiguration:(id<STGAPIConfiguration>) configuration;

@end
