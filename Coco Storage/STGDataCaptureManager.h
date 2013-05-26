//
//  STGDataCaptureManager.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 27.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, STGDropAction)
{
    STGDropActionNone = 0,
    STGDropActionUploadFile = 1,
    STGDropActionUploadDirectoryZip = 2,
    STGDropActionUploadZip = 3,
    STGDropActionUploadText = 4,
    STGDropActionUploadRtfText = 5,
    STGDropActionUploadRtfdText = 6,
    STGDropActionUploadLinkRedirect = 7
};

@class STGDataCaptureEntry;

@interface STGDataCaptureManager : NSObject

+ (NSArray *)getSupportedPasteboardContentTypes;
+ (NSArray *)captureDataFromPasteboard:(NSPasteboard *)pasteboard;
+ (STGDropAction)getActionFromPasteboard:(NSPasteboard *)pasteboard;
+ (NSString *)getReadableActionFromPasteboard:(NSPasteboard *)pasteboard;

+ (STGDataCaptureEntry *)startScreenCapture:(BOOL)fullscreen tempFolder:(NSString *)tempFolder silent:(BOOL)silent;
+ (STGDataCaptureEntry *)captureTextAsFile:(NSString *)text tempFolder:(NSString *)tempFolder;
+ (STGDataCaptureEntry *)captureAttributedTextAsFile:(NSAttributedString *)text tempFolder:(NSString *)tempFolder;
+ (STGDataCaptureEntry *)captureLinkAsRedirectFile:(NSURL *)link tempFolder:(NSString *)tempFolder;
+ (STGDataCaptureEntry *)captureFile:(NSURL *)link tempFolder:(NSString *)tempFolder;
+ (STGDataCaptureEntry *)captureFilesAsZip:(NSArray *)links withTempFolder:(NSString *)tempFolder;
+ (NSArray *)startFileCaptureWithTempFolder:(NSString *)tempFolder;

@end
