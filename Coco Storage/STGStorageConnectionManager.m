//
//  STGDataCaptureManager.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 23.04.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGStorageConnectionManager.h"

#import "STGPacket.h"

@interface STGStorageConnectionManager()

@property (nonatomic, retain) NSMutableData *responseData;
@property (nonatomic, retain) NSURLResponse *urlResponse;

@end

@implementation STGStorageConnectionManager

@synthesize delegate = _delegate;

@synthesize activeUploadConnection = _activeUploadConnection;
@synthesize activeEntry = _activeEntry;

@synthesize responseData = _responseData;
@synthesize urlResponse = _urlResponse;

- (id)init
{
    self = [super init];
    if (self)
    {
        _activeEntry = nil;
    }
    return self;
}

- (BOOL)uploadEntry:(STGPacket *)entry
{
    if (_activeEntry)
        [NSException raise:@"Data Capture Manager busy" format:@"The Data Capture Manager is busy, and can't upload more files!"];
    
    [self setResponseData:[[NSMutableData alloc] init]];

    _activeEntry = entry;
    
    [self setUrlResponse:nil];

    NSURLConnection *myConnection = [[NSURLConnection alloc] initWithRequest:[entry urlRequest] delegate:self startImmediately:YES];
    
    if(myConnection != nil)
    {
        if ([_delegate respondsToSelector:@selector(startUploadingData:entry:)])
        {
            [_delegate startUploadingData:self entry:_activeEntry];
        }

        return YES;
    }
    else
    {
        [self cancelCurrentRequest];
    }

    return NO;
}

- (void)connectionDidFinishDownloading:(NSURLConnection *)connection destinationURL:(NSURL *)destinationURL
{
    STGPacket *cachedEntry = _activeEntry;
    
    _activeEntry = nil;
    _activeUploadConnection = nil;

    if ([_delegate respondsToSelector:@selector(finishUploadingData:entry:fullResponse:urlResponse:)])
    {
        [_delegate finishUploadingData:self entry:cachedEntry fullResponse:_responseData urlResponse:_urlResponse];
    }
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if ([_delegate respondsToSelector:@selector(updateUploadProgress:entry:sentData:totalData:)])
    {
        [_delegate updateUploadProgress:self entry:_activeEntry sentData:totalBytesWritten totalData:totalBytesExpectedToWrite];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSLog(@"Must authenticate: %@", challenge);
    
    [self cancelCurrentRequest];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if ([[error description] rangeOfString:@"The Internet connection appears to be offline."].location == NSNotFound)
        NSLog(@"Connection failed: %@", error);
    
    [self cancelCurrentRequest];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self setUrlResponse:response];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    [_responseData appendData:[cachedResponse data]];
    
    return cachedResponse;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"Connection response data: %@", data);
}

- (void)cancelCurrentRequest
{
    if (_activeUploadConnection)
    {
        [_activeUploadConnection cancel];
    }
    
    _activeEntry = nil;
    _activeUploadConnection = nil;
}

@end
