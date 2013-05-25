//
//  STGPacketCreator.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 19.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STGPacket;
@class STGDataCaptureEntry;

@interface STGPacketCreator : NSObject

+ (STGPacket *)getFilePacket:(NSString *)link key:(NSString *)key;

+ (STGPacket *)uploadFilePacket:(STGDataCaptureEntry *)entry uploadLink:(NSString *)link key:(NSString *)key;
+ (STGPacket *)deleteFilePacket:(STGDataCaptureEntry *)entry uploadLink:(NSString *)link key:(NSString *)key;
+ (STGPacket *)objectInfoPacket:(NSString *)objectID link:(NSString *)link key:(NSString *)key;

+ (STGPacket *)cfsGenericPacket:(NSString *)httpMethod path:(NSString *)filePath link:(NSString *)link key:(NSString *)key;
+ (STGPacket *)cfsFileListPacket:(NSString *)filePath link:(NSString *)link recursive:(BOOL)recursive key:(NSString *)key;
+ (STGPacket *)cfsFileInfoPacket:(NSString *)filePath link:(NSString *)link key:(NSString *)key;
+ (STGPacket *)cfsPostFilePacket:(NSString *)filePath fileURL:(NSURL *)fileURL link:(NSString *)link key:(NSString *)key;
+ (STGPacket *)cfsUpdateFilePacket:(NSString *)filePath fileURL:(NSURL *)fileURL link:(NSString *)link key:(NSString *)key;
+ (STGPacket *)cfsDeleteFilePacket:(NSString *)filePath link:(NSString *)link key:(NSString *)key;

+ (STGPacket *)apiStatusPacket:(NSString *)link apiInfo:(int)apiInfo key:(NSString *)key;

@end
