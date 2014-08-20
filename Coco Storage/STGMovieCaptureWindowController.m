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

@interface STGMovieCaptureWindowController ()

@end

@implementation STGMovieCaptureWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        [self setRecordDuration:[NSNumber numberWithDouble:10.0]];
        [self setRecordDelay:[NSNumber numberWithDouble:3.0]];

        [self setRecordDisplayID:[NSNumber numberWithUnsignedInt:kCGDirectMainDisplay]];
        [self resetRecordRectToFullscreen:self];
        
        [self setQuality:AVCaptureSessionPresetMedium];
        
        [self setRecordsVideo:YES];

        [self setRecordsComputerAudio:NO];
        [self setRecordsMicrophoneAudio:YES];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [_qualitySelectPopupButton removeAllItems];
    [_qualitySelectPopupButton addItemsWithTitles:@[@"Low Quality", @"Medium Quality", @"High Quality"]];
    [_qualitySelectPopupButton selectItemAtIndex:1];
    
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
    NSString *screenName = @"";
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
    
}

- (void)qualitySelected:(id)sender
{
    switch ([_qualitySelectPopupButton indexOfSelectedItem])
    {
        case 1:
            _quality = AVCaptureSessionPresetMedium;
            break;
        case 2:
            _quality = AVCaptureSessionPresetHigh;
            break;
        default:
            _quality = AVCaptureSessionPresetLow;
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

@end
