//
//  STGCFSSyncCheckEntry.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 22.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGCFSSyncCheckEntry.h"

@implementation STGCFSSyncCheckEntry

+ (id)syncCheckEntryWithPath:(NSString *)innerPath modificationType:(STGCFSSyncCheckEntryType)type
{
    STGCFSSyncCheckEntry *entry = [[STGCFSSyncCheckEntry alloc] init];
    
    [entry setInnerPath:innerPath];
    [entry setModificationType:type];
    
    return entry;
}

@end
