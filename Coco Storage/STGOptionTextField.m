//
//  STGOptionTextField.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 27.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGOptionTextField.h"

@implementation STGOptionTextField

- (void)textDidChange:(NSNotification *)notification
{
    if ([_optionDelegate respondsToSelector:@selector(textChanged:)])
    {
        [_optionDelegate textChanged:self];
    }
    
    [super textDidChange:notification];
}

@end
