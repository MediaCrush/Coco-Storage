//
//  Coco_Storage_Uploader.m
//  Coco Storage Uploader
//
//  Created by Lukas Tenbrink on 03.09.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import "Coco_Storage_Uploader.h"

#import <OSAKit/OSAScript.h>

#import <STGIntercommHandler.h>

@implementation Coco_Storage_Uploader

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo
{
    if(![self isAppRunning:@"ivorius.Coco-Storage"] && ![[NSWorkspace sharedWorkspace] launchApplication:@"Coco Storage"])
    {
        *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                       [NSNumber numberWithInteger:errOSACantLaunch], OSAScriptErrorNumber,
                       @"Failed to launch application Coco Storage - required for the upload", OSAScriptErrorMessage,
                       nil];
    }
    else
    {
        NSDistantObject *distantObject = (id)[NSConnection rootProxyForConnectionWithRegisteredName:@"ivorius.Coco-Storage.intercomm" host:nil];
        Protocol *protocol = @protocol(STGIntercommHandler);
        [distantObject setProtocolForProxy:protocol];

        if (!distantObject)
        {
            *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:errOSACantLaunch], OSAScriptErrorNumber,
                          @"Failed to find root proxy for Coco Storage", OSAScriptErrorMessage,
                          nil];
        }
        else
        {
            id<STGIntercommHandler> intercommHandler = (id<STGIntercommHandler>)distantObject;
            NSArray *array = [input isKindOfClass:[NSArray class]] ? input : [NSArray arrayWithObject:input];

//            SEL uploadSelector = @selector(uploadObjects:);
//            NSMethodSignature *uploadSignature = [NSObject instanceMethodSignatureForSelector:uploadSelector];
//            NSInvocation *anInvocation = [NSInvocation invocationWithMethodSignature:uploadSignature];
//            [anInvocation setSelector:uploadSelector];
//            
//            [anInvocation setTarget:intercommHandler];
//            
//            [anInvocation setArgument:(__bridge void *)(array) atIndex:0];
//            
//            [anInvocation invoke];
//            
//            NSArray *returnArray;
//            [anInvocation getReturnValue:&returnArray];
//            NSLog(@"Return: %@", returnArray);
            
            [intercommHandler uploadObjects:array];
        }
    }
	
	return input;
}

- (BOOL)isAppRunning:(NSString *)bundleIdentifier
{
    NSArray *applications = [[NSWorkspace sharedWorkspace] runningApplications];

    for (NSRunningApplication *app in applications)
    {
        if ([[app bundleIdentifier] isEqualToString:bundleIdentifier])
            return YES;
    }

    return NO;
}

@end
