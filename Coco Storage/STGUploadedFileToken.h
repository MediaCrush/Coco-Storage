//
//  STGUploadedFileToken.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 16.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STGUploadedFileToken : NSObject <NSCoding>

@property (nonatomic, retain) NSString *onlineID;

- (instancetype)initWithOnlineID:(NSString *)onlineID;

@end
