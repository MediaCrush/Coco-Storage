//
//  STGQuickUploadWindowController.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 27.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGQuickUploadWindowController.h"

@interface STGQuickUploadWindowController ()

@end

@implementation STGQuickUploadWindowController

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
    [[self window] setMovableByWindowBackground:YES];
    [[self window] setBackgroundColor:[NSColor clearColor]];
    [[self window] setOpaque:NO];
    [[self window] setLevel:NSFloatingWindowLevel];
}

-(void)uploadEntries:(NSArray *)entries
{
    if ([_delegate respondsToSelector:@selector(uploadEntries:)])
    {
        [_delegate uploadEntries:entries];
    }
}

- (IBAction)paste:(id)sender
{
    [_quickUploadView paste];
}

- (BOOL)validateUserInterfaceItem:(id )anItem
{
    if ([anItem action] == @selector(paste:))
		return YES;
    
    return NO;
}

@end
