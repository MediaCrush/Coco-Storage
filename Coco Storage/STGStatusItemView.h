//
//  STGStatusItemView.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 24.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "STGUploadTypeViewController.h"

@protocol STGStatusItemViewDelegate;

@interface STGStatusItemView : NSView <NSMenuDelegate, STGUploadTypeViewControllerDelegate>

@property (nonatomic, assign) id<STGStatusItemViewDelegate> delegate;

@property (nonatomic, retain) NSStatusItem *statusItem;
@property (nonatomic, assign) BOOL highlight;
@property (nonatomic, assign) BOOL onDragging;

@property (nonatomic, retain) NSImage *image;
@property (nonatomic, retain) NSImageCell *imageViewCell; //For highlights :<

@property (nonatomic, retain) NSWindow *overlayWindow;
@property (nonatomic, retain) NSTextField *overlayWindowLabel;

@property (nonatomic, retain) STGUploadTypeViewController *uploadTypeVC;

- (void)displayForUploadTypes:(NSArray *)types;

@end

@protocol STGStatusItemViewDelegate <NSObject>
@optional

-(void)uploadEntries:(NSArray *)entries;
- (void)menuWillOpen:(NSMenu *)menu;
- (void)menuDidClose:(NSMenu *)menu;

@end