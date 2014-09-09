//
//  STGOptionsQuickUploadViewController.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "STGPathChooserView.h"
#import "STGSoundPicker.h"

@interface STGOptionsQuickUploadViewController : NSViewController <STGPathChooserViewDelegate, STGSoundPickerDelegate>

@property (nonatomic, retain) IBOutlet STGPathChooserView *tempFolderChooser;

@property (nonatomic, retain) IBOutlet NSButton *keepFailedScreenshotsButton;
@property (nonatomic, retain) IBOutlet NSButton *keepAllScreenshotsButton;

@property (nonatomic, retain) IBOutlet NSButton *playSoundButton;
@property (nonatomic, retain) IBOutlet STGSoundPicker *finishSoundPicker;
@property (nonatomic, retain) IBOutlet NSButton *linkCopyToPasteboardButton;
@property (nonatomic, retain) IBOutlet NSButton *openLinkInBrowserButton;
@property (nonatomic, retain) IBOutlet NSButton *displayNotificationButton;
@property (nonatomic, retain) IBOutlet NSButton *playScreenshotSoundButton;

+ (void)registerStandardDefaults:(NSMutableDictionary *)defaults;
- (void)saveProperties;

- (IBAction)checkboxButtonClicked:(id)sender;

- (IBAction)openTempFolderInFinder:(id)sender;

@end
