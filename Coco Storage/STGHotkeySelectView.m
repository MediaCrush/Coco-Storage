//
//  STGHotkeySelectView.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 04.09.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGHotkeySelectView.h"

@implementation STGHotkeySelectView

- (void)baseInit
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:0.0f constant:22.0f]];

    _hotkeyTextField = [[NSTextField alloc] init];
    [_hotkeyTextField setBezeled:YES];
    [_hotkeyTextField setBezelStyle:NSRoundedBezelStyle];
    [_hotkeyTextField setAlignment:NSCenterTextAlignment];
    [[_hotkeyTextField cell] setPlaceholderString:@"Enter Key Equivalent"];
    
    _resetHotkeyButton = [[NSButton alloc] init];
    [_resetHotkeyButton setBordered:NO];
    [_resetHotkeyButton setTitle:@""];
    [_resetHotkeyButton setImage:[NSImage imageNamed:@"NSRefreshFreestandingTemplate"]];
    [[_resetHotkeyButton cell] setImageScaling:NSImageScaleProportionallyUpOrDown];
    
    [_resetHotkeyButton setAction:@selector(resetHotkey:)];
    [_resetHotkeyButton setTarget:self];

    _disableHotkeyButton = [[NSButton alloc] init];
    [_disableHotkeyButton setBordered:NO];
    [_disableHotkeyButton setTitle:@""];
    [_disableHotkeyButton setImage:[NSImage imageNamed:@"NSStopProgressFreestandingTemplate"]];
    [[_disableHotkeyButton cell] setImageScaling:NSImageScaleProportionallyUpOrDown];

    [_disableHotkeyButton setAction:@selector(disableHotkey:)];
    [_disableHotkeyButton setTarget:self];

    [self addSubview:_hotkeyTextField];
    [self addSubview:_resetHotkeyButton];
    [self addSubview:_disableHotkeyButton];
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_hotkeyTextField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_resetHotkeyButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_disableHotkeyButton setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (void)updateConstraints
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_hotkeyTextField, _resetHotkeyButton, _disableHotkeyButton);
    
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_hotkeyTextField(>=10)]-[_resetHotkeyButton]-[_disableHotkeyButton]|"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:views]];
    
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_hotkeyTextField]|"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:views]];
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_resetHotkeyButton]-3-|"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:views]];
    [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_disableHotkeyButton]-3-|"
                                                                  options:0
                                                                  metrics:nil
                                                                    views:views]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_resetHotkeyButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_resetHotkeyButton attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_disableHotkeyButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_disableHotkeyButton attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0.0f]];

    [super updateConstraints];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
}

- (void)resetHotkey:(id)sender
{
    [self setHotkey:_defaultHotkeyString withModifiers:_defaultHotkeyModifiers];
}

- (void)disableHotkey:(id)sender
{
    [self setHotkey:nil withModifiers:0];
}

- (void)setHotkeyString:(NSString *)hotkeyString
{
    if (_hotkeyString != hotkeyString)
    {
        _hotkeyString = hotkeyString;
        [self notifyOfChanges];
    }
}

- (void)setHotkeyModifiers:(NSUInteger)hotkeyModifiers
{
    if (_hotkeyModifiers != hotkeyModifiers)
    {
        _hotkeyModifiers = hotkeyModifiers;
        [self notifyOfChanges];
    }
}

- (void)setHotkey:(NSString *)hotkey withModifiers:(NSUInteger)modifiers
{
    if (_hotkeyString != hotkey || _hotkeyModifiers != modifiers)
    {
        _hotkeyString = hotkey;
        _hotkeyModifiers = modifiers;
        [self notifyOfChanges];
    }
}

- (void)setDefaultHotkey:(NSString *)hotkey withModifiers:(NSUInteger)modifiers
{
    [self setDefaultHotkeyString:hotkey];
    [self setDefaultHotkeyModifiers:modifiers];
}

- (void)notifyOfChanges
{
    if ([_delegate respondsToSelector:@selector(hotkeyView:changedHotkey:withModifiers:)])
        [_delegate hotkeyView:self changedHotkey:_hotkeyString withModifiers:_hotkeyModifiers];
    
    [self updateTextFieldContents];
}

- (void)updateTextFieldContents
{
    if ([_hotkeyString length] > 0)
    {
        NSMutableString *title = [[NSMutableString alloc] init];
        
        if ((_hotkeyModifiers & NSAlphaShiftKeyMask) != 0)
            [title appendString:@"\u21EA "];
        if ((_hotkeyModifiers & NSShiftKeyMask) != 0)
            [title appendString:@"\u21E7 "];
        if ((_hotkeyModifiers & NSControlKeyMask) != 0)
            [title appendString:@"\u2303 "];
        if ((_hotkeyModifiers & NSAlternateKeyMask) != 0)
            [title appendString:@"\u2325 "];
        if ((_hotkeyModifiers & NSCommandKeyMask) != 0)
            [title appendString:@"\u2318 "];
        if ((_hotkeyModifiers & NSNumericPadKeyMask) != 0)
            [title appendString:@"NumPad "];
        if ((_hotkeyModifiers & NSHelpKeyMask) != 0)
            [title appendString:@"Help "];
        if ((_hotkeyModifiers & NSFunctionKeyMask) != 0)
            [title appendString:@"fn "];
        
        [title appendString:_hotkeyString];
        
        [_hotkeyTextField setStringValue:title];
    }
    else
    {
        [_hotkeyTextField setStringValue:@""];
    }
}

@end
