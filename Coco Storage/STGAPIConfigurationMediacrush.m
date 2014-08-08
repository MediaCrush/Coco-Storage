//
//  STGAPIConfigurationMediacrush.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 08.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGAPIConfigurationMediacrush.h"

STGAPIConfigurationMediacrush *standardConfiguration;

@implementation STGAPIConfigurationMediacrush

@synthesize delegate;

+ (STGAPIConfigurationMediacrush *)standardConfiguration
{
    if (!standardConfiguration)
    {
        standardConfiguration = [[STGAPIConfigurationMediacrush alloc] init];
    }
    
    return standardConfiguration;
}

@end
