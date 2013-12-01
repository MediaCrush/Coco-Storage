//
//  STGTypeChooserView.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 29.11.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGTypeChooserView.h"

#import "STGTypeChooserViewType.h"
#import "STGDataCaptureManager.h"

@interface STGTypeChooserView ()

@property (nonatomic, retain) NSTimer *selectionUpdateTimer;

@property (nonatomic, retain) NSMutableArray *typeArray;
@property (nonatomic, retain) NSMutableArray *typeViewArray;

@property (nonatomic, assign) NSRect previousSelectionRect;
@property (nonatomic, assign) NSRect nextSelectionRect;
@property (nonatomic, assign) CGFloat nextSelectionRectRatio;

- (void)updateSubviewsForTypes;
- (void)updateSubviewFrames;

- (void)startNewSelectionRectAnimation:(BOOL)animated;
- (NSRect)getCurrentSelectionRect;

- (void)updateSelectionRect:(NSTimer *)timer;

@end

@implementation STGTypeChooserView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setDragMode:NO];
        
        [self setLabelTextField:[[NSTextField alloc] init]];
        [[self labelTextField] setEditable:NO];
        [[self labelTextField] setBezeled:NO];
        [[self labelTextField] setDrawsBackground:NO];
        [[self labelTextField] setTextColor:[NSColor colorWithCalibratedRed:0.4f green:0.4f blue:0.4f alpha:1.0f]];
        [self addSubview:[self labelTextField]];
        
        [self setSelectionFillGradient:[[NSGradient alloc] initWithColorsAndLocations:[NSColor colorWithCalibratedRed:0.547 green:0.551 blue:1.0 alpha:0.6],0.0,[NSColor colorWithCalibratedRed:0.527 green:0.527 blue:0.939 alpha:0.6],0.5,[NSColor colorWithCalibratedRed:0.380 green:0.388 blue:0.996 alpha:0.6],0.5,[NSColor colorWithCalibratedRed:0.337 green:0.337 blue:0.957 alpha:0.6],1.0, nil]];
        [self setSelectionStrokeColor:[NSColor colorWithCalibratedRed:0.0f green:0.0f blue:0.9f alpha:1.0f]];
    }
    return self;
}

- (void)setDragMode:(BOOL)dragMode
{
    _dragMode = dragMode;
    
    [self unregisterDraggedTypes];
    
    if (dragMode)
        [self registerForDraggedTypes:[STGDataCaptureManager getSupportedPasteboardContentTypes]];
}

-(void)updateTrackingAreas
{
    if(_trackingArea)
    {
        [self removeTrackingArea:_trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways);
    [self setTrackingArea:[[NSTrackingArea alloc] initWithRect:[self bounds] options:opts owner:self userInfo:nil]];
    [self addTrackingArea:_trackingArea];
    
    [super updateTrackingAreas];
}

- (void)awakeFromNib
{
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    
//    CGContextRef currentContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    
    if ([self highlightedType] != nil)
    {
        NSRect selectionBounds = [self getCurrentSelectionRect];
        
        NSBezierPath *path = [NSBezierPath bezierPath];
        [path appendBezierPathWithRoundedRect:selectionBounds xRadius:5 yRadius:5];
        
        [[self selectionFillGradient] drawInBezierPath:path angle:-90.0];
        
        [[self selectionStrokeColor] set];
        [path stroke];
    }
}

- (void)clearTypes
{
    [self setTypeArray:[[NSMutableArray alloc] init]];
    [self updateSubviewsForTypes];

    [self setHighlightedType:nil];
}

- (void)setTypes:(NSArray *)types
{
    [self setTypeArray:[types mutableCopy]];
    [self updateSubviewsForTypes];
    
    [self setHighlightedType:nil];
}

- (void)addType:(STGTypeChooserViewType *)type
{
    if (![self typeArray])
        [self setTypeArray:[[NSMutableArray alloc] init]];
    
    [[self typeArray] addObject:type];
    [self updateSubviewsForTypes];
}

- (NSArray *)types
{
    return [self typeArray];
}

- (void)updateSubviewsForTypes
{
    if (![self typeViewArray])
        [self setTypeViewArray:[[NSMutableArray alloc] init]];
    
    for (NSInteger i = 0; i < [[self typeViewArray] count]; i++)
    {
        [[[self typeViewArray] objectAtIndex:i] removeFromSuperview];
    }
    
    [[self typeViewArray] removeAllObjects];
    
    for (NSInteger i = 0; i < [[self typeArray] count]; i++)
    {
        NSImageView *imageView = [[NSImageView alloc] init];
        [imageView setImageScaling:NSImageScaleProportionallyUpOrDown];
        [imageView setImage:[[[self typeArray] objectAtIndex:i] image]];
        [imageView setEditable:NO];
        [imageView unregisterDraggedTypes];
        
        [self addSubview:imageView];
        [[self typeViewArray] addObject:imageView];
    }
    
    [self updateSubviewFrames];
}

- (void)updateSubviewFrames
{
    NSInteger sideInset = 8;
    NSInteger stepSpace = 4;
    NSInteger labelSpace = 5;
    NSInteger labelHeight = 17;
    
    CGFloat stepSize = 1.0f / [[self typeArray] count] * ([self bounds].size.width - sideInset * 2 - ([[self typeViewArray] count] - 1) * stepSpace);

    for (NSInteger i = 0; i < [[self typeViewArray] count]; i++)
    {
        [[[self typeViewArray] objectAtIndex:i] setFrame:NSMakeRect(i * stepSize + sideInset + i * stepSpace, labelHeight + labelSpace, stepSize, [self bounds].size.height - labelHeight - labelSpace - sideInset)];
    }

    [[self labelTextField] setFrame:NSMakeRect(0, 0, [self bounds].size.width, labelHeight)];
}

- (void)setFrame:(NSRect)frameRect
{
    [super setFrame:frameRect];
    [self updateSubviewFrames];
    
    if ([self nextSelectionRectRatio] == 1.0f)
        [self setHighlightedType:[self highlightedType] animated:NO];
}

- (void)setHighlightedType:(STGTypeChooserViewType *)type animated:(BOOL)animated
{
    _highlightedType = type;
    
    if ([self highlightedType])
        [[self labelTextField] setStringValue:[[self highlightedType] name]];
    else
        [[self labelTextField] setStringValue:@""];
    
    [self setNeedsDisplay:YES];
    
    [self startNewSelectionRectAnimation:animated];
    if (![self selectionUpdateTimer])
        [self setSelectionUpdateTimer:[NSTimer scheduledTimerWithTimeInterval:0.025 target:self selector:@selector(updateSelectionRect:) userInfo:nil repeats:YES]];
}

- (void)setHighlightedType:(STGTypeChooserViewType *)highlightedType
{
    [self setHighlightedType:highlightedType animated:YES];
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    return NSDragOperationDelete;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    if ([[self delegate] respondsToSelector:@selector(chooserView:draggingExited:)])
        [[self delegate] chooserView:self draggingExited:sender];
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender
{
    if ([[self delegate] respondsToSelector:@selector(chooserView:draggingEnded:)])
        [[self delegate] chooserView:self draggingEnded:sender];
}

-(BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    for (NSInteger i = 0; i < [[self typeViewArray] count]; i++)
    {
        if (NSPointInRect([sender draggingLocation], [self convertRect:[[[self typeViewArray] objectAtIndex:i] frame] toView:nil]))
        {
            if ([[self delegate] respondsToSelector:@selector(chooserView:choseType:whileDragging:)])
                [[self delegate] chooserView:self choseType:[[self typeArray] objectAtIndex:i] whileDragging:sender];
            
            return YES;
        }
    }
    
    return NO;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender
{
    for (NSInteger i = 0; i < [[self typeViewArray] count]; i++)
    {
        if (NSPointInRect([sender draggingLocation], [self convertRect:[[[self typeViewArray] objectAtIndex:i] frame] toView:nil]))
        {
            [self setHighlightedType:[[self typeArray] objectAtIndex:i]];
 
            return NSDragOperationCopy;
        }
    }

    return NSDragOperationDelete;
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    for (NSInteger i = 0; i < [[self typeViewArray] count]; i++)
    {
        if (NSPointInRect([theEvent locationInWindow], [self convertRect:[[[self typeViewArray] objectAtIndex:i] frame] toView:nil]))
        {
            [self setHighlightedType:[[self typeArray] objectAtIndex:i]];
        }
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if (![self dragMode])
    {
        for (NSInteger i = 0; i < [[self typeViewArray] count]; i++)
        {
            if (NSPointInRect([theEvent locationInWindow], [self convertRect:[[[self typeViewArray] objectAtIndex:i] frame] toView:nil]))
            {
                if ([[self delegate] respondsToSelector:@selector(chooserView:choseType:)])
                    [[self delegate] chooserView:self choseType:[[self typeArray] objectAtIndex:i]];
            }
        }
    }
}

- (void)startNewSelectionRectAnimation:(BOOL)animated
{
    NSRect prevRect = [self getCurrentSelectionRect];

    NSInteger index = [[self typeArray] indexOfObject:[self highlightedType]];
    
    if (index != NSNotFound)
    {
        NSRect frame = [[[self typeViewArray] objectAtIndex:index] frame];
        NSInteger frameScale = 3;
        NSRect selectionBounds = NSMakeRect(frame.origin.x - frameScale, frame.origin.y - frameScale, frame.size.width + frameScale * 2, frame.size.height + frameScale * 2);
        
        BOOL prevExists = !NSEqualRects(prevRect, NSZeroRect);
        [self setPreviousSelectionRect: prevExists ? prevRect : selectionBounds];
        [self setNextSelectionRect:selectionBounds];
        [self setNextSelectionRectRatio:(prevExists && animated) ? 0.0f : 1.0f];
    }
    else
    {
        [self setPreviousSelectionRect:NSZeroRect];
        [self setNextSelectionRect:NSZeroRect];
        [self setNextSelectionRectRatio:1.0f];
    }
}

- (NSRect)getCurrentSelectionRect
{
    CGFloat ratio2 = [self nextSelectionRectRatio];
    CGFloat ratio1 = 1.0f - ratio2;

    NSRect rect1 = [self previousSelectionRect];
    NSRect rect2 = [self nextSelectionRect];
    
    return NSMakeRect(rect1.origin.x * ratio1 + rect2.origin.x * ratio2, rect1.origin.y * ratio1 + rect2.origin.y * ratio2, rect1.size.width * ratio1 + rect2.size.width * ratio2, rect1.size.height * ratio1 + rect2.size.height * ratio2);
}

- (void)updateSelectionRect:(NSTimer *)timer
{
    if ([self nextSelectionRectRatio] < 1.0f)
        [self setNextSelectionRectRatio:[self nextSelectionRectRatio] + 0.3f];
    
    if ([self nextSelectionRectRatio] > 1.0f)
        [self setNextSelectionRectRatio:1.0f];
    
    [self setNeedsDisplay:YES];
    
    if ([self nextSelectionRectRatio] == 1.0f)
    {
        [timer invalidate];
        [self setSelectionUpdateTimer:nil];
    }
}

@end
