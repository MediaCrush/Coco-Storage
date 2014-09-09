//
//  STGFileChooserView.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 09.09.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class STGFileChooserView;

@protocol STGFileChooserViewDelegate <NSObject>
@optional
- (void)pathChooserView:(STGFileChooserView *)view chosePath:(NSString *)path;

@end

@interface STGFileChooserPath : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *path;

+ (instancetype)filePathWithPath:(NSString *)path;
+ (instancetype)filePathWithPath:(NSString *)path customTitle:(NSString *)title;

@end

@interface STGFileChooserView : NSView

@property (nonatomic, assign) IBOutlet id<STGFileChooserViewDelegate> delegate;

@property (nonatomic, retain) NSString *selectedPath;
@property (nonatomic, retain) NSArray *paths;

@end
