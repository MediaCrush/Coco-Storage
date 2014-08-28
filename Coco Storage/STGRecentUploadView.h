//
//  STGRecentUploadView.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 29.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class STGUploadedEntry;

@protocol STGRecentUploadDelegate;

@interface STGRecentUploadView : NSView

@property (nonatomic, assign) id<STGRecentUploadDelegate> recentUploadDelegate;

@property (nonatomic, retain) STGUploadedEntry *captureEntry;

@property (nonatomic, retain) NSTrackingArea *trackingArea;
@property (nonatomic, assign) BOOL isHighlighted;

@end

@protocol STGRecentUploadDelegate <NSObject>
@optional

- (void)recentUploadView:(STGRecentUploadView *)recentUploadView clicked:(NSEvent *)theEvent;

@end