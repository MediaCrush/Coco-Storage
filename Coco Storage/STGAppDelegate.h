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

#import "STGRecentUploadView.h"

#import "STGWelcomeWindowController.h"

#import "STGStatusItemManager.h"

#import "STGAPIConfiguration.h"

#import "STGCreateAlbumWindowController.h"
#import "STGMovieCaptureWindowController.h"

#import "STGOptionsManager.h"

#import "STGNetworkManager.h"

#define API_MEDIACRUSH 1
#define API_STORAGE 2

#define USED_STORAGE_API 1

@class MASPreferencesWindowController;

@class STGStatusItemManager;

@class STGHotkeyHelper;

@class STGMovieCaptureSession;

@class SUUpdater;

@interface STGAppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate, STGHotkeyHelperDelegate, STGOptionsDelegate, STGWelcomeWindowControllerDelegate, STGStatusItemManagerDelegate, STGCreateAlbumWindowControllerDelegate, STGMovieCaptureWindowControllerDelegate, STGDataCaptureDelegate, STGNetworkDelegate>

@property (nonatomic, retain) IBOutlet SUUpdater *sparkleUpdater;

@property (nonatomic, retain) STGNetworkManager *networkManager;

@property (nonatomic, retain) STGWelcomeWindowController *welcomeWC;

@property (nonatomic, retain) STGCreateAlbumWindowController *createAlbumWC;
@property (nonatomic, retain) STGMovieCaptureWindowController *captureMovieWC;

@property (nonatomic, retain) NSMutableArray *recentFilesArray;

@property (nonatomic, retain) STGHotkeyHelper *hotkeyHelper;

@property (nonatomic, retain) STGMovieCaptureSession *currentMovieCapture;

@property (nonatomic, retain) STGOptionsManager *optionsManager;
@property (nonatomic, retain) STGStatusItemManager *statusItemManager;

@property (nonatomic, retain) NSTimer *assistiveDeviceTimer;

- (IBAction)openPreferences:(id)sender;
- (IBAction)openWelcomeWindow:(id)sender;

- (void)readFromUserDefaults;
- (void)saveProperties;

- (void)updateShortcuts;
- (void)registerAsAssistiveDevice;

@end
