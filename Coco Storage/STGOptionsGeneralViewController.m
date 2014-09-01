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

#import "STGAPIConfiguration.h"

@interface STGOptionsGeneralViewController ()

- (void)deleteCurrentRows;

@end

@implementation STGOptionsGeneralViewController

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
    
    [_storageKeyTable registerForDraggedTypes:[NSArray arrayWithObject:NSPasteboardTypeString]];
    
    if (![[STGAPIConfiguration currentConfiguration] hasAPIKeys])
    {
        [[self apiKeyView] removeFromSuperview];
        [[self view] setFrameSize:NSMakeSize([[self view] bounds].size.width, 170)];
    }
}

+ (void)registerStandardDefaults:(NSMutableDictionary *)defaults
{
    [defaults setObject:[NSNumber numberWithInt:0] forKey:@"startAtLogin"];
    [defaults setObject:[NSNumber numberWithInt:0] forKey:@"showDockIcon"];
    [defaults setObject:[NSNumber numberWithInt:1] forKey:@"autoUpdate"];
    
    [defaults setObject:[NSArray array] forKey:@"storageKeys"];
}

- (void)saveProperties
{
    [[NSUserDefaults standardUserDefaults] setInteger:[_launchOnStartupButton integerValue] forKey:@"startAtLogin"];
    [[NSUserDefaults standardUserDefaults] setInteger:[_showDockIconButton integerValue] forKey:@"showDockIcon"];
    [[NSUserDefaults standardUserDefaults] setInteger:[_autoUpdateButton integerValue] forKey:@"autoUpdate"];    
    
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
        [STGSystemHelper setDockTileVisible:([_showDockIconButton integerValue] == 1)];
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
    return [[STGAPIConfiguration currentConfiguration] hasAPIKeys];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [[[NSUserDefaults standardUserDefaults] stringArrayForKey:@"storageKeys"] count] + 1;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSArray *keyArray = [[NSUserDefaults standardUserDefaults] stringArrayForKey:@"storageKeys"];
    
    if ([[tableColumn identifier] isEqualToString:@"Keys"])
    {
        return [keyArray count] > row ? [keyArray objectAtIndex:row] : @"";
    }
    else
    {
        if ([keyArray count] > row && [[[NSUserDefaults standardUserDefaults] stringForKey:@"mainStorageKey"] isEqualToString:[keyArray objectAtIndex:row]])
            return [NSNumber numberWithBool:YES];
        
        return [NSNumber numberWithBool:NO];
    }
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSArray *keyArray = [[NSUserDefaults standardUserDefaults] stringArrayForKey:@"storageKeys"];

    if ([[tableColumn identifier] isEqualToString:@"Main"])
    {
        if (row >= [keyArray count])
        {
            [cell setTransparent:YES];
            [cell setEnabled:NO];
        }
        else
        {
            [cell setTransparent:NO];
            [cell setEnabled:YES];
        }
    }
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([[tableColumn identifier] isEqualToString:@"Keys"])
    {
        NSMutableArray *storageKeyArray = [[[NSUserDefaults standardUserDefaults] stringArrayForKey:@"storageKeys"] mutableCopy];
        if (row < [storageKeyArray count])
            [storageKeyArray removeObjectAtIndex:row];
        if (object && [object length] > 0)
            [storageKeyArray insertObject:object atIndex:row];
            
        [[NSUserDefaults standardUserDefaults] setObject:storageKeyArray forKey:@"storageKeys"];
        
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"mainStorageKey"] length] == 0)
            [[NSUserDefaults standardUserDefaults] setObject:object forKey:@"mainStorageKey"];
        
        
        [tableView reloadData];        
    }
    else
    {
        NSArray *storageKeyArray = [[NSUserDefaults standardUserDefaults] stringArrayForKey:@"storageKeys"];

        if ([object boolValue])
        {
            if (row < [storageKeyArray count])
            {
                [[NSUserDefaults standardUserDefaults] setObject:[storageKeyArray objectAtIndex:row] forKey:@"mainStorageKey"];
                
                [tableView reloadData];                
            }
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"mainStorageKey"];
        }
    }
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation
{
    NSMutableArray *storageKeyArray = [[[NSUserDefaults standardUserDefaults] stringArrayForKey:@"storageKeys"] mutableCopy];

    
    if (row <= [storageKeyArray count])
    {
        BOOL didWrite = NO;
        
        NSPasteboard *pboard = [info draggingPasteboard];
        NSArray *strings = [pboard readObjectsForClasses:[NSArray arrayWithObject:[NSString class]] options:[NSDictionary dictionary]];
        if (strings)
        {
            for (NSString *string in strings)
            {
                if ([info draggingSource] == tableView)
                {
                    NSUInteger oldIndex = [storageKeyArray indexOfObject:string];
                    [storageKeyArray removeObjectAtIndex:oldIndex];
                    
                    if (row > oldIndex)
                        row --;
                }
                
                [storageKeyArray insertObject:string atIndex:row];
                didWrite = YES;
            }
        }
        
        if (didWrite)
        {
            [[NSUserDefaults standardUserDefaults] setObject:storageKeyArray forKey:@"storageKeys"];
            
            [tableView reloadData];
            
            return YES;
        }
    }
    
    return NO;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    NSArray *storageKeyArray = [[NSUserDefaults standardUserDefaults] stringArrayForKey:@"storageKeys"];
    
    if (row > [storageKeyArray count])
        return NSDragOperationNone;
        
    [tableView setDropRow:row dropOperation:NSTableViewDropAbove]; 
	if ([info draggingSource] != tableView)
        return NSDragOperationCopy;
    
    return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard
{
    NSArray *keys = [[NSUserDefaults standardUserDefaults] stringArrayForKey:@"storageKeys"];
    NSUInteger keyCount = [keys count];
    
    __block NSMutableArray *pboardObjects = [[NSMutableArray alloc] init];
    [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if (idx < keyCount)
            [pboardObjects addObject:[keys objectAtIndex:idx]];
    }];
    
    if ([pboardObjects count] > 0)
    {
        [pboard clearContents];
        [pboard writeObjects:pboardObjects];
        
        return YES;
    }
    
    return NO;
}

- (void)keyDown:(NSEvent *)theEvent
{
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
 
    if(key == NSDeleteCharacter || key == NSBackspaceCharacter)
    {
        [self deleteCurrentRows];
        return;
    }
    
    [super keyDown:theEvent];
}

- (void)deleteCurrentRows
{
    __block NSMutableArray *storageKeyArray = [[[NSUserDefaults standardUserDefaults] stringArrayForKey:@"storageKeys"] mutableCopy];
    
    NSIndexSet *selectedIndices = [_storageKeyTable selectedRowIndexes];
    [selectedIndices enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"mainStorageKey"] isEqualToString:[storageKeyArray objectAtIndex:[_storageKeyTable selectedRow]]])
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"mainStorageKey"];
        
        [storageKeyArray removeObjectAtIndex:[_storageKeyTable selectedRow]];
    }];
    
    [[NSUserDefaults standardUserDefaults] setObject:storageKeyArray forKey:@"storageKeys"];
    [_storageKeyTable reloadData];
}

- (IBAction)copy:(id)sender
{
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    NSArray *storageKeyArray = [[NSUserDefaults standardUserDefaults] stringArrayForKey:@"storageKeys"];
    
    NSIndexSet *rowIndexes = [_storageKeyTable selectedRowIndexes];

    __block NSMutableArray *pboardObjects = [[NSMutableArray alloc] init];
    [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if (idx < [storageKeyArray count])
            [pboardObjects addObject:[storageKeyArray objectAtIndex:idx]];
    }];
    
    if ([pboardObjects count] > 0)
    {
        [pboard clearContents];
        [pboard writeObjects:pboardObjects];
    }
}

- (IBAction)cut:(id)sender
{
    [self copy:sender];
    [self deleteCurrentRows];
}

- (IBAction)paste:(id)sender
{
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    NSArray *strings = [pboard readObjectsForClasses:[NSArray arrayWithObject:[NSString class]] options:[NSDictionary dictionary]];
    
    if (strings)
    {
        NSMutableArray *storageKeyArray = [[[NSUserDefaults standardUserDefaults] stringArrayForKey:@"storageKeys"] mutableCopy];

        for (NSString *string in strings)
        {
            NSUInteger insertIndex = 0;
            
            if ([_storageKeyTable selectedRow] >= 0)
                insertIndex = [_storageKeyTable selectedRow];
            
            [storageKeyArray insertObject:string atIndex:insertIndex];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:storageKeyArray forKey:@"storageKeys"];
        [_storageKeyTable reloadData];
    }
}

- (BOOL)validateUserInterfaceItem:(id )anItem
{
    if ([anItem action] == @selector(copy:))
		return YES;

    if ([anItem action] == @selector(cut:))
		return YES;

    if ([anItem action] == @selector(paste:))
		return YES;

    return NO;
}

@end
