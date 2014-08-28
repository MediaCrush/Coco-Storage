//
//  STGUploadedEntryAlbum.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 27.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGUploadedEntryAlbum.h"

@implementation STGUploadedEntryAlbum

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setOnlineID:[aDecoder decodeObjectForKey:@"OnlineID"]];
        [self setOnlineLink:[aDecoder decodeObjectForKey:@"OnlineLink"]];
        [self setNumberOfEntries:[aDecoder decodeIntegerForKey:@"NumberOfEntries"]];
    }
    return self;
}

- (instancetype)initWithID:(NSString *)onlineID link:(NSURL *)onlineLink numberOfEntries:(NSUInteger)numberOfEntries
{
    self = [super init];
    if (self) {
        [self setOnlineID:onlineID];
        [self setOnlineLink:onlineLink];
        [self setNumberOfEntries:numberOfEntries];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_onlineID forKey:@"OnlineID"];
    [aCoder encodeObject:_onlineLink forKey:@"OnlineLink"];
    [aCoder encodeInteger:_numberOfEntries forKey:@"NumberOfEntries"];
}

- (NSString *)entryName
{
    return [NSString stringWithFormat:@"Album (%li uploads)", _numberOfEntries];
}

- (NSImage *)entryIcon
{
    return [NSImage imageNamed:@"NSFolder"];
}

@end
