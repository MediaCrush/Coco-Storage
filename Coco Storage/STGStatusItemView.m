//
//  STGStatusItemView.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 24.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGStatusItemView.h"

#import "STGDataCaptureManager.h"

#import "STGAPIConfiguration.h"

@implementation STGStatusItemView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self registerForDraggedTypes:[STGDataCaptureManager getSupportedPasteboardContentTypes]];
        
        [self setImageViewCell:[[NSImageCell alloc] initImageCell:nil]];
        
        int windowLevel = CGShieldingWindowLevel();
        NSRect screenRect = [[NSScreen mainScreen] frame];
        NSRect windowRect = NSMakeRect(screenRect.origin.x + screenRect.size.width / 3, screenRect.origin.y + screenRect.size.height / 2 - screenRect.size.height / 10, screenRect.size.width / 3, screenRect.size.height / 10 * 2);
        [self setOverlayWindow:[[NSWindow alloc] initWithContentRect:windowRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO screen:[NSScreen mainScreen]]];
        
        [_overlayWindow setReleasedWhenClosed:NO];
        [_overlayWindow setLevel:windowLevel];
        [_overlayWindow setBackgroundColor:[NSColor clearColor]];
        [_overlayWindow setAlphaValue:1.0];
        [_overlayWindow setOpaque:NO];
        [_overlayWindow setIgnoresMouseEvents:YES];
        [[_overlayWindow contentView] setWantsLayer:YES];
        [[[_overlayWindow contentView] layer] setFrame:[[_overlayWindow contentView] frame]];
        [[_overlayWindow contentView] layer].cornerRadius = 10.0;
        [[_overlayWindow contentView] layer].masksToBounds = YES;
        [[[_overlayWindow contentView] layer] setBackgroundColor:[[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.5] CGColor]];

        [self setOverlayWindowLabel:[[NSTextField alloc] init]];
        [_overlayWindowLabel setStringValue:@"Upload (Unknown)"];
        [_overlayWindowLabel setSelectable:NO];
        [_overlayWindowLabel setEditable:NO];
        [_overlayWindowLabel setBezeled:NO];
        [_overlayWindowLabel setAlignment:NSCenterTextAlignment];
        [_overlayWindowLabel setBackgroundColor:[NSColor clearColor]];
        [_overlayWindowLabel setTextColor:[NSColor whiteColor]];
        [_overlayWindowLabel setFont:[NSFont boldSystemFontOfSize:screenRect.size.height / 25]];
        [[_overlayWindow contentView] addSubview:_overlayWindowLabel];
        
        [self setUploadTypeVC:[[STGUploadTypeViewController alloc] initWithNibName:@"STGUploadTypeViewController" bundle:nil]];
        [[self uploadTypeVC] setDelegate:self];
        [[self uploadTypeVC] view]; // Load if not loaded
    }
    
    return self;
}

- (void)setMenu:(NSMenu *)menu
{
    [menu setDelegate:self];

    [super setMenu:menu];
}

- (void)mouseDown:(NSEvent *)event
{
    [_statusItem popUpStatusItemMenu:[_statusItem menu]]; // or another method that returns a menu
}

- (void)menuWillOpen:(NSMenu *)menu
{
    _highlight = YES;
    [self setNeedsDisplay:YES];
    
    if ([_delegate respondsToSelector:@selector(menuWillOpen:)])
    {
        [_delegate menuWillOpen:menu];
    }
}

- (void)menuDidClose:(NSMenu *)menu
{
    _highlight = NO;
    [self setNeedsDisplay:YES];
    
    if ([_delegate respondsToSelector:@selector(menuDidClose:)])
    {
        [_delegate menuDidClose:menu];
    }
}

- (void)setHighlighted:(BOOL)newFlag
{
    if (_highlight == newFlag) return;
    _highlight = newFlag;
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect
{
	[self.statusItem drawStatusBarBackgroundInRect:rect withHighlight:_highlight];
    NSPoint iconPoint = NSMakePoint(rect.origin.x + (rect.size.width - _image.size.width) / 2, rect.origin.y + (rect.size.height - _image.size.height) / 2 + 1);
    
    if (_highlight || _onDragging) //Makes templates gray in non-highlight :/
    {
        if (_onDragging)
        {
            [_imageViewCell setBackgroundStyle:NSBackgroundStyleLowered];
        }
        else if (_highlight)
        {
            [_imageViewCell setBackgroundStyle:NSBackgroundStyleDark];
        }
        else
        {
            [_imageViewCell setBackgroundStyle:NSBackgroundStyleLight];
        }
        
        [_imageViewCell drawInteriorWithFrame:NSMakeRect(iconPoint.x, iconPoint.y, [_image size].width, [_image size].height) inView:self];
    }
    else
    {
        [_image drawAtPoint:iconPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];        
    }

    [super drawRect:rect];
}

- (void)setImage:(NSImage *)image
{
    _image = image;
    [_imageViewCell setImage:image];
    
    [self setNeedsDisplay:YES];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    NSArray *actions = [STGDataCaptureManager getActionsFromPasteboard:[sender draggingPasteboard]];
    actions = [STGAPIConfiguration validUploadActions:actions forConfiguration:[STGAPIConfiguration currentConfiguration]];
    
    if ([actions count] > 0)
    {
        NSString *displayString = [STGDataCaptureManager getNameForAction:[[actions objectAtIndex:0] integerValue]];
        
        if (displayString)
        {
            NSRect screenRect = [[NSScreen mainScreen] frame];
            
            if (screenRect.size.height / 25 != [[[[_overlayWindowLabel font] fontDescriptor] objectForKey:NSFontSizeAttribute] floatValue])
                [_overlayWindowLabel setFont:[NSFont boldSystemFontOfSize:screenRect.size.height / 25]];
            
            CGSize textSize = NSSizeToCGSize([displayString sizeWithAttributes:[NSDictionary dictionaryWithObject:[_overlayWindowLabel font] forKey:NSFontAttributeName]]);
            
            NSRect windowRect = NSMakeRect(screenRect.origin.x + (screenRect.size.width - textSize.width * 1.2) / 2, screenRect.origin.y + (screenRect.size.height - textSize.height * 1.2) / 2, textSize.width * 1.2, textSize.height * 1.2);
            NSRect contentRect = NSMakeRect(0, 0, windowRect.size.width, windowRect.size.height);
            
            [_overlayWindow setFrame:windowRect display:NO];
            [_overlayWindow setAlphaValue:0.0];
            [_overlayWindow orderFront:self];
            [_overlayWindowLabel setFrame:contentRect];
            [_overlayWindowLabel setStringValue:displayString];
            
            NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:_overlayWindow, NSViewAnimationTargetKey, NSViewAnimationFadeInEffect, NSViewAnimationEffectKey, nil]]];
            
            [animation setAnimationBlockingMode: NSAnimationNonblockingThreaded];
            [animation setDuration:0.2];
            
            [animation startAnimation];
            
            [self setOnDragging:YES];
            [self setNeedsDisplay:YES];
            
            [[self uploadTypeVC] setUploadTypes:actions fromDragging:YES];
            [[self uploadTypeVC] showRelativeToRect:[self bounds] ofView:self preferredEdge:CGRectMinYEdge];
            
            return NSDragOperationCopy;
        }
    }
    
    return NSDragOperationNone;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    if (_onDragging)
    {
        [self setOnDragging:NO];
        [self setNeedsDisplay:YES];
        
        if ([_overlayWindow isVisible])
        {
            NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:_overlayWindow, NSViewAnimationTargetKey, NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey, nil]]];
            
            [animation setAnimationBlockingMode: NSAnimationNonblockingThreaded];
            [animation setDuration:0.2];
            
            [animation startAnimation];
        }        

//        [[self uploadTypeVC] hide];
    }
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender
{
    if (_onDragging)
    {
        [self setOnDragging:NO];
        [self setNeedsDisplay:YES];
        
        if ([_overlayWindow isVisible])
        {
            NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:_overlayWindow, NSViewAnimationTargetKey, NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey, nil]]];
            
            [animation setAnimationBlockingMode: NSAnimationNonblockingThreaded];
            [animation setDuration:0.2];
            
            [animation startAnimation];
        }

        [[self uploadTypeVC] hide];
    }
}

-(BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pBoard = [sender draggingPasteboard];

    NSArray *actions = [STGDataCaptureManager getActionsFromPasteboard:pBoard];
    actions = [STGAPIConfiguration validUploadActions:actions forConfiguration:[STGAPIConfiguration currentConfiguration]];
    
    if ([actions count] > 0)
    {
        NSUInteger action = [[actions objectAtIndex:0] unsignedIntegerValue];
        NSArray *entries = [STGDataCaptureManager captureDataFromPasteboard:pBoard withAction:action];
        
        if (entries && [entries count] > 0)
        {
            if ([_delegate respondsToSelector:@selector(uploadEntries:)])
            {
                [_delegate uploadEntries:entries];
                
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)displayForUploadTypes:(NSArray *)types
{
    [[self uploadTypeVC] setUploadTypes:types fromDragging:NO];
    [[self uploadTypeVC] showRelativeToRect:[self bounds] ofView:self preferredEdge:CGRectMinYEdge];
}

- (void)uploadTypeViewController:(STGUploadTypeViewController *)viewController choseType:(STGUploadAction)action
{
    NSPasteboard *pBoard = [NSPasteboard generalPasteboard];
    
    NSArray *entries = [STGDataCaptureManager captureDataFromPasteboard:pBoard withAction:action];
    
    if (entries && [entries count] > 0)
    {
        if ([_delegate respondsToSelector:@selector(uploadEntries:)])
        {
            [_delegate uploadEntries:entries];
        }
    }
    
    [[self uploadTypeVC] hide];
}

- (void)uploadTypeViewController:(STGUploadTypeViewController *)viewController choseType:(STGUploadAction)action whileDragging:(id<NSDraggingInfo>)sender
{
    NSPasteboard *pBoard = [sender draggingPasteboard];
    
    NSArray *entries = [STGDataCaptureManager captureDataFromPasteboard:pBoard withAction:action];

    if (entries && [entries count] > 0)
    {
        if ([_delegate respondsToSelector:@selector(uploadEntries:)])
        {
            [_delegate uploadEntries:entries];
        }
    }
    
    [[self uploadTypeVC] hide];
}

- (void)uploadTypeViewController:(STGUploadTypeViewController *)viewController draggingEnded:(id<NSDraggingInfo>)sender
{
    [[self uploadTypeVC] hide];
}

- (void)uploadTypeViewController:(STGUploadTypeViewController *)viewController draggingExited:(id<NSDraggingInfo>)sender
{
    [[self uploadTypeVC] hide];
}

@end
