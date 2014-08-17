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

#import "STGAPIConfiguration.h"
#import "STGAPIConfigurationStorage.h"
#import "STGAPIConfigurationMediacrush.h"

#import "STGCFSSyncCheck.h"

#import "STGJSONHelper.h"

#import "STGCreateAlbumWindowController.h"

#import "STGMovieCaptureSession.h"

STGAppDelegate *sharedAppDelegate;

@interface STGAppDelegate ()

- (NSString *)getApiKey;
- (BOOL)isAPIKeyValid:(BOOL)output;
- (NSString *)getCFSFolder;
- (NSString *)getTempFolder;

- (void)keyMissingSheetDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

- (void)assistiveDeviceFailedSheetDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
- (void)assistiveDevicePromptSheetDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

- (void)tryAddingStandardShortcut:(NSString *)charsDefaultsKey action:(NSString *)action menuItem:(NSMenuItem *)menuItem;

- (void)promptAssistiveDeviceRegister;

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
    if ([[STGAPIConfiguration currentConfiguration] hasCFS])
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
    [[self hotkeyHelper] linkToSystem];
    
    [STGAPIConfiguration setCurrentConfiguration:[STGAPIConfigurationMediacrush standardConfiguration]];
    [[STGAPIConfiguration currentConfiguration] setDelegate:self];
    
    [self setOptionsGeneralVC:[[STGOptionsGeneralViewController alloc] initWithNibName:@"STGOptionsGeneralViewController" bundle:nil]];
    [self setOptionsShortcutsVC:[[STGOptionsShortcutsViewController alloc] initWithNibName:@"STGOptionsShortcutsViewController" bundle:nil]];
    [_optionsShortcutsVC setDelegate:self];
    [self setOptionsQuickUploadVC:[[STGOptionsQuickUploadViewController alloc] initWithNibName:@"STGOptionsQuickUploadViewController" bundle:nil]];
    [self setOptionsCFSVC:[[STGOptionsCFSViewController alloc] initWithNibName:@"STGOptionsCFSViewController" bundle:nil]];
    [self setOptionsAboutVC:[[STGOptionsAboutViewController alloc] initWithNibName:@"STGOptionsAboutViewController" bundle:nil]];
    
    NSMutableArray *optionsArray = [[NSMutableArray alloc] init];
    [optionsArray addObject:_optionsGeneralVC];
    [optionsArray addObject:_optionsQuickUploadVC];
    if ([[STGAPIConfiguration currentConfiguration] hasCFS])
        [optionsArray addObject:_optionsCFSVC];
    [optionsArray addObject:_optionsShortcutsVC];
    [optionsArray addObject:_optionsAboutVC];
    [self setPrefsController:[[MASPreferencesWindowController alloc] initWithViewControllers:optionsArray title:@"Coco Storage Preferences"]];
    
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
    
    [self setStatusItemManager:[[STGStatusItemManager alloc] init]];
    [_statusItemManager setDelegate:self];
    
    [self setCfsSyncCheck:[[STGCFSSyncCheck alloc] init]];

    [self setCreateAlbumWC:[[STGCreateAlbumWindowController alloc] initWithWindowNibName:@"STGCreateAlbumWindowController"]];
    [_createAlbumWC setDelegate:self];
    [self setCaptureMovieWC:[[STGMovieCaptureWindowController alloc] initWithWindowNibName:@"STGMovieCaptureWindowController"]];
    [_captureMovieWC setDelegate:self];

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
        {
            [[STGAPIConfiguration currentConfiguration] sendFileUploadPacket:_packetUploadV1Queue apiKey:[self getApiKey] entry:entry public:YES];
        }
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
    
    [STGSystemHelper createDockTile];
    [STGSystemHelper setDockTileVisible:([[NSUserDefaults standardUserDefaults] integerForKey:@"showDockIcon"] == 1)];
    
    [_sparkleUpdater setAutomaticallyChecksForUpdates:[[NSUserDefaults standardUserDefaults] integerForKey:@"autoUpdate"] == 1];
    
    [_cfsSyncCheck setBasePath:[self getCFSFolder]];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"promptedAssistiveDeviceRegister"] && ![STGSystemHelper isAssistiveDevice])
    {
        [self promptAssistiveDeviceRegister];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"promptedAssistiveDeviceRegister"];
    }
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
        BOOL reachingServer = [[STGAPIConfiguration currentConfiguration] canReachServer];
        
        if (reachingServer)
        {
            if ([self isAPIKeyValid:NO])
            {
                [[STGAPIConfiguration currentConfiguration] sendStatusPacket:_packetSupportQueue apiKey:[self getApiKey]];
                
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
        
        if ([[self hotkeyHelper] hotkeyStatus] != STGHotkeyStatusOkay)
        {
            if ([STGSystemHelper isAssistiveDevice])
            {
                if (![[self hotkeyHelper] linkToSystem])
                    [STGSystemHelper restartUsingSparkle];
            }

            [[self optionsShortcutsVC] updateHotkeyStatus];
        }
    }
    
    _ticksAlive ++;
}

#pragma mark - Capturing

-(void)captureScreen:(BOOL)fullScreen;
{
    if ([self isAPIKeyValid:YES])
    {
        [STGDataCaptureManager startScreenCapture:fullScreen tempFolder:[self getTempFolder] silent:[[NSUserDefaults standardUserDefaults] integerForKey:@"playScreenshotSound"] == 0 delegate:self];
    }
}

- (void)captureMovie
{
    [_captureMovieWC showWindow:self];
    [NSApp  activateIgnoringOtherApps:YES];
}

- (void)captureFile
{
    if ([self isAPIKeyValid:YES])
    {
        [STGDataCaptureManager startFileCaptureWithTempFolder:[self getTempFolder] delegate:self];
    }
}

- (void)createAlbum
{
    NSMutableArray *uploadIDList = [[NSMutableArray alloc] initWithCapacity:[_recentFilesArray count]];
    
    for (STGDataCaptureEntry *entry in _recentFilesArray)
    {
        [uploadIDList addObject:[entry onlineID]];
    }
    
    [_createAlbumWC setUploadIDList:uploadIDList];
    
    [_createAlbumWC showWindow:self];
    [NSApp  activateIgnoringOtherApps:YES];
}

#pragma mark - Uploading

-(void)uploadEntries:(NSArray *)entries
{
    if (entries && [entries count] > 0)
    {
        for (STGDataCaptureEntry *entry in entries)
        {
            if (entry)
            {
                [[STGAPIConfiguration currentConfiguration] sendFileUploadPacket:_packetUploadV1Queue apiKey:[self getApiKey] entry:entry public:YES];
            }
        }
        
        [_statusItemManager updateUploadQueue:_packetUploadV1Queue currentProgress:0.0];
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
    
    [[STGAPIConfiguration currentConfiguration] handlePacket:entry fullResponse:response urlResponse:urlResponse];
}

- (void)packetQueue:(STGPacketQueue *)queue cancelledEntry:(STGPacket *)entry
{
    [[STGAPIConfiguration currentConfiguration] cancelPacketUpload:entry];
}

- (void)cancelAllUploads
{
    [_packetUploadV1Queue cancelAllEntries];
        
    [_statusItemManager setStatusItemUploadProgress:0.0];
    [_statusItemManager updateUploadQueue:_packetUploadV1Queue currentProgress:0.0];
}

-(void)deleteRecentFile:(STGDataCaptureEntry *)entry
{
    [[STGAPIConfiguration currentConfiguration] sendFileDeletePacket:_packetSupportQueue apiKey:[self getApiKey] entry:entry];
    
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

#pragma mark - Shortcuts

- (void)updateShortcuts
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_hotkeyHelper removeAllShortcutEntries];
    
    [_hotkeyHelper addShortcutEntry:[STGHotkeyHelperEntry entryWithAllStatesAndUserInfo:[NSDictionary dictionaryWithObject:@"hotkeyChange" forKey:@"action"]]];
    
    [self tryAddingStandardShortcut:@"hotkeyCaptureArea" action:@"captureArea" menuItem:[_statusItemManager captureAreaMenuItem]];
    [self tryAddingStandardShortcut:@"hotkeyCaptureFullScreen" action:@"captureFullScreen" menuItem:[_statusItemManager captureFullScreenMenuItem]];
    [self tryAddingStandardShortcut:@"hotkeyCaptureFile" action:@"captureFile" menuItem:[_statusItemManager captureFileMenuItem]];
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
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"pauseUploads"])
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
            
            [[STGAPIConfiguration currentConfiguration] sendFileUploadPacket:_packetUploadV1Queue apiKey:[self getApiKey] entry:entry public:YES];
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
                
                [[STGAPIConfiguration currentConfiguration] sendFileUploadPacket:_packetUploadV1Queue apiKey:[self getApiKey] entry:entry public:YES];
            }
        }
        
        [_statusItemManager updateUploadQueue:_packetUploadV1Queue currentProgress:0.0];
    }
}

#pragma mark - Getters

- (BOOL)isAPIKeyValid:(BOOL)output
{
    if (![[STGAPIConfiguration currentConfiguration] hasAPIKeys])
        return YES;
    else
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

- (void)keyMissingSheetDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == 1)
        [self performSelectorOnMainThread:@selector(openPreferences:) withObject:self waitUntilDone:NO];
}

- (void)assistiveDeviceFailedSheetDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == 1)
        [[NSWorkspace sharedWorkspace] openURL:
         [NSURL fileURLWithPath:@"/System/Library/PreferencePanes/Security.prefPane"]];
}

- (void)promptAssistiveDeviceRegister
{
    NSAlert *alert = [NSAlert alertWithMessageText:@"Coco Storage" defaultButton:@"Register as an assistive device" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@"To make use of hotkeys, Coco Storage requires access as an assistive device. This requires administrative rights. "];
    [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(assistiveDevicePromptSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];

    [NSApp  activateIgnoringOtherApps:YES];
}

- (void)assistiveDevicePromptSheetDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == 1)
        [self registerAsAssistiveDevice];
}

- (void)registerAsAssistiveDevice
{
    NSString *error;
    NSString *output;
    BOOL success = [STGSystemHelper registerAsAssistiveDevice:[[NSBundle mainBundle] bundleIdentifier] error:&error output:&output];
    if (!success)
    {
        if (error != nil)
            NSLog(@"Assistive Device error: %@", error);
        if (error != nil)
            NSLog(@"Assistive Device log: %@", output);

        if (error == nil)
            error = @"Unknown error";
        if ([error isEqualToString:@"Error: columns service, client, client_type are not unique"])
            error = @"Coco Storage is already registered, but most likely not enabled. You can change that in the system preferences.";
        
        NSAlert *alert = [NSAlert alertWithMessageText:@"Coco Storage Error" defaultButton:@"Open System Preferences" alternateButton:@"OK" otherButton:nil informativeTextWithFormat:@"Error while registering for administrative rights: %@\n", error];
        [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(assistiveDeviceFailedSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];

        [NSApp  activateIgnoringOtherApps:YES];
    }
    else
    {
        if (![[self hotkeyHelper] linkToSystem])
            [STGSystemHelper restartUsingSparkle];
    }

    [[self optionsShortcutsVC] updateHotkeyStatus];
}

- (BOOL)hotkeysEnabled
{
    return [[self hotkeyHelper] hotkeyStatus] == STGHotkeyStatusOkay;
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

#pragma mark API Configuration delegate

- (void)didUploadDataCaptureEntry:(STGDataCaptureEntry *)entry success:(BOOL)success 
{
    [[[_statusItemManager statusItem] menu] cancelTracking];
    [_statusItemManager setStatusItemUploadProgress:0.0];
    [_statusItemManager updateUploadQueue:_packetUploadV1Queue currentProgress:0.0];

    if (success)
    {
        [_recentFilesArray addObject:entry];
        
        while (_recentFilesArray.count > 100)
            [_recentFilesArray removeObjectAtIndex:0];
        
        [_statusItemManager updateRecentFiles:_recentFilesArray];
    }
    
    if ([entry deleteOnCompletetion] &&
        ((success && [[NSUserDefaults standardUserDefaults] integerForKey:@"keepAllScreenshots"] == 0)
         || (!success && [[NSUserDefaults standardUserDefaults] integerForKey:@"keepFailedScreenshots"] == 0)))
    {
        if ([entry fileURL] && [[NSFileManager defaultManager] fileExistsAtPath:[[entry fileURL] path]])
        {
            NSError *error = nil;
            
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
    
    [_statusItemManager updateServerStatus:status];
}

#pragma mark Album Controller Delegate

- (void)createAlbumWithIDs:(NSArray *)entryIDs
{
    [[STGAPIConfiguration currentConfiguration] sendAlbumCreatePacket:_packetUploadV1Queue apiKey:[self getApiKey] entries:entryIDs];
}

#pragma mark Movie Controller Delegate

- (void)startMovieCapture:(STGMovieCaptureWindowController *)movieCaptureWC
{
    if ([self isAPIKeyValid:YES] && (_currentMovieCapture == nil || ![_currentMovieCapture isRecording]))
    {
        [self performSelector:@selector(startMovieCaptureIgnoringDelay:) withObject:movieCaptureWC afterDelay:[[movieCaptureWC recordDelay] doubleValue]];
    }
}

- (void)startMovieCaptureIgnoringDelay:(STGMovieCaptureWindowController *)movieCaptureWC
{
    STGMovieCaptureSession *session = [STGDataCaptureManager startScreenMovieCapture:[movieCaptureWC recordRect] display:[[movieCaptureWC recordDisplayID] unsignedIntValue] length:[[movieCaptureWC recordDuration] doubleValue] tempFolder:[self getTempFolder] recordVideo:[movieCaptureWC recordsVideo] recordComputerAudio:[movieCaptureWC recordsComputerAudio] recordMicrophoneAudio:[movieCaptureWC recordsMicrophoneAudio] quality:[movieCaptureWC quality] delegate:self];
    
    [self setCurrentMovieCapture:session];
}

#pragma mark Data Capture Manager Melegate

- (void)dataCaptureCompleted:(STGDataCaptureEntry *)entry sender:(id)sender
{
    [[STGAPIConfiguration currentConfiguration] sendFileUploadPacket:_packetUploadV1Queue apiKey:[self getApiKey] entry:entry public:YES];
    
    [_statusItemManager updateUploadQueue:_packetUploadV1Queue currentProgress:0.0];
}

@end

