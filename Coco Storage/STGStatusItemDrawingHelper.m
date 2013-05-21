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

+ (NSImage *)getIcon:(int)ticks uploadProgress:(float)uploadProgress opacity:(float)opacity
{
    ticks %= 20;
    
    int imageNumber = uploadProgress * 13;
    
    NSString *imageName = [NSString stringWithFormat:@"CocoStorageStatusBarIcon%02i_ticks%02i_opacity%2.2f.png", imageNumber, ticks, opacity];

    NSImage *image = [self getStoredImage:imageName];
    
    if (!image)
    {
        image = [[NSImage imageNamed:(imageNumber == 0 ? @"CocoStorageStatusBarIcon.png" : [NSString stringWithFormat:@"CocoStorageStatusBarIcon%02i.png", imageNumber])] copy];
        
        if (opacity > 0.0)
        {
            NSImage *overlayImage = [NSImage imageNamed:@"StatusBarIconUpdateOverlay.png"];
            
            [image lockFocus];
            
            double rotateDeg = ticks * 18;
            NSAffineTransform *affineTransform = [[NSAffineTransform alloc] init];
            NSGraphicsContext *context = [NSGraphicsContext currentContext];
            
            [context saveGraphicsState];
            [affineTransform translateXBy:[image size].width / 2.0 + 0.5 yBy:[image size].height / 2.0 - 0.5];
            [affineTransform rotateByDegrees:rotateDeg];
            [affineTransform concat];
            
            [overlayImage drawAtPoint:NSMakePoint(-[image size].width / 2.0 - 0.5, -[image size].height / 2.0 + 0.5) fromRect:NSMakeRect(0, 0, [overlayImage size].width, [overlayImage size].height) operation:NSCompositeSourceOver fraction:opacity];
            
            [context restoreGraphicsState];
            
            [image unlockFocus];
        }

        if (uploadProgress == 0.0 && opacity == 0.0)
            [image setTemplate:YES];
        
        [self setStoredImage:image forKey:imageName];
    }
    
    return image;
}

@end
