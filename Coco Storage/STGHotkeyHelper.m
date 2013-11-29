//
//  STGHotkeyHelper.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 26.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGHotkeyHelper.h"

#import "STGHotkeyHelperEntry.h"

#import "STGSystemHelper.h"

@interface STGHotkeyHelper ()

@property (nonatomic, assign) BOOL failed;
@property (nonatomic, assign) BOOL setUp;

@end

@implementation STGHotkeyHelper

CGEventRef copyOrModifyKeyboardEvent(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
{
    STGHotkeyHelper *hotkeyHelper = (__bridge STGHotkeyHelper *)refcon;
    
    if (type == kCGEventKeyDown)
    {
        NSEvent *returnEvent = [hotkeyHelper keyPressed:[NSEvent eventWithCGEvent:event]];

        if (returnEvent)
        {
            CGEventRef eventRef = [returnEvent CGEvent];
            CFRetain(eventRef);
            return eventRef;
        }
        else
        {
            return event = CGEventCreate(NULL);
        }
    }
    if (type == kCGEventTapDisabledByTimeout)
    {
        CGEventTapEnable([hotkeyHelper machPortRef], true);
        return event;
    }
    
    return event;
}

- (id)initWithDelegate:(id<STGHotkeyHelperDelegate>)delegate
{
    self = [self init];
    if(self)
    {
        [self setDelegate:delegate];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setFailed:NO];
        [self setSetUp:NO];
        [self setEntries:[[NSMutableArray alloc] init]];
        
    }
    return self;
}

- (STGHotkeyHelperStatus)hotkeyStatus
{
    return [self failed] ? STGHotkeyStatusFailed : (![self setUp] ? STGHotkeyStatusNotSetUp : STGHotkeyStatusOkay);
}

- (BOOL)linkToSystem
{
    [self unlinkFromSystem];
    
    [self setMachPortRef:CGEventTapCreate(kCGSessionEventTap, kCGTailAppendEventTap, kCGEventTapOptionDefault, CGEventMaskBit(kCGEventKeyDown), (CGEventTapCallBack)copyOrModifyKeyboardEvent, (__bridge void *)(self))];
    
    if (_machPortRef == NULL)
    {
        NSLog(@"CGEventTapCreate failed!\n");
        [self setFailed:YES];
        [self setSetUp:NO];

        return NO;
    }
    else
    {
        [self setMachPortWrapper:[[NSMachPort alloc] initWithMachPort:CFMachPortGetPort(_machPortRef) options:NSMachPortDeallocateNone]];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:_machPortWrapper forMode:NSDefaultRunLoopMode];
        [self setFailed:NO];
        [self setSetUp:YES];
        
        return YES;
    }
}

- (void)unlinkFromSystem
{
    if (_machPortWrapper)
    {
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop removePort:_machPortWrapper forMode:NSDefaultRunLoopMode];
        [self setMachPortWrapper:NULL];
    }
    if (_machPortRef)
    {
        CFRelease(_machPortRef);
        [self setMachPortRef:NULL];
    }
    
    [self setSetUp:NO];
}

- (void)addShortcutEntry:(STGHotkeyHelperEntry *)entry
{
    [_entries addObject:entry];
}

- (void)removeShortcutEntry:(STGHotkeyHelperEntry *)entry
{
    [_entries removeObject:entry];
}

- (void)removeAllShortcutEntries
{
    [_entries removeAllObjects];
}

- (NSEvent *)keyPressed:(NSEvent *)event
{
    NSEvent *returnEvent = event;
    
    for( STGHotkeyHelperEntry *entry in _entries)
    {
        if (([[entry character] isEqualToString:[[event characters] lowercaseString]] && ([entry modifiers] & NSDeviceIndependentModifierFlagsMask) == ([event modifierFlags] & NSDeviceIndependentModifierFlagsMask)) || [entry character] == nil)
        {
            if (returnEvent != nil && [_delegate respondsToSelector:@selector(keyPressed:entry:userInfo:)])
            {
                returnEvent = [_delegate keyPressed:event entry:entry userInfo:[entry userInfo]];
            }
        }
    }
    
    return returnEvent;
}

- (void)dealloc
{
    [self unlinkFromSystem];
}

@end
