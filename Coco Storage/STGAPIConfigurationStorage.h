//
//  STGAPIConfigurationStorage.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 08.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGAPIConfiguration.h"

@interface STGAPIConfigurationStorage : NSObject <STGAPIConfiguration>

+ (STGAPIConfigurationStorage *)standardConfiguration;

@end
