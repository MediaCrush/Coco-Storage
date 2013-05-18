//
//  STGPacketQueueEntry.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 11.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STGPacket : NSObject

@property (nonatomic, retain) NSURLRequest *urlRequest;

@property (nonatomic, retain) NSString *packetType;
@property (nonatomic, retain) NSMutableDictionary *userInfo;

@property (nonatomic, assign) BOOL inUse;

+ (id)genericPacketWithRequest:(NSURLRequest *)request packetType:(NSString *)packetType userInfo:(NSMutableDictionary *)userInfo;
+ (NSMutableURLRequest *)defaultRequestWithUrl:(NSString *)urlString httpMethod:(NSString *)httpMethod contentParts:(NSArray *)parts;
+ (NSMutableURLRequest *)defaultRequestWithUrl:(NSString *)urlString httpMethod:(NSString *)httpMethod fileName:(NSString *)fileName mainBodyString:(NSData *)bodyData;
+ (NSData *)contentPartWithName:(NSString *)name fileName:(NSString *)fileName content:(NSData *)content;
+ (NSString *)getValueFromJSON:(NSString *)json key:(NSString *)key;

@end
