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

#import "STGDataCaptureManager.h"

#import "STGOptionsShortcutsViewController.h"

#import "STGRecentUploadView.h"

#import "STGWelcomeWindowController.h"

#import "STGStatusItemManager.h"

#import "STGAPIConfiguration.h"

#import "STGCreateAlbumWindowController.h"
#import "STGMovieCaptureWindowController.h"

@class STGPacketQueue;

@class MASPreferencesWindowController;

@class STGOptionsGeneralViewController;
@class STGOptionsShortcutsViewController;
@class STGOptionsQuickUploadViewController;
@class STGOptionsCFSViewController;
@class STGOptionsAboutViewController;

@class STGStatusItemManager;

@class STGHotkeyHelper;

@class STGMovieCaptureSession;

@class SUUpdater;

@class STGCFSSyncCheck;

@interface STGAppDelegate : NSObject <NSApplicationDelegate, STGPacketQueueDelegate, NSUserNotificationCenterDelegate, STGHotkeyHelperDelegate, STGOptionsShortcutsDelegate, STGWelcomeWindowControllerDelegate, STGStatusItemManagerDelegate, STGAPIConfigurationDelegate, STGCreateAlbumWindowControllerDelegate, STGMovieCaptureWindowControllerDelegate, STGDataCaptureDelegate>

@property (nonatomic, retain) IBOutlet SUUpdater *sparkleUpdater;

@property (nonatomic, retain) NSTimer *uploadTimer;
@property (nonatomic, assign) NSUInteger ticksAlive;

@property (nonatomic, assign) BOOL apiV1Alive;
@property (nonatomic, assign) BOOL apiV2Alive;

@property (nonatomic, retain) MASPreferencesWindowController *prefsController;
@property (nonatomic, retain) STGWelcomeWindowController *welcomeWC;

@property (nonatomic, retain) STGCreateAlbumWindowController *createAlbumWC;
@property (nonatomic, retain) STGMovieCaptureWindowController *captureMovieWC;

@property (nonatomic, retain) NSMutableArray *recentFilesArray;

@property (nonatomic, retain) STGPacketQueue *packetUploadV1Queue;
@property (nonatomic, retain) STGPacketQueue *packetUploadV2Queue;
@property (nonatomic, retain) STGPacketQueue *packetSupportQueue;

@property (nonatomic, retain) STGCFSSyncCheck *cfsSyncCheck;

@property (nonatomic, retain) STGHotkeyHelper *hotkeyHelper;

@property (nonatomic, retain) STGMovieCaptureSession *currentMovieCapture;

@property (nonatomic, retain) STGOptionsGeneralViewController *optionsGeneralVC;
@property (nonatomic, retain) STGOptionsShortcutsViewController *optionsShortcutsVC;
@property (nonatomic, retain) STGOptionsQuickUploadViewController *optionsQuickUploadVC;
@property (nonatomic, retain) STGOptionsCFSViewController *optionsCFSVC;
@property (nonatomic, retain) STGOptionsAboutViewController *optionsAboutVC;

@property (nonatomic, retain) STGStatusItemManager *statusItemManager;

- (IBAction)openPreferences:(id)sender;
- (IBAction)openWelcomeWindow:(id)sender;

- (void)readFromUserDefaults;
- (void)saveProperties;

- (void)uploadTimerFired:(NSTimer*)theTimer;

- (void)updateShortcuts;
- (void)registerAsAssistiveDevice;

@end
