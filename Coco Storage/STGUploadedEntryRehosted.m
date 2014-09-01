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
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setOriginalLink:[aDecoder decodeObjectForKey:@"OriginalLink"]];
    }
    return self;
}

- (instancetype)initWithAPIConfigurationID:(NSString *)configID onlineID:(NSString *)onlineID onlineLink:(NSURL *)onlineLink originalLink:(NSURL *)originalLink
{
    self = [super initWithAPIConfigurationID:configID onlineID:onlineID onlineLink:onlineLink];
    if (self) {
        [self setOriginalLink:originalLink];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
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
