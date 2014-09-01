//
//  STGAPIConfiguration.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGAPIConfiguration.h"

STGAPIConfiguration *currentConfiguration;
NSMutableDictionary *configurations;

@implementation STGAPIConfiguration

+ (void)setCurrentConfiguration:(STGAPIConfiguration *)configuration
{
    currentConfiguration = configuration;
}

+ (STGAPIConfiguration *)currentConfiguration
{
    return currentConfiguration;
}

+ (NSMutableDictionary *)configurations
{
    if (!configurations)
        configurations = [[NSMutableDictionary alloc] init];
    
    return configurations;
}

+ (id<STGAPIConfiguration>)configurationWithID:(NSString *)configID
{
    return [[self configurations] objectForKey:configID];
}

+ (BOOL)registerConfiguration:(id<STGAPIConfiguration>)configuration withID:(NSString *)configID
{
    if ([[self configurations] objectForKey:configID])
        return NO;
    
    [[self configurations] setObject:configuration forKey:configID];
    return YES;
}

+ (NSString *)idOfConfiguration:(id<STGAPIConfiguration>)configuration
{
    NSArray *keys = [[self configurations] allKeysForObject:configuration];
    return [keys count] > 0 ? [keys objectAtIndex:0] : nil;
}

+ (NSArray *)validUploadActions:(NSArray *)actions forConfiguration:(id<STGAPIConfiguration>) configuration
{
    NSMutableSet *intersection = [NSMutableSet setWithArray:actions];
    [intersection intersectSet:[configuration supportedUploadTypes]];
    
    return [intersection allObjects];
}

@end
