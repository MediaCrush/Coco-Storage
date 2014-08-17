//
//  STGMovieCaptureSession.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

#import "STGDataCaptureManager.h"

typedef NS_ENUM(NSUInteger, STGMovieCaptureType)
{
    STGMovieCaptureTypeScreenMovie = 0,
    STGMovieCaptureTypeCameraMovie = 1,
    STGMovieCaptureTypeAudio = 2,
};

@interface STGMovieCaptureSession : NSObject <AVCaptureFileOutputRecordingDelegate>
{
    @private
    AVCaptureSession *mSession;
    AVCaptureFileOutput *fileOutput;
    NSTimer *mTimer;
}

@property (nonatomic, assign) NSObject<STGDataCaptureDelegate> *delegate;

@property (nonatomic, retain) NSURL *destURL;

@property (nonatomic, assign) NSString *qualityPreset;

@property (nonatomic, assign) NSTimeInterval recordTime;
@property (nonatomic, assign) CGDirectDisplayID displayID;
@property (nonatomic, assign) NSRect recordRect;

@property (nonatomic, assign) STGMovieCaptureType recordType;
@property (nonatomic, assign) BOOL recordMicrophoneAudio;
@property (nonatomic, assign) BOOL recordComputerAudio;

-(BOOL)isRecording;

-(BOOL)beginRecording;
-(void)stopRecording;
-(void)cancelRecording;

@end
