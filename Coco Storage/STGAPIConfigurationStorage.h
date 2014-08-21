//
//  STGAPIConfigurationStorage.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 08.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGAPIConfiguration.h"

#import "STGWelcomeWindowControllerStorage.h"

@interface STGAPIConfigurationStorage : NSObject <STGAPIConfiguration, STGWelcomeWindowControllerDelegate>

@property (nonatomic, retain) STGWelcomeWindowControllerStorage *welcomeWC;

+ (STGAPIConfigurationStorage *)standardConfiguration;

@end
