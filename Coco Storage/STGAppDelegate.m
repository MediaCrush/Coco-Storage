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

#import "MASPreferencesWindowController.h"

#import "STGStatusItemManager.h"

#import "STGPacketQueue.h"

#import "STGAPIConfiguration.h"
#import "STGAPIConfigurationStub.h"
#import "STGAPIConfigurationStorage.h"
#import "STGAPIConfigurationMediacrush.h"

#import "STGJSONHelper.h"

#import "STGCreateAlbumWindowController.h"
#import "STGFloatingWindowController.h"
#import "STGCountdownView.h"

#import "STGMovieCaptureSession.h"

#import "STGUncompletedUploadList.h"

#import "STGUploadedEntry.h"

STGAppDelegate *sharedAppDelegate;

@implementation STGAppDelegate

#pragma mark - Initializer

- (id)init
{
    self = [super init];
    
    if (self)
    {
        sharedAppDelegate = self;
        
        [self setRecentFilesArray:[[NSMutableArray alloc] init]];
    }
    
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [STGAPIConfigurationMediacrush registerStandardConfiguration];
    [[STGAPIConfigurationMediacrush standardConfiguration] setNetworkDelegate:_networkManager];
    [[STGAPIConfigurationMediacrush standardConfiguration] setDelegate:self];
    
    [STGAPIConfigurationStorage registerStandardConfiguration];
    [[STGAPIConfigurationStorage standardConfiguration] setNetworkDelegate:_networkManager];
    [[STGAPIConfigurationStorage standardConfiguration] setDelegate:self];
    
    [STGAPIConfigurationStub registerStandardConfiguration];
    [[STGAPIConfigurationStub standardConfiguration] setNetworkDelegate:_networkManager];
    [[STGAPIConfigurationStub standardConfiguration] setDelegate:self];
    
    [STGAPIConfiguration setCurrentConfiguration:[STGAPIConfigurationMediacrush standardConfiguration]];

    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSMutableDictionary *standardDefaults = [[NSMutableDictionary alloc] init];
    [STGOptionsManager registerDefaults:standardDefaults];
    [STGWelcomeWindowControllerStorage registerStandardDefaults:standardDefaults];
    [standardDefaults setObject:[NSArray array] forKey:@"recentEntries"];
    [standardDefaults setObject:[NSArray array] forKey:@"uploadQueue"];
    [standardDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"pauseUploads"];
    [standardDefaults setObject:@"0.0" forKey:@"lastVersion"];
    [standardDefaults setObject:[NSNumber numberWithInt:0] forKey:@"autoUpdate"];
    [standardDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"HadFirstLaunch"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:standardDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self setNetworkManager:[[STGNetworkManager alloc] init]];
    [_networkManager setDelegate:self];
    
    [self setHotkeyHelper:[[STGHotkeyHelper alloc] initWithDelegate:self]];
    [[self hotkeyHelper] linkToSystem];
    
    [_openWelcomeWindowMenuItem setHidden:![[STGAPIConfiguration currentConfiguration] hasWelcomeWindow]];
    
    [self setOptionsManager:[[STGOptionsManager alloc] init]];
    [_optionsManager setDelegate:self];
    
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
    
    [self setCreateAlbumWC:[[STGCreateAlbumWindowController alloc] initWithWindowNibName:@"STGCreateAlbumWindowController"]];
    [_createAlbumWC setDelegate:self];
    [self setCaptureMovieWC:[[STGMovieCaptureWindowController alloc] initWithWindowNibName:@"STGMovieCaptureWindowController"]];
    [_captureMovieWC setDelegate:self];
    
    [self setCountdownWC:[STGFloatingWindowController floatingWindowController]];
    [_countdownWC setContentView:[[STGCountdownView alloc] init]];
    [[_countdownWC window] setContentSize:NSMakeSize(500, 40)];

    [self readFromUserDefaults];

    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
        
    [_statusItemManager updateRecentFiles:_recentFilesArray];
    [_statusItemManager updateUploadQueue:[_networkManager packetUploadV1Queue] currentProgress:0.0];
    [_statusItemManager updatePauseDownloadItem];
    [self updateShortcuts];
    
    [self setAssistiveDeviceTimer:[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(assistiveDeviceTimerFired:) userInfo:nil repeats:YES]];
  
//    [_packetSupportQueue addEntry:[STGPacketCreator cfsDeleteFilePacket:@"/foo2.png" link:[[STGAPIConfiguration standardConfiguration] cfsBaseLink] key:[self getApiKey]]];
//    [_packetUploadV2Queue addEntry:[STGPacketCreator cfsPostFilePacket:@"/foo9.png" fileURL:[STGFileHelper urlFromStandardPath:[[self getCFSFolder] stringByAppendingPathComponent:@"/foo2/foo2.png"]] link:[[STGAPIConfiguration standardConfiguration] cfsBaseLink] key:[self getApiKey]]];
    
    [self setServiceHandler:[STGServiceHandler registeredHandler]];
    if (_serviceHandler)
        [_serviceHandler setDelegate:self];
    else
        NSLog(@"Could not register service handler");
    NSUpdateDynamicServices();

    [_networkManager checkServerStatus];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HadFirstLaunch"])
    {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Coco Storage - Caution" defaultButton:@"OK" alternateButton:@"Disable auto-updates" otherButton:nil informativeTextWithFormat:@"Note that Coco Storage automatically queries a server (GitHub) for automatic updates. You are free to disable it at any time."];
//        [alert beginSheetModalForWindow:nil completionHandler:^(NSModalResponse returnCode) {
//            if (returnCode == NSModalResponseOK)
//            {
//                [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"autoUpdate"];
//                [_sparkleUpdater setAutomaticallyChecksForUpdates:YES];
//            }
//        }];
        [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(autoUpdateSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
        [NSApp activateIgnoringOtherApps:YES];
    }
}

- (void)autoUpdateSheetDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == 1)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"autoUpdate"];
        [_sparkleUpdater setAutomaticallyChecksForUpdates:YES];
    }
}

#pragma mark - Properties

- (void)readFromUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSData *uncompletedUploadsData = [defaults objectForKey:@"UploadQueue"];
    if (uncompletedUploadsData)
    {
        STGUncompletedUploadList *uncompletedUploads = [NSKeyedUnarchiver unarchiveObjectWithData:uncompletedUploadsData];
        [uncompletedUploads queueAll:[_networkManager packetUploadV1Queue] inConfiguration:[STGAPIConfiguration currentConfiguration] withKey:[self getApiKey]];
    }

    [_networkManager setUploadsPaused:[[NSUserDefaults standardUserDefaults] boolForKey:@"pauseUploads"]];
    
    NSData *recentFilesData = [defaults objectForKey:@"RecentUploads"];
    if (recentFilesData)
        [self setRecentFilesArray:[NSKeyedUnarchiver unarchiveObjectWithData:recentFilesData]];
    if (![_recentFilesArray isKindOfClass:[NSMutableArray class]])
        [self setRecentFilesArray:[[NSMutableArray alloc] init]];
    [_recentFilesArray filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return [evaluatedObject isKindOfClass:[STGUploadedEntry class]];
    }]];
    
    [STGSystemHelper setStartOnSystemLaunch:[[NSUserDefaults standardUserDefaults] integerForKey:@"startAtLogin"] == 1];
    
    [STGSystemHelper createDockTile];
    [STGSystemHelper setDockTileVisible:([[NSUserDefaults standardUserDefaults] integerForKey:@"showDockIcon"] == 1)];
    
    [_sparkleUpdater setAutomaticallyChecksForUpdates:[[NSUserDefaults standardUserDefaults] integerForKey:@"autoUpdate"] == 1];
    
//    [[_networkManager cfsSyncCheck] setBasePath:[self getCFSFolder]];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"promptedAssistiveDeviceRegister"] && ![STGSystemHelper isAssistiveDevice])
    {
        [self promptAssistiveDeviceRegister];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"promptedAssistiveDeviceRegister"];
    }
}

- (void)saveProperties
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    STGUncompletedUploadList *uncompletedUploads = [[STGUncompletedUploadList alloc] initWithPacketQueue:[_networkManager packetUploadV1Queue]];
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:uncompletedUploads] forKey:@"UploadQueue"];
    
    [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:_recentFilesArray] forKey:@"RecentUploads"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] forKey:@"lastVersion"];

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HadFirstLaunch"];

    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Timer

- (void)assistiveDeviceTimerFired:(NSTimer *)timer
{
    if ([[self hotkeyHelper] hotkeyStatus] != STGHotkeyStatusOkay)
    {
        if ([STGSystemHelper isAssistiveDevice])
        {
            if (![[self hotkeyHelper] linkToSystem])
                [STGSystemHelper restartUsingSparkle];
        }
        
        [[self optionsManager] updateHotkeyStatus];
    }
}

#pragma mark - Capturing

-(void)captureScreen:(BOOL)fullScreen;
{
    if ([_networkManager isAPIKeyValid:YES])
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
    if ([_networkManager isAPIKeyValid:YES])
    {
        [STGDataCaptureManager startFileCaptureWithTempFolder:[self getTempFolder] delegate:self];
    }
}

- (void)createAlbum
{
    NSMutableArray *uploadIDList = [[NSMutableArray alloc] initWithCapacity:[_recentFilesArray count]];
    
    for (STGUploadedEntry *entry in _recentFilesArray)
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
    for (STGDataCaptureEntry *entry in entries)
    {
        [[STGAPIConfiguration currentConfiguration] sendFileUploadPacket:[_networkManager packetUploadV1Queue] apiKey:[self getApiKey] entry:entry public:YES];
    }
}

- (void)cancelAllUploads
{
    [[_networkManager packetUploadV1Queue] cancelAllEntries];
}

-(void)deleteRecentFile:(STGUploadedEntry *)entry
{
    id<STGAPIConfiguration> configuration = [STGAPIConfiguration configurationWithID:[entry apiConfigurationID]];
    if (configuration)
    {
        [configuration sendFileDeletePacket:[_networkManager packetSupportQueue] apiKey:[self getApiKey] entry:entry];
        
        [_recentFilesArray removeObject:entry];
        [_statusItemManager updateRecentFiles:_recentFilesArray];
    }
    else
    {
        NSLog(@"Could not find API Configuration for key %@", [entry apiConfigurationID]);
    }
}

-(void)cancelQueueFile:(int)index
{
    [[_networkManager packetUploadV1Queue] cancelEntryAtIndex:index];
}

-(void)togglePauseUploads
{
    BOOL pause = ![[NSUserDefaults standardUserDefaults] boolForKey:@"pauseUploads"];
    
    [[NSUserDefaults standardUserDefaults] setBool:pause forKey:@"pauseUploads"];
    
    [_networkManager setUploadsPaused:pause];
    
    [_statusItemManager updatePauseDownloadItem];
}

- (void)cancelRecording
{
    if (_movieCaptureTimer != nil)
    {
        [_movieCaptureTimer invalidate];
        [self setMovieCaptureTimer:nil];
    }

    if (_currentMovieCapture)
        [_currentMovieCapture cancelRecording];
    
    [_statusItemManager setMovieControlsVisible:NO];
    [[_countdownWC contentView] setCountdownTime:-1];
}

- (void)stopRecording
{
    if (_movieCaptureTimer != nil)
    {
        [_movieCaptureTimer invalidate];
        [self setMovieCaptureTimer:nil];
    }
    
    if (_currentMovieCapture)
        [_currentMovieCapture stopRecording];
    
    [_statusItemManager setMovieControlsVisible:NO];
    [[_countdownWC contentView] setCountdownTime:-1];
}

#pragma mark - Windows

- (IBAction)openPreferences:(id)sender
{
    [_optionsManager openPreferencesWindow];
}

- (IBAction)openWelcomeWindow:(id)sender
{
    if ([[STGAPIConfiguration currentConfiguration] hasWelcomeWindow])
    {
        [[STGAPIConfiguration currentConfiguration] openWelcomeWindow];
        [NSApp  activateIgnoringOtherApps:YES];
    }
}

#pragma mark - Shortcuts

- (void)updateShortcuts
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_hotkeyHelper removeAllShortcutEntries];
    
    [_hotkeyHelper addShortcutEntry:[STGHotkeyHelperEntry entryWithAllStatesAndUserInfo:[NSDictionary dictionaryWithObject:@"hotkeyChange" forKey:@"action"]]];
    
    id<STGAPIConfiguration> configuration = [STGAPIConfiguration currentConfiguration];
    
    [self tryAddingStandardShortcut:@"hotkeyCaptureArea" action:@"captureArea" menuItem:[_statusItemManager captureAreaMenuItem]];
    [self tryAddingStandardShortcut:@"hotkeyCaptureFullScreen" action:@"captureFullScreen" menuItem:[_statusItemManager captureFullScreenMenuItem]];
    [self tryAddingStandardShortcut:@"hotkeyCaptureFile" action:@"captureFile" menuItem:[_statusItemManager captureFileMenuItem]];
    
    if ([configuration hasAlbums])
        [self tryAddingStandardShortcut:@"hotkeyCreateAlbum" action:@"createAlbum" menuItem:[_statusItemManager createAlbumMenuItem]];
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
            NSEvent *hotkeyReturnEvent = [_optionsManager keyPressed:event];
            
            if (hotkeyReturnEvent != event)
            {
                [self performSelectorOnMainThread:@selector(updateShortcuts) withObject:nil waitUntilDone:NO];
            }
            
            event = hotkeyReturnEvent;
        }
        else if ([[userInfo objectForKey:@"action"] isEqualToString:@"captureFullScreen"])
        {
            [self captureScreen:YES];
            
            return nil;
        }
        else if ([[userInfo objectForKey:@"action"] isEqualToString:@"captureArea"])
        {
            [self captureScreen:NO];
            
            return nil;
        }
        else if ([[userInfo objectForKey:@"action"] isEqualToString:@"captureFile"])
        {
            [self captureFile];
            
            return nil;
        }
        else if ([[userInfo objectForKey:@"action"] isEqualToString:@"createAlbum"])
        {
            [self createAlbum];
            
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
    if ([_networkManager isAPIKeyValid:YES])
    {
        NSURL *url = [STGFileHelper urlFromStandardPath:filename];
        
        if (url && [url isFileURL] && [[NSFileManager defaultManager] fileExistsAtPath:[url path]])
        {
            STGDataCaptureEntry *entry = [STGDataCaptureManager captureFile:url tempFolder:[self getTempFolder]];
            
            [[STGAPIConfiguration currentConfiguration] sendFileUploadPacket:[_networkManager packetUploadV1Queue] apiKey:[self getApiKey] entry:entry public:YES];
        }
        
        return YES;
    }
    
    return NO;
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
    if ([_networkManager isAPIKeyValid:YES])
    {
        for (NSString *filename in filenames)
        {
            NSURL *url = [STGFileHelper urlFromStandardPath:filename];
            
            if (url && [url isFileURL] && [[NSFileManager defaultManager] fileExistsAtPath:[url path]])
            {
                STGDataCaptureEntry *entry = [STGDataCaptureManager captureFile:url tempFolder:[self getTempFolder]];
                
                [[STGAPIConfiguration currentConfiguration] sendFileUploadPacket:[_networkManager packetUploadV1Queue] apiKey:[self getApiKey] entry:entry public:YES];
            }
        }
    }
}

#pragma mark - Getters

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

    [_optionsManager updateHotkeyStatus];
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

#pragma mark Network Delegate

- (void)serverStatusChanged:(STGNetworkManager *)networkManager
{
    [_statusItemManager updateServerStatus:[networkManager serverStatus]];
}

- (void)fileUploadProgressChanged:(STGNetworkManager *)networkManager
{
    CGFloat uploadProgress = [networkManager fileUploadProgress];
    [_statusItemManager setStatusItemUploadProgress:uploadProgress];
    [_statusItemManager updateUploadQueue:[networkManager packetUploadV1Queue] currentProgress:uploadProgress];
}

- (void)fileUploadQueueChanged:(STGNetworkManager *)networkManager
{
    [_statusItemManager updateUploadQueue:[networkManager packetUploadV1Queue] currentProgress:[networkManager fileUploadProgress]];
    
    [self saveProperties];
}

- (void)uploadCompleted:(STGNetworkManager *)networkManager entry:(STGUploadedEntry *)entry successful:(BOOL)successful
{
    if (successful)
    {
        [_recentFilesArray addObject:entry];
        
        while (_recentFilesArray.count > 100)
            [_recentFilesArray removeObjectAtIndex:0];
        
        [_statusItemManager updateRecentFiles:_recentFilesArray];
        
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"displayNotification"] == 1)
        {
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            
            [notification setTitle:[NSString stringWithFormat:@"Upload complete: %@!", [entry onlineID]]];
            [notification setInformativeText:@"Click to view the uploaded file"];
            [notification setSoundName:nil];
            [notification setUserInfo:[NSDictionary dictionaryWithObject:[[entry onlineLink] absoluteString] forKey:@"uploadLink"]];
            
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
            [[NSPasteboard generalPasteboard] writeObjects:[NSArray arrayWithObject:[entry onlineLink]]];
        }
        
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"linkOpenInBrowser"] == 1)
        {
            [[NSWorkspace sharedWorkspace] openURL:[entry onlineLink]];
        }

        [self saveProperties];
    }
    else
    {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Coco Storage Upload Error" defaultButton:@"Open Preferences" alternateButton:@"OK" otherButton:nil informativeTextWithFormat:@"Coco Storage could not complete your file upload... Make sure your Storage key is valid, and try again.\n"];
        [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(keyMissingSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];        
        [NSApp activateIgnoringOtherApps:YES];
    }
}

- (void)fileUploadCompleted:(STGNetworkManager *)networkManager entry:(STGUploadedEntry *)entry dataCaptureEntry:(STGDataCaptureEntry *)dataCaptureEntry successful:(BOOL)successful
{
    [self deleteEntryIfNecessary:dataCaptureEntry successful:successful];
}

- (void)uploadDeletionCompleted:(STGNetworkManager *)networkManager entry:(STGUploadedEntry *)entry
{
    [self saveProperties];
}

- (void)deleteEntryIfNecessary:(STGDataCaptureEntry *)entry successful:(BOOL)successful
{
    if ([entry deleteOnCompletetion] &&
        ((successful && [[NSUserDefaults standardUserDefaults] integerForKey:@"keepAllScreenshots"] == 0)
         || (!successful && [[NSUserDefaults standardUserDefaults] integerForKey:@"keepFailedScreenshots"] == 0)))
    {
        [self deleteEntry:entry];
    }
}

- (void)deleteEntry:(STGDataCaptureEntry *)entry
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

#pragma mark Album Controller Delegate

- (void)createAlbumWithIDs:(NSArray *)entryIDs
{
    [[STGAPIConfiguration currentConfiguration] sendAlbumCreatePacket:[_networkManager packetUploadV1Queue] apiKey:[self getApiKey] entries:entryIDs];
}

#pragma mark Movie Controller Delegate

- (void)startMovieCapture:(STGMovieCaptureWindowController *)movieCaptureWC
{
    if ([_networkManager isAPIKeyValid:YES] && (_currentMovieCapture == nil || ![_currentMovieCapture isRecording]))
    {
        CGFloat delay = [[movieCaptureWC recordDelay] doubleValue];

        CGSize screenSize = [[[_countdownWC window] screen] frame].size;
        CGSize windowSize = [[_countdownWC window] frame].size;
        [[_countdownWC window] setFrameOrigin:NSMakePoint(screenSize.width - windowSize.width - 10, screenSize.height - windowSize.height - 50)];

        [(STGCountdownView *)[_countdownWC contentView] setCountdownTime:delay];
        [(STGCountdownView *)[_countdownWC contentView] fadeIn];

        [_countdownWC showWindow:self];
        
        [self setMovieCaptureTimer:[NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(movieCaptureTimerFired:) userInfo:movieCaptureWC repeats:NO]];
        [_statusItemManager setMovieControlsVisible:YES];
    }
}

- (void)movieCaptureTimerFired:(NSTimer *)timer
{
    [self startMovieCaptureIgnoringDelay:[timer userInfo]];
}

- (void)startMovieCaptureIgnoringDelay:(STGMovieCaptureWindowController *)movieCaptureWC
{
    [[_countdownWC window] close];
    STGMovieCaptureSession *session = [STGDataCaptureManager startScreenMovieCapture:[movieCaptureWC recordRect] display:[[movieCaptureWC recordDisplayID] unsignedIntValue] length:[[movieCaptureWC recordDuration] doubleValue] tempFolder:[self getTempFolder] recordVideo:[movieCaptureWC recordsVideo] recordComputerAudio:[movieCaptureWC recordsComputerAudio] recordMicrophoneAudio:[movieCaptureWC recordsMicrophoneAudio] quality:[movieCaptureWC quality] delegate:self];
    
    [self setCurrentMovieCapture:session];
}

#pragma mark Data Capture Manager Melegate

- (void)dataCaptureCompleted:(STGDataCaptureEntry *)entry sender:(id)sender
{
    [[STGAPIConfiguration currentConfiguration] sendFileUploadPacket:[_networkManager packetUploadV1Queue] apiKey:[self getApiKey] entry:entry public:YES];
}

#pragma mark Movie Capture Delegate

- (void)movieCaptureSessionDidBegin:(STGMovieCaptureSession *)movieCaptureSession
{
    [_statusItemManager setMovieControlsVisible:YES];
}

- (void)movieCaptureSessionDidEnd:(STGMovieCaptureSession *)movieCaptureSession withError:(NSError *)error wasCancelled:(BOOL)cancelled
{
    [_statusItemManager setMovieControlsVisible:NO];

    if (error == nil && !cancelled)
    {
        STGDataCaptureEntry *entry = [STGDataCaptureEntry entryWithAction:STGUploadActionUploadFile url:[movieCaptureSession destURL] deleteOnCompletion:YES];
        [self dataCaptureCompleted:entry sender:self];

        // Uncomment to convert to gif instead of uploading the video
//        AVURLAsset *movie = [[AVURLAsset alloc] initWithURL:[movieCaptureSession destURL] options:nil];
//        STGGifConverter *gifConverter = [[STGGifConverter alloc] init];
//        
//        [gifConverter setDelegate:self];
//        [gifConverter setUserInfo:[movieCaptureSession destURL]];
//        [gifConverter beginConversion:movie];
    }
    else
    {
        [self deleteEntry:[STGDataCaptureEntry entryWithAction:STGUploadActionUploadFile url:[movieCaptureSession destURL] deleteOnCompletion:YES]];
    }
}

//#pragma mark Gif conversion delegate
//
//- (void)gifConversionStarted:(STGGifConverter *)gifConverter
//{
//    [[self gifConversions] addObject:gifConverter];
//}
//
//- (void)gifConversionEnded:(STGGifConverter *)gifConverter withData:(NSData *)data canceled:(BOOL)canceleld
//{
//    [[self gifConversions] removeObject:gifConverter];
//    
//    NSURL *srcURL = [gifConverter userInfo];
//
//    if (data != nil)
//    {
//        [[NSFileManager defaultManager] removeItemAtURL:srcURL error:nil];
//        NSURL *gifURL = [srcURL URLByAppendingPathExtension:@"gif"];
//
//        if ([data writeToURL:gifURL atomically:NO])
//        {
//            STGDataCaptureEntry *entry = [STGDataCaptureEntry entryWithURL:gifURL deleteOnCompletion:YES];
//            
//            [self dataCaptureCompleted:entry sender:self];
//        }
//    }
//    else
//    {
//        STGDataCaptureEntry *entry = [STGDataCaptureEntry entryWithURL:srcURL deleteOnCompletion:YES];
//        [self dataCaptureCompleted:entry sender:self];
//    }
//}

#pragma mark API Configuration Delegate

- (void)openPreferences
{
    [_optionsManager openPreferencesWindow];
}

#pragma mark Service Handler Delegate

- (void)uploadObjects:(NSArray *)objects fromHandler:(STGServiceHandler *)handler
{
    [self uploadEntries:objects];
}

@end

