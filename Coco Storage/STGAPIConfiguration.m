//
//  STGAPIConfiguration.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGAPIConfiguration.h"

STGAPIConfiguration *currentConfiguration;

@implementation STGAPIConfiguration

+ (void)setCurrentConfiguration:(STGAPIConfiguration *)configuration
{
    currentConfiguration = configuration;
}

+ (STGAPIConfiguration *)currentConfiguration
{
    return currentConfiguration;
}

+ (NSArray *)validUploadActions:(NSArray *)actions forConfiguration:(id<STGAPIConfiguration>) configuration
{
    NSMutableSet *intersection = [NSMutableSet setWithArray:actions];
    [intersection intersectSet:[configuration supportedUploadTypes]];
    
    return [intersection allObjects];
}

@end
