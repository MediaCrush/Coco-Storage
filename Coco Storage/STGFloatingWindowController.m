//
//  STGFloatingWindowController.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 18.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGFloatingWindowController.h"

@interface STGFloatingWindowController ()

@end

@implementation STGFloatingWindowController

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
    [[self window] setLevel:NSFloatingWindowLevel];
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
