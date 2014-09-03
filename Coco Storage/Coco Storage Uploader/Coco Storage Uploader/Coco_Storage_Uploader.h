//
//  Coco_Storage_Uploader.h
//  Coco Storage Uploader
//
//  Created by Lukas Tenbrink on 03.09.14.
//  Copyright (c) 2014 Lukas Tenbrink. All rights reserved.
//

#import <Automator/AMBundleAction.h>

@interface Coco_Storage_Uploader : AMBundleAction

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo;

@end
