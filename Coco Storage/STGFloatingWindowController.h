//
//  STGFloatingWindowController.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 18.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface STGFloatingWindowController : NSWindowController

+ (STGFloatingWindowController *)floatingWindowController;
+ (STGFloatingWindowController *)overlayWindowController;

- (void)setContentView:(NSView *)view;
- (id)contentView;

@end
