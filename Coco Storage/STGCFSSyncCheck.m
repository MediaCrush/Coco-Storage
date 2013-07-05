//
//  STGCFSSyncCheck.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 19.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGCFSSyncCheck.h"

@implementation STGCFSSyncCheck

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setServerFileDict:[NSMutableDictionary dictionary]];
    }
    return self;
}

- (STGCFSSyncCheckEntry *)getFirstModifiedFile:(NSString *)file
{
    return nil;
}

- (NSArray *)getServerStyleDictionary:(NSString *)file
{
    return nil;
}

@end
