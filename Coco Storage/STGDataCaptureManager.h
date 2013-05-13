//
//  STGDataCaptureManager.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 27.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STGDataCaptureEntry;

@interface STGDataCaptureManager : NSObject

+ (STGDataCaptureEntry *)startScreenCapture:(BOOL)fullscreen tempFolder:(NSString *)tempFolder silent:(BOOL)silent;
+ (NSArray *)startFileCaptureWithTempFolder:(NSString *)tempFolder;

@end
