//
//  STGIntercommHandlerImpl.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 03.09.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGIntercommHandlerImpl.h"

@interface STGIntercommHandlerImpl ()

@property (nonatomic, retain) NSConnection *connection;

@end

@implementation STGIntercommHandlerImpl

+ (instancetype)registeredHandlerForName:(NSString *)name
{
    NSConnection *connection = [NSConnection connectionWithReceivePort:[NSPort port] sendPort:nil];
    
    if ([connection registerName:name])
    {
        STGIntercommHandlerImpl *intercommHandler = [[STGIntercommHandlerImpl alloc] init];
        [intercommHandler setConnection:connection];
        [connection setRootObject:intercommHandler];
        return intercommHandler;
    }
    
    return nil;
}

- (NSArray *)uploadObjects:(NSArray *)objects
{
    if ([_delegate respondsToSelector:@selector(uploadObjects:fromHandler:)])
        return [_delegate uploadObjects:objects fromHandler:self];
    
    return nil;
}

@end
