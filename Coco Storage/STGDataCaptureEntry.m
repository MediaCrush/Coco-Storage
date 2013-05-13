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

@synthesize fileURL = _fileURL;
@synthesize deleteOnCompletetion = _deleteOnCompletetion;

@synthesize onlineLink = _onlineLink;

+ (STGDataCaptureEntry *)entryWithURL:(NSURL *)url deleteOnCompletion:(BOOL)del
{
    STGDataCaptureEntry *entry = [[STGDataCaptureEntry alloc] init];
    [entry setFileURL:url];
    [entry setDeleteOnCompletetion:del];
    [entry setOnlineLink:@""];
    
    return entry;
}

+ (STGDataCaptureEntry *)entryFromString:(NSString *)string
{
    NSArray *stringArray = [STGFileHelper readStringsFromString:string];

    STGDataCaptureEntry *entry = [[STGDataCaptureEntry alloc] init];

    if ([stringArray count] > 0)
        [entry setFileURL:[NSURL URLWithString:[stringArray objectAtIndex:0]]];
    else
        [entry setFileURL:nil];

    if ([stringArray count] > 1)
        [entry setDeleteOnCompletetion:[[stringArray objectAtIndex:1] intValue] == 1];
    else
        [entry setDeleteOnCompletetion:NO];

    if ([stringArray count] > 2)
        [entry setOnlineLink:[stringArray objectAtIndex:2]];
    else
        [entry setOnlineLink:@""];
    
    return entry;
}

- (NSString *)storeInfoInString
{
    return [STGFileHelper storeStringsInString:[NSArray arrayWithObjects:[_fileURL absoluteString], [NSString stringWithFormat:@"%i", _deleteOnCompletetion], _onlineLink, nil]];
}

@end
