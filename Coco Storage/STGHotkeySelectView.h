//
//  STGHotkeySelectView.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 04.09.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class STGHotkeySelectView;

@protocol STGHotkeySelectViewDelegate <NSObject>
@optional
- (void)hotkeyView:(STGHotkeySelectView *)hotkeyView changedHotkey:(NSString *)key withModifiers:(NSUInteger)modifiers;

@end

@interface STGHotkeySelectView : NSView

@property (nonatomic, assign) IBOutlet id<STGHotkeySelectViewDelegate> delegate;

@property (nonatomic, retain, readonly) NSTextField *hotkeyTextField;
@property (nonatomic, retain, readonly) NSButton *resetHotkeyButton;
@property (nonatomic, retain, readonly) NSButton *disableHotkeyButton;

@property (nonatomic, retain) NSString *hotkeyString;
@property (nonatomic, assign) NSUInteger hotkeyModifiers;

@property (nonatomic, retain) NSString *defaultHotkeyString;
@property (nonatomic, assign) NSUInteger defaultHotkeyModifiers;

@property (nonatomic, assign) BOOL canDisableHotkey;

@property (nonatomic, retain) NSColor *backgroundColor;

- (void)setHotkey:(NSString *)hotkey withModifiers:(NSUInteger)modifiers;
- (void)setDefaultHotkey:(NSString *)hotkey withModifiers:(NSUInteger)modifiers;

- (IBAction)resetHotkey:(id)sender;
- (IBAction)disableHotkey:(id)sender;

@end
