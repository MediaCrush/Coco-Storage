//
//  STGPacketCreator.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 19.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGPacketCreator.h"

#import "STGPacket.h"

#import "STGDataCaptureEntry.h"

@implementation STGPacketCreator

+ (STGPacket *)getFilePacket:(NSString *)link key:(NSString *)key
{
    return nil;
}

+ (STGPacket *)uploadFilePacket:(STGDataCaptureEntry *)entry uploadLink:(NSString *)link key:(NSString *)key
{
    NSURLRequest *request = [STGPacket defaultRequestWithUrl:[NSString stringWithFormat:link, key] httpMethod:@"POST" fileName:[[entry fileURL] lastPathComponent] mainBodyData:[NSData dataWithContentsOfURL:[entry fileURL]]];
    
    STGPacket *packet = [STGPacket genericPacketWithRequest:request packetType:@"uploadFile" userInfo:[NSMutableDictionary dictionaryWithObject:entry forKey:@"dataCaptureEntry"]];
    
    return packet;
}

+ (STGPacket *)deleteFilePacket:(STGDataCaptureEntry *)entry uploadLink:(NSString *)link key:(NSString *)key
{
    NSUInteger entryIDLoc = [[entry onlineLink] rangeOfString:@"/" options:NSBackwardsSearch].location;
    
    if (entryIDLoc == NSNotFound)
        return nil;

    NSString *entryID = [[entry onlineLink] substringFromIndex:entryIDLoc + 1];
    NSString *urlString = [NSString stringWithFormat:link, entryID, key];
    
    NSURLRequest *request = [STGPacket defaultRequestWithUrl:urlString httpMethod:@"DELETE" fileName:[[entry fileURL] lastPathComponent] mainBodyData:[NSData dataWithContentsOfURL:[entry fileURL]]];

    STGPacket *packet = [STGPacket genericPacketWithRequest:request packetType:@"deleteFile" userInfo:[NSMutableDictionary dictionaryWithObject:entry forKey:@"dataCaptureEntry"]];
    
    return packet;
}

+ (STGPacket *)objectInfoPacket:(NSString *)objectID link:(NSString *)link key:(NSString *)key
{
    NSURLRequest *request = [STGPacket defaultRequestWithUrl:[NSString stringWithFormat:link, objectID, key] httpMethod:@"GET" contentParts:nil];
    
    STGPacket *packet = [STGPacket genericPacketWithRequest:request packetType:@"getObjectInfo" userInfo:[NSMutableDictionary dictionary]];

    return packet;
}

+ (STGPacket *)cfsGenericPacket:(NSString *)httpMethod path:(NSString *)filePath link:(NSString *)link key:(NSString *)key
{
    NSURLRequest *request = [STGPacket defaultRequestWithUrl:[NSString stringWithFormat:link, filePath, key] httpMethod:httpMethod contentParts:nil];
    
    STGPacket *packet = [STGPacket genericPacketWithRequest:request packetType:@"cfs:getFileList" userInfo:[NSMutableDictionary dictionaryWithObject:filePath forKey:@"filePath"]];
    
    return packet;
}

+ (STGPacket *)cfsFileListPacket:(NSString *)filePath link:(NSString *)link key:(NSString *)key
{
    return [self cfsGenericPacket:@"GET" path:filePath link:link key:key];
}

+ (STGPacket *)cfsFileInfoPacket:(NSString *)filePath link:(NSString *)link key:(NSString *)key
{
    return [self cfsGenericPacket:@"HEAD" path:filePath link:link key:key];
}

+ (STGPacket *)cfsPostFilePacket:(NSString *)filePath fileURL:(NSURL *)fileURL link:(NSString *)link key:(NSString *)key
{
    NSURL *innerURL = [NSURL URLWithString:filePath];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[innerURL lastPathComponent], @"filename", [innerURL path], @"folder", nil];
    
    NSData *contentPart = [STGPacket contentPartObjectsForKeys:dict content:[NSData dataWithContentsOfURL:fileURL]];
    
    NSMutableURLRequest *request = [STGPacket defaultRequestWithUrl:[NSString stringWithFormat:link, "", key] httpMethod:@"POST" contentParts:[NSArray arrayWithObject:contentPart]];
        
    STGPacket *packet = [STGPacket genericPacketWithRequest:request packetType:@"cfs:getFileList" userInfo:[NSMutableDictionary dictionaryWithObject:filePath forKey:@"filePath"]];
    
    return packet;
}

+ (STGPacket *)cfsUpdateFilePacket:(NSString *)filePath fileURL:(NSURL *)fileURL link:(NSString *)link key:(NSString *)key
{
    NSURLRequest *request = [STGPacket defaultRequestWithUrl:[NSString stringWithFormat:link, filePath, key] httpMethod:@"PUT" fileName:nil mainBodyData:[NSData dataWithContentsOfURL:fileURL]];
    
    STGPacket *packet = [STGPacket genericPacketWithRequest:request packetType:@"cfs:getFileList" userInfo:[NSMutableDictionary dictionaryWithObject:filePath forKey:@"filePath"]];
    
    return packet;
}

+ (STGPacket *)cfsDeleteFilePacket:(NSString *)filePath link:(NSString *)link key:(NSString *)key
{
    return [self cfsGenericPacket:@"DELETE" path:filePath link:link key:key];
}

+ (STGPacket *)apiStatusPacket:(NSString *)link apiInfo:(int)apiInfo key:(NSString *)key
{
    NSURLRequest *request = [STGPacket defaultRequestWithUrl:[NSString stringWithFormat:link, key] httpMethod:@"GET" contentParts:nil];
    
    STGPacket *packet = [STGPacket genericPacketWithRequest:request packetType:@"getAPIStatus" userInfo:[NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:apiInfo] forKey:@"apiVersion"]];
    
    return packet;
}

@end
