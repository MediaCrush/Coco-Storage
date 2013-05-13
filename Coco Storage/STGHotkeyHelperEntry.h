//
//  STGHotkeyHelperEntry.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 26.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STGHotkeyHelperEntry : NSObject

@property (nonatomic, retain) NSString *character;
@property (nonatomic, assign) NSUInteger modifiers;

@property (nonatomic, retain) NSDictionary *userInfo;

+ (id)entryWithCharacter:(NSString *)character modifiers:(NSUInteger)modifiers userInfo:(NSDictionary *)userInfo;
+ (id)entryWithAllStatesAndUserInfo:(NSDictionary *)userInfo;

@end
