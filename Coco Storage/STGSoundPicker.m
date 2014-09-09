//
//  STGSoundPicker.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 09.09.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGSoundPicker.h"

@interface STGSoundPicker ()

@property (nonatomic, retain) NSPopUpButton *popUpButton;

@end

@implementation STGSoundPicker

- (void)baseInit
{
    _enabled = YES;
    [self setPopUpButton:[[NSPopUpButton alloc] init]];
    
    [_popUpButton setTarget:self];
    [_popUpButton setAction:@selector(selectSound:)];
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

- (void)setSelectedSound:(NSString *)selectedSound
{
    if (![_selectedSound isEqualToString:selectedSound])
    {
        _selectedSound = [selectedSound copy];
        
        for (NSMenuItem *item in [_popUpButton itemArray])
        {
            if ([[item representedObject] isEqualToString:selectedSound])
            {
                if ([_popUpButton selectedItem] != item)
                {
                    [_popUpButton selectItem:item];
                    break;
                }
            }
        }
        
        if ([_delegate respondsToSelector:@selector(soundPicker:choseSound:)])
            [_delegate soundPicker:self choseSound:_selectedSound];
    }
}

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    [_popUpButton setEnabled:enabled];
}

- (void)updateConstraints
{
    NSDictionary *views = NSDictionaryOfVariableBindings(_popUpButton);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_popUpButton]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_popUpButton]|" options:0 metrics:nil views:views]];
    
    [super updateConstraints];
}

- (void)selectSound:(id)sender
{
    id repObject = [[_popUpButton selectedItem] representedObject];
    [self setSelectedSound:repObject];
}

- (void)updatePopupButtonContents
{
    [_popUpButton removeAllItems];
    
    for (NSString *soundName in [STGSoundPicker systemSounds])
    {
        [_popUpButton addItemWithTitle:soundName];
        [[_popUpButton itemAtIndex:[_popUpButton numberOfItems] - 1] setRepresentedObject:soundName];
    }
}

+ (NSArray *)systemSounds
{
    static NSArray *systemSounds = nil;

    if ( !systemSounds )
    {
        NSMutableArray *returnArr = [[NSMutableArray alloc] init];
        NSEnumerator *librarySources = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSAllDomainsMask, YES) objectEnumerator];
        NSString *sourcePath;
        
        while ( sourcePath = [librarySources nextObject] )
        {
            NSEnumerator *soundSource = [[NSFileManager defaultManager] enumeratorAtPath: [sourcePath stringByAppendingPathComponent: @"Sounds"]];
            NSString *soundFile;
            while ( soundFile = [soundSource nextObject] )
                if ( [NSSound soundNamed: [soundFile stringByDeletingPathExtension]] )
                    [returnArr addObject: [soundFile stringByDeletingPathExtension]];
        }
        
        systemSounds = [[NSArray alloc] initWithArray: [returnArr sortedArrayUsingSelector:@selector(compare:)]];
    }
    return systemSounds;
}

@end
