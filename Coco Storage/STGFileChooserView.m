//
//  STGFileChooserView.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 09.09.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGFileChooserView.h"

@interface STGFileChooserView ()

@property (nonatomic, retain) NSPopUpButton *popUpButton;
@property (nonatomic, retain) NSMenuItem *selectedMenuItem;

@end

@implementation STGFileChooserPath

+ (STGFileChooserPath *)filePathWithPath:(NSString *)path
{
    STGFileChooserPath *filePath = [[STGFileChooserPath alloc] init];
    [filePath setPath:path];
    return filePath;
}

+ (STGFileChooserPath *)filePathWithPath:(NSString *)path customTitle:(NSString *)title
{
    STGFileChooserPath *filePath = [[STGFileChooserPath alloc] init];
    [filePath setPath:path];
    [filePath setTitle:title];
    return filePath;
}

@end

@implementation STGFileChooserView

- (void)baseInit
{
    [self setPopUpButton:[[NSPopUpButton alloc] init]];

    [_popUpButton setTarget:self];
    [_popUpButton setAction:@selector(selectPath:)];
    [self addSubview:_popUpButton];
    
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_popUpButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self updatePopupButtonContents];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (void)setSelectedPath:(NSString *)selectedPath
{
    if (![_selectedPath isEqualToString:selectedPath])
    {
        _selectedPath = [selectedPath copy];
        [self updatePopupButtonContents];
        
        if ([_delegate respondsToSelector:@selector(pathChooserView:chosePath:)])
            [_delegate pathChooserView:self chosePath:_selectedPath];
    }
}

- (void)setPaths:(NSArray *)paths
{
    _paths = [paths copy];
    [self updatePopupButtonContents];
}

- (void)updateConstraints
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_popUpButton);

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_popUpButton]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_popUpButton]|" options:0 metrics:nil views:views]];
    
    [super updateConstraints];
}

- (void)selectPath:(id)sender
{
    id repObject = [[_popUpButton selectedItem] representedObject];
    [_popUpButton selectItem:_selectedMenuItem];
    
    if (repObject)
        [self setSelectedPath:repObject];
    else
    {
        NSOpenPanel *filePanel = [[NSOpenPanel alloc] init];
        [filePanel setCanChooseDirectories:YES];
        [filePanel setCanChooseFiles:NO];
        [filePanel setAllowsMultipleSelection:NO];
        [filePanel setDirectoryURL:[NSURL fileURLWithPath:_selectedPath]];
        [filePanel setFloatingPanel:NO];
        [filePanel setCanSelectHiddenExtension:YES];
        [filePanel setTitle:@"Select Directory"];
        [filePanel setPrompt:@"Select"];
        
        if ([filePanel runModal] == NSOKButton)
        {
            NSURL *selectedURL = [filePanel URL];
            [self setSelectedPath:[selectedURL path]];
        }
    }
}

- (void)updatePopupButtonContents
{
    [_popUpButton removeAllItems];
    
    NSMenu *menu = [[NSMenu alloc] init];
    _selectedMenuItem = nil;
    
    for (id anObject in _paths)
    {
        BOOL isString = [anObject isKindOfClass:[NSString class]];
        BOOL isPath = [anObject isKindOfClass:[STGFileChooserPath class]];

        if (isString || isPath)
        {
            NSString *path = isString ? anObject : [anObject path];
            NSString *title = isString ? [anObject lastPathComponent] : [anObject title];
            if (!title)
                title = [path lastPathComponent];
            
            NSMenuItem *pathItem = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
            [pathItem setImage:[self imageAppropriateForDropdown:path]];

            [pathItem setRepresentedObject:path];
            [menu addItem:pathItem];
            
            if ([path isEqualToString:_selectedPath])
                _selectedMenuItem = pathItem;
        }
        else if ([anObject isKindOfClass:[NSMenuItem class]])
        {
            [menu addItem:anObject];
        }
        else
            [NSException exceptionWithName:@"Unexpected path item class" reason:[NSString stringWithFormat:@"Expected STGFileChooserPath, NSString or NSMenuItem in 'paths', but got %@", anObject] userInfo:[NSDictionary dictionary]];
    }
    
    if (!_selectedMenuItem && _selectedPath)
    {
        [self setSelectedMenuItem:[[NSMenuItem alloc] initWithTitle:[_selectedPath lastPathComponent] action:nil keyEquivalent:@""]];
        [_selectedMenuItem setImage:[self imageAppropriateForDropdown:_selectedPath]];
        
        [_selectedMenuItem setRepresentedObject:_selectedPath];
        [menu insertItem:_selectedMenuItem atIndex:0];
        [menu insertItem:[NSMenuItem separatorItem] atIndex:1];
    }
    
    if ([_paths count] > 0)
        [menu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *differentItem = [[NSMenuItem alloc] initWithTitle:@"Choose..." action:nil keyEquivalent:@""];
    [menu addItem:differentItem];
    
    [_popUpButton setMenu:menu];
    [_popUpButton selectItem:_selectedMenuItem];
}

- (NSImage *)imageAppropriateForDropdown:(NSString *)path
{
    NSImage *image = [[NSWorkspace sharedWorkspace] iconForFile:path];
    [image setSize:NSMakeSize(16, 16)];
    return image;
}

@end
