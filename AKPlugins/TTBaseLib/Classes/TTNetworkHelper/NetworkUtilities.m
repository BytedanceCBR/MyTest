//
//  Created by David Alpha Fox on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <pthread.h>

#import "TTReachability.h"
#import "NetworkUtilities.h"

extern TTNetworkFlags TTNetworkGetFlags(void) {
    NSInteger flags = 0;
    if (TTNetwork2GConnected() || TTNetwork3GConnected() || TTNetwork4GConnected()) {
        flags |= TTNetworkFlagMobile;
    }
    if (TTNetwork2GConnected()) {
        flags |= TTNetworkFlag2G;
    }
    if (TTNetwork3GConnected()) {
        flags |= TTNetworkFlag3G;
    }
    if (TTNetwork4GConnected()) {
        flags |= TTNetworkFlag4G;
    }
    if (TTNetworkWifiConnected()) {
        flags |= TTNetworkFlagWifi;
    }
    return flags;
}

static TTReachability * DefaultReachability()
{
    static TTReachability * instance = nil;
    static pthread_mutex_t  lock = PTHREAD_MUTEX_INITIALIZER;
    
    if (!instance)
    {
        pthread_mutex_lock(&lock);
        if (!instance)
        {
            instance = [TTReachability reachabilityWithHostName:@"toutiao.com"];
        }
        pthread_mutex_unlock(&lock);
    }
    return instance;
}

BOOL TTNetworkConnected(void) 
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kTTNetworkConnectOptimize"] &&[[NSUserDefaults standardUserDefaults] boolForKey:@"kTTNetworkConnectOptimize"]) {
        return [TTReachability isNetworkConnected];
    } else {
        
        TTReachability * reach = DefaultReachability();
        //return NO; // force for offline testing
        NetworkStatus netStatus = [reach currentReachabilityStatus];
        if(netStatus != NotReachable) return YES;
        
        //double check，防止误伤
        TTReachability *retry = [TTReachability reachabilityWithHostName:@"www.apple.com"];
        netStatus = [retry currentReachabilityStatus];
        return (netStatus != NotReachable);
    }
}

BOOL TTNetworkWifiConnected(void)
{
    static NSString *channelName;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        channelName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CHANNEL_NAME"];
    });
    if ([channelName isEqualToString:@"local_test"] || [channelName isEqualToString:@"dev"]) {
        BOOL isDebugDisbaleWIFI = [[NSUserDefaults standardUserDefaults] boolForKey:@"debug_disable_network"];
        if (isDebugDisbaleWIFI) {
            return NO;
        }
    }
    
    TTReachability * reach = DefaultReachability();
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    if(netStatus == NotReachable) {
        return NO;
    }
    if (netStatus == ReachableViaWiFi) {
        return YES; 
    }
    return NO;
}

BOOL TTNetowrkCellPhoneConnected(void)
{
    TTReachability * reach = DefaultReachability();
    NetworkStatus netStatus = [reach currentReachabilityStatus];
    if (netStatus == NotReachable) {
        return NO;
    }
    if (netStatus == ReachableViaWWAN) {
        return YES; 
    }
    if (netStatus == ReachableViaWiFi) {
        // 在 reachable 为 wifi 连接的情况下，通过 TelephonyNetworkInfo 的信息来判断是否有蜂窝网络连接
        return TTNetwork4GConnected() || TTNetwork3GConnected() || TTNetwork2GConnected();
    }
    return NO;
}

BOOL TTNetwork2GConnected(void)
{
    return [TTReachability is2GConnected];
}

BOOL TTNetwork3GConnected(void)
{
    return [TTReachability is3GConnected];
}

BOOL TTNetwork4GConnected(void)
{
    return [TTReachability is4GConnected];
}

BOOL TTNetworkIsCellularDisabled(void)
{
    TTReachability * reach = DefaultReachability();
    if ([reach currentNetworkAuthorizationStatus] != kTTNetworkAuthorizationStatusCantDetermined) {
        return YES;
    }
    return NO;
}

BOOL TTNetworkIsCellularAndWLANDisabled(void)
{
    TTReachability * reach = DefaultReachability();
    if ([reach currentNetworkAuthorizationStatus] == kTTNetworkAuthorizationStatusWLANAndCellNotPermitted) {
        return YES;
    }
    return NO;
}


void TTNetworkStartNotifier(void)
{    
    TTReachability * reach = DefaultReachability();
    dispatch_async(dispatch_get_main_queue(), ^{
        [reach startNotifier];
    });
}

void TTNetworkStopNotifier(void)
{
    TTReachability * reach = DefaultReachability();
    dispatch_async(dispatch_get_main_queue(), ^{
        [reach stopNotifier];
    });
}

