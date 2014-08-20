//
//  STGMovieCaptureSession.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGMovieCaptureSession.h"

#import "STGDataCaptureEntry.h"

@implementation STGMovieCaptureSession

- (BOOL)beginRecording
{
    NSError *error = nil;

    mSession = [[AVCaptureSession alloc] init];
//    [mSession beginConfiguration];
    mSession.sessionPreset = _qualityPreset;
    
    if (_recordType == STGMovieCaptureTypeScreenMovie)
    {
        AVCaptureScreenInput *screenInput = [[AVCaptureScreenInput alloc] initWithDisplayID:_displayID];

        if (!screenInput) {
            mSession = nil;
            return NO;
        }
        
        [screenInput setCropRect:_recordRect];
        
        if ([mSession canAddInput:screenInput])
            [mSession addInput:screenInput];
        else
            NSLog(@"Could not add Screen Input to recording");
    }
    else if (_recordType == STGMovieCaptureTypeCameraMovie)
    {
        AVCaptureDevice *defaultVideoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//        NSArray *videoCaptureDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        
        AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:defaultVideoDevice error:&error];

        if (!videoInput) {
            mSession = nil;
            return NO;
        }
        
        if ([mSession canAddInput:videoInput])
            [mSession addInput:videoInput];
        else
            NSLog(@"Could not add Video Input to recording");
    }
    
    AVCaptureDevice *computerAudioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];

    if (_recordMicrophoneAudio)
    {
        AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:computerAudioDevice error:&error];
        
        if ([mSession canAddInput:audioInput])
            [mSession addInput:audioInput];
        else
            NSLog(@"Could not add Computer Audio Input to recording");
        
        if (error)
            NSLog(@"Error capturing Computer Audio: %@", [error localizedDescription]);
    }
    
    // Can only take one audio channel
//    if (_recordComputerAudio)
//    {
//        NSArray *audioCaptureDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
//        
//        for (AVCaptureDevice *device in audioCaptureDevices)
//        {
//            if (device != computerAudioDevice)
//            {
//                AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
//
//                if ([mSession canAddInput:audioInput])
//                    [mSession addInput:audioInput];
//                else
//                    NSLog(@"Could not add Audio Input to recording");
//                
//                if (error)
//                    NSLog(@"Error capturing Audio: %@", [error localizedDescription]);
//            }
//        }
//    }
    
    if (_recordType == STGMovieCaptureTypeScreenMovie || _recordType == STGMovieCaptureTypeCameraMovie)
    {
        fileOutput = [[AVCaptureMovieFileOutput alloc] init];
        
        if ([mSession canAddOutput:fileOutput])
            [mSession addOutput:fileOutput];
        else
            NSLog(@"Could not add Movie Output to recording");
    }
    else if (_recordType == STGMovieCaptureTypeAudio)
    {
        fileOutput = [[AVCaptureAudioFileOutput alloc] init];
        
        if ([mSession canAddOutput:fileOutput])
            [mSession addOutput:fileOutput];
        else
            NSLog(@"Could not add Audio Output to recording");
    }
    
//    [mSession commitConfiguration];
    
    [mSession startRunning];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[_destURL path]])
    {
        NSError *err;
        if (![[NSFileManager defaultManager] removeItemAtPath:[_destURL path] error:&err])
        {
            NSLog(@"Error deleting existing movie %@",[err localizedDescription]);
        }
    }
    
    if (_recordType == STGMovieCaptureTypeScreenMovie || _recordType == STGMovieCaptureTypeCameraMovie)
        [fileOutput startRecordingToOutputFileURL:_destURL recordingDelegate:self];
    else if (_recordType == STGMovieCaptureTypeAudio)
        [(AVCaptureAudioFileOutput *)fileOutput startRecordingToOutputFileURL:_destURL outputFileType:AVFileTypeAppleM4A recordingDelegate:self];
    
    if ([_delegate respondsToSelector:@selector(movieCaptureSessionDidBegin:)])
        [_delegate movieCaptureSessionDidBegin:self];

    mTimer = [NSTimer scheduledTimerWithTimeInterval:_recordTime target:self selector:@selector(finishRecord:) userInfo:nil repeats:NO];
    
    return YES;
}

- (BOOL)isRecording
{
    return mSession != nil && [mSession isRunning];
}

- (void)stopRecording
{
    if ([self isRecording])
    {
        [mSession stopRunning];
        [self cancelRecording];
        
        if ([_delegate respondsToSelector:@selector(movieCaptureSessionDidEnd:withError:wasCancelled:)])
            [_delegate movieCaptureSessionDidEnd:self withError:nil wasCancelled:NO];
    }
}

- (void)cancelRecording
{
    [mTimer invalidate];
    mTimer = nil;

    if ([self isRecording])
    {
        if ([_delegate respondsToSelector:@selector(movieCaptureSessionDidEnd:withError:wasCancelled:)])
            [_delegate movieCaptureSessionDidEnd:self withError:nil wasCancelled:YES];
    }
    
    [mSession stopRunning];
    mSession = nil;

    [fileOutput stopRecording];
    fileOutput = nil;
}

-(void)finishRecord:(NSTimer *)timer
{
    [self stopRecording];
}

#pragma mark AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    if (![[[error userInfo] objectForKey:@"AVErrorRecordingSuccessfullyFinishedKey"] boolValue])
    {
        NSLog(@"Did finish recording to %@ due to error %@", [outputFileURL description], [error description]);
        
        if ([_delegate respondsToSelector:@selector(movieCaptureSessionDidEnd:withError:wasCancelled:)])
            [_delegate movieCaptureSessionDidEnd:self withError:error wasCancelled:NO];
        [self cancelRecording];
    }
}

@end
