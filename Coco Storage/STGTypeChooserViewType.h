//
//  STGTypeChooserViewType.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 29.11.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STGTypeChooserViewType : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSImage *image;
@property (nonatomic, retain) NSDictionary *userInfo;

- (id)initWithName:(NSString *)name image:(NSImage *)image userInfo:(NSDictionary *)userInfo;

@end
