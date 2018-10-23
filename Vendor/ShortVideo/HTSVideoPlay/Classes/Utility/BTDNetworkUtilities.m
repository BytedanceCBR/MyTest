//
//  Created by David Alpha Fox on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <pthread.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <netdb.h>
#include <arpa/inet.h>
#import "TTReachability.h"
#import "BTDNetworkUtilities.h"
#import "BTDMacros.h"

static TTReachability * gHostReach = nil;
static pthread_mutex_t  gHostReachMutex = PTHREAD_MUTEX_INITIALIZER;
static BOOL gNotifier = NO;

extern BTDNetworkFlags BTDNetworkGetFlags(void) {
    NSInteger flags = 0;
    if (BTDNetwork2GConnected() || BTDNetwork3GConnected() || BTDNetwork4GConnected()) {
        flags |= BTDNetworkFlagMobile;
    }
    if (BTDNetwork2GConnected()) {
        flags |= BTDNetworkFlag2G;
    }
    if (BTDNetwork3GConnected()) {
        flags |= BTDNetworkFlag3G;
    }
    if (BTDNetwork4GConnected()) {
        flags |= BTDNetworkFlag4G;
    }
    if (BTDNetworkWifiConnected()) {
        flags |= BTDNetworkFlagWifi;
    }
    return flags;
}

BOOL BTDNetworkConnected(void) 
{
    if(gHostReach == nil)
    {
        pthread_mutex_lock(&gHostReachMutex);
        if(gHostReach == nil)
        {
            gHostReach = [TTReachability reachabilityForInternetConnection];
        }
        pthread_mutex_unlock(&gHostReachMutex);
    }
   
    
	//return NO; // force for offline testing
	NetworkStatus netStatus = [gHostReach currentReachabilityStatus];	
	return !(netStatus == NotReachable);
}

BOOL BTDNetworkWifiConnected(void)
{
    if(gHostReach == nil)
    {
        pthread_mutex_lock(&gHostReachMutex);
        if(gHostReach == nil)
        {
            gHostReach = [TTReachability reachabilityForInternetConnection];
        }
        pthread_mutex_unlock(&gHostReachMutex);
    }
    
    NetworkStatus netStatus = [gHostReach currentReachabilityStatus];
    if(netStatus == NotReachable) {
        return NO;
    }
    if (netStatus == ReachableViaWiFi) {
        return YES; 
    }
    return NO;
}

BOOL BTDNetworkCellPhoneConnected(void)
{
    if(gHostReach == nil)
    {
        pthread_mutex_lock(&gHostReachMutex);
        if(gHostReach == nil)
        {
            gHostReach = [TTReachability reachabilityForInternetConnection];
        }
        pthread_mutex_unlock(&gHostReachMutex);
    }
    
    NetworkStatus netStatus = [gHostReach currentReachabilityStatus];
    if (netStatus == NotReachable) {
        return NO;
    }
    if (netStatus == ReachableViaWWAN) {
        return YES; 
    }
    return NO;
}

BOOL BTDNetwork2GConnected(void)
{
    return [BTDNetworkUtilities is2GConnected];
}

BOOL BTDNetwork3GConnected(void)
{
    return [BTDNetworkUtilities is3GConnected];
}

BOOL BTDNetwork4GConnected(void)
{
    return [BTDNetworkUtilities is4GConnected];
}

void BTDNetworkStartNotifier(void)
{
    if(gHostReach == nil)
    {
        pthread_mutex_lock(&gHostReachMutex);
        if(gHostReach == nil)
        {
            gHostReach = [TTReachability reachabilityForInternetConnection];
            //gNotifier = [gHostReach startNotifier];
            //[gHostReach performSelectorOnMainThread:@selector(startNotifier) withObject:nil waitUntilDone:YES];
            NSMethodSignature *sig = [gHostReach methodSignatureForSelector:@selector(startNotifier)];
            
            if (sig) {
                NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
                [invo setTarget:gHostReach];
                [invo setSelector:@selector(startNotifier)];
                [invo performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
                NSUInteger length = [[invo methodSignature] methodReturnLength];
                void * buffer = (void *)malloc(length);
                [invo getReturnValue:buffer];
                gNotifier = (BOOL)(*((BOOL *)buffer));
                free(buffer);
            }
        }
        pthread_mutex_unlock(&gHostReachMutex);
    }
    if(!gNotifier)
    {
        pthread_mutex_lock(&gHostReachMutex);
        if(!gNotifier)
        {
            NSMethodSignature *sig = [gHostReach methodSignatureForSelector:@selector(startNotifier)];
            
            if (sig) {
                NSInvocation* invo = [NSInvocation invocationWithMethodSignature:sig];
                [invo setTarget:gHostReach];
                [invo setSelector:@selector(startNotifier)];
                [invo performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:YES];
                NSUInteger length = [[invo methodSignature] methodReturnLength];
                void * buffer = (void *)malloc(length);
                [invo getReturnValue:buffer];
                gNotifier = (BOOL)(*((BOOL *)buffer));
                free(buffer);
            }
        }
        pthread_mutex_unlock(&gHostReachMutex);
    }
}

void BTDNetworkStopNotifier(void)
{
    if(gHostReach == nil)
    {
        return;
    }
    if(gNotifier)
    {
        pthread_mutex_lock(&gHostReachMutex);
        if(gNotifier)
        {
            //[gHostReach stopNotifier];
            [gHostReach performSelectorOnMainThread:@selector(stopNotifier) withObject:nil waitUntilDone:YES];
            gHostReach = nil;
        }
        pthread_mutex_unlock(&gHostReachMutex);
    }
}

@implementation BTDNetworkUtilities

static CTTelephonyNetworkInfo *telephoneInfo = nil;
static NSString *currentRadioAccessTechnology = nil;

+ (void)initialize
{
    telephoneInfo = [[CTTelephonyNetworkInfo alloc] init];
    currentRadioAccessTechnology = telephoneInfo.currentRadioAccessTechnology;
    [[NSNotificationCenter defaultCenter] addObserverForName:CTRadioAccessTechnologyDidChangeNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        currentRadioAccessTechnology = telephoneInfo.currentRadioAccessTechnology;
    }];
}

+ (BOOL)is2GConnected
{
    BOOL result = NO;
    result = [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge];
    return result;
}

+ (BOOL)is3GConnected
{
    BOOL result = NO;
    result = [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA]
    || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x]
    || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]
    || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD];
    return result;
}

+ (BOOL)is4GConnected
{
    BOOL result = NO;
    result = [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE];
    return result;
}

//同步方法， 不要在主线程调用
+ (NSString*)addressOfHost:(NSString*)host
{
    NSString *result = @"";
    if(!BTD_isEmptyString(host))
    {
        struct hostent *hostentry;
        hostentry = gethostbyname([host UTF8String]);
        
        if(hostentry)
        {
            char *ipbuf = inet_ntoa(*((struct in_addr *)hostentry->h_addr_list[0]));
            result = @(ipbuf);
        }
    }
    
    return result;
}

+ (NSString*)connectMethodName
{
    NSString * netType = @"";
    if(BTDNetworkWifiConnected())
    {
        netType = @"WIFI";
    }
    else if(BTDNetwork4GConnected())
    {
        netType = @"4G";
    }
    else if(BTDNetwork3GConnected())
    {
        netType = @"3G";
    }
    else if(BTDNetworkConnected())
    {
        netType = @"mobile";
    }
    return netType;
}


@end

