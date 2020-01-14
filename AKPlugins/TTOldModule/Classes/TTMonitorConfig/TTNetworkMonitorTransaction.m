//
//  TTNetworkMonitorTransaction.m
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/3/9.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import "TTNetworkMonitorTransaction.h"

@implementation TTNetworkMonitorTransaction

- (NSString *)description
{
    NSString *description = [super description];
    description = [description stringByAppendingFormat:@" id = %@;", self.requestID];
    description = [description stringByAppendingFormat:@" url = %@;", self.request.URL];
    description = [description stringByAppendingFormat:@" duration = %f;", self.duration];
    return description;
}

+ (NSInteger)statusCodeForNSUnderlyingError:(NSError *)error
{
    int status = 1;
    if(([error.domain isEqualToString:(NSString*)kCFErrorDomainCFNetwork] || [error.domain isEqualToString:NSURLErrorDomain]) && error.code == kCFURLErrorTimedOut) // ConnectTimeoutException
    {
        status = 2;
    }
    else if(([error.domain isEqualToString:(NSString*)kCFErrorDomainCFNetwork] || [error.domain isEqualToString:NSURLErrorDomain]) && (error.code == ETIMEDOUT || error.code == ETIME)) // SocketTimeoutException
    {
        status = 3;
    }
    else if([error.domain isEqualToString:NSPOSIXErrorDomain] && error.code == ECONNRESET) // reset by peer
    {
        status = 6;
    }
    else if([error.domain isEqualToString:NSPOSIXErrorDomain] && (error.code == EISCONN || error.code == EADDRINUSE || error.code == EADDRNOTAVAIL)) // bind exception
    {
        status = 7;
    }
    else if(([error.domain isEqualToString:NSPOSIXErrorDomain] && (error.code == EHOSTDOWN || error.code == ECONNREFUSED || error.code == ENETRESET || error.code == ECONNABORTED || error.code == ENOTCONN)) ||
            ([error.domain isEqualToString:(NSString*)kCFErrorDomainCFNetwork] && (error.code == kCFErrorHTTPConnectionLost || error.code == kCFURLErrorCannotConnectToHost || error.code == kCFURLErrorNetworkConnectionLost || error.code == kCFErrorHTTPSProxyConnectionFailure))) // connect exception
    {
        status = 8;
    }
    else if([error.domain isEqualToString:NSPOSIXErrorDomain] && error.code == EHOSTUNREACH) // NoRouteToHostException
    {
        status = 9;
    }
    else if(([error.domain isEqualToString:(NSString*)kCFErrorDomainCFNetwork] || [error.domain isEqualToString:NSURLErrorDomain]) &&(error.code == kCFHostErrorHostNotFound || error.code == kCFHostErrorUnknown || error.code == kCFURLErrorCannotFindHost)) // UnknownHostException
    {
        status = 11;
    }
    else if(([error.domain isEqualToString:(NSString*)kCFErrorDomainCFNetwork] || [error.domain isEqualToString:NSURLErrorDomain]) && error.code == kCFURLErrorDataLengthExceedsMaximum) //  content length超过限制
    {
        status = 20;
    }
    else if(([error.domain isEqualToString:(NSString*)kCFErrorDomainCFNetwork] || [error.domain isEqualToString:NSURLErrorDomain]) && (error.code <= -3000 && error.code >= -3007)) // IOException
    {
        status = 4;
    } else {
        status = error.code;
    }
    return status;
}


+ (NSInteger)statusCodeForResponse:(TTHttpResponse *)response
{
    if (response != nil) {
        if ([response isKindOfClass:[TTHttpResponse class]]) {
            NSInteger scode = response.statusCode;
            if (scode != 0) {
                return scode;
            }
        }
    }
    return NSNotFound;
}

@end
