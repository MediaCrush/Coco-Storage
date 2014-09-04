//
//  STGOptionsShortcutsViewController.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 24.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MASPreferencesWindowController.h"
#import "STGHotkeySelectView.h"

@protocol STGOptionsShortcutsDelegate <NSObject>

- (void)updateShortcuts;
- (void)registerAsAssistiveDevice;
- (BOOL)hotkeysEnabled;

@end

@interface STGOptionsShortcutsViewController : NSViewController <MASPreferencesViewController, STGHotkeySelectViewDelegate>

@property (nonatomic, retain) IBOutlet NSTextField *hotkeyStatusTextField;
@property (nonatomic, retain) IBOutlet NSButton *assistiveDeviceRegisterButton;

@property (nonatomic, retain) IBOutlet STGHotkeySelectView *hotkeyViewCaptureArea;
@property (nonatomic, retain) IBOutlet STGHotkeySelectView *hotkeyViewCaptureScreen;
@property (nonatomic, retain) IBOutlet STGHotkeySelectView *hotkeyViewUploadFile;

@property (nonatomic, assign) id<STGOptionsShortcutsDelegate> delegate;

+ (void)registerStandardDefaults:(NSMutableDictionary *)defaults;
- (void)saveProperties;

- (void)updateHotkeyStatus;
- (IBAction)registerAsAssistiveDevice:(id)sender;

- (NSEvent *)keyPressed:(NSEvent *)event;

@end

