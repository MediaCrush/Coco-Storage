//
//  STGStatusItemManager.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 02.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGStatusItemManager.h"

#import "STGRecentUploadView.h"

#import "STGDataCaptureEntry.h"

#import "STGPacketQueue.h"
#import "STGPacket.h"
#import "STGPacketUploadFile.h"

@implementation STGStatusItemManager

@synthesize delegate = _delegate;

@synthesize statusItem = _statusItem;

@synthesize statusMenu = _statusMenu;
@synthesize captureAreaMenuItem = _captureAreaMenuItem;
@synthesize captureFullScreenMenuItem = _captureFullScreenMenuItem;
@synthesize captureFileMenuItem = _captureFileMenuItem;

@synthesize recentFilesItem = _recentFilesItem;
@synthesize noRecentFilesItem = _noRecentFilesItem;

@synthesize currentUploadsItem = _currentUploadsItem;
@synthesize noCurrentUploadItem = _noCurrentUploadItem;
@synthesize moreCurrentUploadsItem = _moreCurrentUploadsItem;

@synthesize pauseUploadsItem = _pauseUploadsItem;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        NSNib *nib = [[NSNib alloc] initWithNibNamed:@"STGStatusItemManager" bundle:nil];
        
        NSArray *topLevelObjects;
        [nib instantiateWithOwner:self topLevelObjects:&topLevelObjects];
        
        _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        [_statusItem setMenu:_statusMenu];
        [_statusItem setTitle:@""];
        [_statusItem setHighlightMode:YES];
        [_statusItem setToolTip:@"Coco Storage"];
        [_statusItem setImage:[NSImage imageNamed:@"CocoStorageStatusBarIcon.png"]];
        [[_statusItem menu] setDelegate:self];
    }
    
    return self;
}

- (void)updateRecentFiles:(NSArray *)recentFiles
{
    [[_recentFilesItem submenu] removeAllItems];
    
    if ([recentFiles count] == 0)
    {
        [[_recentFilesItem submenu] addItem:_noRecentFilesItem];
    }
    else
    {
        for (int i = (int)[recentFiles count] - 1; i >= 0; i--)
        {
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Recent upload" action:@selector(openRecentFile:) keyEquivalent:@""];
            [menuItem setTarget:self];
            [menuItem setTag:i];
            
            NSViewController *tempController = [[NSViewController alloc] initWithNibName:@"STGRecentFileView" bundle:nil];
            
            STGRecentUploadView *itemView = (STGRecentUploadView *)[tempController view];
            [menuItem setView:itemView];
            [itemView setCaptureEntry:[recentFiles objectAtIndex:i]];
            [itemView setRecentUploadDelegate:self];
            
            NSString *fileName = [[[recentFiles objectAtIndex:i] fileURL] lastPathComponent];
            NSInteger pointLoc = [fileName rangeOfString:@"." options:NSBackwardsSearch].location;
            NSString *fileType = pointLoc != NSNotFound ? [fileName substringFromIndex:pointLoc] : @"";
            
            [[[menuItem view] viewWithTag:10] setImage:[[NSWorkspace sharedWorkspace] iconForFileType:fileType]];
            [[itemView viewWithTag:11] setStringValue:[[[recentFiles objectAtIndex:i] fileURL] lastPathComponent]];
            [[itemView viewWithTag:12] setStringValue:[[recentFiles objectAtIndex:i] onlineLink]];
            [[itemView viewWithTag:13] setAction:@selector(deleteRecentFile:)];
            [[itemView viewWithTag:13] setTarget:self];
            [[itemView viewWithTag:14] setAction:@selector(copyRecentFileLink:)];
            [[itemView viewWithTag:14] setTarget:self];
            
            [[_recentFilesItem submenu] addItem:menuItem];
        }
    }
}

- (void)updateUploadQueue:(STGPacketQueue *)packetQueue currentProgress:(float)currentFileProgress
{
    [[_currentUploadsItem submenu] removeAllItems];
    
    NSMutableArray *uploadEntries = [[NSMutableArray alloc] init];
    
    for (STGDataCaptureEntry *entry in [packetQueue uploadQueue])
    {
        if ([entry isKindOfClass:[STGPacket class]])
        {
            [uploadEntries addObject:entry];
        }
    }
    
    if ([uploadEntries count] == 0)
    {
        [[_currentUploadsItem submenu] addItem:_noCurrentUploadItem];
    }
    else
    {
        for (int i = 0; i < [uploadEntries count] && i < 10; i++)
        {
            if (i < 9 || [uploadEntries count] == 10)
            {
                float progress = i == 0 ? currentFileProgress : 0.0;
                NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ (%3.0f%%)", [[[[uploadEntries objectAtIndex:i] dataCaptureEntry] fileURL] lastPathComponent], progress] action:@selector(cancelQueueFile:) keyEquivalent:@""];
                [menuItem setTarget:self];
                [menuItem setImage:[NSImage imageNamed:@"NSStopProgressTemplate"]];
                [menuItem setTag:i];
                
                [[_currentUploadsItem submenu] addItem:menuItem];
            }
            else
            {
                [[_currentUploadsItem submenu] addItem:_moreCurrentUploadsItem];
            }
        }
    }
}

- (void)setStatusItemUploadProgress:(float)progress
{
    int imageNumber = progress * 15;
    if (imageNumber == 0)
        [_statusItem setImage:[NSImage imageNamed:@"CocoStorageStatusBarIcon.png"]];
    else
        [_statusItem setImage:[NSImage imageNamed:[NSString stringWithFormat:@"CocoStorageStatusBarIcon%02i.png", imageNumber]]];
}

- (void)menuDidClose:(NSMenu *)menu
{
    for (NSMenuItem *item in [[_recentFilesItem submenu] itemArray])
    {
        if ([[item view] isKindOfClass:[STGRecentUploadView class]])
        {
            [(STGRecentUploadView *)[item view] setIsHighlighted:NO];
        }
    }
}

- (void)updatePauseDownloadItem
{
    BOOL pause = [[NSUserDefaults standardUserDefaults] boolForKey:@"pauseUploads"];
    
    if (pause)
    {
        [_pauseUploadsItem setState:NSOnState];
    }
    else
    {
        [_pauseUploadsItem setState:NSOffState];
    }
}


- (IBAction)captureArea:(id)sender
{
    if ([_delegate respondsToSelector:@selector(captureScreen:)])
    {
        [_delegate captureScreen:NO];
    }
}

- (IBAction)captureFullScreen:(id)sender
{
    if ([_delegate respondsToSelector:@selector(captureScreen:)])
    {
        [_delegate captureScreen:YES];
    }
}

- (IBAction)captureFile:(id)sender
{
    if ([_delegate respondsToSelector:@selector(captureFile)])
    {
        [_delegate captureFile];
    }
}

- (IBAction)quit:(id)sender
{
    [NSApp terminate:self];
}

- (IBAction)cancelUploads:(id)sender
{
    if ([_delegate respondsToSelector:@selector(cancelAllUploads)])
    {
        [_delegate cancelAllUploads];
    }
}

- (IBAction)togglePauseUploads:(id)sender
{
    if ([_delegate respondsToSelector:@selector(togglePauseUploads)])
    {
        [_delegate togglePauseUploads];
    }
}

- (IBAction)openRecentFile:(id)sender
{
    STGDataCaptureEntry *entry = [(STGRecentUploadView *)[sender superview] captureEntry];
    
    [[NSWorkspace sharedWorkspace] openURL:[entry fileURL]];
}

- (IBAction)deleteRecentFile:(id)sender
{
    if ([_delegate respondsToSelector:@selector(deleteRecentFile:)])
    {
        STGDataCaptureEntry *entry = [(STGRecentUploadView *)[sender superview] captureEntry];

        [_delegate deleteRecentFile:entry];
    }
}

- (IBAction)copyRecentFileLink:(id)sender
{
    NSString *link = [[[sender superview] viewWithTag:12] stringValue];
    
    [[NSPasteboard generalPasteboard] clearContents];
    
    [[NSPasteboard generalPasteboard] setData:[link dataUsingEncoding:NSUTF8StringEncoding] forType:NSPasteboardTypeString];
    
    [[_statusItem menu] cancelTracking];
}

- (void)recentUploadView:(STGRecentUploadView *)recentUploadView clicked:(NSEvent *)theEvent
{
    [[_statusItem menu] cancelTracking];
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[[recentUploadView captureEntry] onlineLink]]];
}

- (IBAction)cancelQueueFile:(id)sender
{
    if ([_delegate respondsToSelector:@selector(cancelQueueFile:)])
    {
        int index = (int)[sender tag];

        [_delegate cancelQueueFile:index];
    }
}

- (IBAction)openStorageAccount:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://getstorage.net/panel/user"]];
}

- (IBAction)openMyFiles:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://getstorage.net/panel/object"]];
}

- (IBAction)openPreferences:(id)sender
{
    if ([_delegate respondsToSelector:@selector(openPreferences)])
    {
        [_delegate openPreferences];
    }
}

@end
