//
//  STGUploadedEntryRehosted.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 28.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGUploadedEntryRehosted.h"

@implementation STGUploadedEntryRehosted

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setOnlineID:[aDecoder decodeObjectForKey:@"OnlineID"]];
        [self setOnlineLink:[aDecoder decodeObjectForKey:@"OnlineLink"]];
        [self setOriginalLink:[aDecoder decodeObjectForKey:@"OriginalLink"]];
    }
    return self;
}

- (instancetype)initWithID:(NSString *)onlineID link:(NSURL *)onlineLink originalLink:(NSURL *)originalLink
{
    self = [super init];
    if (self) {
        [self setOnlineID:onlineID];
        [self setOnlineLink:onlineLink];
        [self setOriginalLink:originalLink];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_onlineID forKey:@"OnlineID"];
    [aCoder encodeObject:_onlineLink forKey:@"OnlineLink"];
    [aCoder encodeObject:_originalLink forKey:@"OriginalLink"];
}

- (NSString *)entryName
{
    return [NSString stringWithFormat:@"Media (%@)", [_originalLink absoluteString]];
}

- (NSImage *)entryIcon
{
    return [NSImage imageNamed:@"NSNetwork"];
}

@end
