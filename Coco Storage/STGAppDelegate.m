//
//  STGAppDelegate.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 23.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGAppDelegate.h"

#import <Sparkle/Sparkle.h>

#import "STGDataCaptureManager.h"

#import "STGDataCaptureEntry.h"

#import "STGHotkeyHelper.h"
#import "STGHotkeyHelperEntry.h"

#import "STGSystemHelper.h"
#import "STGFileHelper.h"
#import "STGNetworkHelper.h"

#import "STGOptionsGeneralViewController.h"
#import "STGOptionsShortcutsViewController.h"
#import "STGOptionsQuickUploadViewController.h"
#import "STGOptionsCFSViewController.h"
#import "STGOptionsAboutViewController.h"

#import "MASPreferencesWindowController.h"

#import "STGStatusItemManager.h"

#import "STGPacketQueue.h"
#import "STGPacket.h"
#import "STGPacketCreator.h"

#import "STGAPIConfiguration.h"

#import "STGCFSSyncCheck.h"

#import "STGJSONHelper.h"

STGAppDelegate *sharedAppDelegate;

@interface STGAppDelegate ()

- (void) onUploadComplete:(STGDataCaptureEntry *)entry success:(BOOL)success;

- (NSString *)getApiKey;
- (BOOL)isAPIKeyValid:(BOOL)output;
- (NSString *)getCFSFolder;
- (NSString *)getTempFolder;

- (void)keyMissingSheetDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

- (void)tryAddingStandardShortcut:(NSString *)charsDefaultsKey action:(NSString *)action menuItem:(NSMenuItem *)menuItem;

@end

@implementation STGAppDelegate

#pragma mark - Initializer

- (id)init
{
    self = [super init];
    
    if (self)
    {
        sharedAppDelegate = self;
        
        [self setRecentFilesArray:[[NSMutableArray alloc] init]];
        
        [self setApiV1Alive:YES];
        [self setApiV2Alive:YES];
    }
    
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSMutableDictionary *standardDefaults = [[NSMutableDictionary alloc] init];
    [STGOptionsGeneralViewController registerStandardDefaults:standardDefaults];
    [STGOptionsShortcutsViewController registerStandardDefaults:standardDefaults];
    [STGOptionsQuickUploadViewController registerStandardDefaults:standardDefaults];
    [STGOptionsCFSViewController registerStandardDefaults:standardDefaults];
    [STGOptionsAboutViewController registerStandardDefaults:standardDefaults];
    [STGWelcomeWindowController registerStandardDefaults:standardDefaults];
    [standardDefaults setObject:[NSArray array] forKey:@"recentEntries"];
    [standardDefaults setObject:[NSArray array] forKey:@"uploadQueue"];
    [standardDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"pauseUploads"];
    [standardDefaults setObject:@"0.0" forKey:@"lastVersion"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:standardDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self setPacketUploadV1Queue:[[STGPacketQueue alloc] init]];
    [_packetUploadV1Queue setDelegate:self];
    [self setPacketUploadV2Queue:[[STGPacketQueue alloc] init]];
    [_packetUploadV2Queue setDelegate:self];
    [self setPacketSupportQueue:[[STGPacketQueue alloc] init]];
    [_packetSupportQueue setDelegate:self];
    
    [self setHotkeyHelper:[[STGHotkeyHelper alloc] initWithDelegate:self]];
    
    [[STGAPIConfiguration standardConfiguration] setUploadLink:@"https://api.stor.ag/v1/object?key=%@"];
    [[STGAPIConfiguration standardConfiguration] setDeletionLink:@"https://api.stor.ag/v1/object/%@?key=%@"];
    [[STGAPIConfiguration standardConfiguration] setGetObjectInfoLink:@"https://api.stor.ag/v1/object/%@?key=%@"];

    [[STGAPIConfiguration standardConfiguration] setGetAPIV1StatusLink:@"https://api.stor.ag/v1/status?key=%@"];
    [[STGAPIConfiguration standardConfiguration] setGetAPIV2StatusLink:@"https://api.stor.ag/v2/status?key=%@"];

    [[STGAPIConfiguration standardConfiguration] setCfsBaseLink:@"https://api.stor.ag/v2/cfs%@?key=%@"];

    [self setOptionsGeneralVC:[[STGOptionsGeneralViewController alloc] initWithNibName:@"STGOptionsGeneralViewController" bundle:nil]];
    [self setOptionsShortcutsVC:[[STGOptionsShortcutsViewController alloc] initWithNibName:@"STGOptionsShortcutsViewController" bundle:nil]];
    [_optionsShortcutsVC setDelegate:self];
    [self setOptionsQuickUploadVC:[[STGOptionsQuickUploadViewController alloc] initWithNibName:@"STGOptionsQuickUploadViewController" bundle:nil]];
    [self setOptionsCFSVC:[[STGOptionsCFSViewController alloc] initWithNibName:@"STGOptionsCFSViewController" bundle:nil]];
    [self setOptionsAboutVC:[[STGOptionsAboutViewController alloc] initWithNibName:@"STGOptionsAboutViewController" bundle:nil]];
    
    [self setPrefsController:[[MASPreferencesWindowController alloc] initWithViewControllers:[NSArray arrayWithObjects:_optionsGeneralVC, _optionsQuickUploadVC, _optionsCFSVC, _optionsShortcutsVC, _optionsAboutVC, nil] title:@"Coco Storage Preferences"]];
    
    [self setWelcomeWC:[[STGWelcomeWindowController alloc] initWithWindowNibName:@"STGWelcomeWindowController"]];
    [_welcomeWC setWelcomeWCDelegate:self];
    if (![[[NSUserDefaults standardUserDefaults] stringForKey:@"lastVersion"] isEqualToString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]])
    {
        // Show the update log?
    }
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"showWelcomeWindowOnLaunch"] == 1)
    {
        [self openWelcomeWindow:self];
    }
    
    [self setQuickUploadWC:[[STGQuickUploadWindowController alloc] initWithWindowNibName:@"STGQuickUploadWindowController"]];
    [_quickUploadWC setDelegate:self];
    
    [self setStatusItemManager:[[STGStatusItemManager alloc] init]];
    [_statusItemManager setDelegate:self];
    
    [self setCfsSyncCheck:[[STGCFSSyncCheck alloc] init]];

    [self readFromUserDefaults];

    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
        
    [self setUploadTimer:[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(uploadTimerFired:) userInfo:nil repeats:YES]];
        
    [_statusItemManager updateRecentFiles:_recentFilesArray];
    [_statusItemManager updateUploadQueue:_packetUploadV1Queue currentProgress:0.0];
    [_statusItemManager updatePauseDownloadItem];
    [self updateShortcuts];
  
//    [_packetSupportQueue addEntry:[STGPacketCreator cfsDeleteFilePacket:@"/foo2.png" link:[[STGAPIConfiguration standardConfiguration] cfsBaseLink] key:[self getApiKey]]];
//    [_packetUploadV2Queue addEntry:[STGPacketCreator cfsPostFilePacket:@"/foo9.png" fileURL:[STGFileHelper urlFromStandardPath:[[self getCFSFolder] stringByAppendingPathComponent:@"/foo2/foo2.png"]] link:[[STGAPIConfiguration standardConfiguration] cfsBaseLink] key:[self getApiKey]]];
}

#pragma mark - Properties

- (void)readFromUserDefaults
{
    NSArray *uploadQueueStringArray = [[NSUserDefaults standardUserDefaults] arrayForKey:@"uploadQueue"];
    for (NSString *string in uploadQueueStringArray)
    {
        STGDataCaptureEntry *entry = [STGDataCaptureEntry entryFromString:string];
        
        if(entry)
            [_packetUploadV1Queue addEntry:[STGPacketCreator uploadFilePacket:entry uploadLink:[[STGAPIConfiguration standardConfiguration] uploadLink] key:[self getApiKey] isPublic:YES]];
    }
    [_packetUploadV1Queue setUploadsPaused:[[NSUserDefaults standardUserDefaults] boolForKey:@"pauseUploads"]];
    [_packetUploadV2Queue setUploadsPaused:[[NSUserDefaults standardUserDefaults] boolForKey:@"pauseUploads"]];
    
    NSArray *recentFilesStringArray = [[NSUserDefaults standardUserDefaults] arrayForKey:@"recentEntries"];
    for (NSString *string in recentFilesStringArray)
    {
        STGDataCaptureEntry *entry = [STGDataCaptureEntry entryFromString:string];
        
        if(entry)
            [_recentFilesArray addObject:entry];
    }
    
    [STGSystemHelper setStartOnSystemLaunch:[[NSUserDefaults standardUserDefaults] integerForKey:@"startAtLogin"] == 1];
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"showDockIcon"] == 1)
        [STGSystemHelper showDockTile];
    
    [_sparkleUpdater setAutomaticallyChecksForUpdates:[[NSUserDefaults standardUserDefaults] integerForKey:@"autoUpdate"] == 1];
    
    [_cfsSyncCheck setBasePath:[self getCFSFolder]];
}

- (void)saveProperties
{
    NSMutableArray *uploadQueueStringArray = [[NSMutableArray alloc] init];
    for (STGPacket *entry in [_packetUploadV1Queue uploadQueue])
    {
        if ([[entry packetType] isEqualToString:@"uploadFile"])
            [uploadQueueStringArray addObject:[[[entry userInfo] objectForKey:@"dataCaptureEntry"] storeInfoInString]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:uploadQueueStringArray forKey:@"uploadQueue"];
    
    NSMutableArray *recentFilesStringArray = [[NSMutableArray alloc] initWithCapacity:[_recentFilesArray count]];
    for (STGDataCaptureEntry *entry in _recentFilesArray)
    {
        [recentFilesStringArray addObject:[entry storeInfoInString]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:recentFilesStringArray forKey:@"recentEntries"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"lastVersion"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];    
}

#pragma mark - Timer 

- (void)uploadTimerFired:(NSTimer*)theTimer
{
    [_packetUploadV1Queue update];
    [_packetUploadV2Queue update];
    [_packetSupportQueue update];
    
    if (_ticksAlive % 5 == 0)
    {
        BOOL reachingStorage = [STGNetworkHelper isWebsiteReachable:@"stor.ag"];
        
        if (reachingStorage)
        {
            if ([self isAPIKeyValid:NO])
            {
                [_packetSupportQueue addEntry:[STGPacketCreator apiStatusPacket:[[STGAPIConfiguration standardConfiguration] getAPIV1StatusLink] apiInfo:1 key:[self getApiKey]]];
                [_packetSupportQueue addEntry:[STGPacketCreator apiStatusPacket:[[STGAPIConfiguration standardConfiguration] getAPIV2StatusLink] apiInfo:2 key:[self getApiKey]]];
                
                //                [_packetSupportQueue addEntry:[STGPacketCreator cfsFileListPacket:@"" link:[[STGAPIConfiguration standardConfiguration] cfsBaseLink] recursive:YES key:[self getApiKey]]];
                
//                [_packetSupportQueue addEntry:[STGPacketCreator objectInfoPacket:[[_recentFilesArray objectAtIndex:0] onlineID] link:[[STGAPIConfiguration standardConfiguration] getObjectInfoLink] key:[self getApiKey]]];
            }
        }
        else
        {
            BOOL reachingApple = [STGNetworkHelper isWebsiteReachable:@"www.apple.com"];

            if (!reachingApple)
                [_statusItemManager updateServerStatus:STGServerStatusClientOffline];
            else
                [_statusItemManager updateServerStatus:STGServerStatusServerOffline];
        }
    }
    
    _ticksAlive ++;
}

#pragma mark - Capturing

-(void)captureScreen:(BOOL)fullScreen;
{
    if ([self isAPIKeyValid:YES])
    {
        STGDataCaptureEntry *entry = [STGDataCaptureManager startScreenCapture:fullScreen tempFolder:[self getTempFolder] silent:[[NSUserDefaults standardUserDefaults] integerForKey:@"playScreenshotSound"] == 0];
        
        if(entry)
            [_packetUploadV1Queue addEntry:[STGPacketCreator uploadFilePacket:entry uploadLink:[[STGAPIConfiguration standardConfiguration] uploadLink] key:[self getApiKey] isPublic:YES]];
        
        [_statusItemManager updateUploadQueue:_packetUploadV1Queue currentProgress:0.0];
    }
}

- (void)captureFile
{
    if ([self isAPIKeyValid:YES])
    {
        NSArray *entries = [STGDataCaptureManager startFileCaptureWithTempFolder:[self getTempFolder]];
        
        if(entries)
        {
            for (STGDataCaptureEntry *entry in entries)
                [_packetUploadV1Queue addEntry:[STGPacketCreator uploadFilePacket:entry uploadLink:[[STGAPIConfiguration standardConfiguration] uploadLink] key:[self getApiKey] isPublic:YES]];
        }
        
        [_statusItemManager updateUploadQueue:_packetUploadV1Queue currentProgress:0.0];
    }
}

#pragma mark - Uploading

-(void)uploadEntries:(NSArray *)entries
{
    if (entries && [entries count] > 0)
    {
        for (STGDataCaptureEntry *entry in entries)
        {
            if (entry)
                [_packetUploadV1Queue addEntry:[STGPacketCreator uploadFilePacket:entry uploadLink:[[STGAPIConfiguration standardConfiguration] uploadLink] key:[self getApiKey] isPublic:YES]];
        }
        
        [_statusItemManager updateUploadQueue:_packetUploadV1Queue currentProgress:0.0];
    }    
}

- (void) onUploadComplete:(STGDataCaptureEntry *)entry success:(BOOL)success
{
    if ([entry deleteOnCompletetion] && ((success && [[NSUserDefaults standardUserDefaults] integerForKey:@"keepAllScreenshots"] == 0) || (!success && [[NSUserDefaults standardUserDefaults] integerForKey:@"keepFailedScreenshots"] == 0)))
    {
        NSError *error = nil;
        
        if ([entry fileURL] && [[NSFileManager defaultManager] fileExistsAtPath:[[entry fileURL] path]])
        {
            [[NSFileManager defaultManager] removeItemAtURL:[entry fileURL] error:&error];
            
            if (error)
                NSLog(@"%@", error);
        }
        else
        {
            NSLog(@"Problem: Trying to delete entry without URL!");
        }
    }
}

- (void)startUploadingData:(STGPacketQueue *)queue entry:(STGPacket *)entry
{
    if ([[entry packetType] isEqualToString:@"uploadFile"])
    {
        [_statusItemManager setStatusItemUploadProgress:0.0];
    }
}

- (void)updateUploadProgress:(STGPacketQueue *)queue entry:(STGPacket *)entry sentData:(NSInteger)sentData totalData:(NSInteger)totalData
{
    if ([[entry packetType] isEqualToString:@"uploadFile"])
    {
        [_statusItemManager updateUploadQueue:_packetUploadV1Queue currentProgress:((double)sentData / (double)totalData)];
        [_statusItemManager setStatusItemUploadProgress:((double)sentData / (double)totalData)];
    }
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
    
    if ([[entry packetType] isEqualToString:@"uploadFile"])
    {
        NSDictionary *dictionary = [STGJSONHelper getDictionaryJSONFromData:response];
        
        NSString *uploadID = [dictionary objectForKey:@"id"];
        NSString *link = uploadID ? [NSString stringWithFormat:@"http://stor.ag/e/%@", uploadID] : nil;
        
        if (link)
        {
            [[[entry userInfo] objectForKey:@"dataCaptureEntry"] setOnlineLink:link];
            [_recentFilesArray addObject:[[entry userInfo] objectForKey:@"dataCaptureEntry"]];
            
            while (_recentFilesArray.count > 7)
                [_recentFilesArray removeObjectAtIndex:0];
            
            [_statusItemManager updateRecentFiles:_recentFilesArray];
            
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
            
            [self onUploadComplete:[[entry userInfo] objectForKey:@"dataCaptureEntry"] success:YES];
        }
        else
        {
            [[[_statusItemManager statusItem] menu] cancelTracking];
            NSAlert *alert = [NSAlert alertWithMessageText:@"Coco Storage Upload Error" defaultButton:@"Open Preferences" alternateButton:@"OK" otherButton:nil informativeTextWithFormat:@"Coco Storage could not complete your file upload... Make sure your Storage key is valid, and try again.\nHTTP Status: %@ (%li)", [NSHTTPURLResponse localizedStringForStatusCode:responseCode], responseCode];
            [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(keyMissingSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
            
            NSLog(@"Upload file (error?). Response:\n%@\nStatus: %li (%@)", response, responseCode, [NSHTTPURLResponse localizedStringForStatusCode:responseCode]);
            
            [self onUploadComplete:[[entry userInfo] objectForKey:@"dataCaptureEntry"] success:NO];
        }
        
        [_statusItemManager setStatusItemUploadProgress:0.0];
        [_statusItemManager updateUploadQueue:_packetUploadV1Queue currentProgress:0.0];
    }
    else if ([[entry packetType] isEqualToString:@"deleteFile"])
    {
        NSDictionary *dictionary = [STGJSONHelper getDictionaryJSONFromData:response];
        
        NSString *message = [dictionary objectForKey:@"message"];
        
        if ([message isEqualToString:@"Object deleted."])
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
        
        STGServerStatus status = STGServerStatusUnknown;
        NSString *stringStatus = dictionary ? [dictionary objectForKey:@"status"] : nil;
        
        if ([stringStatus isEqualToString:@"ok"])
        {
            if ([[[entry userInfo] objectForKey:@"apiVersion"] integerValue] == 1)
                [self setApiV1Alive:YES];
            else if ([[[entry userInfo] objectForKey:@"apiVersion"] integerValue] == 2)
                [self setApiV2Alive:YES];
        }
        else
        {
            if ([[[entry userInfo] objectForKey:@"apiVersion"] integerValue] == 1)
                [self setApiV1Alive:NO];
            else if ([[[entry userInfo] objectForKey:@"apiVersion"] integerValue] == 2)
                [self setApiV2Alive:NO];
        }
        
        if (_apiV1Alive && _apiV2Alive)
            status = STGServerStatusOnline;
        else if (responseCode == 401)
            status = STGServerStatusInvalidKey;
        else
        {
            BOOL reachingStorage = [STGNetworkHelper isWebsiteReachable:@"stor.ag"];
            BOOL reachingApple = [STGNetworkHelper isWebsiteReachable:@"www.apple.com"];
            
            if (!reachingApple && !reachingStorage)
                status = STGServerStatusClientOffline;
            else if (!reachingStorage)
                status = STGServerStatusServerOffline;
            else if (!_apiV1Alive && !_apiV2Alive)
                status = STGServerStatusServerBusy;
            else if (!_apiV1Alive)
                status = STGServerStatusServerV1Busy;
            else if (!_apiV2Alive)
                status = STGServerStatusServerV2Busy;
            else status = STGServerStatusUnknown;
        }
        
        [_statusItemManager updateServerStatus:status];
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
        NSLog(@"Unknown packet entry. Response:\n%@\nStatus: %li (%@)", response, responseCode, [NSHTTPURLResponse localizedStringForStatusCode:responseCode]);
    }
}

- (void)cancelAllUploads
{
    [_packetUploadV1Queue cancelAllEntries];
        
    [_statusItemManager setStatusItemUploadProgress:0.0];
    [_statusItemManager updateUploadQueue:_packetUploadV1Queue currentProgress:0.0];
}

-(void)deleteRecentFile:(STGDataCaptureEntry *)entry
{
    [_packetSupportQueue addEntry:[STGPacketCreator deleteFilePacket:entry uploadLink:[[STGAPIConfiguration standardConfiguration] deletionLink] key:[self getApiKey]]];
    
    [_recentFilesArray removeObject:entry];
    [_statusItemManager updateRecentFiles:_recentFilesArray];
}

-(void)cancelQueueFile:(int)index
{
    [_packetUploadV1Queue cancelEntryAtIndex:index];
    
    if (index == 0)
        [_statusItemManager setStatusItemUploadProgress:0.0];
    [_statusItemManager updateUploadQueue:_packetUploadV1Queue currentProgress:0.0];
}

-(void)togglePauseUploads
{
    BOOL pause = ![[NSUserDefaults standardUserDefaults] boolForKey:@"pauseUploads"];
    
    [[NSUserDefaults standardUserDefaults] setBool:pause forKey:@"pauseUploads"];
    
    [_packetUploadV1Queue setUploadsPaused:pause];
    [_packetUploadV2Queue setUploadsPaused:pause];
    
    [_statusItemManager setStatusItemUploadProgress:0.0];
    [_statusItemManager updatePauseDownloadItem];
}

#pragma mark - Windows

- (void)openPreferences
{
    [_prefsController selectControllerAtIndex:0];
    [_prefsController showWindow:self];
    
    [NSApp  activateIgnoringOtherApps:YES];
}

- (IBAction)openPreferences:(id)sender
{
    [self openPreferences];
}

- (IBAction)openWelcomeWindow:(id)sender
{
    [_welcomeWC showWindow:self];
    
    [NSApp  activateIgnoringOtherApps:YES];
}

-(void)openQuickUploadWindow
{
    [_quickUploadWC showWindow:self];
    
    [NSApp  activateIgnoringOtherApps:YES];
}

#pragma mark - Shortcuts

- (void)updateShortcuts
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_hotkeyHelper removeAllShortcutEntries];
    
    [_hotkeyHelper addShortcutEntry:[STGHotkeyHelperEntry entryWithAllStatesAndUserInfo:[NSDictionary dictionaryWithObject:@"hotkeyChange" forKey:@"action"]]];
    
    [self tryAddingStandardShortcut:@"hotkeyCaptureArea" action:@"captureArea" menuItem:[_statusItemManager captureAreaMenuItem]];
    [self tryAddingStandardShortcut:@"hotkeyCaptureFullScreen" action:@"captureFullScreen" menuItem:[_statusItemManager captureFullScreenMenuItem]];
    [self tryAddingStandardShortcut:@"hotkeyCaptureFile" action:@"captureFile" menuItem:[_statusItemManager captureFileMenuItem]];
    [self tryAddingStandardShortcut:@"hotkeyQuickCapture" action:@"showQuickCapture" menuItem:[_statusItemManager quickCaptureMenuItem]];
}

- (void)tryAddingStandardShortcut:(NSString *)charsDefaultsKey action:(NSString *)action menuItem:(NSMenuItem *)menuItem
{
    NSString *hotkey = [[NSUserDefaults standardUserDefaults] stringForKey:charsDefaultsKey];

    if ([hotkey length] > 0)
    {
        NSInteger modifiers = [[NSUserDefaults standardUserDefaults] integerForKey:[charsDefaultsKey stringByAppendingString:@"Modifiers"]];
        
        [_hotkeyHelper addShortcutEntry:[STGHotkeyHelperEntry entryWithCharacter:hotkey modifiers:modifiers userInfo:[NSDictionary dictionaryWithObject:action forKey:@"action"]]];
        
        if (menuItem != nil)
        {
            [menuItem setKeyEquivalent:hotkey];
            [menuItem setKeyEquivalentModifierMask:modifiers];
        }        
    }
}

- (NSEvent *)keyPressed:(NSEvent *)event entry:(STGHotkeyHelperEntry *)entry userInfo:(NSDictionary *)userInfo
{
    if ([[userInfo objectForKey:@"action"] isEqualToString:@"hotkeyChange"])
    {
        NSEvent *hotkeyReturnEvent = [_optionsShortcutsVC keyPressed:event];
        
        if (hotkeyReturnEvent != event)
        {
            [self performSelectorOnMainThread:@selector(updateShortcuts) withObject:nil waitUntilDone:NO];
        }
        
        event = hotkeyReturnEvent;
    }
    if ([[userInfo objectForKey:@"action"] isEqualToString:@"captureFullScreen"])
    {
        [self captureScreen:YES];
        
        return nil;
    }
    if ([[userInfo objectForKey:@"action"] isEqualToString:@"captureArea"])
    {
        [self captureScreen:NO];
        
        return nil;
    }
    if ([[userInfo objectForKey:@"action"] isEqualToString:@"captureFile"])
    {
        [self captureFile];
        
        return nil;
    }
    if ([[userInfo objectForKey:@"action"] isEqualToString:@"showQuickCapture"])
    {
        if (![[_quickUploadWC window] isVisible])
            [self openQuickUploadWindow];
        else
            [[_quickUploadWC window] close];
        
        return nil;
    }
    
    return event;
}

#pragma mark NSApp

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [self saveProperties];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    if ([[notification userInfo] objectForKey:@"uploadLink"])
    {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[notification userInfo] objectForKey:@"uploadLink"]]];
    }
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
    if ([self isAPIKeyValid:YES])
    {
        NSURL *url = [STGFileHelper urlFromStandardPath:filename];
        
        if (url && [url isFileURL] && [[NSFileManager defaultManager] fileExistsAtPath:[url path]])
        {
            STGDataCaptureEntry *entry = [STGDataCaptureManager captureFile:url tempFolder:[self getTempFolder]];
            
            [_packetUploadV1Queue addEntry:[STGPacketCreator uploadFilePacket:entry uploadLink:[[STGAPIConfiguration standardConfiguration] uploadLink] key:[self getApiKey] isPublic:YES]];
        }
        
        [_statusItemManager updateUploadQueue:_packetUploadV1Queue currentProgress:0.0];
        
        return YES;
    }
    
    return NO;
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
    if ([self isAPIKeyValid:YES])
    {
        for (NSString *filename in filenames)
        {
            NSURL *url = [STGFileHelper urlFromStandardPath:filename];
            
            if (url && [url isFileURL] && [[NSFileManager defaultManager] fileExistsAtPath:[url path]])
            {
                STGDataCaptureEntry *entry = [STGDataCaptureManager captureFile:url tempFolder:[self getTempFolder]];
                
                [_packetUploadV1Queue addEntry:[STGPacketCreator uploadFilePacket:entry uploadLink:[[STGAPIConfiguration standardConfiguration] uploadLink] key:[self getApiKey] isPublic:YES]];
            }
        }
        
        [_statusItemManager updateUploadQueue:_packetUploadV1Queue currentProgress:0.0];
    }
}

#pragma mark - Getters

- (BOOL)isAPIKeyValid:(BOOL)output
{
    NSString *key = [self getApiKey];
    
    int error = -1;
    
    if (!key || [key length] == 0)
        error = 1;
    else if ([key length] < 40)
        error = 2;
    
    if (error > 0 && output)
    {
        if (error == 1)
        {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Coco Storage Upload Error" defaultButton:@"Open Preferences" alternateButton:@"OK" otherButton:nil informativeTextWithFormat:@"You have entered no Storage key! This is required as identification for stor.ag. Please move to the preferences to enter / create one."];
            [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(keyMissingSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
        }
        else if (error == 2)
        {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Coco Storage Upload Error" defaultButton:@"Open Preferences" alternateButton:@"OK" otherButton:nil informativeTextWithFormat:@"Your storage key is too short [invalid]. This is required as identification for stor.ag. Please move to the preferences to enter / create one."];
            [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(keyMissingSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
        }
        
        return NO;
    }
    else
        return YES;
}

- (void)keyMissingSheetDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == 1)
        [self performSelectorOnMainThread:@selector(openPreferences:) withObject:self waitUntilDone:NO];
}

- (NSString *)getApiKey
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"mainStorageKey"];
}

- (NSString *)getCFSFolder
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"cfsFolder"];
}

- (NSString *)getTempFolder
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"];
}

@end
