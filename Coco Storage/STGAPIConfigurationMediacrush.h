//
//  STGAPIConfigurationMediacrush.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 08.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGAPIConfiguration.h"

extern NSString * const kSTGAPIConfigurationKeyMediacrush;

@interface STGAPIConfigurationMediacrush : NSObject <STGAPIConfiguration>

+ (STGAPIConfigurationMediacrush *)standardConfiguration;
+ (void)registerStandardConfiguration;

@end
