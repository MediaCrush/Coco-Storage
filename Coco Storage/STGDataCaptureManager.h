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

+ (NSArray *)getSupportedPasteboardContentTypes;
+ (NSArray *)captureDataFromPasteboard:(NSPasteboard *)pasteboard;
+ (NSString *)getActionFromPasteboard:(NSPasteboard *)pasteboard;

+ (STGDataCaptureEntry *)startScreenCapture:(BOOL)fullscreen tempFolder:(NSString *)tempFolder silent:(BOOL)silent;
+ (STGDataCaptureEntry *)captureTextAsFile:(NSString *)text tempFolder:(NSString *)tempFolder;
+ (STGDataCaptureEntry *)captureLinkAsRedirectFile:(NSURL *)link tempFolder:(NSString *)tempFolder;
+ (NSArray *)startFileCaptureWithTempFolder:(NSString *)tempFolder;

@end
