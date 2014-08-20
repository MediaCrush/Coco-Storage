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
    STGDropActionUploadFile = 0,
    STGDropActionUploadDirectoryZip = 1,
    STGDropActionUploadZip = 2,
    STGDropActionUploadText = 3,
    STGDropActionUploadRtfText = 4,
    STGDropActionUploadImage = 5,
    STGDropActionUploadLinkRedirect = 6,
    STGDropActionUploadColor = 7
};

@class STGDataCaptureEntry;
@class STGMovieCaptureSession;

@protocol STGMovieCaptureSessionDelegate;

@protocol STGDataCaptureDelegate <NSObject>
@optional
- (void)dataCaptureCompleted:(STGDataCaptureEntry *)entry sender:(id)sender;
@end

@interface STGDataCaptureManager : NSObject

+ (NSArray *)getSupportedPasteboardContentTypes;
+ (NSArray *)captureDataFromPasteboard:(NSPasteboard *)pasteboard withAction:(STGDropAction)action;
+ (NSArray *)getActionsFromPasteboard:(NSPasteboard *)pasteboard;
+ (NSString *)getNameForAction:(STGDropAction)action;
+ (NSArray *)getReadableActionsFromPasteboard:(NSPasteboard *)pasteboard;

+ (void)startScreenCapture:(BOOL)fullscreen tempFolder:(NSString *)tempFolder silent:(BOOL)silent delegate:(NSObject<STGDataCaptureDelegate> *)delegate;

+ (void)startFileCaptureWithTempFolder:(NSString *)tempFolder delegate:(NSObject<STGDataCaptureDelegate> *)delegate;

+ (STGMovieCaptureSession *)startScreenMovieCapture:(NSRect)capturedRect display:(CGDirectDisplayID)displayID length:(NSTimeInterval)length tempFolder:(NSString *)tempFolder recordVideo:(BOOL)recordVideo recordComputerAudio:(BOOL)recordComputerAudio recordMicrophoneAudio:(BOOL)recordMicrophoneAudio quality:(NSString *)qualityPreset delegate:(NSObject<STGMovieCaptureSessionDelegate> *)delegate;

+ (STGDataCaptureEntry *)captureTextAsFile:(NSString *)text tempFolder:(NSString *)tempFolder;
+ (STGDataCaptureEntry *)captureAttributedTextAsFile:(NSAttributedString *)text tempFolder:(NSString *)tempFolder;
+ (STGDataCaptureEntry *)captureLinkAsRedirectFile:(NSURL *)link tempFolder:(NSString *)tempFolder;
+ (STGDataCaptureEntry *)captureImageAsFile:(NSImage *)image tempFolder:(NSString *)tempFolder;
+ (STGDataCaptureEntry *)captureColorAsFile:(NSColor *)color tempFolder:(NSString *)tempFolder;
+ (STGDataCaptureEntry *)captureFile:(NSURL *)link tempFolder:(NSString *)tempFolder;
+ (STGDataCaptureEntry *)captureFilesAsZip:(NSArray *)links withTempFolder:(NSString *)tempFolder;

@end
