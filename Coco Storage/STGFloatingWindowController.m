//
//  STGFloatingWindowController.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 18.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGFloatingWindowController.h"

#import "STGScreenOverlayWindow.h"

@interface STGFloatingWindowController ()

@end

@implementation STGFloatingWindowController

+ (STGFloatingWindowController *)floatingWindowController
{
    NSWindow *window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 100, 100) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    
    [window setHasShadow:NO];

    [window setMovableByWindowBackground:NO];
    [window setBackgroundColor:[NSColor clearColor]];
    [window setOpaque:NO];
    [window setLevel:CGShieldingWindowLevel()];
    
    return [[STGFloatingWindowController alloc] initWithWindow:window];
}

+ (STGFloatingWindowController *)overlayWindowController
{
    NSWindow *window = [[STGScreenOverlayWindow alloc] initWithContentRect:NSMakeRect(0, 0, 100, 100) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    
    [window setStyleMask:NSBorderlessWindowMask];
    [window setHasShadow:NO];
    
    [window setMovableByWindowBackground:NO];
    [window setBackgroundColor:[NSColor clearColor]];
    [window setOpaque:NO];
    [window setLevel:CGShieldingWindowLevel()];
    [window setSharingType:NSWindowSharingNone];
    [window setAcceptsMouseMovedEvents:YES];
    [window setIgnoresMouseEvents:NO];

    return [[STGFloatingWindowController alloc] initWithWindow:window];
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)awakeFromNib
{
    [[self window] setMovableByWindowBackground:NO];
    [[self window] setBackgroundColor:[NSColor clearColor]];
    [[self window] setOpaque:NO];
    [[self window] setLevel:CGShieldingWindowLevel()];
}

- (void)setContentView:(NSView *)view
{
    [[self window] setContentView:view];
}

- (id)contentView
{
    return [[self window] contentView];
}

@end
