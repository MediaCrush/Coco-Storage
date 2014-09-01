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
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setNumberOfEntries:[aDecoder decodeIntegerForKey:@"NumberOfEntries"]];
    }
    return self;
}

- (instancetype)initWithAPIConfigurationID:(NSString *)configID onlineID:(NSString *)onlineID onlineLink:(NSURL *)onlineLink entries:(NSArray *)objectIDs
{
    self = [super initWithAPIConfigurationID:configID onlineID:onlineID onlineLink:onlineLink];
    if (self) {
        [self setNumberOfEntries:[objectIDs count]];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeInteger:_numberOfEntries forKey:@"NumberOfEntries"];
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
