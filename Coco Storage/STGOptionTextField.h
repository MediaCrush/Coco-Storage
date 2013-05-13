//
//  STGOptionTextField.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 27.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface STGOptionTextField : NSTextField

@property (nonatomic, assign) IBOutlet id optionDelegate;

@end

@protocol STGOptionTextFieldDelegate <NSObject>

- (void)textChanged:(STGOptionTextField *)textField;

@end