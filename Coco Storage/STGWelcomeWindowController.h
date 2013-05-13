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

@interface STGWelcomeWindowController : NSWindowController

@property (nonatomic, assign) id<STGWelcomeWindowControllerDelegate> welcomeWCDelegate;

@property (nonatomic, retain) IBOutlet NSTextView *changelogTextView;

- (IBAction)openPreferences:(id)sender;

@end
