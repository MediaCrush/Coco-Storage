//
//  STGFileChooserView.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 09.09.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class STGPathChooserView;

@protocol STGPathChooserViewDelegate <NSObject>
@optional
- (void)pathChooserView:(STGPathChooserView *)view chosePath:(NSString *)path;

@end

@interface STGPathChooserEntry : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *path;

+ (instancetype)entryWithPath:(NSString *)path;
+ (instancetype)entryWithPath:(NSString *)path customTitle:(NSString *)title;

@end

@interface STGPathChooserView : NSView

@property (nonatomic, assign) IBOutlet id<STGPathChooserViewDelegate> delegate;

@property (nonatomic, retain) NSString *selectedPath;
@property (nonatomic, retain) NSArray *paths;

@end
