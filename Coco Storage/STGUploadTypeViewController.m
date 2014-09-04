//
//  STGTypeChooserViewController.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 30.11.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGUploadTypeViewController.h"

#import "STGDataCaptureManager.h"
#import "STGTypeChooserView.h"
#import "STGTypeChooserViewType.h"

@interface STGUploadTypeViewController ()

@end

@implementation STGUploadTypeViewController

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
    
}

- (void)setUploadTypes:(NSArray *)uploadTypes fromDragging:(BOOL)dragging
{
    NSMutableArray *types = [[NSMutableArray alloc] initWithCapacity:[uploadTypes count]];
    
    for (NSInteger i = 0; i < [uploadTypes count]; i++)
    {
        STGUploadAction dropAction = [[uploadTypes objectAtIndex:i] integerValue];
        
        NSImage *image;
        NSString *name;
        
        if (dropAction == STGUploadActionUploadFile)
        {
            image = [NSImage imageNamed:@"NSMultipleDocuments"];
            name = @"File";
        }
        else if (dropAction == STGUploadActionUploadDirectoryZip)
        {
            image = [NSImage imageNamed:@"NSFolder"];
            name = @"Folder as Zip";
        }
        else if (dropAction == STGUploadActionUploadZip)
        {
            image = [NSImage imageNamed:@"NSFolder"];
            name = @"Files as Zip";
        }
        else if (dropAction == STGUploadActionUploadColor)
        {
            image = [NSImage imageNamed:@"NSColorPanel"];
            name = @"Color";
        }
        else if (dropAction == STGUploadActionUploadImage)
        {
            image = [[NSWorkspace sharedWorkspace] iconForFileType:@"png"];
            name = @"Image";
        }
        else if (dropAction == STGUploadActionRedirectLink)
        {
            image = [NSImage imageNamed:@"NSNetwork"];
            name = @"Shorten link";
        }
        else if (dropAction == STGUploadActionUploadRtfText)
        {
            image = [[NSWorkspace sharedWorkspace] iconForFileType:@"rtf"];
            name = @"Attributed Text";
        }
        else if (dropAction == STGUploadActionUploadText)
        {
            image = [[NSWorkspace sharedWorkspace] iconForFileType:@"txt"];
            name = @"Text";
        }
        else if (dropAction == STGUploadActionRehostFromLink)
        {
            image = [NSImage imageNamed:@"NSNetwork"];
            name = @"Fetch Media from URL";
        }
        else
        {
            image = [NSImage imageNamed:@"AppIcon"];
            name = @"Unknown (?!)";
        }
        
        [types addObject:[[STGTypeChooserViewType alloc] initWithName:name image:image userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInteger:dropAction] forKey:@"actionType"]]];
    }

    BOOL same = NO;
    if ([[self popover] isShown])
    {
        same = YES;

        if ([[[self typeChooserView] types] count] == [types count])
        {
            for (NSInteger i = 0; i < [types count]; i++)
            {
                BOOL nameEqual = [[[[[self typeChooserView] types] objectAtIndex:i] name] isEqualToString:[[types objectAtIndex:i] name]];
                
                if (!nameEqual)
                    same = NO;
            }
        }
    }
    
    if (!same)
    {
        [[self popover] setContentSize:NSMakeSize(([types count] > 1 ? [types count] : 1.5) * 55, 55 + 10)];
        [[self typeChooserView] setTypes:types];
    }
    
    if ([types count] > 0)
        [[self typeChooserView] setHighlightedType:[[[self typeChooserView] types] objectAtIndex:0] animated:same];
    
    [[self typeChooserView] setDragMode:dragging];
}

- (void)showRelativeToRect:(NSRect)referenceFrame ofView:(NSView *)view preferredEdge:(NSRectEdge)preferredEdge
{
    [[self popover] showRelativeToRect:referenceFrame ofView:view preferredEdge:preferredEdge];
}

- (void)hide
{
    [[self popover] performClose:self];
}

- (void)chooserView:(STGTypeChooserView *)view choseType:(STGTypeChooserViewType *)type
{
    STGUploadAction action = [[[type userInfo] objectForKey:@"actionType"] unsignedIntegerValue];
    
    if ([[self delegate] respondsToSelector:@selector(uploadTypeViewController:choseType:)])
    {
        [[self delegate] uploadTypeViewController:self choseType:action];
    }
}

- (void)chooserView:(STGTypeChooserView *) view choseType:(STGTypeChooserViewType *)type whileDragging:(id<NSDraggingInfo>)sender
{
    STGUploadAction action = [[[type userInfo] objectForKey:@"actionType"] unsignedIntegerValue];
    
    if ([[self delegate] respondsToSelector:@selector(uploadTypeViewController:choseType:whileDragging:)])
    {
        [[self delegate] uploadTypeViewController:self choseType:action whileDragging:sender];
    }
}

- (void)chooserView:(STGTypeChooserView *)view draggingEnded:(id<NSDraggingInfo>)sender
{
    if ([[self delegate] respondsToSelector:@selector(uploadTypeViewController:draggingEnded:)])
    {
        [[self delegate] uploadTypeViewController:self draggingEnded:sender];
    }
}

- (void)chooserView:(STGTypeChooserView *)view draggingExited:(id<NSDraggingInfo>)sender
{
    if ([[self delegate] respondsToSelector:@selector(uploadTypeViewController:draggingExited:)])
    {
        [[self delegate] uploadTypeViewController:self draggingExited:sender];
    }
}

@end
