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
@class STGUploadedEntry;

@protocol STGAPIConfigurationNetworkDelegate<NSObject>

@optional
- (void)didUploadDataCaptureEntry:(STGUploadedEntry *)entry dataCaptureEntry:(STGDataCaptureEntry *)dataCaptureEntry success:(BOOL)success;
- (void)didUploadEntry:(STGUploadedEntry *)entry success:(BOOL)success;
- (void)didDeleteEntry:(STGUploadedEntry *)entry;
- (void)updateAPIStatus:(BOOL)active validKey:(BOOL)validKey;
- (void)openPreferences;
@end

@protocol STGAPIConfigurationDelegate<NSObject>

@optional
- (void)openPreferences;
@end

@protocol STGAPIConfiguration<NSObject>

@property (nonatomic, assign) id<STGAPIConfigurationDelegate> delegate;
@property (nonatomic, assign) id<STGAPIConfigurationNetworkDelegate> networkDelegate;

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
- (void)sendFileDeletePacket:(STGPacketQueue *)packetQueue apiKey:(NSString *)apiKey entry:(STGUploadedEntry *)entry;

@optional
- (NSString *)cfsLinkTitle;
- (void)openCFSLink;
- (void)openAccountLink;
- (void)openFileListLink;

- (void)sendAlbumCreatePacket:(STGPacketQueue *)packetQueue apiKey:(NSString *)apiKey entries:(NSArray *)entries;

- (void)openWelcomeWindow;
@end

@interface STGAPIConfiguration : NSObject

+ (void)setCurrentConfiguration:(id<STGAPIConfiguration>)configuration;
+ (id<STGAPIConfiguration>)currentConfiguration;

+ (NSArray *)validUploadActions:(NSArray *)actions forConfiguration:(id<STGAPIConfiguration>) configuration;

@end
