//
//  STGOptionsAboutViewController.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 25.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGOptionsAboutViewController.h"

@interface STGOptionsAboutViewController ()

@end

@implementation STGOptionsAboutViewController

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
    [_versionLabel setStringValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
}

+ (void)registerStandardDefaults:(NSMutableDictionary *)defaults
{
    
}

- (void)saveProperties
{
    
}

- (void)viewDidDisappear
{
    [self saveProperties];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)sendEmailToIvorius:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:lukastenbrink@gmail.com"]];
}

- (IBAction)sendEmailToClone:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:help@getstorage.net"]];
}

- (IBAction)openStorageLink:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://getstorage.net"]];
}

- (IBAction)openMASPreferencesLink:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/shpakovski/MASPreferences"]];
}

- (IBAction)openSparkleLink:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://sparkle.andymatuschak.org"]];
}


- (NSString *)identifier
{
    return @"optionsAbout";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:@"NSUser"];
}

- (NSString *)toolbarItemLabel
{
    return @"About";
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
