//
//  STGOptionsGeneralViewController.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 24.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGOptionsGeneralViewController.h"

#import "STGFileHelper.h"
#import "STGSystemHelper.h"

#import <Sparkle/Sparkle.h>

@interface STGOptionsGeneralViewController ()

@end

@implementation STGOptionsGeneralViewController

@synthesize launchOnStartupButton = _launchOnStartupButton;
@synthesize showDockIconButton = _showDockIconButton;
@synthesize autoUpdateButton = _autoUpdateButton;

@synthesize keyTextField = _keyTextField;

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
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_launchOnStartupButton setState:[[NSUserDefaults standardUserDefaults] integerForKey:@"startAtLogin"]];
    [_showDockIconButton setState:[[NSUserDefaults standardUserDefaults] integerForKey:@"showDockIcon"]];
    [_autoUpdateButton setState:[[NSUserDefaults standardUserDefaults] integerForKey:@"autoUpdate"]];
    
    [_keyTextField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"storageKey"]];
}

+ (void)registerStandardDefaults:(NSMutableDictionary *)defaults
{
    [defaults setObject:[NSNumber numberWithInt:0] forKey:@"startAtLogin"];
    [defaults setObject:[NSNumber numberWithInt:0] forKey:@"showDockIcon"];
    [defaults setObject:[NSNumber numberWithInt:1] forKey:@"autoUpdate"];

    [defaults setObject:@"" forKey:@"storageKey"];
}

- (void)saveProperties
{
    [[NSUserDefaults standardUserDefaults] setInteger:[_launchOnStartupButton integerValue] forKey:@"startAtLogin"];
    [[NSUserDefaults standardUserDefaults] setInteger:[_showDockIconButton integerValue] forKey:@"showDockIcon"];
    [[NSUserDefaults standardUserDefaults] setInteger:[_autoUpdateButton integerValue] forKey:@"autoUpdate"];

    [[NSUserDefaults standardUserDefaults] setObject:[_keyTextField stringValue] forKey:@"storageKey"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)checkboxButtonClicked:(id)sender
{
    [self saveProperties];

    if (sender == _autoUpdateButton)
    {
        [[SUUpdater sharedUpdater] setAutomaticallyChecksForUpdates:[_autoUpdateButton integerValue] == 1];
    }
    
    if (sender == _showDockIconButton)
    {
        if ([_showDockIconButton integerValue] == 0)
        {
            //Restart app
        }
        else
        {
            [STGSystemHelper showDockTile];
        }
    }    
}

- (void)textChanged:(STGOptionTextField *)textField
{
    [self saveProperties];
}

- (IBAction)openStorageKeysPage:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://getstorage.net/panel/keys"]];
}

- (IBAction)checkForUpdates:(id)sender
{
    [[SUUpdater sharedUpdater] checkForUpdates:self];
}

- (NSString *)identifier
{
    return @"optionsGeneral";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:@"NSPreferencesGeneral"];
}

- (NSString *)toolbarItemLabel
{
    return @"General";
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
