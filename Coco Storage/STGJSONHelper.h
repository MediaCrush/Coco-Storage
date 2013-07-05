//
//  STGJSONHelper.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.06.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STGJSONHelper : NSObject

+ (NSObject *)getJSONFromData:(NSData *)data;
+ (NSDictionary *)getDictionaryJSONFromData:(NSData *)data;
+ (NSArray *)getArrayJSONFromData:(NSData *)data;

@end
