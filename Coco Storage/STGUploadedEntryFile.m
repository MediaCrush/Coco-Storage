//
//  STGUploadedEntryFile.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 27.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGUploadedEntryFile.h"

#import "STGDataCaptureEntry.h"

@implementation STGUploadedEntryFile

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setOnlineID:[aDecoder decodeObjectForKey:@"OnlineID"]];
        [self setOnlineLink:[aDecoder decodeObjectForKey:@"OnlineLink"]];
        [self setFileName:[aDecoder decodeObjectForKey:@"FileName"]];
    }
    return self;
}

- (instancetype)initWithDataCaptureEntry:(STGDataCaptureEntry *)entry onlineID:(NSString *)onlineID onlineLink:(NSURL *)onlineLink
{
    self = [super init];
    if (self) {
        [self setOnlineID:onlineID];
        [self setOnlineLink:onlineLink];
        [self setFileName:[[entry fileURL] lastPathComponent]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_onlineID forKey:@"OnlineID"];
    [aCoder encodeObject:_onlineLink forKey:@"OnlineLink"];
    [aCoder encodeObject:_fileName forKey:@"FileName"];
}

- (NSString *)entryName
{
    return _fileName;
}

- (NSImage *)entryIcon
{
    NSInteger pointLoc = [_fileName rangeOfString:@"." options:NSBackwardsSearch].location;
    NSString *fileType = pointLoc != NSNotFound ? [_fileName substringFromIndex:pointLoc] : @"";
    
    return [[NSWorkspace sharedWorkspace] iconForFileType:fileType];
}

@end
