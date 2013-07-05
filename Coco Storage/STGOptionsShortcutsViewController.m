//
//  STGOptionsShortcutsViewController.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 24.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGOptionsShortcutsViewController.h"

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
    [self updateTextFieldString:_hotkeyCaptureAreaTextField];
    [self updateTextFieldString:_hotkeyCaptureFullScreenTextField];
    [self updateTextFieldString:_hotkeyCaptureFileTextField];
    [self updateTextFieldString:_hotkeyShowQuickCaptureTextField];
    
    [[self view] setNextResponder:nil];
}

+ (void)registerStandardDefaults:(NSMutableDictionary *)defaults
{
    [defaults setObject:@"2" forKey:@"hotkeyCaptureArea"];
    [defaults setObject:[NSNumber numberWithInteger:NSCommandKeyMask | NSShiftKeyMask] forKey:@"hotkeyCaptureAreaModifiers"];
    [defaults setObject:@"3" forKey:@"hotkeyCaptureFullScreen"];
    [defaults setObject:[NSNumber numberWithInteger:NSCommandKeyMask | NSShiftKeyMask] forKey:@"hotkeyCaptureFullScreenModifiers"];
    [defaults setObject:@"4" forKey:@"hotkeyCaptureFile"];
    [defaults setObject:[NSNumber numberWithInteger:NSCommandKeyMask | NSShiftKeyMask] forKey:@"hotkeyCaptureFileModifiers"];
    [defaults setObject:@"1" forKey:@"hotkeyQuickCapture"];
    [defaults setObject:[NSNumber numberWithInteger:NSCommandKeyMask | NSShiftKeyMask] forKey:@"hotkeyQuickCaptureModifiers"];
}

- (void)saveProperties
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)resetHotkeyCaptureArea:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"2" forKey:@"hotkeyCaptureArea"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:NSCommandKeyMask | NSShiftKeyMask] forKey:@"hotkeyCaptureAreaModifiers"];
    
    [self updateTextFieldString:_hotkeyCaptureAreaTextField];
    
    if ([_delegate respondsToSelector:@selector(updateShortcuts)])
        [_delegate updateShortcuts];
}

- (IBAction)resetHotkeyCaptureFullScreen:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"3" forKey:@"hotkeyCaptureFullScreen"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:NSCommandKeyMask | NSShiftKeyMask] forKey:@"hotkeyCaptureFullScreenModifiers"];
    
    [self updateTextFieldString:_hotkeyCaptureFullScreenTextField];
    
    if ([_delegate respondsToSelector:@selector(updateShortcuts)])
        [_delegate updateShortcuts];
}

- (IBAction)resetHotkeyCaptureFile:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"4" forKey:@"hotkeyCaptureFile"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:NSCommandKeyMask | NSShiftKeyMask] forKey:@"hotkeyCaptureFileModifiers"];
    
    [self updateTextFieldString:_hotkeyCaptureFileTextField];
    
    if ([_delegate respondsToSelector:@selector(updateShortcuts)])
        [_delegate updateShortcuts];
}

- (IBAction)resetHotkeyShowQuickCapture:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"hotkeyQuickCapture"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:NSCommandKeyMask | NSShiftKeyMask] forKey:@"hotkeyQuickCaptureModifiers"];
    
    [self updateTextFieldString:_hotkeyShowQuickCaptureTextField];
    
    if ([_delegate respondsToSelector:@selector(updateShortcuts)])
        [_delegate updateShortcuts];
}

- (IBAction)disableHotkeyCaptureArea:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"hotkeyCaptureArea"];
    
    [self updateTextFieldString:_hotkeyCaptureAreaTextField];
    
    if ([_delegate respondsToSelector:@selector(updateShortcuts)])
        [_delegate updateShortcuts];
}

- (IBAction)disableHotkeyCaptureFullScreen:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"hotkeyCaptureFullScreen"];
    
    [self updateTextFieldString:_hotkeyCaptureFullScreenTextField];
    
    if ([_delegate respondsToSelector:@selector(updateShortcuts)])
        [_delegate updateShortcuts];
}

- (IBAction)disableHotkeyCaptureFile:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"hotkeyCaptureFile"];
    
    [self updateTextFieldString:_hotkeyCaptureFileTextField];
    
    if ([_delegate respondsToSelector:@selector(updateShortcuts)])
        [_delegate updateShortcuts];
}

- (IBAction)disableHotkeyShowQuickCapture:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"hotkeyQuickCapture"];
    
    [self updateTextFieldString:_hotkeyShowQuickCaptureTextField];
    
    if ([_delegate respondsToSelector:@selector(updateShortcuts)])
        [_delegate updateShortcuts];
}

- (void)updateTextFieldString:(NSTextField *)textField
{
    NSString *userDefaultsKey = nil;
    if (textField == _hotkeyCaptureAreaTextField)
        userDefaultsKey = @"hotkeyCaptureArea";
    if (textField == _hotkeyCaptureFullScreenTextField)
        userDefaultsKey = @"hotkeyCaptureFullScreen";
    if (textField == _hotkeyCaptureFileTextField)
        userDefaultsKey = @"hotkeyCaptureFile";
    if (textField == _hotkeyShowQuickCaptureTextField)
        userDefaultsKey = @"hotkeyQuickCapture";
    
    NSString *key = [[NSUserDefaults standardUserDefaults] stringForKey:userDefaultsKey];
    
    if ([key length] > 0)
    {
        NSInteger modifiers = [[NSUserDefaults standardUserDefaults] integerForKey:[userDefaultsKey stringByAppendingString:@"Modifiers"]];
        
        NSMutableString *title = [[NSMutableString alloc] init];
        
        if ((modifiers & NSAlphaShiftKeyMask) != 0)
            [title appendString:@"\u21EA "];
        if ((modifiers & NSShiftKeyMask) != 0)
            [title appendString:@"\u21E7 "];
        if ((modifiers & NSControlKeyMask) != 0)
            [title appendString:@"\u2303 "];
        if ((modifiers & NSAlternateKeyMask) != 0)
            [title appendString:@"\u2325 "];
        if ((modifiers & NSCommandKeyMask) != 0)
            [title appendString:@"\u2318 "];
        if ((modifiers & NSNumericPadKeyMask) != 0)
            [title appendString:@"NumPad "];
        if ((modifiers & NSHelpKeyMask) != 0)
            [title appendString:@"Help "];
        if ((modifiers & NSFunctionKeyMask) != 0)
            [title appendString:@"fn "];
        
        [title appendString:key];
        
        [textField setStringValue:title];
    }
    else
    {
        [textField setStringValue:@""];
    }
}

- (NSEvent *)keyPressed:(NSEvent *)event
{
    NSString *userDefaultsKey = nil;
    NSTextField *textField = nil;

    if ([_hotkeyCaptureAreaTextField currentEditor])
    {
        userDefaultsKey = @"hotkeyCaptureArea";
        textField = _hotkeyCaptureAreaTextField;
    }
    if ([_hotkeyCaptureFullScreenTextField currentEditor])
    {
        userDefaultsKey = @"hotkeyCaptureFullScreen";
        textField = _hotkeyCaptureFullScreenTextField;
    }
    if ([_hotkeyCaptureFileTextField currentEditor])
    {
        userDefaultsKey = @"hotkeyCaptureFile";
        textField = _hotkeyCaptureFileTextField;
    }
    if ([_hotkeyShowQuickCaptureTextField currentEditor])
    {
        userDefaultsKey = @"hotkeyQuickCapture";
        textField = _hotkeyShowQuickCaptureTextField;
    }
    
    if (userDefaultsKey)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[[event characters] lowercaseString] forKey:userDefaultsKey];
        [[NSUserDefaults standardUserDefaults] setInteger:[event modifierFlags] forKey:[userDefaultsKey stringByAppendingString:@"Modifiers"]];
        
        [self updateTextFieldString:textField];
        [[textField window] makeFirstResponder:nil];
        
        return nil;
    }
    
    return event;
}

- (NSString *)identifier
{
    return @"optionsShortcuts";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:@"NSUserGroup"];
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

@end
