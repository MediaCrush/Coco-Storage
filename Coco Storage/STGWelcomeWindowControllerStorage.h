//
//  STGWelcomeWindowController.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 01.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol STGWelcomeWindowControllerDelegate <NSObject>

- (void)openPreferences;

@end

@interface STGWelcomeWindowControllerStorage : NSWindowController

@property (nonatomic, assign) id<STGWelcomeWindowControllerDelegate> welcomeWCDelegate;

@property (nonatomic, retain) NSTrackingArea *trackingArea;

@property (nonatomic, retain) IBOutlet NSButton *showOnLaunchButton;

@property (nonatomic, retain) IBOutlet NSBox *storageKeyBox;
@property (nonatomic, retain) IBOutlet NSBox *cfsFolderBox;
@property (nonatomic, retain) IBOutlet NSBox *accountBox;

+ (void)registerStandardDefaults:(NSMutableDictionary *)defaults;
- (void)saveProperties;

- (IBAction)checkboxButtonClicked:(id)sender;

- (IBAction)openPreferences:(id)sender;
- (IBAction)openCFSFolder:(id)sender;
- (IBAction)openStorageAccount:(id)sender;


@end
