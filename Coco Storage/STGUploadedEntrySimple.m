//
//  STGUploadedEntrySimple.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 01.09.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGUploadedEntrySimple.h"

@implementation STGUploadedEntrySimple

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setApiConfigurationID:[aDecoder decodeObjectForKey:@"ApiConfigurationID"]];
        [self setOnlineID:[aDecoder decodeObjectForKey:@"OnlineID"]];
        [self setOnlineLink:[aDecoder decodeObjectForKey:@"OnlineLink"]];
    }
    return self;
}

- (instancetype)initWithAPIConfigurationID:(NSString *)configID onlineID:(NSString *)onlineID onlineLink:(NSURL *)onlineLink
{
    self = [super init];
    if (self) {
        [self setApiConfigurationID:configID];
        [self setOnlineID:onlineID];
        [self setOnlineLink:onlineLink];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_apiConfigurationID forKey:@"ApiConfigurationID"];
    [aCoder encodeObject:_onlineID forKey:@"OnlineID"];
    [aCoder encodeObject:_onlineLink forKey:@"OnlineLink"];
}

@end
