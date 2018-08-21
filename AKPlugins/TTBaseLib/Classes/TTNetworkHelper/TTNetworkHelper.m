//
//  TTNetworkHelper.m
//  Pods
//
//  Created by 冯靖君 on 17/2/15.
//
//

#import "TTNetworkHelper.h"
#import "NetworkUtilities.h"
#include <ifaddrs.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <arpa/inet.h>
#include <netdb.h>

@import CoreTelephony;

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

static CTTelephonyNetworkInfo *netInfo;

//http://openfibers.github.io/blog/2016/10/22/deadlock-caused-by-dispatch-once/ 可能存在的隐患
//http://www.jianshu.com/p/036f502a2b15 __attribute__((constructor))修饰的方法调用时机在main函数之前，时机足够早，初始化一个实例在本文件内共享
__attribute__((constructor)) void generate_netInfo() {
        netInfo = [[CTTelephonyNetworkInfo alloc] init];
}

@implementation TTNetworkHelper

+ (NSString*)connectMethodName {
    NSString * netType = @"";
    if(TTNetworkWifiConnected())
    {
        netType = @"WIFI";
    }
    else if(TTNetwork4GConnected())
    {
        netType = @"4G";
    }
    else if(TTNetwork3GConnected())
    {
        netType = @"3G";
    }
    else if(TTNetworkConnected())
    {
        netType = @"mobile";
    }
    return netType;
}

+ (NSString *)carrierName {
    static NSString *carrierName;
    static dispatch_once_t onceToken;
    NSCAssert(netInfo != nil, @"netInfo此时应该已经初始化");
    if(!netInfo) return nil;
    dispatch_once(&onceToken, ^{
        CTCarrier *carrier = [netInfo subscriberCellularProvider];
        carrierName = [carrier carrierName];
    });
    return carrierName;
}

+ (NSString *)carrierMCC {
    static NSString *mcc;
    static dispatch_once_t onceToken;
    NSCAssert(netInfo != nil, @"netInfo此时应该已经初始化");
    if(!netInfo) return nil;
    dispatch_once(&onceToken, ^{
        CTCarrier *carrier = [netInfo subscriberCellularProvider];
        mcc = [carrier mobileCountryCode];
    });
    return mcc;
}

+ (NSString *)carrierMNC {
    static NSString *mnc;
    static dispatch_once_t onceToken;
    NSCAssert(netInfo != nil, @"netInfo此时应该已经初始化");
    if(!netInfo) return nil;
    dispatch_once(&onceToken, ^{
        CTCarrier *carrier = [netInfo subscriberCellularProvider];
        mnc = [carrier mobileNetworkCode];
    });
    return mnc;
}

+ (NSDictionary *)getIPAddresses {
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

+ (NSString*)addressOfHost:(NSString*)host {
    struct addrinfo hints, *res, *p;
    int status;
    char ipstr[INET6_ADDRSTRLEN];
    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_UNSPEC; // AF_INET or AF_INET6 to force version
    hints.ai_socktype = SOCK_STREAM;
    
    if ((status = getaddrinfo([host UTF8String], "http", &hints, &res)) != 0) {
        fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(status));
        return @"";
    }
    
    NSMutableArray *resultList = [NSMutableArray array];
    
    for(p = res;p != NULL; p = p->ai_next) {
        void *addr;
        char *ipver;
        
        // get the pointer to the address itself,
        // different fields in IPv4 and IPv6:
        if (p->ai_family == AF_INET) { // IPv4
            struct sockaddr_in *ipv4 = (struct sockaddr_in *)p->ai_addr;
            addr = &(ipv4->sin_addr);
            ipver = "IPv4";
        } else { // IPv6
            struct sockaddr_in6 *ipv6 = (struct sockaddr_in6 *)p->ai_addr;
            addr = &(ipv6->sin6_addr);
            ipver = "IPv6";
        }
        
        // convert the IP to a string and print it:
        const char* ip = inet_ntop(p->ai_family, addr, ipstr, sizeof ipstr);
        
        [resultList addObject:[NSString stringWithUTF8String:ip]];
    }
    freeaddrinfo(res); // 释放 getaddrinfo() 返回的 res 链表
    if (resultList.count>0) {
        return [resultList objectAtIndex:0];
    }
    return @"";
}

@end
