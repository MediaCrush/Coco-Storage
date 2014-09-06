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

@interface STGHotkeyViewEntry : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *userDefaultsKey;

@property (nonatomic, retain) NSString *defaultHotkey;
@property (nonatomic, assign) NSUInteger defaultModifiers;

+ (STGHotkeyViewEntry *)entryWithTitle:(NSString *)title key:(NSString *)defaultsKey defaultKey:(NSString *)key defaultModifiers:(NSUInteger)modifiers;

@end

@interface STGOptionsShortcutsViewController : NSViewController <MASPreferencesViewController, STGHotkeySelectViewDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, retain) IBOutlet NSTextField *hotkeyStatusTextField;
@property (nonatomic, retain) IBOutlet NSButton *assistiveDeviceRegisterButton;

@property (nonatomic, retain) IBOutlet NSTableView *hotkeyTableView;

@property (nonatomic, assign) id<STGOptionsShortcutsDelegate> delegate;

+ (void)registerStandardDefaults:(NSMutableDictionary *)defaults;
- (void)saveProperties;

- (void)updateHotkeyStatus;
- (IBAction)registerAsAssistiveDevice:(id)sender;

- (NSEvent *)keyPressed:(NSEvent *)event;

@end

