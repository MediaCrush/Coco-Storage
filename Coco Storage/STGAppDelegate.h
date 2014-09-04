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

#import "STGStatusItemManager.h"

#import "STGAPIConfiguration.h"

#import "STGCreateAlbumWindowController.h"
#import "STGMovieCaptureWindowController.h"

#import "STGOptionsManager.h"

#import "STGNetworkManager.h"

#import "STGMovieCaptureSession.h"

#import "STGServiceHandler.h"

@class MASPreferencesWindowController;

@class STGStatusItemManager;

@class STGHotkeyHelper;

@class SUUpdater;

@class STGFloatingWindowController;

@interface STGAppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate, STGHotkeyHelperDelegate, STGOptionsDelegate, STGStatusItemManagerDelegate, STGCreateAlbumWindowControllerDelegate, STGMovieCaptureWindowControllerDelegate, STGDataCaptureDelegate, STGNetworkDelegate, STGMovieCaptureSessionDelegate, STGAPIConfigurationDelegate, STGServiceHandlerDelegate>

@property (nonatomic, retain) IBOutlet SUUpdater *sparkleUpdater;

@property (nonatomic, retain) IBOutlet STGServiceHandler *serviceHandler;

@property (nonatomic, retain) IBOutlet NSMenuItem *openWelcomeWindowMenuItem;

@property (nonatomic, retain) STGNetworkManager *networkManager;

@property (nonatomic, retain) STGCreateAlbumWindowController *createAlbumWC;
@property (nonatomic, retain) STGMovieCaptureWindowController *captureMovieWC;

@property (nonatomic, retain) NSMutableArray *recentFilesArray;

@property (nonatomic, retain) STGHotkeyHelper *hotkeyHelper;

@property (nonatomic, retain) STGMovieCaptureSession *currentMovieCapture;

@property (nonatomic, retain) STGOptionsManager *optionsManager;
@property (nonatomic, retain) STGStatusItemManager *statusItemManager;

@property (nonatomic, retain) NSTimer *assistiveDeviceTimer;

@property (nonatomic, retain) NSTimer *movieCaptureTimer;
@property (nonatomic, retain) STGFloatingWindowController *countdownWC;

- (IBAction)openPreferences:(id)sender;
- (IBAction)openWelcomeWindow:(id)sender;

- (void)readFromUserDefaults;
- (void)saveProperties;

- (void)updateShortcuts;
- (void)registerAsAssistiveDevice;

@end
