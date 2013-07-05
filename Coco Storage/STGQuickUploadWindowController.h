//
//  STGQuickUploadWindowController.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 27.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "STGQuickUploadView.h"

@protocol STGQuickUploadWindowControllerDelegate;

@interface STGQuickUploadWindowController : NSWindowController <STGQuickUploadViewDelegate>

@property (nonatomic, assign) id<STGQuickUploadWindowControllerDelegate> delegate;

@property (nonatomic, retain) IBOutlet STGQuickUploadView *quickUploadView;

@end

@protocol STGQuickUploadWindowControllerDelegate <NSObject>
@optional

-(void)uploadEntries:(NSArray *)entries;

@end