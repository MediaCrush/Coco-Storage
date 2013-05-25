//
//  STGStatusItemView.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 24.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGStatusItemView.h"

#import "STGFileHelper.h"

#import "STGDataCaptureManager.h"

@implementation STGStatusItemView

@synthesize delegate = _delegate;

@synthesize statusItem = _statusItem;
@synthesize highlight = _highlight;
@synthesize onDragging = _onDragging;

@synthesize image = _image;
@synthesize imageViewCell = _imageViewCell;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self registerForDraggedTypes:[STGDataCaptureManager getSupportedPasteboardContentTypes]];
        
        [self setImageViewCell:[[NSImageCell alloc] initImageCell:nil]];
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
    [self setOnDragging:YES];
    [self setNeedsDisplay:YES];
    
    return NSDragOperationCopy;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    [self setOnDragging:NO];
    [self setNeedsDisplay:YES];
}

-(BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pBoard = [sender draggingPasteboard];

    NSArray *entries = [STGDataCaptureManager captureDataFromPasteboard:pBoard];
    
    if (entries && [entries count] > 0)
    {
        if ([_delegate respondsToSelector:@selector(uploadEntries:)])
        {
            [_delegate uploadEntries:entries];
            
            return YES;
        }
    }
        
    return NO;
}

@end
