//
//  STGTypeChooserViewController.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 30.11.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "STGTypeChooserView.h"
#import "STGDataCaptureManager.h"

@protocol STGUploadTypeViewControllerDelegate;

@interface STGUploadTypeViewController : NSViewController <STGTypeChooserViewDelegate>

@property (nonatomic, assign) IBOutlet id<STGUploadTypeViewControllerDelegate> delegate;

@property (nonatomic, retain) IBOutlet STGTypeChooserView *typeChooserView;
@property (nonatomic, retain) IBOutlet NSPopover *popover;

- (void)setUploadTypes:(NSArray *)uploadTypes fromDragging:(BOOL)dragging;

- (void)showRelativeToRect:(NSRect)referenceFrame ofView:(NSView *)view preferredEdge:(NSRectEdge)preferredEdge;
- (void)hide;

@end

@protocol STGUploadTypeViewControllerDelegate <NSObject>
@optional
- (void)uploadTypeViewController:(STGUploadTypeViewController *)viewController choseType:(STGUploadAction)action;

- (void)uploadTypeViewController:(STGUploadTypeViewController *)viewController choseType:(STGUploadAction)action whileDragging:(id<NSDraggingInfo>)sender;
- (void)uploadTypeViewController:(STGUploadTypeViewController *)viewController draggingEnded:(id<NSDraggingInfo>)sender;
- (void)uploadTypeViewController:(STGUploadTypeViewController *)viewController draggingExited:(id<NSDraggingInfo>)sender;

@end
