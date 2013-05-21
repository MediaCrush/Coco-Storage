//
//  STGRecentUploadView.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 29.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGRecentUploadView.h"

@implementation STGRecentUploadView

@synthesize recentUploadDelegate = _recentUploadDelegate;

@synthesize captureEntry = _captureEntry;

@synthesize trackingArea = _trackingArea;
@synthesize isHighlighted = _isHighlighted;

- (void)drawRect:(NSRect)dirtyRect
{
    if (_isHighlighted)
        [[NSColor selectedMenuItemColor] set];
    else
        [[NSColor whiteColor] set];
    
    [NSBezierPath fillRect:dirtyRect];

    [super drawRect:dirtyRect];
}

-(void)mouseEntered:(NSEvent *)theEvent
{
    [self setIsHighlighted:YES];
    
    [self setNeedsDisplay:YES];
}

-(void)mouseExited:(NSEvent *)theEvent
{
    [self setIsHighlighted:NO];
    
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if ([_recentUploadDelegate respondsToSelector:@selector(recentUploadView:clicked:)])
    {
        [_recentUploadDelegate recentUploadView:self clicked:theEvent];
    }
}

-(void)updateTrackingAreas
{
    if(_trackingArea)
    {
        [self removeTrackingArea:_trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    [self setTrackingArea:[[NSTrackingArea alloc] initWithRect:[self bounds] options:opts owner:self userInfo:nil]];
    [self addTrackingArea:_trackingArea];
    
    [super updateTrackingAreas];
}

- (void)setIsHighlighted:(BOOL)isHighlighted
{
    _isHighlighted = isHighlighted;
    
    if (_isHighlighted)
    {
        [(NSTextField *)[self viewWithTag:11] setTextColor:[NSColor highlightColor]];
        [(NSTextField *)[self viewWithTag:12] setTextColor:[NSColor colorWithCalibratedRed:0.646445 green:0.867147 blue:1.0 alpha:1.0]];
    }
    else
    {
        [(NSTextField *)[self viewWithTag:11] setTextColor:[NSColor textColor]];
        [(NSTextField *)[self viewWithTag:12] setTextColor:[NSColor colorWithCalibratedRed:0.389645 green:0.522673 blue:0.60275 alpha:1.0]];
    }
}

@end
