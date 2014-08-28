//
//  STGUploadedEntry.h
//  Coco Storage
//
//  Created by Lukas Tenbrink on 28.08.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STGUploadedEntry : NSObject <NSCoding>

- (NSString *)onlineID;
- (NSURL *)onlineLink;

- (NSString *)entryName;
- (NSImage *)entryIcon;

@end
