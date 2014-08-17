//
//  STGMovieCaptureWindowController.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class STGMovieCaptureWindowController;

@protocol STGMovieCaptureWindowControllerDelegate <NSObject>

- (void)startMovieCapture:(STGMovieCaptureWindowController *)movieCaptureWC;

@end

@interface STGMovieCaptureWindowController : NSWindowController

@property (nonatomic, assign) NSObject<STGMovieCaptureWindowControllerDelegate> *delegate;

@property (nonatomic, retain) IBOutlet NSPopUpButton *screenSelectPopupButton;
@property (nonatomic, retain) IBOutlet NSPopUpButton *qualitySelectPopupButton;

@property (nonatomic, retain) NSNumber *recordDuration;
@property (nonatomic, retain) NSNumber *recordDelay;

@property (nonatomic, assign) BOOL recordsVideo;
@property (nonatomic, assign) NSNumber *recordDisplayID;
@property (nonatomic, assign) CGRect recordRect;

@property (nonatomic, retain) NSString *quality;

@property (nonatomic, assign) BOOL recordsComputerAudio;
@property (nonatomic, assign) BOOL recordsMicrophoneAudio;

- (IBAction)selectRecordRect:(id)sender;
- (IBAction)resetRecordRectToFullscreen:(id)sender;

- (IBAction)qualitySelected:(id)sender;

- (IBAction)startMovieCapture:(id)sender;

- (void)startMovieCaptureIgnoringDelay;

@end
