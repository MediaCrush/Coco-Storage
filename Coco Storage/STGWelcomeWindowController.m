//
//  STGWelcomeWindowController.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 01.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGWelcomeWindowController.h"

@interface STGWelcomeWindowController ()

- (void)addVersion:(NSString *)version withChanges:(NSArray *)array;

@end

@implementation STGWelcomeWindowController

@synthesize welcomeWCDelegate = _welcomeWCDelegate;

@synthesize changelogTextView = _changelogTextView;

- (void)awakeFromNib
{
    [_changelogTextView setString:@""];
    
    [self addVersion:@"1.0" withChanges:[NSArray arrayWithObject:@"Main Release!"]];
    [self addVersion:@"1.1" withChanges:[NSArray arrayWithObject:@"Bug fixes"]];
    [self addVersion:@"1.2" withChanges:[NSArray arrayWithObjects:@"Improved recent uploads", @"Added deletion of objects", @"Added Welcome Screen", @"Clicking files queued for upload now cancels them", @"Renamed the App Support and Temp folders", @"Bug Fixes", nil]];
    [self addVersion:@"1.3" withChanges:[NSArray arrayWithObjects:@"Added server status checks", "Bug Fixes", nil]];
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
    [attributedString appendAttributedString:[_changelogTextView attributedString]];
    [attributedString endEditing];
    
    [[_changelogTextView textStorage] setAttributedString:attributedString];
}

- (IBAction)openPreferences:(id)sender
{
    [[self window] performClose:self];
    
    if ([_welcomeWCDelegate respondsToSelector:@selector(openPreferences)])
    {
        [_welcomeWCDelegate openPreferences];
    }
}

@end
