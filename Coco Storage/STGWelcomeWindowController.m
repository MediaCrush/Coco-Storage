//
//  STGWelcomeWindowController.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 01.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGWelcomeWindowController.h"

#import "NSButton+TextColor.h"

#import "STGFileHelper.h"

CGFloat boxOpacityHover = 1.0f;
CGFloat boxOpacityIdle = 0.0f;

@interface STGWelcomeWindowController ()

- (void)addVersion:(NSString *)version withChanges:(NSArray *)array;

@end

@implementation STGWelcomeWindowController

- (void)awakeFromNib
{
//    [_changelogTextView setString:@""];
    
    [self addVersion:@"1.0" withChanges:[NSArray arrayWithObject:@"Main Release!"]];
    [self addVersion:@"1.1" withChanges:[NSArray arrayWithObject:@"Bug fixes"]];
    [self addVersion:@"1.2" withChanges:[NSArray arrayWithObjects:@"Improved recent uploads", @"Added deletion of objects", @"Added Welcome Screen", @"Clicking files queued for upload now cancels them", @"Renamed the App Support and Temp folders", @"Bug Fixes", nil]];
    [self addVersion:@"1.3" withChanges:[NSArray arrayWithObjects:@"Added server status checks", @"Added CFS functionality", @"Added auto-updates (Sparkle)", @"Drag and Drop support", @"Usage of https (secure data up- and downloads)", @"Bug Fixes", nil]];
    
    [[self window] setAcceptsMouseMovedEvents:YES];
    
    [_showOnLaunchButton setIntegerValue:[[NSUserDefaults standardUserDefaults] integerForKey:@"showWelcomeWindowOnLaunch"]];
    [_showOnLaunchButton setTextColor:[NSColor whiteColor]];
    
    [_storageKeyBox setAlphaValue:boxOpacityIdle];
    [_cfsFolderBox setAlphaValue:boxOpacityIdle];
    [_accountBox setAlphaValue:boxOpacityIdle];
}

- (void)addVersion:(NSString *)version withChanges:(NSArray *)array
{
    NSMutableString *versionString = [[NSMutableString alloc] init];
    
    [versionString appendString:@"\n"];

    [versionString appendFormat:@"Version %@\n", version];
    
    NSUInteger versionTitleLength = [versionString length];
    
    for (NSString *string in array)
    {
        [versionString appendFormat:@"- %@", string];
        
        if ([array lastObject] != string)
            [versionString appendString:@"\n"];
    }
    
    [versionString appendString:@"\n"];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:versionString];
    [attributedString beginEditing];
    [attributedString addAttribute:NSFontAttributeName value:[NSFont boldSystemFontOfSize:12] range:NSMakeRange(0, versionTitleLength)];
    [attributedString addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:12] range:NSMakeRange(versionTitleLength, [versionString length] - versionTitleLength)];
//    [attributedString appendAttributedString:[_changelogTextView attributedString]];
    [attributedString endEditing];
    
//    [[_changelogTextView textStorage] setAttributedString:attributedString];
}

+ (void)registerStandardDefaults:(NSMutableDictionary *)defaults
{
    [defaults setObject:[NSNumber numberWithInt:1] forKey:@"showWelcomeWindowOnLaunch"];
}

- (void)saveProperties
{
    [[NSUserDefaults standardUserDefaults] setInteger:[_showOnLaunchButton integerValue] forKey:@"showWelcomeWindowOnLaunch"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)checkboxButtonClicked:(id)sender
{
    [self saveProperties];
}

- (IBAction)openPreferences:(id)sender
{    
    if ([_welcomeWCDelegate respondsToSelector:@selector(openPreferences)])
    {
        [_welcomeWCDelegate openPreferences];
    }
}

- (IBAction)openCFSFolder:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[STGFileHelper urlFromStandardPath:[[NSUserDefaults standardUserDefaults] stringForKey:@"cfsFolder"]]];
}

- (IBAction)openStorageAccount:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://getstorage.net/panel/user"]];
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    if (NSPointInRect([theEvent locationInWindow], [_storageKeyBox frame]))
        [_storageKeyBox setAlphaValue:boxOpacityHover];
    else
        [_storageKeyBox setAlphaValue:boxOpacityIdle];

    if (NSPointInRect([theEvent locationInWindow], [_cfsFolderBox frame]))
        [_cfsFolderBox setAlphaValue:boxOpacityHover];
    else
        [_cfsFolderBox setAlphaValue:boxOpacityIdle];

    if (NSPointInRect([theEvent locationInWindow], [_accountBox frame]))
        [_accountBox setAlphaValue:boxOpacityHover];
    else
        [_accountBox setAlphaValue:boxOpacityIdle];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if (NSPointInRect([theEvent locationInWindow], [_storageKeyBox frame]))
        [self openPreferences:self];
    
    if (NSPointInRect([theEvent locationInWindow], [_cfsFolderBox frame]))
        [self openCFSFolder:self];
    
    if (NSPointInRect([theEvent locationInWindow], [_accountBox frame]))
        [self openStorageAccount:self];
    
    [_storageKeyBox setAlphaValue:boxOpacityIdle];
    [_cfsFolderBox setAlphaValue:boxOpacityIdle];
    [_accountBox setAlphaValue:boxOpacityIdle];
}

@end
