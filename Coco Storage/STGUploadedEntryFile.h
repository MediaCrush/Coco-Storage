//
//  STGUploadedEntryFile.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 27.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STGUploadedEntrySimple.h"

@class STGDataCaptureEntry;

@interface STGUploadedEntryFile : STGUploadedEntrySimple

@property (nonatomic, retain) NSString *fileName;

- (instancetype)initWithAPIConfigurationID:(NSString *)configID onlineID:(NSString *)onlineID onlineLink:(NSURL *)onlineLink dataCaptureEntry:(STGDataCaptureEntry *)dataCaptureEntry;

@end
