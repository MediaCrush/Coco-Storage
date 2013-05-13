//
//  STGPacketQueueEntryDeleteFile.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 12.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGPacketDeleteFile.h"

#import "STGDataCaptureEntry.h"

@implementation STGPacketDeleteFile

@synthesize dataCaptureEntry = _dataCaptureEntry;

- (id)initWithDataCaptureEntry:(STGDataCaptureEntry *)entry deletionLink:(NSString *)link key:(NSString *)key
{
    self = [super init];
    if (self)
    {
        [self setDataCaptureEntry:entry];
        
        NSUInteger entryIDLoc = [[entry onlineLink] rangeOfString:@"/" options:NSBackwardsSearch].location;
        
        if (entryIDLoc == NSNotFound)
        {
            [self setUrlRequest:nil];
        }
        else
        {
            NSString *entryID = [[entry onlineLink] substringFromIndex:entryIDLoc + 1];
            NSString *urlString = [NSString stringWithFormat:link, entryID, key];
            
            [self setUrlRequest:[STGPacket defaultRequestWithUrl:urlString httpMethod:@"DELETE" fileName:[[entry fileURL] lastPathComponent] mainBodyString:[NSData dataWithContentsOfURL:[entry fileURL]]]];   
        }
    }
    return self;
}

@end
