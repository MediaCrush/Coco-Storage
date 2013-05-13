//
//  STGSystemHelper.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 26.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STGSystemHelper : NSObject

+ (BOOL)appLaunchesAtLogin;
+ (void)setStartOnSystemLaunch:(BOOL)start;

+ (void)showDockTile;

@end
