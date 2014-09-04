//
//  STGServiceHandler.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 04.09.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STGServiceHandler;

@protocol STGServiceHandlerDelegate <NSObject>

- (void)uploadObjects:(NSArray *)objects fromHandler:(STGServiceHandler *)handler;

@end

@interface STGServiceHandler : NSObject

@property (nonatomic, assign) id<STGServiceHandlerDelegate> delegate;

+ (instancetype)registeredHandler;

- (void)uploadObjects:(NSPasteboard *)pasteboard userData:(NSString *)udata error:(NSString **)err;

@end
