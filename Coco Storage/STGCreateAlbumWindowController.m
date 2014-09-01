//
//  STGCreateAlbumWindowController.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 16.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGCreateAlbumWindowController.h"

#import "STGUploadedFileToken.h"

#import "STGAPIConfiguration.h"

@interface STGCreateAlbumWindowController ()

@end

@implementation STGCreateAlbumWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    [_tokenField setCompletionDelay:0.5];
}

- (void)createAlbum:(id)sender
{
    if ([_delegate respondsToSelector:@selector(createAlbumWithIDs:)])
    {
        NSArray *tokenArray = [_tokenField objectValue];
        NSMutableArray *idArray = [[NSMutableArray alloc] initWithCapacity:[tokenArray count]];
        
        for (STGUploadedFileToken *token in tokenArray)
        {
            [idArray addObject:[token onlineID]];
        }
        
        [_delegate createAlbumWithIDs:idArray];
    }
    
    [[self window] close];
}

- (id)tokenField:(NSTokenField *)tokenField representedObjectForEditingString:(NSString *)editingString
{
    return [[STGUploadedFileToken alloc] initWithOnlineID:editingString];
}

- (NSString *)tokenField:(NSTokenField *)tokenField displayStringForRepresentedObject:(id)representedObject
{
    return [representedObject onlineID];
}

- (NSString *)tokenField:(NSTokenField *)tokenField editingStringForRepresentedObject:(id)representedObject
{
    return [representedObject onlineID];
}

- (BOOL)tokenField:(NSTokenField *)tokenField hasMenuForRepresentedObject:(id)representedObject
{
    return NO;
}

- (NSMenu *)tokenField:(NSTokenField *)tokenField menuForRepresentedObject:(id)representedObject
{
    return nil;
}

- (NSArray *)tokenField:(NSTokenField *)tokenField readFromPasteboard:(NSPasteboard *)pboard
{
    NSArray *strings = [pboard readObjectsForClasses:[NSArray arrayWithObject:[NSString class]]     options:[NSDictionary dictionary]];
    
    NSMutableArray *tokens = [[NSMutableArray alloc] init];
    
    for (NSString *string in strings)
    {
        NSArray *words = [string componentsSeparatedByString:@","];
        
        for (NSString *tokenString in words)
        {
            NSString *representedID = [[STGAPIConfiguration currentConfiguration] objectIDFromString:tokenString];
            
            [tokens addObject:[[STGUploadedFileToken alloc] initWithOnlineID:representedID ? representedID : tokenString]];
        }
    }
    
    return tokens;
}

- (BOOL)tokenField:(NSTokenField *)tokenField writeRepresentedObjects:(NSArray *)objects toPasteboard:(NSPasteboard *)pboard
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[objects count]];
    
    for (STGUploadedFileToken *token in objects)
        [array addObject:[token onlineID]];
    
    [pboard writeObjects:array];
    
    return YES;
}

- (NSArray *)tokenField:(NSTokenField *)tokenField shouldAddObjects:(NSArray *)tokens atIndex:(NSUInteger)index
{
    return tokens;
}

- (NSTokenStyle)tokenField:(NSTokenField *)tokenField styleForRepresentedObject:(id)representedObject
{
    return NSRoundedTokenStyle;
}

// Auto-completions lag as all shit

//- (NSArray *)tokenField:(NSTokenField *)tokenField completionsForSubstring:(NSString *)substring indexOfToken:(NSInteger)tokenIndex indexOfSelectedItem:(NSInteger *)selectedIndex
//{
//    NSMutableArray *completions = [[NSMutableArray alloc] init];
//
//    BOOL containsSameString = NO;
//    for (NSString *uploadID in _uploadIDList)
//    {
//        if ([uploadID rangeOfString:substring options:NSCaseInsensitiveSearch].location != NSNotFound)
//            [completions addObject:uploadID];
//        
//        if ([uploadID isEqualToString:substring])
//            containsSameString = YES;
//    }
//    
//    if (!containsSameString)
//        [completions addObject:substring];
//    
//    *selectedIndex = 0;
//
//    return completions;
//}

@end
