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
#import "STGUploadedEntryFile.h"
#import "STGUploadedEntryAlbum.h"
#import "STGUploadedEntryRehosted.h"

NSString * const kSTGAPIConfigurationKeyMediacrush = @"kSTGAPIConfigurationKeyMediacrush";
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

+ (void)registerStandardConfiguration
{
    [STGAPIConfiguration registerConfiguration:[self standardConfiguration] withID:kSTGAPIConfigurationKeyMediacrush];
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
            [NSNumber numberWithUnsignedInteger:STGUploadActionUploadFile],
            [NSNumber numberWithUnsignedInteger:STGUploadActionUploadImage],
            [NSNumber numberWithUnsignedInteger:STGUploadActionRehostFromLink],
//            [NSNumber numberWithUnsignedInteger:STGUploadActionUploadText],
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
            NSString *link = [NSString stringWithFormat:@"https://mediacru.sh/%@", uploadID];
            STGUploadedEntry *uploadedEntry = [[STGUploadedEntryFile alloc] initWithDataCaptureEntry:dataCaptureEntry onlineID:uploadID onlineLink:[NSURL URLWithString:link]];
            
            if ([_networkDelegate respondsToSelector:@selector(didUploadEntry:success:)])
                [_networkDelegate didUploadEntry:uploadedEntry success:YES];

            if ([_networkDelegate respondsToSelector:@selector(didUploadDataCaptureEntry:dataCaptureEntry:success:)])
                [_networkDelegate didUploadDataCaptureEntry:uploadedEntry dataCaptureEntry:dataCaptureEntry success:YES];
        }
        else
        {
            STGUploadedEntry *uploadedEntry = [[STGUploadedEntryFile alloc] initWithDataCaptureEntry:dataCaptureEntry onlineID:nil onlineLink:nil];
            NSLog(@"Upload file (error?). Response:\n%@\nStatus: %li (%@)", response, responseCode, [NSHTTPURLResponse localizedStringForStatusCode:responseCode]);
            
            if ([_networkDelegate respondsToSelector:@selector(didUploadEntry:success:)])
                [_networkDelegate didUploadEntry:uploadedEntry success:NO];

            if ([_networkDelegate respondsToSelector:@selector(didUploadDataCaptureEntry:dataCaptureEntry:success:)])
                [_networkDelegate didUploadDataCaptureEntry:uploadedEntry dataCaptureEntry:dataCaptureEntry success:NO];
        }
    }
    else if ([[entry packetType] isEqualToString:@"deleteFile"])
    {
        NSDictionary *dictionary = [STGJSONHelper getDictionaryJSONFromData:response];
        
        NSString *message = [dictionary objectForKey:@"status"];
        
        if ([message isEqualToString:@"success"])
        {
            STGUploadedEntry *uploadedEntry = [[entry userInfo] objectForKey:@"uploadedEntry"];
            if ([_networkDelegate respondsToSelector:@selector(didDeleteEntry:)])
                [_networkDelegate didDeleteEntry:uploadedEntry];
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
        NSArray *entryIDs = [[entry userInfo] objectForKey:@"entryIDs"];
        
        NSString *uploadID = [dictionary objectForKey:@"hash"];
        
        if (uploadID)
        {
            NSString *link = [NSString stringWithFormat:@"https://mediacru.sh/%@", uploadID];
            STGUploadedEntryAlbum *uploadedEntry = [[STGUploadedEntryAlbum alloc] initWithID:uploadID link:[NSURL URLWithString:link] numberOfEntries:[entryIDs count]];
            
            if ([_networkDelegate respondsToSelector:@selector(didUploadEntry:success:)])
                [_networkDelegate didUploadEntry:uploadedEntry success:YES];
        }
    }
    else if ([[entry packetType] isEqualToString:@"rehostLink"])
    {
        NSDictionary *dictionary = [STGJSONHelper getDictionaryJSONFromData:response];
        STGDataCaptureEntry *dataCaptureEntry = [[entry userInfo] objectForKey:@"dataCaptureEntry"];
        
        NSString *uploadID = [dictionary objectForKey:@"hash"];
        
        if (uploadID)
        {
            NSString *originalLink = [[entry userInfo] objectForKey:@"link"];
            NSString *link = [NSString stringWithFormat:@"https://mediacru.sh/%@", uploadID];
            STGUploadedEntry *uploadedEntry = [[STGUploadedEntryRehosted alloc] initWithID:uploadID link:[NSURL URLWithString:link] originalLink:[NSURL URLWithString:originalLink]];
            
            if ([_networkDelegate respondsToSelector:@selector(didUploadEntry:success:)])
                [_networkDelegate didUploadEntry:uploadedEntry success:YES];
            
            if ([_networkDelegate respondsToSelector:@selector(didUploadDataCaptureEntry:dataCaptureEntry:success:)])
                [_networkDelegate didUploadDataCaptureEntry:uploadedEntry dataCaptureEntry:dataCaptureEntry success:YES];
        }
        else
        {
            STGUploadedEntry *uploadedEntry = [[STGUploadedEntryFile alloc] initWithDataCaptureEntry:dataCaptureEntry onlineID:nil onlineLink:nil];
            NSLog(@"Upload file (error?). Response:\n%@\nStatus: %li (%@)", response, responseCode, [NSHTTPURLResponse localizedStringForStatusCode:responseCode]);
            
            if ([_networkDelegate respondsToSelector:@selector(didUploadEntry:success:)])
                [_networkDelegate didUploadEntry:uploadedEntry success:NO];
            
            if ([_networkDelegate respondsToSelector:@selector(didUploadDataCaptureEntry:dataCaptureEntry:success:)])
                [_networkDelegate didUploadDataCaptureEntry:uploadedEntry dataCaptureEntry:dataCaptureEntry success:NO];
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
    NSData *fileData = [NSData dataWithContentsOfURL:[entry fileURL]];
    
    if ([entry uploadAction] == STGUploadActionRehostFromLink)
    {
        NSString *urlToFetchFrom = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
        NSData *contentPart = [STGPacket contentPartObjectsForKeys:
                               [NSDictionary dictionaryWithObjectsAndKeys:
                                @"url", @"name",
                                urlToFetchFrom, @"url",
                                publicFile ? @"false" : @"true", @"private",
                                nil] content:fileData];
        NSArray *requestParts = [NSArray arrayWithObject:contentPart];
        
        NSURLRequest *request = [STGPacket defaultRequestWithUrl:[NSString stringWithFormat:@"https://mediacru.sh/api/upload/url"] httpMethod:@"POST" contentParts:requestParts];
        
        STGPacket *packet = [STGPacket genericPacketWithRequest:request packetType:@"rehostLink" userInfo:[NSMutableDictionary dictionaryWithObjectsAndKeys: entry, @"dataCaptureEntry", urlToFetchFrom, @"link", nil]];
        
        [packetQueue addEntry:packet];
    }
    else
    {
        NSData *contentPart = [STGPacket contentPartObjectsForKeys:
                               [NSDictionary dictionaryWithObjectsAndKeys:
                                @"file", @"name",
                                [[entry fileURL] lastPathComponent], @"filename",
                                publicFile ? @"false" : @"true", @"private",
                                nil] content:fileData];
        NSArray *requestParts = [NSArray arrayWithObject:contentPart];
        
        NSURLRequest *request = [STGPacket defaultRequestWithUrl:[NSString stringWithFormat:@"https://mediacru.sh/api/upload/file"] httpMethod:@"POST" contentParts:requestParts];
        
        STGPacket *packet = [STGPacket genericPacketWithRequest:request packetType:@"uploadFile" userInfo:[NSMutableDictionary dictionaryWithObject:entry forKey:@"dataCaptureEntry"]];
        
        [packetQueue addEntry:packet];
    }
}

- (void)sendFileDeletePacket:(STGPacketQueue *)packetQueue apiKey:(NSString *)apiKey entry:(STGUploadedEntry *)entry
{
    NSString *entryID = [entry onlineID];
    NSString *urlString = [NSString stringWithFormat:@"https://mediacru.sh/api/%@", entryID];
    
    NSURLRequest *request = [STGPacket defaultRequestWithUrl:urlString httpMethod:@"DELETE" fileName:entryID mainBodyData:[NSData data]];
    
    STGPacket *packet = [STGPacket genericPacketWithRequest:request packetType:@"deleteFile" userInfo:[NSMutableDictionary dictionaryWithObject:entry forKey:@"uploadedEntry"]];
    
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
