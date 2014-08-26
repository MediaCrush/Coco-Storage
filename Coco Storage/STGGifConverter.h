//
//  STGGifConverter.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 26.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

@class STGGifConverter;

@protocol STGGifConverterDelegate <NSObject>

@optional
- (void)gifConversionStarted:(STGGifConverter *)gifConverter;
- (void)gifConversionEnded:(STGGifConverter *)gifConverter withData:(NSData *)data canceled:(BOOL)canceleld;
@end

@interface STGGifConverter : NSObject

@property (nonatomic, assign) id<STGGifConverterDelegate> delegate;

@property (nonatomic, retain) id userInfo;

@property (nonatomic, assign, readonly) BOOL isConverting;
@property (nonatomic, retain, readonly) AVURLAsset *movie;

- (void)beginConversion:(AVURLAsset *)movie;
- (void)cancelConversion;

- (CGFloat)conversionProgress;

@end
