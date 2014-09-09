//
//  STGSoundPicker.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 09.09.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class STGSoundPicker;

@protocol STGSoundPickerDelegate <NSObject>
@optional
- (void)soundPicker:(STGSoundPicker *)view choseSound:(NSString *)sound;

@end

@interface STGSoundPicker : NSView

@property (nonatomic, assign) IBOutlet id<STGSoundPickerDelegate> delegate;

@property (nonatomic, assign) BOOL enabled;

@property (nonatomic, retain) NSString *selectedSound;

@end
