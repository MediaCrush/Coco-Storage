//
//  STGQuickUploadView.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 27.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol STGQuickUploadViewDelegate;

@interface STGQuickUploadView : NSView

@property (nonatomic, assign) IBOutlet id<STGQuickUploadViewDelegate> delegate;

@property (nonatomic, retain) NSTimer *timer;

@property (nonatomic, assign) BOOL onDragging;

@property (nonatomic, retain) NSArray *pasteActionArray;
@property (nonatomic, retain) NSArray *dropActionArray;

@property (nonatomic, retain) NSFont *displayFont;
@property (nonatomic, retain) NSColor *lineColor;
@property (nonatomic, assign) float dashPhase;

- (void)timerFired:(NSTimer *)theTimer;

- (void)paste;

@end

@protocol STGQuickUploadViewDelegate <NSObject>
@optional

-(void)uploadEntries:(NSArray *)entries;

@end