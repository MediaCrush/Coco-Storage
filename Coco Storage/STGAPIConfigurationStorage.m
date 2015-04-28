//
//  STGAPIConfigurationStorage.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 08.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGAPIConfigurationStorage.h"

#import "STGNetworkHelper.h"
#import "STGPacket.h"
#import "STGJSONHelper.h"
#import "STGPacketQueue.h"

#import "STGDataCaptureEntry.h"
#import "STGUploadedEntryFile.h"

#import "STGWelcomeWindowControllerStorage.h"

STGAPIConfigurationStorage *standardConfiguration;

@implementation STGAPIConfigurationStorage

@synthesize delegate = _delegate, networkDelegate = _networkDelegate;

+ (STGAPIConfigurationStorage *)standardConfiguration
{
    if (!standardConfiguration)
    {
        standardConfiguration = [[STGAPIConfigurationStorage alloc] init];
        
//        [standardConfiguration setGetObjectInfoLink:@"https://api.stor.ag/v1/object/%@?key=%@"];
//        [standardConfiguration setCfsBaseLink:@"https://api.stor.ag/v2/cfs%@?key=%@"];
    }
    
    return standardConfiguration;
}

- (void)registerConfiguration:(NSString *)regID
{
    [STGAPIConfiguration registerConfiguration:self withID:regID];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setWelcomeWC:[[STGWelcomeWindowControllerStorage alloc] initWithWindowNibName:@"STGWelcomeWindowController"]];
        [_welcomeWC setWelcomeWCDelegate:self];
    }
    return self;
}

- (NSString *)apiHostName
{
    return @"stor.ag";
}

- (BOOL)hasAPIKeys
{
    return YES;
}

- (BOOL)hasCFS
{
    return YES;
}

- (BOOL)hasAlbums
{
    return NO;
}

- (NSString *)cfsLinkTitle
{
    return @"Open CFS Folder";
}

- (void)openCFSLink
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:[[NSUserDefaults standardUserDefaults] stringForKey:@"cfsFolder"]]];
}

- (NSString *)accountLinkTitle
{
    return @"Storage Account";
}

- (void)openAccountLink
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://getstorage.net/panel/user"]];
}

- (NSString *)fileListLinkTitle
{
    return @"My Files...";
}

- (NSSet *)supportedUploadTypes
{
    return [NSSet setWithObjects:
            [NSNumber numberWithUnsignedInteger:STGUploadActionUploadFile],
            [NSNumber numberWithUnsignedInteger:STGUploadActionUploadImage],
            [NSNumber numberWithUnsignedInteger:STGUploadActionUploadText],
            [NSNumber numberWithUnsignedInteger:STGUploadActionUploadRtfText],
            [NSNumber numberWithUnsignedInteger:STGUploadActionUploadColor],
            [NSNumber numberWithUnsignedInteger:STGUploadActionUploadZip],
            [NSNumber numberWithUnsignedInteger:STGUploadActionUploadDirectoryZip],
            [NSNumber numberWithUnsignedInteger:STGUploadActionRedirectLink],
            nil];
}

- (BOOL)hasWelcomeWindow
{
    return YES;
}

- (void)openWelcomeWindow
{
    [_welcomeWC showWindow:self];
}

- (NSString *)objectIDFromString:(NSString *)string
{
    NSRange linkRange = [string rangeOfString:@"stor.ag/e/"];
    if (linkRange.location != NSNotFound)
    {
        NSString *startCut = [string substringFromIndex:linkRange.location + linkRange.length];
        NSRange nextSlash = [startCut rangeOfString:@"/"];
        return nextSlash.location != NSNotFound ? [startCut substringToIndex:nextSlash.location] : startCut;
    }
    
    return nil;
}

- (void)openFileListLink
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://getstorage.net/panel/object"]];
}

- (BOOL)canReachServer
{
    return [STGNetworkHelper isWebsiteReachable:@"stor.ag"];
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
        
        NSString *uploadID = [dictionary objectForKey:@"id"];
        
        if (uploadID)
        {
            NSString *link = [NSString stringWithFormat:@"http://stor.ag/e/%@", uploadID];
            STGUploadedEntry *uploadedEntry = [[STGUploadedEntryFile alloc] initWithAPIConfigurationID:[STGAPIConfiguration idOfConfiguration:self] onlineID:uploadID onlineLink:[NSURL URLWithString:link] dataCaptureEntry:dataCaptureEntry];
            
            if ([_networkDelegate respondsToSelector:@selector(didUploadEntry:success:)])
                [_networkDelegate didUploadEntry:uploadedEntry success:YES];

            if ([_networkDelegate respondsToSelector:@selector(didUploadDataCaptureEntry:dataCaptureEntry:success:)])
                [_networkDelegate didUploadDataCaptureEntry:uploadedEntry dataCaptureEntry:dataCaptureEntry success:YES];
        }
        else
        {
            STGUploadedEntry *uploadedEntry = [[STGUploadedEntryFile alloc] initWithAPIConfigurationID:[STGAPIConfiguration idOfConfiguration:self] onlineID:nil onlineLink:nil dataCaptureEntry:dataCaptureEntry];

            NSLog(@"Upload file (error?). Response:\n%@\nStatus: %li (%@)", response, responseCode, [NSHTTPURLResponse localizedStringForStatusCode:responseCode]);

            if ([_networkDelegate respondsToSelector:@selector(didUploadEntry:)])
                [_networkDelegate didUploadEntry:uploadedEntry success:NO];

            if ([_networkDelegate respondsToSelector:@selector(didUploadDataCaptureEntry:dataCaptureEntry:success:)])
                [_networkDelegate didUploadDataCaptureEntry:uploadedEntry dataCaptureEntry:dataCaptureEntry success:NO];
        }
    }
    else if ([[entry packetType] isEqualToString:@"deleteFile"])
    {
        NSDictionary *dictionary = [STGJSONHelper getDictionaryJSONFromData:response];
        
        NSString *message = [dictionary objectForKey:@"message"];
        
        if ([message isEqualToString:@"Object deleted."])
        {
            STGUploadedEntry *uploadedEntry = [[entry userInfo] objectForKey:@"uploadedEntry"];
            if ([_networkDelegate respondsToSelector:@selector(didDeleteEntry:)])
                [_networkDelegate didDeleteEntry:uploadedEntry];
        }
        else
        {
            /*            [[[_statusItemManager statusItem] menu] cancelTracking];
             NSAlert *alert = [NSAlert alertWithMessageText:@"Coco Storage Upload Error" defaultButton:@"Open Preferences" alternateButton:@"OK" otherButton:nil informativeTextWithFormat:@"Coco Storage could not complete your file deletion... Make sure your Storage key is valid, and try again.\nHTTP Status: %@ (%li)", [NSHTTPURLResponse localizedStringForStatusCode:responseCode], responseCode];
             [alert beginSheetModalForWindow:nil modalDelegate:_networkDelegate didEndSelector:@selector(keyMissingSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];*/
            
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
    else if ([[entry packetType] isEqualToString:@"cfs:getFileList"])
    {
        NSArray *filesRoot = [STGJSONHelper getArrayJSONFromData:response];
        
        NSLog(@"Files: %@", filesRoot);
    }
    else if ([[entry packetType] isEqualToString:@"cfs:deleteFile"])
    {
        if (responseCode != 200)
            NSLog(@"File deletion failed: %@. Response:\n%@\nStatus: %li (%@)", [[entry urlRequest] URL], response, responseCode, [NSHTTPURLResponse localizedStringForStatusCode:responseCode]);
    }
    else
    {
        NSLog(@"Unknown packet entry. Entry: \"%@\"\nResponse:\n%@\nStatus: %li (%@)", [entry packetType], response, responseCode, [NSHTTPURLResponse localizedStringForStatusCode:responseCode]);
    }
}

- (void)cancelPacketUpload:(STGPacket *)entry
{
//    if ([[entry packetType] isEqualToString:@"uploadFile"])
//    {
//        if ([_networkDelegate respondsToSelector:@selector(didUploadDataCaptureEntry:)])
//        {
//            [_networkDelegate didUploadDataCaptureEntry:[[entry userInfo] objectForKey:@"dataCaptureEntry"] success:NO];
//        }
//    }
}

- (void)sendStatusPacket:(STGPacketQueue *)packetQueue apiKey:(NSString *)apiKey
{
    NSURLRequest *request = [STGPacket defaultRequestWithUrl:[NSString stringWithFormat:@"https://api.stor.ag/v1/status?key=%@", apiKey] httpMethod:@"GET" contentParts:nil];
    
    STGPacket *packet = [STGPacket genericPacketWithRequest:request packetType:@"getAPIStatus" userInfo:[NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:@"apiVersion"]];

    [packetQueue addEntry:packet];
    
//    [_packetSupportQueue addEntry:[STGPacketCreator apiStatusPacket:@"https://api.stor.ag/v2/status?key=%@" apiInfo:2 key:[self getApiKey]]];
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
    
    NSURLRequest *request = [STGPacket defaultRequestWithUrl:[NSString stringWithFormat:@"https://api.stor.ag/v1/object?key=%@", apiKey] httpMethod:@"POST" contentParts:requestParts];
    
    STGPacket *packet = [STGPacket genericPacketWithRequest:request packetType:@"uploadFile" userInfo:[NSMutableDictionary dictionaryWithObject:entry forKey:@"dataCaptureEntry"]];
    
    [packetQueue addEntry:packet];
}

- (void)sendFileDeletePacket:(STGPacketQueue *)packetQueue apiKey:(NSString *)apiKey entry:(STGUploadedEntry *)entry
{
    NSString *entryID = [entry onlineID];
    NSString *urlString = [NSString stringWithFormat:@"https://api.stor.ag/v1/object/%@?key=%@", entryID, apiKey];
    
    NSURLRequest *request = [STGPacket defaultRequestWithUrl:urlString httpMethod:@"DELETE" fileName:[entry onlineID] mainBodyData:[NSData data]];
    
    STGPacket *packet = [STGPacket genericPacketWithRequest:request packetType:@"deleteFile" userInfo:[NSMutableDictionary dictionaryWithObject:entry forKey:@"uploadedEntry"]];

    [packetQueue addEntry:packet];
}

//+ (STGPacket *)objectInfoPacket:(NSString *)objectID link:(NSString *)link key:(NSString *)key
//{
//    NSURLRequest *request = [STGPacket defaultRequestWithUrl:[NSString stringWithFormat:link, objectID, key] httpMethod:@"GET" contentParts:nil];
//    
//    STGPacket *packet = [STGPacket genericPacketWithRequest:request packetType:@"getObjectInfo" userInfo:[NSMutableDictionary dictionary]];
//    
//    return packet;
//}
//
//+ (STGPacket *)cfsGenericPacket:(NSString *)httpMethod path:(NSString *)filePath link:(NSString *)link key:(NSString *)key packetType:(NSString *)packetType
//{
//    NSURLRequest *request = [STGPacket defaultRequestWithUrl:[NSString stringWithFormat:link, filePath, key] httpMethod:httpMethod contentParts:nil];
//    
//    STGPacket *packet = [STGPacket genericPacketWithRequest:request packetType:packetType userInfo:[NSMutableDictionary dictionaryWithObject:filePath forKey:@"filePath"]];
//    
//    return packet;
//}
//
//+ (STGPacket *)cfsFileListPacket:(NSString *)filePath link:(NSString *)link recursive:(BOOL)recursive key:(NSString *)key
//{
//    NSURLRequest *request = [STGPacket defaultRequestWithUrl:[NSString stringWithFormat:link, filePath, key] httpMethod:@"GET" contentParts:nil];
//    
//    STGPacket *packet = [STGPacket genericPacketWithRequest:request packetType:@"cfs:getFileList" userInfo:[NSMutableDictionary dictionaryWithObject:filePath forKey:@"filePath"]];
//    
//    return packet;
//}
//
//+ (STGPacket *)cfsFileInfoPacket:(NSString *)filePath link:(NSString *)link key:(NSString *)key
//{
//    return [self cfsGenericPacket:@"HEAD" path:filePath link:link key:key packetType:@"cfs:getFileInfo"];
//}
//
//+ (STGPacket *)cfsPostFilePacket:(NSString *)filePath fileURL:(NSURL *)fileURL link:(NSString *)link key:(NSString *)key
//{
//    NSURL *innerURL = [NSURL URLWithString:filePath];
//    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:@"file", @"name", [innerURL lastPathComponent], @"filename", [[innerURL URLByDeletingLastPathComponent] path], @"folder", nil];
//    
//    NSData *contentPart = [STGPacket contentPartObjectsForKeys:dict content:[NSData dataWithContentsOfURL:fileURL]];
//    
//    NSMutableURLRequest *request = [STGPacket defaultRequestWithUrl:[NSString stringWithFormat:link, @"", key] httpMethod:@"POST" contentParts:[NSArray arrayWithObject:contentPart]];
//    
//    STGPacket *packet = [STGPacket genericPacketWithRequest:request packetType:@"cfs:postFile" userInfo:[NSMutableDictionary dictionaryWithObject:filePath forKey:@"filePath"]];
//    
//    return packet;
//}
//
//+ (STGPacket *)cfsUpdateFilePacket:(NSString *)filePath fileURL:(NSURL *)fileURL link:(NSString *)link key:(NSString *)key
//{
//    NSURLRequest *request = [STGPacket defaultRequestWithUrl:[NSString stringWithFormat:link, filePath, key] httpMethod:@"PUT" fileName:nil mainBodyData:[NSData dataWithContentsOfURL:fileURL]];
//    
//    STGPacket *packet = [STGPacket genericPacketWithRequest:request packetType:@"cfs:updateFile" userInfo:[NSMutableDictionary dictionaryWithObject:filePath forKey:@"filePath"]];
//    
//    return packet;
//}
//
//+ (STGPacket *)cfsDeleteFilePacket:(NSString *)filePath link:(NSString *)link key:(NSString *)key
//{
//    return [self cfsGenericPacket:@"DELETE" path:filePath link:link key:key packetType:@"cfs:deleteFile"];
//}

#pragma mark Welcome Window Delegate

- (void)openPreferences
{
    if ([_delegate respondsToSelector:@selector(openPreferences)])
        [_delegate openPreferences];
}

@end
