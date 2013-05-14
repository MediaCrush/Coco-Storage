//
//  STGDataCaptureEntry.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 25.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STGDataCaptureEntry : NSObject

@property (nonatomic, retain) NSURL *fileURL;
@property (nonatomic, assign) BOOL deleteOnCompletetion;

@property (nonatomic, assign) NSString *onlineID;
@property (nonatomic, assign) NSString *onlineLink;

+ (id)entryWithURL:(NSURL *)url deleteOnCompletion:(BOOL)del;
+ (id)entryFromString:(NSString *)string;

- (NSString *)storeInfoInString;

@end
