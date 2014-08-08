//
//  STGAPIConfigurationStorage.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 08.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGAPIConfigurationStorage.h"

STGAPIConfiguration *standardConfiguration;

@implementation STGAPIConfigurationStorage

+ (STGAPIConfiguration *)standardConfiguration
{
    if (!standardConfiguration)
    {
        standardConfiguration = [[STGAPIConfiguration alloc] init];
        
        [standardConfiguration setUploadLink:@"https://api.stor.ag/v1/object?key=%@"];
        [standardConfiguration setDeletionLink:@"https://api.stor.ag/v1/object/%@?key=%@"];
        [standardConfiguration setGetObjectInfoLink:@"https://api.stor.ag/v1/object/%@?key=%@"];
        
        [standardConfiguration setGetAPIV1StatusLink:@"https://api.stor.ag/v1/status?key=%@"];
        [standardConfiguration setGetAPIV2StatusLink:@"https://api.stor.ag/v2/status?key=%@"];
        
        [standardConfiguration setCfsBaseLink:@"https://api.stor.ag/v2/cfs%@?key=%@"];
    }
    
    return standardConfiguration;
}

@end
