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
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setFileName:[aDecoder decodeObjectForKey:@"FileName"]];
    }
    return self;
}

- (instancetype)initWithAPIConfigurationID:(NSString *)configID onlineID:(NSString *)onlineID onlineLink:(NSURL *)onlineLink dataCaptureEntry:(STGDataCaptureEntry *)dataCaptureEntry
{
    self = [super initWithAPIConfigurationID:configID onlineID:onlineID onlineLink:onlineLink];
    if (self) {
        [self setOnlineID:onlineID];
        [self setOnlineLink:onlineLink];
        [self setFileName:[[dataCaptureEntry fileURL] lastPathComponent]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
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
