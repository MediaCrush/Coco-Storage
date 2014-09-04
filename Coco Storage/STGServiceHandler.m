//
//  STGServiceHandler.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 04.09.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "STGServiceHandler.h"

#import "STGAPIConfiguration.h"
#import "STGDataCaptureManager.h"

@implementation STGServiceHandler

+ (instancetype)registeredHandler
{
    STGServiceHandler *serviceHandler = [[STGServiceHandler alloc] init];
    [NSApp setServicesProvider:serviceHandler];
    return serviceHandler;
}

- (void)uploadObjects:(NSPasteboard *)pasteboard userData:(NSString *)udata error:(NSString **)err
{
    NSArray *actions = [STGDataCaptureManager getActionsFromPasteboard:pasteboard];
    actions = [STGAPIConfiguration validUploadActions:actions forConfiguration:[STGAPIConfiguration currentConfiguration]];
    
    if (actions && [actions count] > 0)
    {
        NSArray *entries = [STGDataCaptureManager captureDataFromPasteboard:pasteboard withAction:[[actions objectAtIndex:0] integerValue]];
        
        if (entries && [entries count] > 0)
        {
            if ([_delegate respondsToSelector:@selector(uploadObjects:fromHandler:)])
                [_delegate uploadObjects:entries fromHandler:self];
        }
        else
        {
            NSLog(@"Could not capture objects for upload: %@", [pasteboard types]);
        }
    }
    else
    {
        NSLog(@"Could not interprete objects: %@", [pasteboard types]);
    }
}

@end
