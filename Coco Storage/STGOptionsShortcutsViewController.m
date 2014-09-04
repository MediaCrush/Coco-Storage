//
//  STGOptionsShortcutsViewController.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 24.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGOptionsShortcutsViewController.h"

#import "STGSystemHelper.h"

@interface STGOptionsShortcutsViewController ()

@end

@implementation STGOptionsShortcutsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {

    }
    
    return self;
}

- (void)awakeFromNib
{
    [self updateHotkeyView:_hotkeyViewCaptureArea withBaseUserDefaultsKey:@"hotkeyCaptureArea"];
    [self updateHotkeyView:_hotkeyViewCaptureScreen withBaseUserDefaultsKey:@"hotkeyCaptureFullScreen"];
    [self updateHotkeyView:_hotkeyViewUploadFile withBaseUserDefaultsKey:@"hotkeyCaptureFile"];
    
    [_hotkeyViewCaptureArea setDefaultHotkey:@"5" withModifiers:NSCommandKeyMask | NSShiftKeyMask];
    [_hotkeyViewCaptureScreen setDefaultHotkey:@"6" withModifiers:NSCommandKeyMask | NSShiftKeyMask];
    [_hotkeyViewUploadFile setDefaultHotkey:@"u" withModifiers:NSCommandKeyMask | NSShiftKeyMask];
    
    [[self view] setNextResponder:nil];
    [self updateHotkeyStatus];
}

+ (void)registerStandardDefaults:(NSMutableDictionary *)defaults
{
    [defaults setObject:@"5" forKey:@"hotkeyCaptureArea"];
    [defaults setObject:[NSNumber numberWithInteger:NSCommandKeyMask | NSShiftKeyMask] forKey:@"hotkeyCaptureAreaModifiers"];
    [defaults setObject:@"6" forKey:@"hotkeyCaptureFullScreen"];
    [defaults setObject:[NSNumber numberWithInteger:NSCommandKeyMask | NSShiftKeyMask] forKey:@"hotkeyCaptureFullScreenModifiers"];
    [defaults setObject:@"u" forKey:@"hotkeyCaptureFile"];
    [defaults setObject:[NSNumber numberWithInteger:NSCommandKeyMask | NSShiftKeyMask] forKey:@"hotkeyCaptureFileModifiers"];
}

- (void)saveProperties
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateHotkeyStatus
{
    BOOL hotkeysEnabled = NO;
    if ([_delegate respondsToSelector:@selector(hotkeysEnabled)])
        hotkeysEnabled = [_delegate hotkeysEnabled];
    
    if (![STGSystemHelper isAssistiveDevice])
    {
        [_hotkeyStatusTextField setStringValue:@"Not an assistive device"];
        [_assistiveDeviceRegisterButton setEnabled:YES];
    }
    else if (!hotkeysEnabled)
    {
        [_hotkeyStatusTextField setStringValue:@"Failed to register shortcuts"];
        [_assistiveDeviceRegisterButton setEnabled:NO];
    }
    else
    {
        [_hotkeyStatusTextField setStringValue:@"Okay"];
        [_assistiveDeviceRegisterButton setEnabled:NO];
    }
}

- (void)registerAsAssistiveDevice:(id)sender
{
    if ([_delegate respondsToSelector:@selector(registerAsAssistiveDevice)])
        [_delegate registerAsAssistiveDevice];
}

- (void)updateHotkeyView:(STGHotkeySelectView *)view withBaseUserDefaultsKey:(NSString *)key
{
    [view setHotkey:[[NSUserDefaults standardUserDefaults] stringForKey:key] withModifiers:[[NSUserDefaults standardUserDefaults] integerForKey:[key stringByAppendingString:@"Modifiers"]]];
}

- (NSEvent *)keyPressed:(NSEvent *)event
{
    if ([[_hotkeyViewCaptureArea hotkeyTextField] currentEditor])
    {
        [_hotkeyViewCaptureArea setHotkey:[[event characters] lowercaseString] withModifiers:[event modifierFlags]];
    }
    else if ([[_hotkeyViewCaptureScreen hotkeyTextField] currentEditor])
    {
        [_hotkeyViewCaptureScreen setHotkey:[[event characters] lowercaseString] withModifiers:[event modifierFlags]];
    }
    else if ([[_hotkeyViewUploadFile hotkeyTextField] currentEditor])
    {
        [_hotkeyViewUploadFile setHotkey:[[event characters] lowercaseString] withModifiers:[event modifierFlags]];
    }
    else
    {
        return event;
    }
    
    [[[self view] window] makeFirstResponder:nil];
    return nil;
}

- (NSString *)identifier
{
    return @"optionsShortcuts";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:@"NSComputer"];
}

- (NSString *)toolbarItemLabel
{
    return @"Shortcuts";
}

- (BOOL)hasResizableWidth
{
    return NO;
}

- (BOOL)hasResizableHeight
{
    return NO;
}

#pragma mark Hotkey Select View delegate

- (void)hotkeyView:(STGHotkeySelectView *)hotkeyView changedHotkey:(NSString *)key withModifiers:(NSUInteger)modifiers
{
    NSString *userDefaultsKey = nil;
    if (hotkeyView == _hotkeyViewCaptureArea)
        userDefaultsKey = @"hotkeyCaptureArea";
    else if (hotkeyView == _hotkeyViewCaptureScreen)
        userDefaultsKey = @"hotkeyCaptureFullScreen";
    else if (hotkeyView == _hotkeyViewUploadFile)
        userDefaultsKey = @"hotkeyCaptureFile";
    
    [[NSUserDefaults standardUserDefaults] setObject:key forKey:userDefaultsKey];
    [[NSUserDefaults standardUserDefaults] setInteger:modifiers forKey:[userDefaultsKey stringByAppendingString:@"Modifiers"]];
    
    if ([_delegate respondsToSelector:@selector(updateShortcuts)])
        [_delegate updateShortcuts];
}

@end
