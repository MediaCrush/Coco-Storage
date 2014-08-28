//
//  STGDataCaptureEntry.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 25.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STGDataCaptureManager.h"

@interface STGDataCaptureEntry : NSObject <NSCoding>

@property (nonatomic, retain) NSURL *fileURL;
@property (nonatomic, assign) BOOL deleteOnCompletetion;

@property (nonatomic, assign) STGDropAction uploadAction;

+ (id)entryWithAction:(STGDropAction)action url:(NSURL *)url deleteOnCompletion:(BOOL)del;

@end
