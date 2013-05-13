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

@synthesize hotkeyCaptureAreaTextField = _hotkeyCaptureAreaTextField;
@synthesize hotkeyCaptureFullScreenTextField = _hotkeyCaptureFullScreenTextField;
@synthesize hotkeyCaptureFileTextField = _hotkeyCaptureFileTextField;

@synthesize delegate = _delegate;

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
    
    [[self view] setNextResponder:nil];
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

- (IBAction)resetHotkeyCaptureArea:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"5" forKey:@"hotkeyCaptureArea"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:NSCommandKeyMask | NSShiftKeyMask] forKey:@"hotkeyCaptureAreaModifiers"];
    
    [self updateTextFieldString:_hotkeyCaptureAreaTextField];
    
    if ([_delegate respondsToSelector:@selector(updateShortcuts)])
        [_delegate updateShortcuts];
}

- (IBAction)resetHotkeyCaptureFullScreen:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"6" forKey:@"hotkeyCaptureFullScreen"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:NSCommandKeyMask | NSShiftKeyMask] forKey:@"hotkeyCaptureFullScreenModifiers"];
    
    [self updateTextFieldString:_hotkeyCaptureFullScreenTextField];
    
    if ([_delegate respondsToSelector:@selector(updateShortcuts)])
        [_delegate updateShortcuts];
}

- (IBAction)resetHotkeyCaptureFile:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setObject:@"u" forKey:@"hotkeyCaptureFile"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:NSCommandKeyMask | NSShiftKeyMask] forKey:@"hotkeyCaptureFileModifiers"];
    
    [self updateTextFieldString:_hotkeyCaptureFileTextField];
    
    if ([_delegate respondsToSelector:@selector(updateShortcuts)])
        [_delegate updateShortcuts];
}

- (void)viewDidDisappear
{
    [self saveProperties];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
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

    [title appendString:[[NSUserDefaults standardUserDefaults] stringForKey:userDefaultsKey]];
    
    [textField setStringValue:title];
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
