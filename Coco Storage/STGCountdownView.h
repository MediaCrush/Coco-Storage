//
//  STGCountdownView.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 18.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface STGCountdownView : NSView

@property (nonatomic, retain) NSDate *destinationDate;
@property (nonatomic, assign) NSUInteger displayedNumbers;

- (void)setCountdownTime:(NSTimeInterval)countdownTime;
- (void)fadeIn;

@end
