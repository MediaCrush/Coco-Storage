//
//  STGTypeChooserView.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 29.11.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class STGTypeChooserViewType;

@protocol STGTypeChooserViewDelegate;

@interface STGTypeChooserView : NSView

@property (nonatomic, assign) BOOL dragMode;

@property (nonatomic, retain) NSTextField *labelTextField;
@property (nonatomic, assign) IBOutlet id<STGTypeChooserViewDelegate> delegate;

@property (nonatomic, retain) STGTypeChooserViewType *highlightedType;

@property (nonatomic, retain) NSGradient *selectionFillGradient;
@property (nonatomic, retain) NSColor *selectionStrokeColor;

@property (nonatomic, retain) NSTrackingArea *trackingArea;

- (void)clearTypes;

- (void)setTypes:(NSArray *)types;
- (void)addType:(STGTypeChooserViewType *)type;

- (NSArray *)types;

- (void)setHighlightedType:(STGTypeChooserViewType *)type animated:(BOOL)animated;

@end

@protocol STGTypeChooserViewDelegate <NSObject>
@optional
- (void)chooserView:(STGTypeChooserView *) view choseType:(STGTypeChooserViewType *)type;

- (void)chooserView:(STGTypeChooserView *) view choseType:(STGTypeChooserViewType *)type whileDragging:(id<NSDraggingInfo>)sender;
- (void)chooserView:(STGTypeChooserView *) view draggingEnded:(id<NSDraggingInfo>)sender;
- (void)chooserView:(STGTypeChooserView *) view draggingExited:(id<NSDraggingInfo>)sender;

@end
