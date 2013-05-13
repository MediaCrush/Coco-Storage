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

@synthesize tempFolderTextField = _tempFolderTextField;
@synthesize keepFailedScreenshotsButton = _keepFailedScreenshotsButton;
@synthesize keepAllScreenshotsButton = _keepAllScreenshotsButton;

@synthesize playSoundButton = _playSoundButton;
@synthesize selectSoundButton = _selectSoundButton;
@synthesize linkCopyToPasteboardButton = _linkCopyToPasteboardButton;
@synthesize openLinkInBrowserButton = _openLinkInBrowserButton;
@synthesize displayNotificationButton = _displayNotificationButton;
@synthesize playScreenshotSoundButton = _playScreenshotSoundButton;

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

    [_tempFolderTextField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]];
    [_keepFailedScreenshotsButton setState:[[NSUserDefaults standardUserDefaults] integerForKey:@"keepFailedScreenshots"]];
    [_keepAllScreenshotsButton setState:[[NSUserDefaults standardUserDefaults] integerForKey:@"keepAllScreenshots"]];

    NSString *completionSound = [[NSUserDefaults standardUserDefaults] stringForKey:@"completionSound"];
    if ([completionSound isEqualToString:@"noSound"])
        [_playSoundButton setState:0];
    else
    {
        [_playSoundButton setState:1];
        [_selectSoundButton selectItemWithTitle:[completionSound substringToIndex:[completionSound rangeOfString:@"." options:NSBackwardsSearch].location]];
    }
    [_linkCopyToPasteboardButton setState:[[NSUserDefaults standardUserDefaults] integerForKey:@"linkCopyToPasteboard"]];
    [_openLinkInBrowserButton setState:[[NSUserDefaults standardUserDefaults] integerForKey:@"linkOpenInBrowser"]];
    [_displayNotificationButton setState:[[NSUserDefaults standardUserDefaults] integerForKey:@"displayNotification"]];
    [_playScreenshotSoundButton setState:[[NSUserDefaults standardUserDefaults] integerForKey:@"playScreenshotSound"]];
    
    if([_keepFailedScreenshotsButton integerValue] == 0)
        [_keepAllScreenshotsButton setEnabled:NO];
    else
        [_keepAllScreenshotsButton setEnabled:YES];
    
    if ([_playSoundButton integerValue] == 0)
        [_selectSoundButton setEnabled:NO];
    else
        [_selectSoundButton setEnabled:YES];
}

+ (void)registerStandardDefaults:(NSMutableDictionary *)defaults
{
    [defaults setObject:[NSNumber numberWithInt:0] forKey:@"startAtLogin"];
    [defaults setObject:[NSNumber numberWithInt:0] forKey:@"showDockIcon"];
    [defaults setObject:[NSNumber numberWithInt:1] forKey:@"autoUpdate"];

    [defaults setObject:@"" forKey:@"storageKey"];

    [STGFileHelper createFolderIfNonExistent:[[STGFileHelper getApplicationSupportDirectory] stringByAppendingString:@"/temp"]];
    [defaults setObject:[[STGFileHelper getApplicationSupportDirectory] stringByAppendingString:@"/temp"] forKey:@"tempFolder"];
    [defaults setObject:[NSNumber numberWithInt:1] forKey:@"keepFailedScreenshots"];
    [defaults setObject:[NSNumber numberWithInt:0] forKey:@"keepAllScreenshots"];

    [defaults setObject:@"Hero.aiff" forKey:@"completionSound"];
    [defaults setObject:[NSNumber numberWithInt:0] forKey:@"linkCopyToPasteboard"];
    [defaults setObject:[NSNumber numberWithInt:1] forKey:@"linkOpenInBrowser"];
    [defaults setObject:[NSNumber numberWithInt:1] forKey:@"displayNotification"];
    [defaults setObject:[NSNumber numberWithInt:1] forKey:@"playScreenshotSound"];
}

- (void)saveProperties
{
    [[NSUserDefaults standardUserDefaults] setInteger:[_launchOnStartupButton integerValue] forKey:@"startAtLogin"];
    [[NSUserDefaults standardUserDefaults] setInteger:[_showDockIconButton integerValue] forKey:@"showDockIcon"];
    [[NSUserDefaults standardUserDefaults] setInteger:[_autoUpdateButton integerValue] forKey:@"autoUpdate"];

    [[NSUserDefaults standardUserDefaults] setObject:[_keyTextField stringValue] forKey:@"storageKey"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[_tempFolderTextField stringValue] forKey:@"tempFolder"];
    [[NSUserDefaults standardUserDefaults] setInteger:[_keepFailedScreenshotsButton integerValue] forKey:@"keepFailedScreenshots"];
    [[NSUserDefaults standardUserDefaults] setInteger:[_keepAllScreenshotsButton integerValue] forKey:@"keepAllScreenshots"];

    if ([_playSoundButton integerValue] == 1)
        [[NSUserDefaults standardUserDefaults] setObject:[[[_selectSoundButton selectedItem] title] stringByAppendingString:@".aiff"] forKey:@"completionSound"];
    else
        [[NSUserDefaults standardUserDefaults] setObject:@"noSound" forKey:@"completionSound"];
    [[NSUserDefaults standardUserDefaults] setInteger:[_linkCopyToPasteboardButton integerValue] forKey:@"linkCopyToPasteboard"];
    [[NSUserDefaults standardUserDefaults] setInteger:[_openLinkInBrowserButton integerValue] forKey:@"linkOpenInBrowser"];
    [[NSUserDefaults standardUserDefaults] setInteger:[_displayNotificationButton integerValue] forKey:@"displayNotification"];
    [[NSUserDefaults standardUserDefaults] setInteger:[_playScreenshotSoundButton integerValue] forKey:@"playScreenshotSound"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)checkboxButtonClicked:(id)sender
{
    [self saveProperties];

    if (sender == _autoUpdateButton)
    {
        [[SUUpdater sharedUpdater] setAutomaticallyChecksForUpdates:[_autoUpdateButton integerValue] == 1];
    }
    
    if (sender == _keepFailedScreenshotsButton)
    {
        if ([_keepFailedScreenshotsButton integerValue] == 0)
        {
            [_keepAllScreenshotsButton setIntegerValue:0];
            [_keepAllScreenshotsButton setEnabled:NO];
        }
        else
        {
            [_keepAllScreenshotsButton setEnabled:YES];
        }
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
    
    if (sender == _playSoundButton)
    {
        if ([_playSoundButton integerValue] == 0)
            [_selectSoundButton setEnabled:NO];
        else
            [_selectSoundButton setEnabled:YES];
    }
    
    if (sender == _selectSoundButton)
    {
        NSSound *sound = [NSSound soundNamed:[[NSUserDefaults standardUserDefaults] stringForKey:@"completionSound"]];
        [sound play];
    }
}

- (void)textChanged:(STGOptionTextField *)textField
{
    [self saveProperties];
}

- (IBAction)resetTempFolderClicked:(id)sender
{
    NSString *folderPath = [[STGFileHelper getApplicationSupportDirectory] stringByAppendingString:@"/temp"];

    [STGFileHelper createFolderIfNonExistent:folderPath];
    
    [_tempFolderTextField setStringValue:folderPath];
    
    [self saveProperties];
}

- (void)openTempFolderDialogue:(id)sender
{
    NSOpenPanel *filePanel = [[NSOpenPanel alloc] init];
    [filePanel setCanChooseDirectories:YES];
    [filePanel setCanChooseFiles:NO];
    [filePanel setAllowsMultipleSelection:NO];
    [filePanel setDirectoryURL:[NSURL URLWithString:[[NSString stringWithFormat:@"file://localhost%@", [_tempFolderTextField stringValue]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [filePanel setFloatingPanel:NO];
    [filePanel setCanSelectHiddenExtension:YES];
    [filePanel setTitle:@"Select Temp Folder Path"];
    [filePanel setPrompt:@"Select"];
    
    if ([filePanel runModal] == NSOKButton)
    {
        NSURL *selectedURL = [filePanel URL];
        
        [_tempFolderTextField setStringValue:[selectedURL relativeString]];
        
        [self saveProperties];
    }
}

- (IBAction)openTempFolderInFinder:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[NSString stringWithFormat:@"file://localhost%@", [_tempFolderTextField stringValue]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
}

- (IBAction)openStorageKeysPage:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://getstorage.net/panel/keys"]];
}

- (void)viewDidDisappear
{
    [self saveProperties];

    [[NSUserDefaults standardUserDefaults] synchronize];
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
