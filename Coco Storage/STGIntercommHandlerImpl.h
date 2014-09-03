//
//  STGIntercommHandlerImpl.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 03.09.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STGIntercommHandler.h"

@class STGIntercommHandlerImpl;

@protocol STGIntercommHandlerDelegate <NSObject>

- (NSArray *)uploadObjects:(NSArray *)objects fromHandler:(STGIntercommHandlerImpl *)handler;

@end

@interface STGIntercommHandlerImpl : NSObject <STGIntercommHandler>

@property (nonatomic, assign) id<STGIntercommHandlerDelegate> delegate;

+ (instancetype)registeredHandlerForName:(NSString *)name;

@end
