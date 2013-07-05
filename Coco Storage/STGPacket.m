//
//  STGPacketQueueEntry.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 11.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGPacket.h"

@implementation STGPacket

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setUserInfo:[[NSMutableDictionary alloc] init]];
    }
    return self;
}

+ (id)genericPacketWithRequest:(NSURLRequest *)request packetType:(NSString *)packetType userInfo:(NSMutableDictionary *)userInfo
{
    STGPacket *packet = [[STGPacket alloc] init];
    
    [packet setUrlRequest:request];
    
    [packet setUserInfo:userInfo];
    [packet setPacketType:packetType];
    
    return packet;
}

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

+ (NSMutableURLRequest *)defaultRequestWithUrl:(NSString *)urlString httpMethod:(NSString *)httpMethod fileName:(NSString *)fileName mainBodyData:(NSData *)bodyData
{
    return [STGPacket defaultRequestWithUrl:urlString httpMethod:httpMethod contentParts:[NSArray arrayWithObject:[STGPacket contentPartWithName:@"file" fileName:fileName content:bodyData]]];
}

+ (NSData *)contentPartWithName:(NSString *)name fileName:(NSString *)fileName content:(NSData *)content
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    if (name)
        [dict setObject:name forKey:@"name"];
    if (fileName)
        [dict setObject:fileName forKey:@"filename"];
    
    return [self contentPartObjectsForKeys:dict content:content];
}

+ (NSData *)contentPartObjectsForKeys:(NSDictionary *)dict content:(NSData *)content
{
    NSMutableData *partData = [[NSMutableData alloc] init];
    NSMutableString *header = [[NSMutableString alloc] init];
    
    [header appendString:@"Content-Disposition: form-data;"];

    if (dict)
    {
        NSArray *keys = [dict allKeys];
        
        for(NSString *key in keys)
        {
            [header appendFormat:@" %@=\"%@\";", key, [dict objectForKey:key]];
        }        
    }
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

@end
