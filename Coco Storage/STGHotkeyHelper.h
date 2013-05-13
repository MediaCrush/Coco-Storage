//
//  STGHotkeyHelper.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 26.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STGHotkeyHelperEntry;

@protocol STGHotkeyHelperDelegate;

@interface STGHotkeyHelper : NSObject

@property (nonatomic, assign) CFMachPortRef machPortRef;
@property (nonatomic, retain) NSMachPort *machPortWrapper;

@property (nonatomic, retain) NSMutableArray *entries;

@property (nonatomic, weak) id<STGHotkeyHelperDelegate> delegate;

- (id)initWithDelegate:(id<STGHotkeyHelperDelegate>)delegate;

- (void)addShortcutEntry:(STGHotkeyHelperEntry *)entry;
- (void)removeShortcutEntry:(STGHotkeyHelperEntry *)entry;
- (void)removeAllShortcutEntries;

- (NSEvent *)keyPressed:(NSEvent *)event;

@end

@protocol STGHotkeyHelperDelegate <NSObject>

- (NSEvent *)keyPressed:(NSEvent *)event entry:(STGHotkeyHelperEntry *)entry userInfo:(NSDictionary *)userInfo;

@end