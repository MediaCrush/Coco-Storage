//
//  STGJSONHelper.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 17.06.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGJSONHelper.h"

@implementation STGJSONHelper

+ (NSObject *)getJSONFromData:(NSData *)data
{
    if (NSClassFromString(@"NSJSONSerialization"))
    {
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        
        if(error)
        {
            NSLog(@"Bad JSON: %@", error);
            NSString *stringRep = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"String representation: \n%@", stringRep);
            
            return nil;
        }
        
        return json;
    }
    else
    {
        NSLog(@"Can't JSON! NOOOOO!");
        
        return nil;
    }
}

+ (NSDictionary *)getDictionaryJSONFromData:(NSData *)data
{
    NSObject *json = [self getJSONFromData:data];
    
    if([json isKindOfClass:[NSDictionary class]])
    {
        return (NSDictionary *)json;
    }
    else
    {
        NSLog(@"JSON not a dictionary: (%@) %@", [json class], json);
        NSString *stringRep = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"String representation: \n%@", stringRep);
        
        return nil;
    }
}

+ (NSArray *)getArrayJSONFromData:(NSData *)data
{
    NSObject *json = [self getJSONFromData:data];
    
    if([json isKindOfClass:[NSArray class]])
    {
        return (NSArray *)json;
    }
    else
    {
        NSLog(@"JSON not an array: (%@) %@", [json class], json);
        NSString *stringRep = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"String representation: \n%@", stringRep);
        
        return nil;
    }
}

@end
