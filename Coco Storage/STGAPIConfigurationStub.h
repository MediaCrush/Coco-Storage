//
//  STGAPIConfigurationStub.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 18.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STGAPIConfiguration.h"

extern NSString * const kSTGAPIConfigurationKeyStub;

@interface STGAPIConfigurationStub : NSObject <STGAPIConfiguration>

+ (STGAPIConfigurationStub *)standardConfiguration;
+ (void)registerStandardConfiguration;

@end
