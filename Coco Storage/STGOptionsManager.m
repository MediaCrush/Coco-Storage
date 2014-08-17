//
//  STGOptionsManager.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGOptionsManager.h"

#import "STGOptionsGeneralViewController.h"
#import "STGOptionsShortcutsViewController.h"
#import "STGOptionsQuickUploadViewController.h"
#import "STGOptionsCFSViewController.h"
#import "STGOptionsAboutViewController.h"

#import "STGAPIConfiguration.h"

@implementation STGOptionsManager

+ (void)registerDefaults:(NSMutableDictionary *)userDefaults
{
    [STGOptionsGeneralViewController registerStandardDefaults:userDefaults];
    [STGOptionsShortcutsViewController registerStandardDefaults:userDefaults];
    [STGOptionsQuickUploadViewController registerStandardDefaults:userDefaults];
    if ([[STGAPIConfiguration currentConfiguration] hasCFS])
        [STGOptionsCFSViewController registerStandardDefaults:userDefaults];
    [STGOptionsAboutViewController registerStandardDefaults:userDefaults];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setOptionsGeneralVC:[[STGOptionsGeneralViewController alloc] initWithNibName:@"STGOptionsGeneralViewController" bundle:nil]];
        [self setOptionsShortcutsVC:[[STGOptionsShortcutsViewController alloc] initWithNibName:@"STGOptionsShortcutsViewController" bundle:nil]];
        [_optionsShortcutsVC setDelegate:self];
        [self setOptionsQuickUploadVC:[[STGOptionsQuickUploadViewController alloc] initWithNibName:@"STGOptionsQuickUploadViewController" bundle:nil]];
        [self setOptionsCFSVC:[[STGOptionsCFSViewController alloc] initWithNibName:@"STGOptionsCFSViewController" bundle:nil]];
        [self setOptionsAboutVC:[[STGOptionsAboutViewController alloc] initWithNibName:@"STGOptionsAboutViewController" bundle:nil]];
        
        NSMutableArray *optionsArray = [[NSMutableArray alloc] init];
        [optionsArray addObject:_optionsGeneralVC];
        [optionsArray addObject:_optionsQuickUploadVC];
        if ([[STGAPIConfiguration currentConfiguration] hasCFS])
            [optionsArray addObject:_optionsCFSVC];
        [optionsArray addObject:_optionsShortcutsVC];
        [optionsArray addObject:_optionsAboutVC];
        [self setPrefsController:[[MASPreferencesWindowController alloc] initWithViewControllers:optionsArray title:@"Coco Storage Preferences"]];
    }
    return self;
}

- (BOOL)hotkeysEnabled
{
    return [_delegate respondsToSelector:@selector(hotkeysEnabled)] ? [_delegate hotkeysEnabled] : YES;
}

- (void)registerAsAssistiveDevice
{
    if ([_delegate respondsToSelector:@selector(registerAsAssistiveDevice)])
        [_delegate registerAsAssistiveDevice];
}

- (void)updateShortcuts
{
    if ([_delegate respondsToSelector:@selector(updateShortcuts)])
        [_delegate updateShortcuts];
}

- (void)updateHotkeyStatus
{
    [[self optionsShortcutsVC] updateHotkeyStatus];
}

- (NSEvent *)keyPressed:(NSEvent *)event
{
    return [_optionsShortcutsVC keyPressed:event];
}

- (void)openPreferencesWindow
{
    [_prefsController selectControllerAtIndex:0];
    [_prefsController showWindow:self];
    
    [NSApp  activateIgnoringOtherApps:YES];
}

@end
