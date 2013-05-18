//
//  STGStatusItemDrawingHelper.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 18.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGStatusItemDrawingHelper.h"

NSMutableDictionary *imageDict;

@interface STGStatusItemDrawingHelper ()

+ (NSImage *)getStoredImage:(NSString *)name;
+ (void)setStoredImage:(NSImage *)image forKey:(NSString *)name;

@end

@implementation STGStatusItemDrawingHelper

+ (NSImage *)getStoredImage:(NSString *)name
{
    if (!imageDict)
        imageDict = [[NSMutableDictionary alloc] init];
    
    return [imageDict objectForKey:name];
}

+ (void)setStoredImage:(NSImage *)image forKey:(NSString *)name
{
    if (!imageDict)
        imageDict = [[NSMutableDictionary alloc] init];
    
    [imageDict setObject:image forKey:name];
}

+ (NSImage *)getIcon:(float)uploadProgress
{
    int imageNumber = uploadProgress * 13;
    NSString *imageName = imageNumber == 0 ? @"CocoStorageStatusBarIcon.png" : [NSString stringWithFormat:@"CocoStorageStatusBarIcon%02i.png", imageNumber];

    NSImage *image = [self getStoredImage:imageName];
    
    if (!image)
    {
        image = [NSImage imageNamed:imageName];
        [self setStoredImage:image forKey:imageName];
    }
    
    return image;
}

+ (NSImage *)getSyncingIcon:(int)ticks
{
    ticks %= 20;
        
    NSString *imageName = [NSString stringWithFormat:@"CocoStorageStatusBarUpdate%02i.png", ticks];

    NSImage *image = [self getStoredImage:imageName];
    
    if (!image)
    {
        image = [[NSImage imageNamed:@"CocoStorageStatusBarIcon.png"] copy];
        NSImage *overlayImage = [NSImage imageNamed:@"StatusBarIconUpdateOverlay.png"];
        
        [image lockFocus];
        
        double rotateDeg = ticks * 18;
        NSAffineTransform *affineTransform = [[NSAffineTransform alloc] init];
        NSGraphicsContext *context = [NSGraphicsContext currentContext];
        
        [context saveGraphicsState];
        [affineTransform translateXBy:[image size].width / 2.0 + 0.5 yBy:[image size].height / 2.0 - 0.5];
        [affineTransform rotateByDegrees:rotateDeg];
        [affineTransform concat];
        
        [overlayImage drawAtPoint:NSMakePoint(-[image size].width / 2.0 - 0.5, -[image size].height / 2.0 + 0.5) fromRect:NSMakeRect(0, 0, [overlayImage size].width, [overlayImage size].height) operation:NSCompositeSourceOver fraction:1.0];
        
        [context restoreGraphicsState];
        
        [image unlockFocus];
        
        [self setStoredImage:image forKey:imageName];
    }
    
    return image;
}

@end
