//
//  STGCFSSyncCheck.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 19.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STGCFSSyncCheckEntry.h"

@interface STGCFSSyncCheck : NSObject

@property (nonatomic, retain) NSMutableDictionary *serverFileDict;
@property (nonatomic, retain) NSMutableDictionary *cachedServerFileDict;

@property (nonatomic, retain) NSString *basePath;

- (STGCFSSyncCheckEntry *)getFirstModifiedFile:(NSString *)file;
- (NSArray *)getServerStyleDictionary:(NSString *)file;

@end
