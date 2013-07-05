//
//  STGHotkeyHelperEntry.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 26.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGHotkeyHelperEntry.h"

@implementation STGHotkeyHelperEntry

+ (id)entryWithCharacter:(NSString *)character modifiers:(NSUInteger)modifiers userInfo:(NSDictionary *)userInfo
{
    STGHotkeyHelperEntry *entry = [[STGHotkeyHelperEntry alloc] init];
    
    [entry setCharacter:character];
    [entry setModifiers:modifiers];
    [entry setUserInfo:userInfo];
    
    return entry;
}

+ (id)entryWithAllStatesAndUserInfo:(NSDictionary *)userInfo
{
    STGHotkeyHelperEntry *entry = [[STGHotkeyHelperEntry alloc] init];
    
    [entry setCharacter:nil];
    [entry setModifiers:0];
    [entry setUserInfo:userInfo];
    
    return entry;
}


@end
