//
//  STGUploadedFileToken.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 16.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGUploadedFileToken.h"

@implementation STGUploadedFileToken

- (instancetype)initWithOnlineID:(NSString *)onlineID
{
    self = [super init];
    if (self)
    {
        [self setOnlineID:onlineID];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.onlineID];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    _onlineID = [decoder decodeObject];
    return self;
}

@end
