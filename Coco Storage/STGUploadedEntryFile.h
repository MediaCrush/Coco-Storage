//
//  STGUploadedEntryFile.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 27.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STGUploadedEntry.h"

@class STGDataCaptureEntry;

@interface STGUploadedEntryFile : STGUploadedEntry

@property (nonatomic, retain) NSString *onlineID;
@property (nonatomic, retain) NSURL *onlineLink;

@property (nonatomic, retain) NSString *fileName;

- (instancetype)initWithDataCaptureEntry:(STGDataCaptureEntry *)entry onlineID:(NSString *)onlineID onlineLink:(NSURL *)onlineLink;

@end
