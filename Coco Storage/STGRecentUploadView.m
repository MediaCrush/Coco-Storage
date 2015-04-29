//
//  STGRecentUploadView.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 29.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGRecentUploadView.h"

@implementation STGRecentUploadView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setUp];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self)
    {
        [self setUp];
    }
    
    return self;
}

- (void)setUp
{
    CALayer *blurLayer = [CALayer layer];
    [self setWantsLayer:YES];
    [self setLayer:blurLayer];
    
    // Set up the default parameters
    _blurRadius = 20;
    _saturationFactor = 2.5;
    [self setTintColor:[NSColor whiteColor]];
    
    // It's important to set the layer to mask to its bounds, otherwise the whole parent view
    /// might get blurred
    [self.layer setMasksToBounds:YES];
    
    // To apply CIFilters on OS X 10.9, we need to set the property accordingly:
    if ([self respondsToSelector:@selector(setLayerUsesCoreImageFilters:)])
        [self setLayerUsesCoreImageFilters:YES];
    
    // Set the layer to redraw itself once it's size is changed
    [self.layer setNeedsDisplayOnBoundsChange:YES];
    
    // Initially create the filter instances
    [self resetFilters];
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
        [self removeTrackingArea:_trackingArea];
    
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
        [_titleTextField setTextColor:[NSColor highlightColor]];
        [_subTitleTextField setTextColor:[NSColor highlightColor]];
        [self setTintColor:[NSColor selectedMenuItemColor]];
    }
    else
    {
        [_titleTextField setTextColor:[NSColor labelColor]];
        [_subTitleTextField setTextColor:[NSColor secondaryLabelColor]];
        [self setTintColor:[NSColor clearColor]];
    }
}

- (void) setTintColor:(NSColor *)tintColor
{
    _tintColor = tintColor;
    
    // Since we need a CGColor reference, store it for the drawing of the layer.
    if (_tintColor)
    {
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        [self.layer setBackgroundColor:_tintColor.CGColor];
        [CATransaction commit];
    }
    
    // Trigger a re-drawing of the layer
    [self.layer setNeedsDisplay];
}

- (void)setBlurRadius:(float)blurRadius
{
    // Setting the blur radius requires a resetting of the filters
    _blurRadius = blurRadius;
    [self resetFilters];
}

- (void) setSaturationFactor:(float)saturationFactor
{
    // Setting the saturation factor also requires a resetting of the filters
    _saturationFactor = saturationFactor;
    [self resetFilters];
}

- (void)resetFilters
{
    // To get a higher color saturation, we create a ColorControls filter
    _saturationFilter = [CIFilter filterWithName:@"CIColorControls"];
    [_saturationFilter setDefaults];
    [_saturationFilter setValue:[NSNumber numberWithFloat:_saturationFactor]
                         forKey:@"inputSaturation"];
    
    // Next, we create the blur filter
    _blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [_blurFilter setDefaults];
    [_blurFilter setValue:[NSNumber numberWithFloat:_blurRadius] forKey:@"inputRadius"];
    
    // Now we apply the two filters as the layer's background filters
    [self.layer setBackgroundFilters:@[_saturationFilter,_blurFilter]];
    
    // ... and trigger a refresh
    [self.layer setNeedsDisplay];
}

@end
