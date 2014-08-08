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

@synthesize delegate, cfsBaseLink, deletionLink, getObjectInfoLink;

+ (STGAPIConfigurationMediacrush *)standardConfiguration
{
    if (!standardConfiguration)
    {
        standardConfiguration = [[STGAPIConfigurationMediacrush alloc] init];
        
        [standardConfiguration setDeletionLink:@"https://mediacru.sh/v1/object/%@?key=%@"];
        [standardConfiguration setGetObjectInfoLink:@"https://mediacru.sh/v1/object/%@?key=%@"];
        
        [standardConfiguration setCfsBaseLink:@"https://mediacru.sh/v2/cfs%@?key=%@"];
    }
    
    return standardConfiguration;
}

@end
