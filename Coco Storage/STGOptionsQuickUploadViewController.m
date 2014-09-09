//
//  STGOptionsQuickUploadViewController.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGOptionsQuickUploadViewController.h"

#import "STGFileHelper.h"

@interface STGOptionsQuickUploadViewController ()

@end

@implementation STGOptionsQuickUploadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)awakeFromNib
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [_tempFolderChooser setPaths:[NSArray arrayWithObjects:[STGPathChooserEntry entryWithPath:[[STGFileHelper getApplicationSupportDirectory] stringByAppendingString:@"/temp"] customTitle:@"Default"], [STGFileHelper getDownloadsDirectory], [STGFileHelper getDesktopDirectory], nil]];
    [_tempFolderChooser setSelectedPath:[[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"]];
    
    [_keepFailedScreenshotsButton setState:[[NSUserDefaults standardUserDefaults] integerForKey:@"keepFailedScreenshots"]];
    [_keepAllScreenshotsButton setState:[[NSUserDefaults standardUserDefaults] integerForKey:@"keepAllScreenshots"]];
    
    NSString *completionSound = [[NSUserDefaults standardUserDefaults] stringForKey:@"completionSound"];
    if ([completionSound isEqualToString:@"noSound"])
        [_playSoundButton setState:0];
    else
    {
        [_playSoundButton setState:1];
        [_finishSoundPicker setSelectedSound:completionSound];
    }
    [_linkCopyToPasteboardButton setState:[[NSUserDefaults standardUserDefaults] integerForKey:@"linkCopyToPasteboard"]];
    [_openLinkInBrowserButton setState:[[NSUserDefaults standardUserDefaults] integerForKey:@"linkOpenInBrowser"]];
    [_displayNotificationButton setState:[[NSUserDefaults standardUserDefaults] integerForKey:@"displayNotification"]];
    [_playScreenshotSoundButton setState:[[NSUserDefaults standardUserDefaults] integerForKey:@"playScreenshotSound"]];

    [_keepAllScreenshotsButton setEnabled:[_keepFailedScreenshotsButton integerValue] == 1];
    
    [_finishSoundPicker setEnabled:[_playSoundButton integerValue] == 1];
}

+ (void)registerStandardDefaults:(NSMutableDictionary *)defaults
{
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
    [[NSUserDefaults standardUserDefaults] setInteger:[_keepFailedScreenshotsButton integerValue] forKey:@"keepFailedScreenshots"];
    [[NSUserDefaults standardUserDefaults] setInteger:[_keepAllScreenshotsButton integerValue] forKey:@"keepAllScreenshots"];
    
    if ([_playSoundButton integerValue] == 1)
        [[NSUserDefaults standardUserDefaults] setObject:[_finishSoundPicker selectedSound] forKey:@"completionSound"];
    else
        [[NSUserDefaults standardUserDefaults] setObject:@"noSound" forKey:@"completionSound"];
    [[NSUserDefaults standardUserDefaults] setInteger:[_linkCopyToPasteboardButton integerValue] forKey:@"linkCopyToPasteboard"];
    [[NSUserDefaults standardUserDefaults] setInteger:[_openLinkInBrowserButton integerValue] forKey:@"linkOpenInBrowser"];
    [[NSUserDefaults standardUserDefaults] setInteger:[_displayNotificationButton integerValue] forKey:@"displayNotification"];
    [[NSUserDefaults standardUserDefaults] setInteger:[_playScreenshotSoundButton integerValue] forKey:@"playScreenshotSound"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)checkboxButtonClicked:(id)sender
{
    [self saveProperties];
        
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
    
    if (sender == _playSoundButton)
    {
        [_finishSoundPicker setEnabled:[_playSoundButton integerValue] == 1];
    }
}

- (IBAction)openTempFolderInFinder:(id)sender
{
    NSString *currentFilePath = [[NSUserDefaults standardUserDefaults] stringForKey:@"tempFolder"];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:currentFilePath]];
}

- (NSString *)identifier
{
    return @"optionsQuickUploads";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:@"NSNetwork"];
}

- (NSString *)toolbarItemLabel
{
    return @"Quick Uploads";
}

- (BOOL)hasResizableWidth
{
    return NO;
}

- (BOOL)hasResizableHeight
{
    return NO;
}

#pragma mark Path chooser Delegate

- (void)pathChooserView:(STGPathChooserView *)view chosePath:(NSString *)path
{
    [[NSUserDefaults standardUserDefaults] setObject:path forKey:@"tempFolder"];
}

#pragma mark Sound Picker Delegate

- (void)soundPicker:(STGSoundPicker *)view choseSound:(NSString *)sound
{
    NSString *completionSound = [[NSUserDefaults standardUserDefaults] stringForKey:@"completionSound"];
    if (![sound isEqualToString:completionSound])
    {
        [[NSSound soundNamed:sound] play];
        
        [self saveProperties];
    }
}

@end
