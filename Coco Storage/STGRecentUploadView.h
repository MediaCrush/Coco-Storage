//
//  STGRecentUploadView.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 29.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@class STGUploadedEntry;

@protocol STGRecentUploadDelegate;

@interface STGRecentUploadView : NSView
{
    CIFilter *_blurFilter, *_saturationFilter;
}

@property (nonatomic, assign) id<STGRecentUploadDelegate> recentUploadDelegate;

@property (nonatomic, retain) IBOutlet NSTextField *titleTextField;
@property (nonatomic, retain) IBOutlet NSTextField *subTitleTextField;

@property (nonatomic, retain) STGUploadedEntry *captureEntry;

@property (nonatomic, retain) NSTrackingArea *trackingArea;
@property (nonatomic, assign) BOOL isHighlighted;

/** The layer will be tinted using the tint color. By default it is a 70% White Color */
@property (strong,nonatomic) NSColor *tintColor;

/** To get more vibrant colors, a filter to increase the saturation of the colors can be applied.
 The default value is 2.5. */
@property (assign,nonatomic) float saturationFactor;

/** The blur radius defines the strength of the Gaussian Blur filter. The default value is 20.0. */
@property (assign,nonatomic) float blurRadius;

@end

@protocol STGRecentUploadDelegate <NSObject>
@optional

- (void)recentUploadView:(STGRecentUploadView *)recentUploadView clicked:(NSEvent *)theEvent;

@end