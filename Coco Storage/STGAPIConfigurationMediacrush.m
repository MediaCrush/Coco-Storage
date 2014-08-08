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

@synthesize delegate;

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
    NSLog(@"RECEIVE %@", [entry packetType]);
    NSLog(@"CODE %lu", (unsigned long)responseCode);
    NSLog(@"RESPONSE %lu", (unsigned long)[response length]);
    
    if ([[entry packetType] isEqualToString:@"uploadFile"])
    {
        NSDictionary *dictionary = [STGJSONHelper getDictionaryJSONFromData:response];
        
        NSString *uploadID = [dictionary objectForKey:@"hash"];
        NSString *link = uploadID ? [NSString stringWithFormat:@"https://mediacru.sh/%@", uploadID] : nil;
        
        if (link)
        {
            [[[entry userInfo] objectForKey:@"dataCaptureEntry"] setOnlineLink:link];
            
            if ([[NSUserDefaults standardUserDefaults] integerForKey:@"displayNotification"] == 1)
            {
                NSUserNotification *notification = [[NSUserNotification alloc] init];
                
                [notification setTitle:[NSString stringWithFormat:@"Coco Storage Upload complete: %@!", link]];
                [notification setInformativeText:@"Click to view the uploaded file"];
                [notification setSoundName:nil];
                [notification setUserInfo:[NSDictionary dictionaryWithObject:link forKey:@"uploadLink"]];
                
                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
            }
            
            if (![[[NSUserDefaults standardUserDefaults] stringForKey:@"completionSound"] isEqualToString:@"noSound"])
            {
                NSSound *sound = [NSSound soundNamed:[[NSUserDefaults standardUserDefaults] stringForKey:@"completionSound"]];
                
                if (sound)
                    [sound play];
            }
            
            if ([[NSUserDefaults standardUserDefaults] integerForKey:@"linkCopyToPasteboard"] == 1)
            {
                [[NSPasteboard generalPasteboard] clearContents];
                [[NSPasteboard generalPasteboard] setString:link forType:NSPasteboardTypeString];
            }
            
            if ([[NSUserDefaults standardUserDefaults] integerForKey:@"linkOpenInBrowser"] == 1)
            {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:link]];
            }
            
            if ([[self delegate] respondsToSelector:@selector(didUploadDataCaptureEntry:)])
            {
                [[self delegate] didUploadDataCaptureEntry:[[entry userInfo] objectForKey:@"dataCaptureEntry"] success:YES];
            }
        }
        else
        {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Coco Storage Upload Error" defaultButton:@"Open Preferences" alternateButton:@"OK" otherButton:nil informativeTextWithFormat:@"Coco Storage could not complete your file upload... Make sure your Storage key is valid, and try again.\nHTTP Status: %@ (%li)", [NSHTTPURLResponse localizedStringForStatusCode:responseCode], responseCode];
            [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(keyMissingSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
            
            NSLog(@"Upload file (error?). Response:\n%@\nStatus: %li (%@)", response, responseCode, [NSHTTPURLResponse localizedStringForStatusCode:responseCode]);
            
            if ([[self delegate] respondsToSelector:@selector(didUploadDataCaptureEntry:)])
            {
                [[self delegate] didUploadDataCaptureEntry:[[entry userInfo] objectForKey:@"dataCaptureEntry"] success:NO];
            }
        }
    }
    else if ([[entry packetType] isEqualToString:@"deleteFile"])
    {
        NSDictionary *dictionary = [STGJSONHelper getDictionaryJSONFromData:response];
        
        NSString *message = [dictionary objectForKey:@"status"];
        
        if ([message isEqualToString:@"success"])
        {
            
        }
        else
        {
            /*            [[[_statusItemManager statusItem] menu] cancelTracking];
             NSAlert *alert = [NSAlert alertWithMessageText:@"Coco Storage Upload Error" defaultButton:@"Open Preferences" alternateButton:@"OK" otherButton:nil informativeTextWithFormat:@"Coco Storage could not complete your file deletion... Make sure your Storage key is valid, and try again.\nHTTP Status: %@ (%li)", [NSHTTPURLResponse localizedStringForStatusCode:responseCode], responseCode];
             [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(keyMissingSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];*/
            
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
        
        if ([[self delegate] respondsToSelector:@selector(updateAPIStatus:validKey:)])
        {
            if ([[[entry userInfo] objectForKey:@"apiVersion"] integerValue] == 1)
                [[self delegate] updateAPIStatus:[stringStatus isEqualToString:@"ok"] validKey:responseCode != 401];
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
        if ([[self delegate] respondsToSelector:@selector(didUploadDataCaptureEntry:)])
        {
            [[self delegate] didUploadDataCaptureEntry:[[entry userInfo] objectForKey:@"dataCaptureEntry"] success:NO];
        }
    }
}

- (void)sendStatusPacket:(STGPacketQueue *)packetQueue apiKey:(NSString *)apiKey
{
    if ([[self delegate] respondsToSelector:@selector(updateAPIStatus:validKey:)])
    {
        [[self delegate] updateAPIStatus:[STGNetworkHelper isWebsiteReachable:@"mediacru.sh"] validKey:true];
    }

    // No API status packet
}

- (void)sendFileUploadPacket:(STGPacketQueue *)packetQueue apiKey:(NSString *)apiKey entry:(STGDataCaptureEntry *)entry public:(BOOL)publicFile
{
    NSLog(@"SEND %@", [entry fileURL]);
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
    NSUInteger entryIDLoc = [[entry onlineLink] rangeOfString:@"/" options:NSBackwardsSearch].location;
    
    if (entryIDLoc == NSNotFound)
        NSLog(@"Could not find ID in online link!");
    
    NSString *entryID = [[entry onlineLink] substringFromIndex:entryIDLoc + 1];
    NSString *urlString = [NSString stringWithFormat:@"/api/%@", entryID];
    
    NSURLRequest *request = [STGPacket defaultRequestWithUrl:urlString httpMethod:@"DELETE" fileName:[[entry fileURL] lastPathComponent] mainBodyData:[NSData dataWithContentsOfURL:[entry fileURL]]];
    
    STGPacket *packet = [STGPacket genericPacketWithRequest:request packetType:@"deleteFile" userInfo:[NSMutableDictionary dictionaryWithObject:entry forKey:@"dataCaptureEntry"]];
    
    [packetQueue addEntry:packet];
}

@end
