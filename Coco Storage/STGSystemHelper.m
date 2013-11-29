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

/*
 From http://stackoverflow.com/questions/17693408/enable-access-for-assistive-devices-programmatically-on-10-9
*/
+ (BOOL)registerAsAssistiveDevice:(NSString *)programID error:(NSString **)errorR output:(NSString **)outputR
{
    NSMutableArray *args = [[NSMutableArray alloc] init];
    
    [args addObject:@"\\\"/Library/Application Support/com.apple.TCC/TCC.db\\\""];
    [args addObject:[NSString stringWithFormat:@"\\\"INSERT INTO access VALUES('kTCCServiceAccessibility','%@',0,1,1,NULL);\\\"", programID]];
    
    NSString *output = nil;
    NSString *errorDescription = nil;
    BOOL success = [STGSystemHelper runProcessAsAdministrator:@"/usr/bin/sqlite3" withArguments:args output:&output errorDescription:&errorDescription];
    
    if (errorR != nil)
        *errorR = errorDescription;
    if (outputR != nil)
        *outputR = output;
    
    return success;
}

/*
 From http://stackoverflow.com/questions/17693408/enable-access-for-assistive-devices-programmatically-on-10-9
 */
+ (BOOL)deleteFromAssistiveDevices:(NSString *)programID error:(NSString **)errorR output:(NSString **)outputR
{
    NSMutableArray *args = [[NSMutableArray alloc] init];
    
    [args addObject:@"\\\"/Library/Application Support/com.apple.TCC/TCC.db\\\""];
    [args addObject:[NSString stringWithFormat:@"\\\"delete from access where client='%@';\\\"", programID]];
    
    NSString *output = nil;
    NSString *errorDescription = nil;
    BOOL success = [STGSystemHelper runProcessAsAdministrator:@"/usr/bin/sqlite3" withArguments:args output:&output errorDescription:&errorDescription];
    
    if (errorR != nil)
        *errorR = errorDescription;
    if (outputR != nil)
        *outputR = output;
    
    return success;
}

+ (BOOL)isAssistiveDevice
{
    NSDictionary *options = @{(__bridge id)kAXTrustedCheckOptionPrompt: @NO};
    BOOL accessibilityEnabled = AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options);
    
    return accessibilityEnabled;
}

/*
 From http://stackoverflow.com/questions/3541654/how-to-give-permission-using-nstask-objective-c
 */
+ (BOOL) runProcessAsAdministrator:(NSString*)scriptPath
                     withArguments:(NSArray *)arguments
                            output:(NSString **)output
                  errorDescription:(NSString **)errorDescription {
    
    NSString * allArgs = [arguments componentsJoinedByString:@" "];
    NSString * fullScript = [NSString stringWithFormat:@"%@ %@", scriptPath, allArgs];
    
    NSDictionary *errorInfo = [NSDictionary new];
    NSString *script =  [NSString stringWithFormat:@"do shell script \"%@\" with administrator privileges", fullScript];
    
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    NSAppleEventDescriptor * eventResult = [appleScript executeAndReturnError:&errorInfo];
    NSLog(@"%@", appleScript);
    
    // Check errorInfo
    if (! eventResult)
    {
        // Describe common errors
        *errorDescription = nil;
        if ([errorInfo valueForKey:NSAppleScriptErrorNumber])
        {
            NSNumber * errorNumber = (NSNumber *)[errorInfo valueForKey:NSAppleScriptErrorNumber];
            if ([errorNumber intValue] == -128)
                *errorDescription = @"The administrator password is required to do this.";
        }
        
        // Set error message from provided message
        if (*errorDescription == nil)
        {
            if ([errorInfo valueForKey:NSAppleScriptErrorMessage])
                *errorDescription =  (NSString *)[errorInfo valueForKey:NSAppleScriptErrorMessage];
        }
        
        return NO;
    }
    else
    {
        // Set output to the AppleScript's output
        *output = [eventResult stringValue];
        
        return YES;
    }
}

@end
