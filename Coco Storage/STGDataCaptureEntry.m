//
//  STGDataCaptureEntry.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 25.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGDataCaptureEntry.h"

#import "STGFileHelper.h"

@implementation STGDataCaptureEntry

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        [self setFileURL:[aDecoder decodeObjectForKey:@"FileURL"]];
        [self setDeleteOnCompletetion:[aDecoder decodeBoolForKey:@"DeleteOnCompletion"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_fileURL forKey:@"FileURL"];
    [aCoder encodeBool:_deleteOnCompletetion forKey:@"DeleteOnCompletion"];
}

+ (STGDataCaptureEntry *)entryWithURL:(NSURL *)url deleteOnCompletion:(BOOL)del
{
    STGDataCaptureEntry *entry = [[STGDataCaptureEntry alloc] init];
    [entry setFileURL:url];
    [entry setDeleteOnCompletetion:del];
    
    return entry;
}

@end
