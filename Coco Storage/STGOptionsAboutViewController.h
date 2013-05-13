//
//  STGOptionsAboutViewController.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 25.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface STGOptionsAboutViewController : NSViewController

@property (nonatomic, retain) IBOutlet NSTextField *versionLabel;

+ (void)registerStandardDefaults:(NSMutableDictionary *)defaults;
- (void)saveProperties;

- (IBAction)sendEmailToIvorius:(id)sender;
- (IBAction)sendEmailToClone:(id)sender;
- (IBAction)openStorageLink:(id)sender;

- (IBAction)openMASPreferencesLink:(id)sender;

@end
