//
//  STGOptionsGeneralViewController.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 24.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MASPreferencesWindowController.h"

#import "STGOptionTextField.h"

@interface STGOptionsGeneralViewController : NSViewController <MASPreferencesViewController, STGOptionTextFieldDelegate>

@property (nonatomic, retain) IBOutlet NSButton *launchOnStartupButton;
@property (nonatomic, retain) IBOutlet NSButton *showDockIconButton;
@property (nonatomic, retain) IBOutlet NSButton *autoUpdateButton;

@property (nonatomic, retain) IBOutlet NSTextField *keyTextField;

+ (void)registerStandardDefaults:(NSMutableDictionary *)defaults;
- (void)saveProperties;

- (IBAction)checkboxButtonClicked:(id)sender;

- (IBAction)openStorageKeysPage:(id)sender;

- (IBAction)checkForUpdates:(id)sender;

@end
