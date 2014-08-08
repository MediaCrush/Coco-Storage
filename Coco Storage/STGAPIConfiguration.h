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

@protocol STGAPIConfigurationDelegate

@optional
- (void)didUploadDataCaptureEntry:(STGDataCaptureEntry *)entry success:(BOOL)success;
- (void)updateAPIStatus:(BOOL)active validKey:(BOOL)validKey;

@end

@protocol STGAPIConfiguration

@property (nonatomic, assign) NSObject<STGAPIConfigurationDelegate> *delegate;

@property (nonatomic, retain) NSString *uploadLink;
@property (nonatomic, retain) NSString *deletionLink;
@property (nonatomic, retain) NSString *getObjectInfoLink;

@property (nonatomic, retain) NSString *getAPIV1StatusLink;
@property (nonatomic, retain) NSString *getAPIV2StatusLink;

@property (nonatomic, retain) NSString *cfsBaseLink;

- (BOOL)canReachServer;
- (void)handlePacket:(STGPacket *)entry fullResponse:(NSData *)response urlResponse:(NSURLResponse *)urlResponse;
- (void)cancelPacketUpload:(STGPacket *)entry;

@end

@interface STGAPIConfiguration : NSObject

+ (void)setCurrentConfiguration:(NSObject<STGAPIConfiguration> *)configuration;
+ (NSObject<STGAPIConfiguration> *)currentConfiguration;

@end
