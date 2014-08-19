//
//  STGCountdownView.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 18.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGCountdownView.h"

@interface STGCountdownView ()

@property (nonatomic, retain) NSTimer *redrawTimer;
@property (nonatomic, retain) NSMutableDictionary *stringDrawAttributes;

@property (nonatomic, retain) NSDate *fadeInTime;

@end

@implementation STGCountdownView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setStringDrawAttributes:[[NSMutableDictionary alloc] init]];
        [self setDisplayedNumbers:3];
    }
    return self;
}

- (void)setCountdownTime:(NSTimeInterval)countdownTime
{
    [self setDestinationDate:[NSDate dateWithTimeIntervalSinceNow:countdownTime]];
}

- (void)setDestinationDate:(NSDate *)destinationDate
{
    _destinationDate = destinationDate;
    
    [self setNeedsDisplay:YES];
    [self updateTimerValid];
}

- (void)updateTimerValid
{
    if ([_destinationDate timeIntervalSinceNow] > 0.0)
    {
        if (![_redrawTimer isValid])
            [self setRedrawTimer:[NSTimer scheduledTimerWithTimeInterval:1.0 / 60.0 target:self selector:@selector(redrawTimerFired:) userInfo:nil repeats:YES]];
    }
    else
    {
        if (_redrawTimer)
        {
            [self setRedrawTimer:nil];
            [_redrawTimer invalidate];
        }
    }
}

- (void)redrawTimerFired:(NSTimer *)timer
{
    [self setNeedsDisplay:YES];
    [self updateTimerValid];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    NSTimeInterval timeToDate = [_destinationDate timeIntervalSinceNow];

    if (timeToDate > 0.0)
    {
        CGFloat fadeInAlpha = MAX(MIN(_fadeInTime != nil ? 1.0 - [_fadeInTime timeIntervalSinceNow] : 1.0, 1.0), 0.0);
        CGFloat baseAlpha = MIN(timeToDate, fadeInAlpha);
        NSInteger timeToDateBase = floor(timeToDate);
        CGFloat timeToDateFract = fract(timeToDate);
        
        CGFloat centerX = _bounds.origin.x + _bounds.size.width / 2;

        CGFloat fontHeight = _bounds.size.height;
        [_stringDrawAttributes setObject:[NSFont fontWithName:@"Arial" size:fontHeight] forKey:NSFontAttributeName];
        
        [[NSColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:baseAlpha * 0.3] set];
        NSRectFill(NSMakeRect(centerX - 2, _bounds.origin.y, 4, _bounds.size.height));

        for (NSInteger i = 0; i < _displayedNumbers; i++)
        {
            NSInteger displayedNumber = timeToDateBase - i + (_displayedNumbers / 2);
            
            if (displayedNumber >= 0)
            {
                CGFloat alpha = MIN(baseAlpha, i == 0 ? timeToDateFract : (i == _displayedNumbers - 1 ? 1.0 - timeToDateFract : 1.0));
                CGFloat xPos = ((CGFloat) (i + timeToDateFract) / (CGFloat) _displayedNumbers) * (_bounds.size.width - fontHeight);
                
                [_stringDrawAttributes setObject:[NSColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:alpha] forKey:NSForegroundColorAttributeName];
                
                NSPoint drawPoint = NSMakePoint(_bounds.origin.x + xPos, _bounds.origin.y);
                
                NSString *textToDraw = [NSString stringWithFormat:@"%li", displayedNumber];
                [textToDraw drawAtPoint:drawPoint withAttributes:_stringDrawAttributes];
            }
        }
    }
}

- (void)fadeIn
{
    [self setFadeInTime:[NSDate dateWithTimeIntervalSinceNow:1.0]];
}

CGFloat fract(CGFloat val)
{
    return val - floor(val);
}

@end
