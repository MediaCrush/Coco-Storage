//
//  STGOptionsManager.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STGOptionsShortcutsViewController.h"

@class STGOptionsGeneralViewController;
@class STGOptionsShortcutsViewController;
@class STGOptionsQuickUploadViewController;
@class STGOptionsCFSViewController;
@class STGOptionsAboutViewController;

@protocol STGOptionsDelegate <NSObject>

- (void)updateShortcuts;
- (void)registerAsAssistiveDevice;
- (BOOL)hotkeysEnabled;

@end

@interface STGOptionsManager : NSObject <STGOptionsShortcutsDelegate>

@property (nonatomic, assign) NSObject<STGOptionsDelegate> *delegate;

@property (nonatomic, retain) MASPreferencesWindowController *prefsController;

@property (nonatomic, retain) STGOptionsGeneralViewController *optionsGeneralVC;
@property (nonatomic, retain) STGOptionsShortcutsViewController *optionsShortcutsVC;
@property (nonatomic, retain) STGOptionsQuickUploadViewController *optionsQuickUploadVC;
@property (nonatomic, retain) STGOptionsCFSViewController *optionsCFSVC;
@property (nonatomic, retain) STGOptionsAboutViewController *optionsAboutVC;

+ (void)registerDefaults:(NSMutableDictionary *)userDefaults;

- (void)updateHotkeyStatus;
- (NSEvent *)keyPressed:(NSEvent *)event;

- (void)openPreferencesWindow;

@end
