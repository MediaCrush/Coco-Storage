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

#import "STGNetworkManager.h"

#define STGStatusItemWidth 24.0

@class STGPacketQueue;
@class STGUploadedEntry;
@class STGCreateAlbumWindowController;

@protocol STGStatusItemManagerDelegate <NSObject>

-(void)captureScreen:(BOOL)fullScreen;
-(void)captureMovie;
-(void)captureFile;
-(void)createAlbum;
-(void)uploadEntries:(NSArray *)entries;
-(void)cancelAllUploads;
-(void)togglePauseUploads;
-(void)deleteRecentFile:(STGUploadedEntry *)entry;
-(void)cancelQueueFile:(int)index;
-(void)openPreferences;

-(void)stopRecording;
-(void)cancelRecording;

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

@property (nonatomic, retain) IBOutlet NSMenuItem *stopRecordingMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *cancelRecordingMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *recordingSectionSeparatorItem;

@property (nonatomic, retain) IBOutlet NSMenuItem *captureAreaMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *captureFullScreenMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *captureMovieMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *captureFileMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *captureClipboardMenuItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *createAlbumMenuItem;

@property (nonatomic, retain) IBOutlet NSMenuItem *recentFilesItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *noRecentFilesItem;

@property (nonatomic, retain) IBOutlet NSMenuItem *currentUploadsItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *noCurrentUploadItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *moreCurrentUploadsItem;

@property (nonatomic, retain) IBOutlet NSMenuItem *pauseUploadsItem;

@property (nonatomic, retain) IBOutlet NSMenuItem *accountLinkItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *fileListLinkItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *cfsLinkItem;
@property (nonatomic, retain) IBOutlet NSMenuItem *cfsSectionSeparatorItem;

- (IBAction)captureArea:(id)sender;
- (IBAction)captureFullScreen:(id)sender;
- (IBAction)captureMovie:(id)sender;
- (IBAction)captureFile:(id)sender;
- (IBAction)captureClipboard:(id)sender;
- (IBAction)createAlbum:(id)sender;

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

- (IBAction)stopRecording:(id)sender;
- (IBAction)cancelRecording:(id)sender;

- (void)timerFired:(NSTimer *)timer;

- (void)updateRecentFiles:(NSArray *)recentFiles;
- (void)updateUploadQueue:(STGPacketQueue *)packetQueue currentProgress:(float)currentFileProgress;
- (void)updatePauseDownloadItem;
- (void)updateServerStatus:(STGServerStatus)status;

- (void)setStatusItemUploadProgress:(float)progress;

- (void)setMovieControlsVisible:(BOOL)visible;

@end
