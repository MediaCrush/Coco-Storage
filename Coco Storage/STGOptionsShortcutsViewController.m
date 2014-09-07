//
//  STGOptionsShortcutsViewController.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 24.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGOptionsShortcutsViewController.h"

#import "STGSystemHelper.h"
#import "STGAPIConfiguration.h"

#import "RSVerticallyCenteredTextFieldCell.h"

@interface STGOptionsShortcutsViewController ()

@property (nonatomic, retain) NSArray *hotkeyEntries;
@property (nonatomic, retain) NSArray *hotkeyViews;

@end

@implementation STGHotkeyViewEntry

+ (STGHotkeyViewEntry *)entryWithTitle:(NSString *)title key:(NSString *)defaultsKey defaultKey:(NSString *)key defaultModifiers:(NSUInteger)modifiers
{
    STGHotkeyViewEntry *entry = [[STGHotkeyViewEntry alloc] init];
    [entry setTitle:title];
    [entry setUserDefaultsKey:defaultsKey];
    [entry setDefaultHotkey:key];
    [entry setDefaultModifiers:modifiers];
    return entry;
}

@end

@implementation STGOptionsShortcutsViewController

+ (NSArray *)hotkeyEntriesForAPI:(id<STGAPIConfiguration>)configuration
{
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    
    [entries addObject:[STGHotkeyViewEntry entryWithTitle:@"Capture Area" key:@"hotkeyCaptureArea" defaultKey:@"5" defaultModifiers:NSCommandKeyMask | NSShiftKeyMask]];
    [entries addObject:[STGHotkeyViewEntry entryWithTitle:@"Capture Full Screen" key:@"hotkeyCaptureFullScreen" defaultKey:@"6" defaultModifiers:NSCommandKeyMask | NSShiftKeyMask]];
    [entries addObject:[STGHotkeyViewEntry entryWithTitle:@"Upload File" key:@"hotkeyCaptureFile" defaultKey:nil defaultModifiers:0]];

    [entries addObject:[STGHotkeyViewEntry entryWithTitle:@"Start/Stop Recording" key:@"hotkeyToggleRecording" defaultKey:@"2" defaultModifiers:NSCommandKeyMask | NSShiftKeyMask]];

    [entries addObject:[STGHotkeyViewEntry entryWithTitle:@"Upload clipboard" key:@"hotkeyUploadClipboard" defaultKey:nil defaultModifiers:0]];

    if ([configuration hasAlbums])
        [entries addObject:[STGHotkeyViewEntry entryWithTitle:@"Create Album" key:@"hotkeyCreateAlbum" defaultKey:nil defaultModifiers:0]];

    
    return [entries copy];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self setHotkeyEntries:[STGOptionsShortcutsViewController hotkeyEntriesForAPI:[STGAPIConfiguration currentConfiguration]]];
    }
    
    return self;
}

- (void)awakeFromNib
{
    NSMutableArray *hotkeyViews = [[NSMutableArray alloc] init];
    for (STGHotkeyViewEntry *entry in _hotkeyEntries)
    {
        STGHotkeySelectView *hotkeyView = [[STGHotkeySelectView alloc] init];
        
        [hotkeyView setIdentifier:[entry userDefaultsKey]];
        
        [hotkeyView setHotkey:[[NSUserDefaults standardUserDefaults] stringForKey:[entry userDefaultsKey]] withModifiers:[[NSUserDefaults standardUserDefaults] integerForKey:[[entry userDefaultsKey] stringByAppendingString:@"Modifiers"]]];
        
        [hotkeyView setDefaultHotkey:[entry defaultHotkey] withModifiers:[entry defaultModifiers]];
        if (![entry defaultHotkey])
            [hotkeyView setCanResetHotkey:NO];
            
        [hotkeyView setDelegate:self];
        
        [hotkeyViews addObject:hotkeyView];
    }
    [self setHotkeyViews:[hotkeyViews copy]];
    
    [[self view] setNextResponder:nil];
    [self updateHotkeyStatus];
}

+ (void)registerStandardDefaults:(NSMutableDictionary *)defaults
{
    for (STGHotkeyViewEntry *entry in [STGOptionsShortcutsViewController hotkeyEntriesForAPI:[STGAPIConfiguration currentConfiguration]])
    {
        if ([entry defaultHotkey])
        {
            [defaults setObject:[entry defaultHotkey] forKey:[entry userDefaultsKey]];
            [defaults setObject:[NSNumber numberWithInteger:[entry defaultModifiers]] forKey:[[entry userDefaultsKey] stringByAppendingString:@"Modifiers"]];            
        }
    }
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

- (NSEvent *)keyPressed:(NSEvent *)event
{
    BOOL foundTextField = NO;
    
    for (STGHotkeySelectView *hotkeyView in _hotkeyViews)
    {
        if ([[hotkeyView hotkeyTextField] currentEditor])
        {
            [hotkeyView setHotkey:[[event characters] lowercaseString] withModifiers:[event modifierFlags]];
            foundTextField = YES;
            break;
        }
    }

    if (foundTextField)
    {
        [[[self view] window] makeFirstResponder:nil];
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
    return [NSImage imageNamed:@"NSComputer"];
}

- (NSString *)toolbarItemLabel
{
    return @"Shortcuts";
}

- (BOOL)hasResizableWidth
{
    return YES;
}

- (BOOL)hasResizableHeight
{
    return YES;
}

#pragma mark Table View delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_hotkeyEntries count] * 2 - 1;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (row % 2 == 1)
        return nil;
    
    if ([[tableColumn identifier] isEqualToString:@"title"])
    {
        STGHotkeyViewEntry *entry = [_hotkeyEntries objectAtIndex:row / 2];

        NSTextField *title = [[NSTextField alloc] init];
        [title setCell:[[RSVerticallyCenteredTextFieldCell alloc] initTextCell:[entry title]]];
        [title setBezeled:NO];
        [title setEditable:NO];
        [title setSelectable:YES];
        [title setDrawsBackground:NO];
        [title setStringValue:[entry title]];
        return title;
    }
    else if ([[tableColumn identifier] isEqualToString:@"hotkey"])
    {
        STGHotkeySelectView *hotkeyView = [_hotkeyViews objectAtIndex:row / 2];
        
        return hotkeyView;
    }
    
    return nil;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return row % 2 == 1 ? 8 : 22;
}

#pragma mark Hotkey Select View delegate

- (void)hotkeyView:(STGHotkeySelectView *)hotkeyView changedHotkey:(NSString *)key withModifiers:(NSUInteger)modifiers
{
    NSString *userDefaultsKey = [hotkeyView identifier];
    
    [[NSUserDefaults standardUserDefaults] setObject:key forKey:userDefaultsKey];
    [[NSUserDefaults standardUserDefaults] setInteger:modifiers forKey:[userDefaultsKey stringByAppendingString:@"Modifiers"]];
    
    if ([_delegate respondsToSelector:@selector(updateShortcuts)])
        [_delegate updateShortcuts];
}

@end
