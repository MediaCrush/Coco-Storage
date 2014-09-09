//
//  STGOptionsCFSViewController.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGOptionsCFSViewController.h"

#import "STGFileHelper.h"

@interface STGOptionsCFSViewController ()

@end

@implementation STGOptionsCFSViewController

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
    
    [_cfsFolderTextField setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"cfsFolder"]];
    
    NSString *completionSound = [[NSUserDefaults standardUserDefaults] stringForKey:@"cfsCompletionSound"];
    if ([completionSound isEqualToString:@"noSound"])
        [_playSoundButton setState:0];
    else
    {
        [_playSoundButton setState:1];
        [_selectSoundButton selectItemWithTitle:[completionSound substringToIndex:[completionSound rangeOfString:@"." options:NSBackwardsSearch].location]];
    }
    
    [_displayNotificationButton setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"cfsDisplayNotification"]];
}

+ (void)registerStandardDefaults:(NSMutableDictionary *)defaults
{
    [STGFileHelper createFolderIfNonExistent:[[STGFileHelper getDocumentsDirectory] stringByAppendingString:@"/Coco Storage"]];
    [defaults setObject:[[STGFileHelper getDocumentsDirectory] stringByAppendingString:@"/Coco Storage"] forKey:@"cfsFolder"];
    
    [defaults setObject:@"Hero.aiff" forKey:@"cfsCompletionSound"];

    [defaults setObject:[NSNumber numberWithInt:1] forKey:@"cfsDisplayNotification"];
}

- (void)saveProperties
{
    [[NSUserDefaults standardUserDefaults] setObject:[_cfsFolderTextField stringValue] forKey:@"cfsFolder"];
    
    if ([_playSoundButton integerValue] == 1)
        [[NSUserDefaults standardUserDefaults] setObject:[[[_selectSoundButton selectedItem] title] stringByAppendingString:@".aiff"] forKey:@"cfsCompletionSound"];

    [[NSUserDefaults standardUserDefaults] setInteger:[_displayNotificationButton integerValue] forKey:@"cfsDisplayNotification"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)checkboxButtonClicked:(id)sender
{
    [self saveProperties];
    
    if (sender == _playSoundButton)
    {
        if ([_playSoundButton integerValue] == 0)
            [_selectSoundButton setEnabled:NO];
        else
            [_selectSoundButton setEnabled:YES];
    }
    
    if (sender == _selectSoundButton)
    {
        NSSound *sound = [NSSound soundNamed:[[NSUserDefaults standardUserDefaults] stringForKey:@"cfsCompletionSound"]];
        [sound play];
    }
}

- (void)textChanged:(STGOptionTextField *)textField
{
    [self saveProperties];
}

- (IBAction)resetCfsFolderClicked:(id)sender
{
    NSString *folderPath = [[STGFileHelper getDocumentsDirectory] stringByAppendingString:@"/Coco Storage"];
    
    [STGFileHelper createFolderIfNonExistent:folderPath];
    
    [_cfsFolderTextField setStringValue:folderPath];
    
    [self saveProperties];
}

- (IBAction)openCfsFolderDialogue:(id)sender
{
    NSOpenPanel *filePanel = [[NSOpenPanel alloc] init];
    [filePanel setCanChooseDirectories:YES];
    [filePanel setCanChooseFiles:NO];
    [filePanel setAllowsMultipleSelection:NO];
    [filePanel setDirectoryURL:[NSURL fileURLWithPath:[_cfsFolderTextField stringValue]]];
    [filePanel setFloatingPanel:NO];
    [filePanel setCanSelectHiddenExtension:YES];
    [filePanel setTitle:@"Select Temp Folder Path"];
    [filePanel setPrompt:@"Select"];
    
    if ([filePanel runModal] == NSOKButton)
    {
        NSURL *selectedURL = [filePanel URL];
        
        [_cfsFolderTextField setStringValue:[selectedURL relativeString]];
        
        [self saveProperties];
    }
}

- (IBAction)openCfsFolderInFinder:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:[_cfsFolderTextField stringValue]]];
}

- (NSString *)identifier
{
    return @"optionsCFS";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:@"NSFolder"];
}

- (NSString *)toolbarItemLabel
{
    return @"CFS";
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
