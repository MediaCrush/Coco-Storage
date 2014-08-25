//
//  STGNetworkManager.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGNetworkManager.h"

#import "STGCFSSyncCheck.h"
#import "STGPacket.h"

#import "STGDataCaptureEntry.h"

#import "STGAPIConfiguration.h"

#import "STGNetworkHelper.h"

@implementation STGNetworkManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setApiV1Alive:YES];
        [self setApiV2Alive:YES];
        
        [self setPacketUploadV1Queue:[[STGPacketQueue alloc] init]];
        [_packetUploadV1Queue setDelegate:self];
        [self setPacketUploadV2Queue:[[STGPacketQueue alloc] init]];
        [_packetUploadV2Queue setDelegate:self];
        [self setPacketSupportQueue:[[STGPacketQueue alloc] init]];
        [_packetSupportQueue setDelegate:self];
        
        [self setCfsSyncCheck:[[STGCFSSyncCheck alloc] init]];
        [self setUploadTimer:[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(uploadTimerFired:) userInfo:nil repeats:YES]];

        [self setServerStatusTimer:[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(serverStatusTimerFired:) userInfo:nil repeats:YES]];
    }
    return self;
}

- (void)setUploadsPaused:(BOOL)uploadsPaused
{
    _uploadsPaused = uploadsPaused;
    
    [_packetUploadV1Queue setUploadsPaused:uploadsPaused];
    [_packetUploadV2Queue setUploadsPaused:uploadsPaused];
}

#pragma mark - Timer

- (void)uploadTimerFired:(NSTimer*)theTimer
{
    [_packetUploadV1Queue update];
    [_packetUploadV2Queue update];
    [_packetSupportQueue update];
    
    _apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"mainStorageKey"];
}

- (void)serverStatusTimerFired:(NSTimer*)theTimer
{
    [self checkServerStatus];
}

- (void)checkServerStatus
{
    BOOL reachingServer = [[STGAPIConfiguration currentConfiguration] canReachServer];
    
    if (reachingServer)
    {
        if ([self isAPIKeyValid:NO])
        {
            [[STGAPIConfiguration currentConfiguration] sendStatusPacket:_packetSupportQueue apiKey:_apiKey];
            
            //                [_packetSupportQueue addEntry:[STGPacketCreator cfsFileListPacket:@"" link:[[STGAPIConfiguration standardConfiguration] cfsBaseLink] recursive:YES key:[self getApiKey]]];
            
            //                [_packetSupportQueue addEntry:[STGPacketCreator objectInfoPacket:[[_recentFilesArray objectAtIndex:0] onlineID] link:[[STGAPIConfiguration standardConfiguration] getObjectInfoLink] key:[self getApiKey]]];
        }
    }
    else
    {
        BOOL reachingApple = [STGNetworkHelper isWebsiteReachable:@"www.apple.com"];
        
        if (!reachingApple)
            [self setServerStatus:STGServerStatusClientOffline];
        else
            [self setServerStatus:STGServerStatusServerOffline];
    }
}

- (BOOL)isAPIKeyValid:(BOOL)output
{
    if (![[STGAPIConfiguration currentConfiguration] hasAPIKeys])
        return YES;
    else
    {
        NSString *key = _apiKey;
        
        int error = -1;
        
        if (!key || [key length] == 0)
            error = 1;
        else if ([key length] < 40)
            error = 2;
        
        if (error > 0 && output)
        {
            if (error == 1)
            {
                NSAlert *alert = [NSAlert alertWithMessageText:@"Coco Storage Upload Error" defaultButton:@"Open Preferences" alternateButton:@"OK" otherButton:nil informativeTextWithFormat:@"You have entered no Storage key! This is required as identification for %@. Please move to the preferences to enter / create one.", [[STGAPIConfiguration currentConfiguration] apiHostName]];
                [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(keyMissingSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
            }
            else if (error == 2)
            {
                NSAlert *alert = [NSAlert alertWithMessageText:@"Coco Storage Upload Error" defaultButton:@"Open Preferences" alternateButton:@"OK" otherButton:nil informativeTextWithFormat:@"Your storage key is too short [invalid]. This is required as identification for %@. Please move to the preferences to enter / create one.", [[STGAPIConfiguration currentConfiguration] apiHostName]];
                [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(keyMissingSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
            }
            
            return NO;
        }
        else
            return YES;
    }
}

#pragma mark API Configuration delegate

- (void)didUploadDataCaptureEntry:(STGDataCaptureEntry *)entry success:(BOOL)success
{
    if ([_delegate respondsToSelector:@selector(fileUploadCompleted:entry:successful:)])
        [_delegate fileUploadCompleted:self entry:entry successful:success];
}

- (void)startUploadingData:(STGPacketQueue *)queue entry:(STGPacket *)entry
{
}

- (void)finishUploadingData:(STGPacketQueue *)queue entry:(STGPacket *)entry fullResponse:(NSData *)response urlResponse:(NSURLResponse *)urlResponse
{
    NSUInteger responseCode = 0;
    if ([urlResponse isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) urlResponse;
        
        responseCode = [httpResponse statusCode];
        
        BOOL debugOutput = NO;
        
        if (debugOutput)
            NSLog(@"Status (ERROR!): (%li) %@", (long)[httpResponse statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]]);
        
        BOOL outputHeaders = NO;
        
        if (outputHeaders)
        {
            NSDictionary *headerFields = [httpResponse allHeaderFields];
            
            NSLog(@"----Headers----");
            
            for (NSObject *key in [headerFields allKeys])
            {
                NSLog(@"\"%@\" : \"%@\"", key, [headerFields objectForKey:key]);
            }
        }
    }
    
    [[STGAPIConfiguration currentConfiguration] handlePacket:entry fullResponse:response urlResponse:urlResponse];
}

- (void)packetQueue:(STGPacketQueue *)queue cancelledEntry:(STGPacket *)entry
{
    [[STGAPIConfiguration currentConfiguration] cancelPacketUpload:entry];
}

- (void)packetQueueUpdatedEntries:(STGPacketQueue *)queue
{
    if (queue == _packetUploadV1Queue)
        [self notifyOfFileUploadQueueChanges];
}

-(void)updateAPIStatus:(BOOL)active validKey:(BOOL)validKey
{
    [self setApiV1Alive:active];
    //    [self setApiV2Alive:alive];
    
    STGServerStatus status;
    
    if (_apiV1Alive/* && _apiV2Alive*/)
        status = STGServerStatusOnline;
    else if (!validKey)
        status = STGServerStatusInvalidKey;
    else
    {
        BOOL reachingServer = [[STGAPIConfiguration currentConfiguration] canReachServer];
        BOOL reachingApple = [STGNetworkHelper isWebsiteReachable:@"www.apple.com"];
        
        if (!reachingApple && !reachingServer)
            status = STGServerStatusClientOffline;
        else if (!reachingServer)
            status = STGServerStatusServerOffline;
        else if (!_apiV1Alive/* && !_apiV2Alive*/)
            status = STGServerStatusServerBusy;
        else if (!_apiV1Alive)
            status = STGServerStatusServerV1Busy;
        //        else if (!_apiV2Alive)
        //            status = STGServerStatusServerV2Busy;
        else
            status = STGServerStatusUnknown;
    }
    
    [self setServerStatus:status];
}

- (double)fileUploadProgress
{
    return [_packetUploadV1Queue uploadedData];
}

- (void)packetQueueUpdatedProgress:(STGPacketQueue *)queue
{
    if (queue == _packetUploadV1Queue)
    {
        if ([_delegate respondsToSelector:@selector(fileUploadProgressChanged:)])
            [_delegate fileUploadProgressChanged:self];
    }
}

- (void)notifyOfFileUploadQueueChanges
{
    if ([_delegate respondsToSelector:@selector(fileUploadQueueChanged:)])
        [_delegate fileUploadQueueChanged:self];
}

- (void)setServerStatus:(STGServerStatus)serverStatus
{
    if (_serverStatus != serverStatus)
    {
        _serverStatus = serverStatus;
        
        if ([_delegate respondsToSelector:@selector(serverStatusChanged:)])
            [_delegate serverStatusChanged:self];
    }
}

- (void)didDeleteDataCaptureEntry:(STGDataCaptureEntry *)entry
{
    if ([_delegate respondsToSelector:@selector(fileDeletionCompleted:entry:)])
        [_delegate fileDeletionCompleted:self entry:entry];
}


@end
