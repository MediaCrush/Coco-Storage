//
//  STGAPIConfigurationMediacrush.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 08.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGAPIConfigurationMediacrush.h"

STGAPIConfiguration *standardConfiguration;

@implementation STGAPIConfigurationMediacrush

+ (STGAPIConfiguration *)standardConfiguration
{
    if (!standardConfiguration)
    {
        standardConfiguration = [[STGAPIConfiguration alloc] init];
        
        [standardConfiguration setUploadLink:@"https://mediacru.sh/v1/object?key=%@"];
        [standardConfiguration setDeletionLink:@"https://mediacru.sh/v1/object/%@?key=%@"];
        [standardConfiguration setGetObjectInfoLink:@"https://mediacru.sh/v1/object/%@?key=%@"];
        
        [standardConfiguration setGetAPIV1StatusLink:@"https://mediacru.sh/v1/status?key=%@"];
        [standardConfiguration setGetAPIV2StatusLink:@"https://mediacru.sh/v2/status?key=%@"];
        
        [standardConfiguration setCfsBaseLink:@"https://mediacru.sh/v2/cfs%@?key=%@"];
    }
    
    return standardConfiguration;
}

@end