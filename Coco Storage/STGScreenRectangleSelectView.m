//
//  STGScreenRectangleSelectView.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 20.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGScreenRectangleSelectView.h"

@interface STGScreenRectangleSelectView ()

@property (nonatomic, assign) BOOL isMouseDown;

@end

@implementation STGScreenRectangleSelectView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSImage *selectionCursorImage = [[NSImage alloc] initWithContentsOfFile:@"/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/HIServices.framework/Versions/A/Resources/cursors/screenshotselection/cursor.pdf"];
        [self setSelectionCursor:[[NSCursor alloc] initWithImage:selectionCursorImage hotSpot:NSMakePoint(15, 15)]];

        NSImage *windowCursorImage = [[NSImage alloc] initWithContentsOfFile:@"/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/HIServices.framework/Versions/A/Resources/cursors/screenshotwindow/cursor.pdf"];
        [self setWindowSelectionCursor:[[NSCursor alloc] initWithImage:windowCursorImage hotSpot:NSMakePoint(14, 11)]];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    
    if (_windowSelectMode)
    {
        NSRect windowRect = [self convertRect:[[self window] convertRectFromScreen:[self currentWindowRect]] fromView:nil];
        CGContextSetRGBFillColor(context, 0.0, 0.5, 1.0, 0.2);
        CGContextFillRect(context, windowRect);
    }
    else if (_isMouseDown)
    {
        CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 0.1);
        CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
        
        NSRect drawRect = [self convertRect:[[self window] convertRectFromScreen:[self currentSelectedRect]] fromView:nil];
        CGContextFillRect(context, drawRect);
        CGContextStrokeRectWithWidth(context, drawRect, 1.0);
    }
}

- (void)resetCursorRects
{
    [self addCursorRect:NSMakeRect(_bounds.origin.x, _bounds.origin.y, _bounds.size.width, _bounds.size.height) cursor:_windowSelectMode ? _windowSelectionCursor : _selectionCursor];
}

- (void)setWindowSelectMode:(BOOL)windowSelectMode
{
    _windowSelectMode = windowSelectMode;
    
    [self setNeedsDisplay:YES];
    [[self window] invalidateCursorRectsForView:self];
}

- (void)setMouseDownPoint:(NSPoint)mouseDownPoint
{
    _mouseDownPoint = mouseDownPoint;
    
    [self setNeedsDisplay:YES];
}

- (void)cancelOperation:(id)sender
{
    [[self window] close];
    
    if ([_delegate respondsToSelector:@selector(screenRectangleSelectViewCanceled:)])
        [_delegate screenRectangleSelectViewCanceled:self];
}

- (void)keyDown:(NSEvent *)theEvent
{
    if ([theEvent keyCode] == 49) // Space
    {
        [self setWindowSelectMode:!_windowSelectMode];
    }
    else
        [super keyDown:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [self setMouseDownPoint:[NSEvent mouseLocation]];
    [self setIsMouseDown:YES];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if (_windowSelectMode || _isMouseDown)
    {
        NSRect selectedRect = _windowSelectMode ? [self currentWindowRect] : [self currentSelectedRect];
        
        [self setIsMouseDown:NO];
        
        [self setNeedsDisplay:YES];
        [[self window] close];
        
        if ([_delegate respondsToSelector:@selector(screenRectangleSelectView:didSelectRectangle:)])
            [_delegate screenRectangleSelectView:self didSelectRectangle:selectedRect];
    }
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    [self setNeedsDisplay:YES];    
}

- (NSRect)currentWindowRect
{
    NSArray *array = (NSArray *)CFBridgingRelease(CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID));
    NSPoint mousePoint = [NSEvent mouseLocation];
    
    NSRect highestRect = NSZeroRect;
    long *highestLevel = nil;

    NSScreen *screen = [[self window] screen];
    
    for (NSDictionary *windowInfo in array)
    {
//        NSLog(@"WINDOW %@", [windowInfo objectForKey:(id)kCGWindowName]);

        int sharingState = [[windowInfo objectForKey:(id)kCGWindowSharingState] intValue];
        if(sharingState != kCGWindowSharingNone && ![[windowInfo objectForKey:(id)kCGWindowName] isEqualToString:@"Dock"])
        {
            long windowLevel = [[windowInfo objectForKey:(id)kCGWindowLayer] intValue];
            
            if (highestLevel == nil || windowLevel > *highestLevel)
            {
                NSRect windowRect;
                CGRectMakeWithDictionaryRepresentation((CFDictionaryRef)[windowInfo objectForKey:(id)kCGWindowBounds],&windowRect);
                windowRect = NSScreenRectFromWindowBounds(screen, windowRect);
                
                if (NSPointInRect(mousePoint, windowRect))
                {
                    highestRect = windowRect;
                    highestLevel = &windowLevel;
                }
            }
        }
    }
    
    return highestRect;
}

- (NSRect)currentSelectedRect
{
    NSPoint mousePoint = [NSEvent mouseLocation];
    CGFloat minX = MIN(_mouseDownPoint.x, mousePoint.x);
    CGFloat minY = MIN(_mouseDownPoint.y, mousePoint.y);
    CGFloat maxX = MAX(_mouseDownPoint.x, mousePoint.x);
    CGFloat maxY = MAX(_mouseDownPoint.y, mousePoint.y);
    return NSMakeRect(minX, minY, maxX - minX, maxY - minY);
}

NSRect NSScreenRectFromWindowBounds(NSScreen *screen, NSRect rect)
{
    return NSMakeRect(rect.origin.x, [screen frame].size.height - rect.origin.y - rect.size.height, rect.size.width, rect.size.height);
}

NSRect NSRectMove(NSRect rect, NSPoint byPoint)
{
    return NSMakeRect(rect.origin.x + byPoint.x, rect.origin.y + byPoint.y, rect.size.width, rect.size.height);
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

@end
