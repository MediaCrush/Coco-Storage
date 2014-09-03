//
//  STGIntercommHandler.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 03.09.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STGIntercommHandler <NSObject>

- (NSArray *)uploadObjects:(NSArray *)objects;

@end
