//
//  STGPacketQueueEntry.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 11.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGPacket.h"

@implementation STGPacket

+ (NSMutableURLRequest *)defaultRequestWithUrl:(NSString *)urlString httpMethod:(NSString *)httpMethod contentParts:(NSArray *)parts
{
    NSMutableURLRequest *request= [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:100.0];
    [request setHTTPMethod:httpMethod];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField: @"Content-Type"];
    [request addValue:[NSString stringWithFormat:@"Coco Storage v%@ ~Ivorius", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]] forHTTPHeaderField: @"User-Agent"];
    [request addValue:@"text" forHTTPHeaderField: @"Accept"];
    
    NSMutableData *postbody = [NSMutableData data];
    
    if (parts)
    {
        for (NSData *data in parts)
        {
            [postbody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [postbody appendData:data];
            
            [postbody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }        
    }
    
    [request setHTTPBody:postbody];
    [request addValue:[NSString stringWithFormat:@"%d", (int)[postbody length]] forHTTPHeaderField: @"Content-Length"];
    
    return request;
}

+ (NSMutableURLRequest *)defaultRequestWithUrl:(NSString *)urlString httpMethod:(NSString *)httpMethod fileName:(NSString *)fileName mainBodyString:(NSData *)bodyData
{
    return [STGPacket defaultRequestWithUrl:urlString httpMethod:httpMethod contentParts:[NSArray arrayWithObject:[STGPacket contentPartWithName:@"file" fileName:fileName content:bodyData]]];
}

+ (NSData *)contentPartWithName:(NSString *)name fileName:(NSString *)fileName content:(NSData *)content
{
    NSMutableData *partData = [[NSMutableData alloc] init];
    NSMutableString *header = [[NSMutableString alloc] init];
    
    [header appendString:@"Content-Disposition: form-data;"];
    if (name)
        [header appendFormat:@" name=\"%@\";", name];
    if (fileName)
        [header appendFormat:@" filename=\"%@\";", fileName];
    [header appendString:@"\r\n"];
    
    [header appendString:@"Content-Type: application/octet-stream\r\n"];
    [header appendString:[NSString stringWithFormat:@"Content-Length: %li\r\n", content ? [content length] : 0]];
    [header appendFormat:@"Content-Transfer-Encoding: binary\r\n"];

    [header appendString:@"\r\n"];

    [partData appendData:[header dataUsingEncoding:NSUTF8StringEncoding]];
    if (content)
        [partData appendData:content];

    return partData;
}

+ (NSString *)getValueFromJSON:(NSString *)json key:(NSString *)key
{
    NSRange idRange = [json rangeOfString:[NSString stringWithFormat:@"\"%@\"", key]];
    if (idRange.location != NSNotFound)
    {
        NSString *keySubstring = [json substringFromIndex:idRange.location + idRange.length];
        
        NSRange firstValueRange = [keySubstring rangeOfString:@"\""];
        if (firstValueRange.location != NSNotFound)
        {
            NSString *valueSubstring = [keySubstring substringFromIndex:firstValueRange.location + firstValueRange.length];
            
            NSRange endRange = [valueSubstring rangeOfString:@"\""];
            
            if (endRange.location != NSNotFound)
            {
                return [valueSubstring substringToIndex:endRange.location];
            }
        }
    }
    
    return nil;
}

@end
