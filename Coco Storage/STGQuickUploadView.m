//
//  STGQuickUploadView.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 27.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGQuickUploadView.h"

#import "STGDataCaptureManager.h"

@interface STGQuickUploadView ()

- (NSRect)getRectAtPosition:(NSInteger)pos withActions:(NSInteger)actionCount;
- (BOOL)isMouseInRect:(NSInteger)pos withActions:(NSInteger)actionCount;
- (NSString *)getDisplayString:(NSInteger)pos pasteboard:(BOOL)fromPasteboard shortV:(BOOL)shortVersion;

- (BOOL)uploadFromPasteboard:(NSPasteboard *)pBoard actions:(NSArray *)actions needsRectangle:(BOOL)needsRectangle;

@end

@implementation STGQuickUploadView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self registerForDraggedTypes:[STGDataCaptureManager getSupportedPasteboardContentTypes]];
                
        [self setWantsLayer:YES];
        [self layer].cornerRadius = 10.0;
        [self layer].masksToBounds = YES;
        [[self layer] setBackgroundColor:[[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:0.5] CGColor]];
        
        [self setDisplayFont:[NSFont boldSystemFontOfSize:25.0]];
        [self setLineColor:[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:1.0 alpha:0.5]];        
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    NSRect innerRect = CGRectMake(dirtyRect.origin.x + 12.0, dirtyRect.origin.y + 12.0, dirtyRect.size.width - 24.0, dirtyRect.size.height - 24.0);
    
    [_lineColor set];
    CGContextRef currentContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetLineWidth( currentContext, 8.0 );
    CGFloat dashLengths[] = { 30.0f, 15.0f };
    CGContextSetLineDash( currentContext, _dashPhase, dashLengths, sizeof( dashLengths ) / sizeof( CGFloat ) );
    CGPathCreateWithRect(innerRect, NULL);
    CGContextStrokeRect(currentContext, innerRect);
    CGContextStrokePath( currentContext );
    
    CGContextSetLineDash( currentContext, 0, NULL, 0);

    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSCenterTextAlignment];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    NSDictionary *dStringAttr = [NSDictionary dictionaryWithObjectsAndKeys:_displayFont, NSFontAttributeName, [NSColor whiteColor], NSForegroundColorAttributeName, style, NSParagraphStyleAttributeName, nil];

    BOOL mouseInWindow = (NSPointInRect([[self window] mouseLocationOutsideOfEventStream], dirtyRect));

    if ((_onDragging && _dropActionArray && [_dropActionArray count] > 1) || (([[self window] isKeyWindow] || mouseInWindow) && _pasteActionArray && [_pasteActionArray count] > 1 && (!_dropActionArray || [_dropActionArray count] == 0)))
    {
        NSArray *actionArray = _onDragging ? _dropActionArray : _pasteActionArray;
        
        for (int i = 0; i < [actionArray count]; i++)
        {
            NSRect partRect = [self getRectAtPosition:i withActions:[actionArray count]];
            
            if (NSPointInRect([[self window] mouseLocationOutsideOfEventStream], partRect))
            {
                [_lineColor set];
                
                CGContextSetLineWidth( currentContext, 4.0 );
                CGPathCreateWithRect(partRect, NULL);
                CGContextStrokeRect(currentContext, partRect);
                CGContextStrokePath( currentContext );
            }
            
            CGContextSaveGState(currentContext);
            CGContextRotateCTM(currentContext, -M_PI_2);

            for (int n = 0; n < 2; n++)
            {
                NSString *string = [self getDisplayString:i pasteboard:!_onDragging shortV:n != 0];
                NSRect partRectR = NSMakeRect(partRect.origin.y - dirtyRect.size.height, partRect.origin.x, partRect.size.height, partRect.size.width);
                
                NSRect stringRect = [string boundingRectWithSize:partRectR.size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:dStringAttr];
                
                if (stringRect.size.width <= partRectR.size.width && stringRect.size.height <= partRectR.size.height)
                {
                    [string drawInRect:NSMakeRect(partRectR.origin.x + (partRectR.size.width - stringRect.size.width) / 2, partRectR.origin.y + (partRectR.size.height - stringRect.size.height) / 2, stringRect.size.width, stringRect.size.height) withAttributes:dStringAttr];
                    
                    n = 2; //Cancel out of inner loop
                }
            }
            
            CGContextRestoreGState(currentContext);
        }
    }
    else
    {
        NSRect singlePartRect = [self getRectAtPosition:0 withActions:1];

        BOOL mouseInSinglePartRect = (NSPointInRect([[self window] mouseLocationOutsideOfEventStream], singlePartRect));

        if (mouseInSinglePartRect)
        {
            [_lineColor set];
            
            CGContextSetLineWidth( currentContext, 4.0 );
            CGPathCreateWithRect(singlePartRect, NULL);
            CGContextStrokeRect(currentContext, singlePartRect);
            CGContextStrokePath( currentContext );
        }

        for (int i = 0; i < 2; i++)
        {
            NSString *string;
            
            if (mouseInWindow || [[self window] isKeyWindow] || _onDragging)
                string = [self getDisplayString:0 pasteboard:!_onDragging shortV:i != 0];
            else
                string = i == 0 ? @"Drop or paste anything to upload": @"Drop or Paste";

            
            NSRect stringRect = [string boundingRectWithSize:singlePartRect.size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:dStringAttr];

            if (stringRect.size.width <= singlePartRect.size.width && stringRect.size.height <= singlePartRect.size.height)
            {
                [string drawInRect:NSMakeRect(singlePartRect.origin.x + (singlePartRect.size.width - stringRect.size.width) / 2, singlePartRect.origin.y + (singlePartRect.size.height - stringRect.size.height) / 2, stringRect.size.width, stringRect.size.height) withAttributes:dStringAttr];
                
                break;
            }
        }
    }
}

- (void)timerFired:(NSTimer *)theTimer
{
    [self setPasteActionArray:[STGDataCaptureManager getActionsFromPasteboard:[NSPasteboard generalPasteboard]]];
    
    if (_onDragging || (([[self window] isKeyWindow] || [self isMouseInRect:0 withActions:1]) && _pasteActionArray && [_pasteActionArray count] > 0))
        _dashPhase += 1.0;
    
    [self setNeedsDisplay:YES];

    if (![[self window] isVisible])
    {
        if (_timer)
            [_timer invalidate];
        
        [self setTimer:nil];
    }
}

- (NSRect)getRectAtPosition:(NSInteger)pos withActions:(NSInteger)actionCount
{
    NSRect innerRect = CGRectMake([self frame].origin.x + 12.0, [self frame].origin.y + 12.0, [self frame].size.width - 24.0, [self frame].size.height - 24.0);
    
    int partSize = innerRect.size.width / actionCount;
    
    return NSMakeRect(innerRect.origin.x + partSize * pos + 10.0, innerRect.origin.y + 10.0, partSize - 20.0, innerRect.size.height - 20.0);
}

- (BOOL)isMouseInRect:(NSInteger)pos withActions:(NSInteger)actionCount
{
    return (NSPointInRect([[self window] mouseLocationOutsideOfEventStream], [self getRectAtPosition:pos withActions:actionCount]));
}

- (NSString *)getDisplayString:(NSInteger)pos pasteboard:(BOOL)fromPasteboard shortV:(BOOL)shortVersion
{
    NSArray *actions = fromPasteboard ? _pasteActionArray : _dropActionArray;
    
    if (actions && [actions count] > 0)
    {
        NSString *action = [STGDataCaptureManager getNameForAction:[[actions objectAtIndex:pos] integerValue]];
        
        if(shortVersion)
            return action;
        
        if (fromPasteboard)
            return [NSString stringWithFormat:@"%@ from Pasteboard", action];
        
        else return [NSString stringWithFormat:@"Drop to %@", action];
    }
    
    if(shortVersion)
        return @"Not supported";

    return @"Data type not supported =(";
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    [self setDropActionArray:[STGDataCaptureManager getActionsFromPasteboard:[sender draggingPasteboard]]];
    
    NSString *displayString = [_dropActionArray objectAtIndex:0];
    
    if (displayString)
    {
        [self setOnDragging:YES];
        [self setNeedsDisplay:YES];
        
        return NSDragOperationCopy;
    }
    
    return NSDragOperationNone;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    if (_onDragging)
    {
        [self setOnDragging:NO];
        [self setNeedsDisplay:YES];        
    }
    
    [self setDropActionArray:nil];
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender
{
    if (_onDragging)
    {
        [self setOnDragging:NO];
        [self setNeedsDisplay:YES];        
    }
}

-(BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    return [self uploadFromPasteboard:[sender draggingPasteboard] actions:_dropActionArray needsRectangle:YES];
}

- (void)paste
{
    [self uploadFromPasteboard:[NSPasteboard generalPasteboard] actions:_pasteActionArray needsRectangle:NO];
}

- (BOOL)uploadFromPasteboard:(NSPasteboard *)pBoard actions:(NSArray *)actions needsRectangle:(BOOL)needsRectangle
{
    if ([actions count] > 1)
    {
        for (int i = 0; i < [actions count]; i++)
        {
            if ([self isMouseInRect:i withActions:[actions count]])
            {
                NSArray *entries = [STGDataCaptureManager captureDataFromPasteboard:pBoard withAction:[[actions objectAtIndex:i] integerValue]];
                
                if (entries && [entries count] > 0 && [_delegate respondsToSelector:@selector(uploadEntries:)])
                {
                    [_delegate uploadEntries:entries];
                    
                    return YES;
                }
            }
        }
    }
    else if ([actions count] > 0)
    {        
        if (!needsRectangle || [self isMouseInRect:0 withActions:1])
        {
            NSArray *entries = [STGDataCaptureManager captureDataFromPasteboard:pBoard withAction:[[actions objectAtIndex:0] integerValue]];
            
            if ([_delegate respondsToSelector:@selector(uploadEntries:)])
            {
                [_delegate uploadEntries:entries];
                
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    [self uploadFromPasteboard:[NSPasteboard generalPasteboard] actions:_pasteActionArray needsRectangle:YES];
}

- (void)viewWillDraw
{
    if (!_timer)
        [self setTimer:[NSTimer scheduledTimerWithTimeInterval:0.03333 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES]];
}

- (void)dealloc
{
    if (_timer)
        [_timer invalidate];
}

@end
