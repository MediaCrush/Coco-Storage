//
//  STGStatusItemView.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 24.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol STGStatusItemViewDelegate;

@interface STGStatusItemView : NSView <NSMenuDelegate>

@property (nonatomic, assign) id<STGStatusItemViewDelegate> delegate;

@property (nonatomic, assign) NSStatusItem *statusItem;
@property (nonatomic, assign) BOOL highlight;
@property (nonatomic, assign) BOOL onDragging;

@property (nonatomic, retain) NSImage *image;
@property (nonatomic, retain) NSImageCell *imageViewCell; //For highlights :<

@end

@protocol STGStatusItemViewDelegate <NSObject>
@optional

-(void)uploadEntries:(NSArray *)entries;
- (void)menuWillOpen:(NSMenu *)menu;
- (void)menuDidClose:(NSMenu *)menu;

@end