//
//  STGSystemHelper.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 26.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGSystemHelper.h"

@interface STGSystemHelper ()

+ (LSSharedFileListItemRef)itemRefInLoginItems;

@end

@implementation STGSystemHelper

+ (BOOL)appLaunchesAtLogin
{
    // See if the app is currently in LoginItems.
    LSSharedFileListItemRef itemRef = [self itemRefInLoginItems];
    // Store away that boolean.
    BOOL isInList = itemRef != nil;
    // Release the reference if it exists.
    if (itemRef != nil) CFRelease(itemRef);
    
    return isInList;
}

+ (LSSharedFileListItemRef)itemRefInLoginItems
{
    LSSharedFileListItemRef itemRef = nil;
    NSURL *itemUrl = nil;
    
    // Get the app's URL.
    NSURL *appUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    // Get the LoginItems list.
    LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    if (loginItemsRef == nil)
        return nil;
    
    // Iterate over the LoginItems.
    CFArrayRef loginItems = LSSharedFileListCopySnapshot(loginItemsRef, nil);
    NSArray *loginItemsArray = (__bridge NSArray *)loginItems;
    for (int currentIndex = 0; currentIndex < [loginItemsArray count]; currentIndex++)
    {
        // Get the current LoginItem and resolve its URL.
        LSSharedFileListItemRef currentItemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray objectAtIndex:currentIndex];
        if (LSSharedFileListItemResolve(currentItemRef, 0, (void *) &itemUrl, NULL) == noErr)
        {
            // Compare the URLs for the current LoginItem and the app.
            if ([itemUrl isEqual:appUrl])
            {
                // Save the LoginItem reference.
                itemRef = currentItemRef;
            }
        }
    }
    // Retain the LoginItem reference.
    if (itemRef != nil) CFRetain(itemRef);
    // Release the LoginItems lists.
    CFRelease(loginItemsRef);
    CFRelease(loginItems);
    
    return itemRef;
}

+ (void)setStartOnSystemLaunch:(BOOL)start
{
    // Get the LoginItems list.
    LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    if (loginItemsRef == nil) return;
    
    if (start)
    {
        // Add the app to the LoginItems list.
        CFURLRef appUrl = (__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
        LSSharedFileListItemRef itemRef = LSSharedFileListInsertItemURL(loginItemsRef,  kLSSharedFileListItemLast, NULL, NULL, appUrl, NULL, NULL);

        if (itemRef)
            CFRelease(itemRef);
    }
    else
    {
        // Remove the app from the LoginItems list.
        LSSharedFileListItemRef itemRef = [self itemRefInLoginItems];
        
        if (itemRef != nil)
        {
            LSSharedFileListItemRemove(loginItemsRef,itemRef);
            CFRelease(itemRef);
        }
    }
    CFRelease(loginItemsRef);
}

+ (void)showDockTile
{
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    
    OSStatus returnCode = TransformProcessType(&psn, kProcessTransformToForegroundApplication);
    if( returnCode != 0)
    {
        NSLog(@"Could not bring the application to front. Error %d", returnCode);
    }
}
@end
