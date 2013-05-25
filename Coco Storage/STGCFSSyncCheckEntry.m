//
//  STGCFSSyncCheckEntry.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 22.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGCFSSyncCheckEntry.h"

@implementation STGCFSSyncCheckEntry

@synthesize filePath = _filePath;
@synthesize innerPath = _innerPath;

@synthesize modificationType = _modificationType;

+ (id)syncCheckEntryWithPath:(NSString *)path innerPath:(NSString *)innerPath modificationType:(STGCFSSyncCheckEntryType)type
{
    STGCFSSyncCheckEntry *entry = [[STGCFSSyncCheckEntry alloc] init];
    
    [entry setFilePath:path];
    [entry setInnerPath:innerPath];
    [entry setModificationType:type];
    
    return entry;
}

@end
