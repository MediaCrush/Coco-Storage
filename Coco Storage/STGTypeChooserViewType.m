//
//  STGTypeChooserViewType.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 29.11.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGTypeChooserViewType.h"

@implementation STGTypeChooserViewType

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (id)initWithName:(NSString *)name image:(NSImage *)image userInfo:(NSDictionary *)userInfo
{
    self = [super init];
    if (self)
    {
        [self setName:name];
        [self setImage:image];
        [self setUserInfo:userInfo];
    }
    
    return self;
}

@end
