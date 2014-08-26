//
//  STGGifConverter.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 26.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGGifConverter.h"

@interface STGGifConverter ()

@property (nonatomic, retain) AVAssetImageGenerator *currentImageGenerator;

@property (nonatomic, assign) NSUInteger convertingFrames;
@property (nonatomic, assign) NSUInteger convertedFrames;

@property (nonatomic, assign) CFMutableDataRef gifData;
@property (nonatomic, assign) CGImageDestinationRef imageDestRef;

@end

@implementation STGGifConverter

- (void)beginConversion:(AVURLAsset *)movie
{
    if (!_isConverting)
    {
        _movie = movie;
        
        _isConverting = YES;
        if ([_delegate respondsToSelector:@selector(gifConversionStarted:)])
            [_delegate gifConversionStarted:self];

        [self setCurrentImageGenerator:[[AVAssetImageGenerator alloc] initWithAsset:_movie]];
        
        AVAssetTrack *videoTrack = [[_movie tracksWithMediaType:AVMediaTypeVideo] lastObject];
        if(!videoTrack)
            ;
        
        float frameRate = [videoTrack nominalFrameRate];
        CMTime movieDuration = [_movie duration];
        int maxFrames = (int)(frameRate * (float)movieDuration.value / (float)movieDuration.timescale);
        
        [_currentImageGenerator setRequestedTimeToleranceBefore:kCMTimeZero];
        [_currentImageGenerator setRequestedTimeToleranceAfter:kCMTimeZero];
        
        NSMutableArray *timesArray = [[NSMutableArray alloc] initWithCapacity:maxFrames];
        
        for (NSUInteger i = 0; i < maxFrames; i++)
        {
            CMTime currentTime = CMTimeMake((int)((float)i / frameRate * movieDuration.timescale), movieDuration.timescale);
            [timesArray addObject:[NSValue valueWithCMTime:currentTime]];
        }
        
        float frameDelay = 1.0f / frameRate;
        NSDictionary *frameProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:frameDelay] forKey:(NSString *)kCGImagePropertyGIFDelayTime] forKey:(NSString *)kCGImagePropertyGIFDictionary];

        [self setConvertingFrames:[timesArray count]];
        
        _gifData = CFDataCreateMutable(kCFAllocatorDefault, 0);
        _imageDestRef = CGImageDestinationCreateWithData(_gifData, kUTTypeGIF, _convertingFrames, NULL);

        [_currentImageGenerator generateCGImagesAsynchronouslyForTimes:timesArray completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
            
            if (result == AVAssetImageGeneratorSucceeded)
            {
                CGImageDestinationAddImage(_imageDestRef, image, (__bridge CFDictionaryRef)frameProperties);
            }

            _convertedFrames ++;
            
            if (_convertedFrames == _convertingFrames)
                [self endConversion:result == AVAssetImageGeneratorCancelled success:result == AVAssetImageGeneratorSucceeded];
        }];
    }
}

- (void)cancelConversion
{
    [_currentImageGenerator cancelAllCGImageGeneration];
}

- (CGFloat)conversionProgress
{
    return _isConverting ? (CGFloat)_convertedFrames / (CGFloat)_convertingFrames : 0.0;
}

- (void)endConversion:(BOOL)canceled success:(BOOL)success
{
    if (success)
    {
        NSDictionary *gifProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:1] forKey:(NSString *)kCGImagePropertyGIFLoopCount] forKey:(NSString *)kCGImagePropertyGIFDictionary];
        
        CGImageDestinationSetProperties(_imageDestRef, (__bridge CFDictionaryRef)gifProperties);
        CGImageDestinationFinalize(_imageDestRef);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _isConverting = NO;
        
        if ([_delegate respondsToSelector:@selector(gifConversionEnded:withData:canceled:)])
            [_delegate gifConversionEnded:self withData:(success ? [NSData dataWithData:(__bridge NSData *)_gifData] : nil) canceled:canceled];
        
        [self setCurrentImageGenerator:nil];
        [self setGifData:nil];
        [self setImageDestRef:nil];
        [self setConvertedFrames:0];
        [self setConvertingFrames:0];
    });
}

@end
