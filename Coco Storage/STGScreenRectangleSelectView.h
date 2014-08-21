//
//  STGScreenRectangleSelectView.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 20.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class STGScreenRectangleSelectView;

@protocol STGScreenRectangleSelectViewDelegate <NSObject>

@optional
- (void)screenRectangleSelectView:(STGScreenRectangleSelectView *)view didSelectRectangle:(NSRect)rectangle;
- (void)screenRectangleSelectViewCanceled:(STGScreenRectangleSelectView *)view;
@end

@interface STGScreenRectangleSelectView : NSView

@property (nonatomic, assign) NSObject<STGScreenRectangleSelectViewDelegate> *delegate;

@property (nonatomic, retain) NSCursor *selectionCursor;
@property (nonatomic, retain) NSCursor *windowSelectionCursor;

@property (nonatomic, assign) NSPoint mouseDownPoint;
@property (nonatomic, assign) BOOL windowSelectMode;

@end
