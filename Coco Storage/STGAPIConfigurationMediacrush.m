//
//  STGAPIConfigurationMediacrush.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 08.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGAPIConfigurationMediacrush.h"

#import "STGNetworkHelper.h"
#import "STGPacket.h"
#import "STGJSONHelper.h"
#import "STGPacketQueue.h"

#import "STGDataCaptureEntry.h"

STGAPIConfigurationMediacrush *standardConfiguration;

@implementation STGAPIConfigurationMediacrush

@synthesize delegate = _delegate, networkDelegate = _networkDelegate;

+ (STGAPIConfigurationMediacrush *)standardConfiguration
{
    if (!standardConfiguration)
    {
        standardConfiguration = [[STGAPIConfigurationMediacrush alloc] init];
    }
    
    return standardConfiguration;
}

- (NSString *)apiHostName
{
    return @"mediacru.sh";
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
    return YES;
}

- (NSString *)accountLinkTitle
{
    return @"Mediacru.sh";
}

- (void)openAccountLink
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://mediacru.sh"]];
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
//            [NSNumber numberWithUnsignedInteger:STGDropActionUploadText],
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
    return [STGNetworkHelper isWebsiteReachable:@"mediacru.sh"];
}

- (void)handlePacket:(STGPacket *)entry fullResponse:(NSData *)response urlResponse:(NSURLResponse *)urlResponse
{
    NSUInteger responseCode = 0;
    if ([urlResponse isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) urlResponse;
        
        responseCode = [httpResponse statusCode];
        
//        NSLog(@"Status (ERROR!): (%li) %@", (long)[httpResponse statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]]);
//
//        NSDictionary *headerFields = [httpResponse allHeaderFields];
//        NSLog(@"----Headers----");
//        for (NSObject *key in [headerFields allKeys])
//        {
//            NSLog(@"\"%@\" : \"%@\"", key, [headerFields objectForKey:key]);
//        }
    }
    
    if ([[entry packetType] isEqualToString:@"uploadFile"])
    {
        NSDictionary *dictionary = [STGJSONHelper getDictionaryJSONFromData:response];
        STGDataCaptureEntry *dataCaptureEntry = [[entry userInfo] objectForKey:@"dataCaptureEntry"];
        
        NSString *uploadID = [dictionary objectForKey:@"hash"];
        
        if (uploadID)
        {
            [dataCaptureEntry setOnlineID:uploadID];
            NSString *link = [NSString stringWithFormat:@"https://mediacru.sh/%@", uploadID];
            [dataCaptureEntry setOnlineLink:link];
                        
            if ([_networkDelegate respondsToSelector:@selector(didUploadDataCaptureEntry:success:)])
            {
                [_networkDelegate didUploadDataCaptureEntry:dataCaptureEntry success:YES];
            }
        }
        else
        {
            NSLog(@"Upload file (error?). Response:\n%@\nStatus: %li (%@)", response, responseCode, [NSHTTPURLResponse localizedStringForStatusCode:responseCode]);
            
            if ([_networkDelegate respondsToSelector:@selector(didUploadDataCaptureEntry:success:)])
            {
                [_networkDelegate didUploadDataCaptureEntry:dataCaptureEntry success:NO];
            }
        }
    }
    else if ([[entry packetType] isEqualToString:@"deleteFile"])
    {
        NSDictionary *dictionary = [STGJSONHelper getDictionaryJSONFromData:response];
        
        NSString *message = [dictionary objectForKey:@"status"];
        
        if ([message isEqualToString:@"success"])
        {
            STGDataCaptureEntry *dataCaptureEntry = [[entry userInfo] objectForKey:@"dataCaptureEntry"];
            if ([_networkDelegate respondsToSelector:@selector(didDeleteDataCaptureEntry:)])
                [_networkDelegate didDeleteDataCaptureEntry:dataCaptureEntry];
        }
        else
        {
            /*            [[[_statusItemManager statusItem] menu] cancelTracking];
             NSAlert *alert = [NSAlert alertWithMessageText:@"Coco Storage Upload Error" defaultButton:@"Open Preferences" alternateButton:@"OK" otherButton:nil informativeTextWithFormat:@"Coco Storage could not complete your file deletion... Make sure your Storage key is valid, and try again.\nHTTP Status: %@ (%li)", [NSHTTPURLResponse localizedStringForStatusCode:responseCode], responseCode];
             [alert beginSheetModalForWindow:nil modalDelegate:_delegate didEndSelector:@selector(keyMissingSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];*/
            
            if (responseCode != 500) //Not found, probably
                NSLog(@"Delete file (error?). Response:\n%@\nStatus: %li (%@)", response, responseCode, [NSHTTPURLResponse localizedStringForStatusCode:responseCode]);
        }
    }
    else if ([[entry packetType] isEqualToString:@"getAPIStatus"])
    {
        NSDictionary *dictionary = nil;
        if ([response length] > 0)
            dictionary = [STGJSONHelper getDictionaryJSONFromData:response];
        
        NSString *stringStatus = dictionary ? [dictionary objectForKey:@"status"] : nil;
        
        if ([_networkDelegate respondsToSelector:@selector(updateAPIStatus:validKey:)])
        {
            if ([[[entry userInfo] objectForKey:@"apiVersion"] integerValue] == 1)
                [_networkDelegate updateAPIStatus:[stringStatus isEqualToString:@"ok"] validKey:responseCode != 401];
        }
    }
    else if ([[entry packetType] isEqualToString:@"createAlbum"])
    {
        NSDictionary *dictionary = [STGJSONHelper getDictionaryJSONFromData:response];
//        NSArray *entryIDs = [[entry userInfo] objectForKey:@"entryIDs"];
        
        NSString *uploadID = [dictionary objectForKey:@"hash"];
        
        if (uploadID)
        {
//            STGDataCaptureEntry *dataCaptureEntry = [STGDataCaptureEntry entryWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"Album (%li files)", [entryIDs count]]] deleteOnCompletion:NO];
            STGDataCaptureEntry *dataCaptureEntry = [STGDataCaptureEntry entryWithURL:[NSURL URLWithString:@"Album"] deleteOnCompletion:NO];
            
            [dataCaptureEntry setOnlineID:uploadID];
            NSString *link = [NSString stringWithFormat:@"https://mediacru.sh/%@", uploadID];
            [dataCaptureEntry setOnlineLink:link];
            
            if ([_networkDelegate respondsToSelector:@selector(didUploadDataCaptureEntry:success:)])
            {
                [_networkDelegate didUploadDataCaptureEntry:dataCaptureEntry success:YES];
            }
        }
    }
    else
    {
        NSLog(@"Unknown packet entry. Entry: \"%@\"\nResponse:\n%@\nStatus: %li (%@)", [entry packetType], response, responseCode, [NSHTTPURLResponse localizedStringForStatusCode:responseCode]);
    }
}

- (void)cancelPacketUpload:(STGPacket *)entry
{
    if ([[entry packetType] isEqualToString:@"uploadFile"])
    {
//        if ([_networkDelegate respondsToSelector:@selector(didUploadDataCaptureEntry:success:)])
//        {
//            [_networkDelegate didUploadDataCaptureEntry:[[entry userInfo] objectForKey:@"dataCaptureEntry"] success:NO];
//        }
    }
}

- (void)sendStatusPacket:(STGPacketQueue *)packetQueue apiKey:(NSString *)apiKey
{
    if ([_networkDelegate respondsToSelector:@selector(updateAPIStatus:validKey:)])
    {
        [_networkDelegate updateAPIStatus:[STGNetworkHelper isWebsiteReachable:@"mediacru.sh"] validKey:true];
    }

    // No API status packet
}

- (void)sendFileUploadPacket:(STGPacketQueue *)packetQueue apiKey:(NSString *)apiKey entry:(STGDataCaptureEntry *)entry public:(BOOL)publicFile
{
    NSData *contentPart = [STGPacket contentPartObjectsForKeys:
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            @"file", @"name",
                            [[entry fileURL] lastPathComponent], @"filename",
                            publicFile ? @"false" : @"true", @"private",
                            nil] content:[NSData dataWithContentsOfURL:[entry fileURL]]];
    NSArray *requestParts = [NSArray arrayWithObject:contentPart];
    
    NSURLRequest *request = [STGPacket defaultRequestWithUrl:[NSString stringWithFormat:@"https://mediacru.sh/api/upload/file"] httpMethod:@"POST" contentParts:requestParts];
    
    STGPacket *packet = [STGPacket genericPacketWithRequest:request packetType:@"uploadFile" userInfo:[NSMutableDictionary dictionaryWithObject:entry forKey:@"dataCaptureEntry"]];
    
    [packetQueue addEntry:packet];
}

- (void)sendFileDeletePacket:(STGPacketQueue *)packetQueue apiKey:(NSString *)apiKey entry:(STGDataCaptureEntry *)entry
{
    NSString *entryID = [entry onlineID];
    NSString *urlString = [NSString stringWithFormat:@"https://mediacru.sh/api/%@", entryID];
    
    NSURLRequest *request = [STGPacket defaultRequestWithUrl:urlString httpMethod:@"DELETE" fileName:[[entry fileURL] lastPathComponent] mainBodyData:[NSData dataWithContentsOfURL:[entry fileURL]]];
    
    STGPacket *packet = [STGPacket genericPacketWithRequest:request packetType:@"deleteFile" userInfo:[NSMutableDictionary dictionaryWithObject:entry forKey:@"dataCaptureEntry"]];
    
    [packetQueue addEntry:packet];
}

- (void)sendAlbumCreatePacket:(STGPacketQueue *)packetQueue apiKey:(NSString *)apiKey entries:(NSArray *)entries
{
    NSString *listString = [entries componentsJoinedByString:@","];
    
    NSData *contentPart = [STGPacket contentPartObjectsForKeys:
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            @"list", @"name",
                            nil] content:[listString dataUsingEncoding:NSUTF8StringEncoding]];
    NSArray *requestParts = [NSArray arrayWithObject:contentPart];
    
    NSURLRequest *request = [STGPacket defaultRequestWithUrl:[NSString stringWithFormat:@"https://mediacru.sh/api/album/create"] httpMethod:@"POST" contentParts:requestParts];
    
    STGPacket *packet = [STGPacket genericPacketWithRequest:request packetType:@"createAlbum" userInfo:[NSMutableDictionary dictionaryWithObject:entries forKey:@"entryIDs"]];
    
    [packetQueue addEntry:packet];
}

@end
