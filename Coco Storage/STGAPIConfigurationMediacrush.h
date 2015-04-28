//
//  STGAPIConfigurationMediacrush.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 08.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGAPIConfiguration.h"

@interface STGAPIConfigurationMediacrush : NSObject <STGAPIConfiguration>

@property (strong) NSString *name;
@property (strong) NSString *baseUrl;

- (id)initWithName:(NSString *)name url:(NSString *)baseUrl;

@end
