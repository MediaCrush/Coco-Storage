//
//  STGAPIConfigurationStub.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 18.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGAPIConfigurationStub.h"

#import "STGDataCaptureEntry.h"

#import "STGUploadedEntry.h"
#import "STGUploadedEntryFile.h"

STGAPIConfigurationStub *standardConfiguration;

@implementation STGAPIConfigurationStub 

@synthesize delegate = _delegate, networkDelegate = _networkDelegate;

+ (STGAPIConfigurationStub *)standardConfiguration
{
    if (!standardConfiguration)
    {
        standardConfiguration = [[STGAPIConfigurationStub alloc] init];
    }
    
    return standardConfiguration;
}

- (NSString *)apiHostName
{
    return @"Coco Storage - Local";
}

- (BOOL)hasAPIKeys
{
    return NO;
}

- (BOOL)hasCFS
{
    return NO;
}

- (BOOL)hasAlbums
{
    return NO;
}

- (NSString *)accountLinkTitle
{
    return @"Temp Files";
}

- (void)openAccountLink
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[@"file://" stringByAppendingString:[self destinationDirectory]]]];
}

- (NSString *)fileListLinkTitle
{
    return nil;
}

- (NSSet *)supportedUploadTypes
{
    return [NSSet setWithObjects:
            [NSNumber numberWithUnsignedInteger:STGDropActionUploadFile],
            [NSNumber numberWithUnsignedInteger:STGDropActionUploadImage],
            [NSNumber numberWithUnsignedInteger:STGDropActionUploadText],
            [NSNumber numberWithUnsignedInteger:STGDropActionUploadRtfText],
            [NSNumber numberWithUnsignedInteger:STGDropActionUploadColor],
            [NSNumber numberWithUnsignedInteger:STGDropActionUploadZip],
            [NSNumber numberWithUnsignedInteger:STGDropActionUploadDirectoryZip],
            [NSNumber numberWithUnsignedInteger:STGDropActionUploadLinkRedirect],
            nil];
}

- (BOOL)hasWelcomeWindow
{
    return NO;
}

- (NSString *)objectIDFromString:(NSString *)string
{
    NSRange linkRange = [string rangeOfString:@"mediacru.sh/"];
    if (linkRange.location != NSNotFound)
    {
        NSString *startCut = [string substringFromIndex:linkRange.location + linkRange.length];
        NSRange nextSlash = [startCut rangeOfString:@"/"];
        return nextSlash.location != NSNotFound ? [startCut substringToIndex:nextSlash.location] : startCut;
    }
    
    return nil;
}

- (BOOL)canReachServer
{
    return YES;
}

- (void)handlePacket:(STGPacket *)entry fullResponse:(NSData *)response urlResponse:(NSURLResponse *)urlResponse
{
    
}

- (void)cancelPacketUpload:(STGPacket *)entry
{
    
}

- (void)sendStatusPacket:(STGPacketQueue *)packetQueue apiKey:(NSString *)apiKey
{
    if ([_networkDelegate respondsToSelector:@selector(updateAPIStatus:validKey:)])
    {
        [_networkDelegate updateAPIStatus:YES validKey:true];
    }
    
    // No API status packet
}

- (void)sendFileUploadPacket:(STGPacketQueue *)packetQueue apiKey:(NSString *)apiKey entry:(STGDataCaptureEntry *)entry public:(BOOL)publicFile
{
    NSString *onlineID = [NSString stringWithFormat:@"%i", rand()];
    
    NSURL *destDirectoryURL = [NSURL URLWithString:[@"file://" stringByAppendingString:[self destinationDirectory]]];
    NSURL *destURL = [destDirectoryURL URLByAppendingPathComponent:[onlineID stringByAppendingString:[[entry fileURL] lastPathComponent]]];

    STGUploadedEntryFile *fileEntry = [[STGUploadedEntryFile alloc] initWithDataCaptureEntry:entry onlineID:onlineID onlineLink:destURL];

    NSError *error = nil;
    [[NSFileManager defaultManager] copyItemAtURL:[entry fileURL] toURL:destURL error:&error];
    
    if (error)
        NSLog(@"File copy error %@", error);
    
    if ([_networkDelegate respondsToSelector:@selector(didUploadEntry:success:)])
        [_networkDelegate didUploadEntry:fileEntry success:error == nil];

    if ([_networkDelegate respondsToSelector:@selector(didUploadDataCaptureEntry:dataCaptureEntry:success:)])
        [_networkDelegate didUploadDataCaptureEntry:fileEntry dataCaptureEntry:entry success:error == nil];
}

- (void)sendFileDeletePacket:(STGPacketQueue *)packetQueue apiKey:(NSString *)apiKey entry:(STGUploadedEntry *)entry
{
    if ([_networkDelegate respondsToSelector:@selector(didDeleteDataCaptureEntry:)])
        [_networkDelegate didDeleteEntry:entry];
}

- (void)sendAlbumCreatePacket:(STGPacketQueue *)packetQueue apiKey:(NSString *)apiKey entries:(NSArray *)entries
{
    
}

- (NSString *)destinationDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDownloadsDirectory, NSUserDomainMask, YES );
    
    if ([paths count] > 0)
        return [paths objectAtIndex:0];
    
    return nil;
}

@end
