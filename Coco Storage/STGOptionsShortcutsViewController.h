//
//  STGOptionsShortcutsViewController.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 24.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MASPreferencesWindowController.h"

@protocol STGOptionsShortcutsDelegate <NSObject>

- (void)updateShortcuts;
- (void)registerAsAssistiveDevice;
- (BOOL)hotkeysEnabled;

@end

@interface STGOptionsShortcutsViewController : NSViewController <MASPreferencesViewController>

@property (nonatomic, retain) IBOutlet NSTextField *hotkeyStatusTextField;
@property (nonatomic, retain) IBOutlet NSButton *assistiveDeviceRegisterButton;

@property (nonatomic, retain) IBOutlet NSTextField *hotkeyCaptureAreaTextField;
@property (nonatomic, retain) IBOutlet NSTextField *hotkeyCaptureFullScreenTextField;
@property (nonatomic, retain) IBOutlet NSTextField *hotkeyCaptureFileTextField;
@property (nonatomic, retain) IBOutlet NSTextField *hotkeyShowQuickCaptureTextField;

@property (nonatomic, assign) id<STGOptionsShortcutsDelegate> delegate;

+ (void)registerStandardDefaults:(NSMutableDictionary *)defaults;
- (void)saveProperties;

- (void)updateHotkeyStatus;
- (IBAction)registerAsAssistiveDevice:(id)sender;

- (IBAction)resetHotkeyCaptureArea:(id)sender;
- (IBAction)resetHotkeyCaptureFullScreen:(id)sender;
- (IBAction)resetHotkeyCaptureFile:(id)sender;
- (IBAction)resetHotkeyShowQuickCapture:(id)sender;

- (IBAction)disableHotkeyCaptureArea:(id)sender;
- (IBAction)disableHotkeyCaptureFullScreen:(id)sender;
- (IBAction)disableHotkeyCaptureFile:(id)sender;
- (IBAction)disableHotkeyShowQuickCapture:(id)sender;

- (NSEvent *)keyPressed:(NSEvent *)event;

@end

