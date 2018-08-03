//
//  Copyright (c) 2012年 Domob Ltd. All rights reserved.
//

#import "DMConversionTracker.h"
#import "OpenUDID.h"
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@interface DMConversionTracker()
+ (NSString *)macAddress;
+ (void)startTracking:(NSString *)appId;
@end

@implementation DMConversionTracker

+ (void)startAsynchronousConversionTrackingWithDomobAppId:(NSString *)appId
{
    @autoreleasepool 
    {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        NSInvocationOperation *iop= [[NSInvocationOperation alloc] initWithTarget:self 
                                                                         selector:@selector(startTracking:)
                                                                           object:appId];
        [queue addOperation:iop];
        [iop release];
        [queue release];        
    }
}

+ (void)startTracking:(NSString *)appId
{
    [appId retain];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *appOpenPath = [documentsDirectory stringByAppendingPathComponent:@"domob_app_open"];    
    NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
    
    if(![fileManager fileExistsAtPath:appOpenPath]) 
    {
        NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];

        NSString *reportUrl = [NSString stringWithFormat:@"http://e.domob.cn/track?app_id=%@&ma=%@&oid=%@&date=%@",
                               appId,
                               [self macAddress],
                               [OpenUDID value],
                               [formatter stringFromDate:[NSDate date]]];

        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:reportUrl]];
        NSURLResponse *response;
        NSError *error = nil;
        
        NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        if((!error) && ([(NSHTTPURLResponse *)response statusCode] == 200) && ([responseData length] > 0)) {
            [fileManager createFileAtPath:appOpenPath contents:nil attributes:nil];
        }
    }
    [appId release];
}

+ (NSString *)macAddress
{        
    // MAC address    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        return nil;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        return nil;
    }
    
    if ((buf = malloc(len)) == NULL) {
        return nil;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        return nil;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    
    NSString *macStr = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", 
                        *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
//    NSLog(@"[DomobTracker] MAC Address: %@", macStr);
    
    // MD5
    const char *tmpPtr = [macStr UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(tmpPtr, strlen(tmpPtr), md5Buffer);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) 
        [output appendFormat:@"%02X",md5Buffer[i]];

    free(buf);
   
    return output;

}
@end
