//
//  STGStatusItemManager.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 02.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STGRecentUploadView.h"

#import "STGStatusItemView.h"

#define STGStatusItemWidth 24.0

typedef NS_ENUM(NSUInteger, STGServerStatus)
{
    STGServerStatusOnline = 0,
    STGServerStatusServerOffline = 1,
    STGServerStatusClientOffline = 2,
    STGServerStatusUnknown = 3,
    STGServerStatusServerV1Busy = 4,
    STGServerStatusServerV2Busy = 5,
    STGServerStatusServerBusy = 6,
    STGServerStatusInvalidKey = 7
};

@class STGPacketQueue;
@class STGDataCaptureEntry;

@protocol STGStatusItemManagerDelegate <NSObject>

-(void)captureScreen:(BOOL)fullScreen;
-(void)captureFile;
-(void)captureFile:(NSURL *)url;
-(void)cancelAllUploads;
-(void)togglePauseUploads;
-(void)deleteRecentFile:(STGDataCaptureEntry *)entry;
-(void)cancelQueueFile:(int)index;
-(void)openPreferences;

@end

@interface STGStatusItemManager : NSObject <STGRecentUploadDelegate, STGStatusItemViewDelegate>

@property (nonatomic, assign) id<STGStatusItemManagerDelegate> delegate;

@property (nonatomic, retain) NSStatusItem *statusItem;
@property (nonatomic, retain) IBOutlet NSMenu *statusMenu;
@property (nonatomic, retain) IBOutlet STGStatusItemView *statusItemView;

@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, assign) BOOL isSyncing;
@property (nonatomic, assign) int ticks;

@property (nonatomic, retain) IBOutlet NSMenuItem *serverStatusItem;

@property (nonatomic, retain) IBOutlet NSMenuItem *captureAreaMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *captureFullScreenMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *captureFileMenuItem;

@property (nonatomic, retain) IBOutlet NSMenuItem *recentFilesItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *noRecentFilesItem;

@property (nonatomic, retain) IBOutlet NSMenuItem *currentUploadsItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *noCurrentUploadItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *moreCurrentUploadsItem;

@property (nonatomic, retain) IBOutlet NSMenuItem *pauseUploadsItem;

- (IBAction)captureArea:(id)sender;
- (IBAction)captureFullScreen:(id)sender;
- (IBAction)captureFile:(id)sender;

- (IBAction)openStorageAccount:(id)sender;
- (IBAction)openMyFiles:(id)sender;
- (IBAction)openPreferences:(id)sender;
- (IBAction)quit:(id)sender;

- (IBAction)openCFSFolder:(id)sender;

- (IBAction)cancelUploads:(id)sender;
- (IBAction)togglePauseUploads:(id)sender;

- (IBAction)openRecentFile:(id)sender;
- (IBAction)deleteRecentFile:(id)sender;
- (IBAction)copyRecentFileLink:(id)sender;

- (IBAction)cancelQueueFile:(id)sender;

- (void)timerFired:(NSTimer *)timer;

- (void)updateRecentFiles:(NSArray *)recentFiles;
- (void)updateUploadQueue:(STGPacketQueue *)packetQueue currentProgress:(float)currentFileProgress;
- (void)updatePauseDownloadItem;
- (void)updateServerStatus:(STGServerStatus)status;

- (void)setStatusItemUploadProgress:(float)progress;

@end
