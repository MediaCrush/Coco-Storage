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

+ (void)createDockTile;
+ (void)setDockTileVisible:(BOOL)visible;

+ (BOOL)registerAsAssistiveDevice:(NSString *)programID error:(NSString **)error output:(NSString **)output;
+ (BOOL)deleteFromAssistiveDevices:(NSString *)programID error:(NSString **)error output:(NSString **)output;
+ (BOOL)isAssistiveDevice;

+ (BOOL)runProcessAsAdministrator:(NSString*)scriptPath
                     withArguments:(NSArray *)arguments
                            output:(NSString **)output
                  errorDescription:(NSString **)errorDescription;

+ (void)restartUsingSparkle;


@end
