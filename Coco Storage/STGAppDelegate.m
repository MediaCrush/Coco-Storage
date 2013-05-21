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

STGAppDelegate *sharedAppDelegate;

@interface STGAppDelegate ()

- (void) onUploadComplete:(STGDataCaptureEntry *)entry success:(BOOL)success;

- (BOOL)checkStorageKeyValid;

- (NSString *)getApiKey;

- (NSString *)getCFSFolder;

@end

@implementation STGAppDelegate

@synthesize sparkleUpdater;

@synthesize uploadTimer = _uploadTimer;
@synthesize ticksAlive = _ticksAlive;

@synthesize apiV1Alive = _apiV1Alive;
@synthesize apiV2Alive = _apiV2Alive;

@synthesize prefsController = _prefsController;
@synthesize welcomeWC = _welcomeWC;

@synthesize packetUploadV1Queue = _packetUploadV1Queue;
@synthesize packetUploadV2Queue = _packetUploadV2Queue;
@synthesize packetSupportQueue = _packetSupportQueue;

@synthesize cfsSyncCheck = _cfsSyncCheck;

@synthesize recentFilesArray = _recentFilesArray;

@synthesize hotkeyHelper = _hotkeyHelper;

@synthesize optionsGeneralVC = _optionsGeneralVC;
@synthesize optionsShortcutsVC = _optionsShortcutsVC;
@synthesize optionsQuickUploadVC = _optionsQuickUploadVC;
@synthesize optionsCFSVC = _optionsCFSVC;
@synthesize optionsAboutVC = _optionsAboutVC;

@synthesize statusItemManager = _statusItemManager;

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
    
    [[STGAPIConfiguration standardConfiguration] setUploadLink:@"http://api.stor.ag/v1/object?key=%@"];
    [[STGAPIConfiguration standardConfiguration] setDeletionLink:@"http://api.stor.ag/v1/object/%@?key=%@"];
    [[STGAPIConfiguration standardConfiguration] setGetObjectInfoLink:@"http://api.stor.ag/v1/object/%@?key=%@"];

    [[STGAPIConfiguration standardConfiguration] setGetAPIV1StatusLink:@"http://api.stor.ag/v1/status?key=%@"];
    [[STGAPIConfiguration standardConfiguration] setGetAPIV2StatusLink:@"http://api.stor.ag/v2/status?key=%@"];

    [[STGAPIConfiguration standardConfiguration] setCfsBaseLink:@"api.stor.ag/v2/cfs%@?key=%@"];

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
        
    }
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"showWelcomeWindowOnLaunch"] == 1)
    {
        [self openWelcomeWindow:self];
    }
    
    [self setStatusItemManager:[[STGStatusItemManager alloc] init]];
    [_statusItemManager setDelegate:self];
    
    [self readFromUserDefaults];

    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
        
    [self setUploadTimer:[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(uploadTimerFired:) userInfo:nil repeats:YES]];
        
    [_statusItemManager updateRecentFiles:_recentFilesArray];
    [_statusItemManager updateUploadQueue:_packetUploadV1Queue currentProgress:0.0];
    [_statusItemManager updatePauseDownloadItem];
    [self updateShortcuts];    
}

- (void)readFromUserDefaults
{
    NSArray *uploadQueueStringArray = [[NSUserDefaults standardUserDefaults] arrayForKey:@"uploadQueue"];
    for (NSString *string in uploadQueueStringArray)
    {
        STGDataCaptureEntry *entry = [STGDataCaptureEntry entryFromString:string];
        
        if(entry)
            [_packetUploadV1Queue addEntry:[STGPacketCreator uploadFilePacket:entry uploadLink:[[STGAPIConfiguration standardConfiguration] uploadLink] key:[self getApiKey]]];
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
    
    [sparkleUpdater setAutomaticallyChecksForUpdates:[[NSUserDefaults standardUserDefaults] integerForKey:@"autoUpdate"] == 1];
    
    [self setCfsSyncCheck:[[STGCFSSyncCheck alloc] init]];
    [_cfsSyncCheck readFromFolder:[STGFileHelper getApplicationSupportDirectory]];
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
    
    [_cfsSyncCheck saveToFolder:[STGFileHelper getApplicationSupportDirectory]];
}

-(void)captureScreen:(BOOL)fullScreen;
{
    if ([self checkStorageKeyValid])
    {
        STGDataCaptureEntry *entry = [STGDataCaptureManager startScreenCapture:fullScreen tempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"] silent:[[NSUserDefaults standardUserDefaults] integerForKey:@"playScreenshotSound"] == 0];
        
        if(entry)
            [_packetUploadV1Queue addEntry:[STGPacketCreator uploadFilePacket:entry uploadLink:[[STGAPIConfiguration standardConfiguration] uploadLink] key:[self getApiKey]]];
        
        
        [_statusItemManager updateUploadQueue:_packetUploadV1Queue currentProgress:0.0];
    }
}

- (void)captureFile
{
    if ([self checkStorageKeyValid])
    {
        NSArray *entries = [STGDataCaptureManager startFileCaptureWithTempFolder:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]];
        
        if(entries)
        {
            for (STGDataCaptureEntry *entry in entries)
                [_packetUploadV1Queue addEntry:[STGPacketCreator uploadFilePacket:entry uploadLink:[[STGAPIConfiguration standardConfiguration] uploadLink] key:[self getApiKey]]];
        }
        
        [_statusItemManager updateUploadQueue:_packetUploadV1Queue currentProgress:0.0];
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

- (void)uploadTimerFired:(NSTimer*)theTimer
{
//    [_packetUploadV1Queue update];
//    [_packetUploadV2Queue update];
    [_packetSupportQueue update];
    
    if (_ticksAlive % 15 == 0)
    {
        BOOL reachingStorage = [STGNetworkHelper isWebsiteReachable:@"stor.ag"];
        BOOL reachingApple = [STGNetworkHelper isWebsiteReachable:@"www.apple.com"];
        
        if (!reachingApple && !reachingStorage)
            [_statusItemManager updateServerStatus:STGServerStatusClientOffline];
        else if (!reachingStorage)
            [_statusItemManager updateServerStatus:STGServerStatusServerOffline];
        else
        {
            [_packetSupportQueue addEntry:[STGPacketCreator apiStatusPacket:[[STGAPIConfiguration standardConfiguration] getAPIV1StatusLink] apiInfo:1 key:[self getApiKey]]];
            [_packetSupportQueue addEntry:[STGPacketCreator apiStatusPacket:[[STGAPIConfiguration standardConfiguration] getAPIV2StatusLink] apiInfo:2 key:[self getApiKey]]];
//            [_packetSupportQueue addEntry:[[STGPacketGetFileList alloc] initWithFilePath:@"" link:[[STGAPIConfiguration standardConfiguration] getFileListLink] key:[self getApiKey]]];
            
/*            if ([_recentFilesArray count] > 0)
            {
                NSString *link = [[_recentFilesArray objectAtIndex:0] onlineLink];
                NSRange range = [link rangeOfString:@"stor.ag/e/"];
                
                if (range.location != NSNotFound)
                {
                    [_packetQueue addEntry:[[STGPacketGetObjectInfo alloc] initWithObjectID:[link substringFromIndex:range.location + range.length] link:_getObjectInfoLink key:[self getApiKey]]];
                }
            }*/
        }
    }
    
    NSArray *changedFiles = [_cfsSyncCheck getModifiedFiles:[self getCFSFolder]];
    
    for (NSString *path in changedFiles)
    {
        [_cfsSyncCheck updateModificationDate:path];
        
        NSLog(@"Upload file: %@", path);
        
//        [_statusItemManager setIsSyncing:YES];
    }
        
    _ticksAlive ++;
}

- (void)updateShortcuts
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_hotkeyHelper removeAllShortcutEntries];
    
    [_hotkeyHelper addShortcutEntry:[STGHotkeyHelperEntry entryWithAllStatesAndUserInfo:[NSDictionary dictionaryWithObject:@"hotkeyChange" forKey:@"action"]]];
    
    [_hotkeyHelper addShortcutEntry:[STGHotkeyHelperEntry entryWithCharacter:[[NSUserDefaults standardUserDefaults] stringForKey:@"hotkeyCaptureArea"] modifiers:[[NSUserDefaults standardUserDefaults] integerForKey:@"hotkeyCaptureAreaModifiers"] userInfo:[NSDictionary dictionaryWithObject:@"captureArea" forKey:@"action"]]];
    [[_statusItemManager captureAreaMenuItem] setKeyEquivalent:[[NSUserDefaults standardUserDefaults] stringForKey:@"hotkeyCaptureArea"]];
    [[_statusItemManager captureAreaMenuItem] setKeyEquivalentModifierMask:[[NSUserDefaults standardUserDefaults] integerForKey:@"hotkeyCaptureAreaModifiers"]];
    
    [_hotkeyHelper addShortcutEntry:[STGHotkeyHelperEntry entryWithCharacter:[[NSUserDefaults standardUserDefaults] stringForKey:@"hotkeyCaptureFullScreen"] modifiers:[[NSUserDefaults standardUserDefaults] integerForKey:@"hotkeyCaptureFullScreenModifiers"] userInfo:[NSDictionary dictionaryWithObject:@"captureFullScreen" forKey:@"action"]]];
    [[_statusItemManager captureFullScreenMenuItem] setKeyEquivalent:[[NSUserDefaults standardUserDefaults] stringForKey:@"hotkeyCaptureFullScreen"]];
    [[_statusItemManager captureFullScreenMenuItem] setKeyEquivalentModifierMask:[[NSUserDefaults standardUserDefaults] integerForKey:@"hotkeyCaptureFullScreenModifiers"]];

    [_hotkeyHelper addShortcutEntry:[STGHotkeyHelperEntry entryWithCharacter:[[NSUserDefaults standardUserDefaults] stringForKey:@"hotkeyCaptureFile"] modifiers:[[NSUserDefaults standardUserDefaults] integerForKey:@"hotkeyCaptureFileModifiers"] userInfo:[NSDictionary dictionaryWithObject:@"captureFile" forKey:@"action"]]];
    [[_statusItemManager captureFileMenuItem] setKeyEquivalent:[[NSUserDefaults standardUserDefaults] stringForKey:@"hotkeyCaptureFile"]];
    [[_statusItemManager captureFileMenuItem] setKeyEquivalentModifierMask:[[NSUserDefaults standardUserDefaults] integerForKey:@"hotkeyCaptureFileModifiers"]];
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

- (BOOL)checkStorageKeyValid
{
    NSString *key = [self getApiKey];
    
    int error = -1;
    
    if (!key || [key length] == 0)
        error = 1;
    else if ([key length] < 40)
        error = 2;
    
    if (error > 0)
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

- (NSString *)getApiKey
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"storageKey"];
}

- (NSString *)getCFSFolder
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"cfsFolder"];
}

- (NSEvent *)keyPressed:(NSEvent *)event entry:(STGHotkeyHelperEntry *)entry userInfo:(NSDictionary *)userInfo
{
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
    if ([[userInfo objectForKey:@"action"] isEqualToString:@"hotkeyChange"])
    {
        NSEvent *hotkeyReturnEvent = [_optionsShortcutsVC keyPressed:event];
        
        if (hotkeyReturnEvent != event)
        {
            [self performSelectorOnMainThread:@selector(updateShortcuts) withObject:nil waitUntilDone:NO];
        }
        
        event = hotkeyReturnEvent;
    }
    
    return event;
}

- (void)keyMissingSheetDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == 1)
        [self performSelectorOnMainThread:@selector(openPreferences:) withObject:self waitUntilDone:NO];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [self saveProperties];
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

- (void)finishUploadingData:(STGPacketQueue *)queue entry:(STGPacket *)entry fullResponse:(NSString *)response urlResponse:(NSURLResponse *)urlResponse
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
        
        if (outputHeaders || debugOutput)
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
        NSString *uploadID = [STGPacket getValueFromJSON:response key:@"id"];
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
                [notification setSoundName:[[NSUserDefaults standardUserDefaults] stringForKey:@"completionSound"]];
                [notification setUserInfo:[NSDictionary dictionaryWithObject:link forKey:@"uploadLink"]];
                
                if ([[NSUserDefaults standardUserDefaults] integerForKey:@"playSoundOnCompletion"])
                {
                    NSSound *sound = [NSSound soundNamed:NSUserNotificationDefaultSoundName];
                    [sound play];
                }
                
                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
            }
            
            if ([[NSUserDefaults standardUserDefaults] integerForKey:@"linkCopyToPasteboard"] == 1)
            {
                [[NSPasteboard generalPasteboard] clearContents];
                
                [[NSPasteboard generalPasteboard] setData:[link dataUsingEncoding:NSUTF8StringEncoding] forType:NSPasteboardTypeString];
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
        NSString *message = [STGPacket getValueFromJSON:response key:@"message"];        

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
        STGServerStatus status = STGServerStatusUnknown;
        NSString *stringStatus = [STGPacket getValueFromJSON:response key:@"status"];
        
        BOOL reachingStorage = [STGNetworkHelper isWebsiteReachable:@"stor.ag"];
        BOOL reachingApple = [STGNetworkHelper isWebsiteReachable:@"www.apple.com"];
        
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
        else if (!reachingApple && !reachingStorage)
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

        [_statusItemManager updateServerStatus:status];
    }
    else if ([[entry packetType] isEqualToString:@"cfs:getFileList"])
    {
        NSLog(@"File list. Response:\n%@\nStatus: %li (%@)", response, responseCode, [NSHTTPURLResponse localizedStringForStatusCode:responseCode]);
    }
    else
    {
        NSLog(@"Unknown packet entry. Response:\n%@\nStatus: %li (%@)", response, responseCode, [NSHTTPURLResponse localizedStringForStatusCode:responseCode]);
    }
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

@end
