//
//  STGOptionsCFSViewController.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "STGOptionTextField.h"

@interface STGOptionsCFSViewController : NSViewController <STGOptionTextFieldDelegate>

@property (nonatomic, retain) IBOutlet NSTextField *cfsFolderTextField;

@property (nonatomic, retain) IBOutlet NSButton *playSoundButton;
@property (nonatomic, retain) IBOutlet NSPopUpButton *selectSoundButton;
@property (nonatomic, retain) IBOutlet NSButton *displayNotificationButton;

+ (void)registerStandardDefaults:(NSMutableDictionary *)defaults;
- (void)saveProperties;

- (IBAction)checkboxButtonClicked:(id)sender;

- (IBAction)resetCfsFolderClicked:(id)sender;
- (IBAction)openCfsFolderDialogue:(id)sender;
- (IBAction)openCfsFolderInFinder:(id)sender;

@end
