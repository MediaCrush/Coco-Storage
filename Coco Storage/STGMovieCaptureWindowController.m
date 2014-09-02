//
//  STGMovieCaptureWindowController.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGMovieCaptureWindowController.h"

#import <IOKit/graphics/IOGraphicsLib.h>
#import <AVFoundation/AVFoundation.h>

#import "STGFloatingWindowController.h"
#import "STGScreenRectangleSelectView.h"

@interface STGMovieCaptureWindowController ()

@end

@implementation STGMovieCaptureWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        [self setRecordDuration:[NSNumber numberWithDouble:300.0]];
        [self setRecordDelay:[NSNumber numberWithDouble:5.0]];

        [self setRecordDisplayID:[NSNumber numberWithUnsignedInt:kCGDirectMainDisplay]];
        [self resetRecordRectToFullscreen:self];
        
        [self setQuality:AVCaptureSessionPresetHigh];
        
        [self setRecordsVideo:YES];

        [self setRecordsComputerAudio:NO];
        [self setRecordsMicrophoneAudio:YES];
        
        [self setRectSelectWC:[STGFloatingWindowController overlayWindowController]];
        [_rectSelectWC setContentView:[[STGScreenRectangleSelectView alloc] init]];
        [(STGScreenRectangleSelectView *)[_rectSelectWC contentView] setDelegate:self];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [_qualitySelectPopupButton removeAllItems];
    [_qualitySelectPopupButton addItemsWithTitles:@[@"High Quality", @"Medium Quality", @"Low Quality"]];
    [_qualitySelectPopupButton selectItemAtIndex:0];
    
    [_screenSelectPopupButton removeAllItems];

    NSArray *screenArray = [NSScreen screens];
    for (NSScreen *screen in screenArray)
    {
        NSDictionary *screenDescription = [screen deviceDescription];
        CGDirectDisplayID screenID = [[screenDescription objectForKey:@"NSScreenNumber"] unsignedIntValue];
        [_screenSelectPopupButton addItemWithTitle:[self screenNameForDisplay:screenID]];
        [[_screenSelectPopupButton itemAtIndex:[_screenSelectPopupButton numberOfItems] - 1] setTag:screenID];
    }
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (NSString *)screenNameForDisplay:(CGDirectDisplayID)displayID
{
    NSString *screenName = @"Screen";
    NSDictionary *deviceInfo = (__bridge NSDictionary *)IODisplayCreateInfoDictionary(CGDisplayIOServicePort(displayID), kIODisplayOnlyPreferredName);
    NSDictionary *localizedNames = [deviceInfo objectForKey:[NSString stringWithUTF8String:kDisplayProductName]];
    
    if ([localizedNames count] > 0)
    {
        screenName = [localizedNames objectForKey:[[localizedNames allKeys] objectAtIndex:0]];
    }
    return screenName;
}


- (void)selectRecordRect:(id)sender
{
    NSRect displayRect = CGDisplayBounds([_recordDisplayID unsignedIntValue]);
    [[_rectSelectWC window] setFrame:displayRect display:YES];
    [[_rectSelectWC contentView] setWindowSelectMode:NO];
    
    [_rectSelectWC showWindow:self];
    [NSApp  activateIgnoringOtherApps:YES];
    [[_rectSelectWC window] makeFirstResponder:[_rectSelectWC contentView]];
}

- (void)qualitySelected:(id)sender
{
    switch ([_qualitySelectPopupButton indexOfSelectedItem])
    {
        case 2:
            _quality = AVCaptureSessionPresetLow;
            break;
        case 0:
            _quality = AVCaptureSessionPresetHigh;
            break;
        default:
            _quality = AVCaptureSessionPresetMedium;
            break;
    }
}

- (void)resetRecordRectToFullscreen:(id)sender
{
    [self setRecordRect:CGDisplayBounds([_recordDisplayID unsignedIntValue])];
}

- (void)startMovieCapture:(id)sender
{
    if ([[self window] makeFirstResponder:sender]) // Force a value validation
    {
        [self close];
        
        if ([_delegate respondsToSelector:@selector(startMovieCapture:)])
        {
            [_delegate startMovieCapture:self];
        }
    }
}

#pragma mark Screen Rectangle Select Delegate

- (void)screenRectangleSelectView:(STGScreenRectangleSelectView *)view didSelectRectangle:(NSRect)rectangle
{
    [self setRecordRect:rectangle];
}

@end
