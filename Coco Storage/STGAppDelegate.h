//
//  STGAppDelegate.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 23.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "STGPacketQueue.h"
#import "STGHotkeyHelper.h"

#import "STGOptionsShortcutsViewController.h"

#import "STGRecentUploadView.h"

#import "STGWelcomeWindowController.h"

#import "STGStatusItemManager.h"

@class STGPacketQueue;

@class MASPreferencesWindowController;

@class STGOptionsGeneralViewController;
@class STGOptionsShortcutsViewController;
@class STGOptionsAboutViewController;

@class STGStatusItemManager;

@class STGHotkeyHelper;

@class SUUpdater;

@interface STGAppDelegate : NSObject <NSApplicationDelegate, STGPacketQueueDelegate, NSUserNotificationCenterDelegate, STGHotkeyHelperDelegate, STGOptionsShortcutsDelegate, STGWelcomeWindowControllerDelegate, STGStatusItemManagerDelegate>

@property (nonatomic, retain) IBOutlet SUUpdater *sparkleUpdater;

@property (nonatomic, retain) NSTimer *uploadTimer;
@property (nonatomic, assign) NSUInteger ticksAlive;

@property (nonatomic, retain) MASPreferencesWindowController *prefsController;
@property (nonatomic, retain) STGWelcomeWindowController *welcomeWC;

@property (nonatomic, retain) NSMutableArray *recentFilesArray;

@property (nonatomic, retain) STGPacketQueue *packetUploadV1Queue;
@property (nonatomic, retain) STGPacketQueue *packetUploadV2Queue;
@property (nonatomic, retain) STGPacketQueue *packetSupportQueue;
@property (nonatomic, retain) NSString *uploadLink;
@property (nonatomic, retain) NSString *deletionLink;
@property (nonatomic, retain) NSString *getAPIStatusLink;
@property (nonatomic, retain) NSString *getObjectInfoLink;

@property (nonatomic, retain) STGHotkeyHelper *hotkeyHelper;

@property (nonatomic, retain) STGOptionsGeneralViewController *optionsGeneralVC;
@property (nonatomic, retain) STGOptionsShortcutsViewController *optionsShortcutsVC;
@property (nonatomic, retain) STGOptionsAboutViewController *optionsAboutVC;

@property STGStatusItemManager *statusItemManager;

- (IBAction)openPreferences:(id)sender;

- (void)readFromUserDefaults;

- (void)uploadTimerFired:(NSTimer*)theTimer;

- (void)saveProperties;

- (void)updateShortcuts;

- (void)keyMissingSheetDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

@end
