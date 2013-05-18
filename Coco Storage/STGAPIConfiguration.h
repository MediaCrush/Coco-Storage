//
//  STGAPIConfiguration.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STGAPIConfiguration : NSObject

@property (nonatomic, retain) NSString *uploadLink;
@property (nonatomic, retain) NSString *deletionLink;
@property (nonatomic, retain) NSString *getObjectInfoLink;

@property (nonatomic, retain) NSString *getAPIV1StatusLink;
@property (nonatomic, retain) NSString *getAPIV2StatusLink;

@property (nonatomic, retain) NSString *getFileListLink;

+ (STGAPIConfiguration *)standardConfiguration;

@end
