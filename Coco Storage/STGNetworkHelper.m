//
//  STGNetworkHelper.m
//  Coco Storage
//
//  Created by Lukas Tenbrink on 13.05.13.
//  Copyright (c) 2013 Lukas Tenbrink. All rights reserved.
//

#import "STGNetworkHelper.h"

#import <SystemConfiguration/SystemConfiguration.h>

@implementation STGNetworkHelper

+ (BOOL)isWebsiteReachable:(NSString *)link
{
    BOOL bRet = FALSE;
    const char *hostName = [link cStringUsingEncoding:NSASCIIStringEncoding];
    SCNetworkConnectionFlags flags = 0;
    
    SCNetworkReachabilityRef target;
    target = SCNetworkReachabilityCreateWithName(NULL, hostName);
    Boolean ok = SCNetworkReachabilityGetFlags(target, &flags);
    CFRelease(target);

    if (ok && flags > 0)
    {
        if (flags == kSCNetworkFlagsReachable)
        {
            bRet = TRUE;
        }
        else
        {
        }
    }
    else
    {
    }
    return bRet;
}

@end
