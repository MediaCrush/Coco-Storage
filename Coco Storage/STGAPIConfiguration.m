//
//  STGAPIConfiguration.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGAPIConfiguration.h"

STGAPIConfiguration *standardConfiguration;

@implementation STGAPIConfiguration

+ (STGAPIConfiguration *)standardConfiguration
{
    if (!standardConfiguration)
        standardConfiguration = [[STGAPIConfiguration alloc] init];
    
    return standardConfiguration;
}

@end
