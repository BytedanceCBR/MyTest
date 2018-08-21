//
//  TTWebviewAntiHijackManager.m
//  Article
//
//  Created by gaohaidong on 8/22/16.
//
//

#import "TTWebviewAntiHijackManager.h"
#import "TTWebviewAntiHijackServerConfig.h"

@interface AntiHijackURLProtocol : NSURLProtocol
    
@end

@implementation AntiHijackURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    BOOL isInBlackList = [[TTWebviewAntiHijackServerConfig sharedTTWebviewAntiHijackServerConfig] isInBlackList:[request URL]];
    return isInBlackList;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)startLoading {
    ENTER;

    id<NSURLProtocolClient> client = [self client];
    NSError* error = [NSError errorWithDomain:NSURLErrorDomain
                                         code:kCFURLErrorNotConnectedToInternet //-1009
                                     userInfo:@{ NSLocalizedDescriptionKey:@"request is blocked by the AntiHijackURLProtocol"}];
    [client URLProtocol:self didFailWithError:error];
}

- (void)stopLoading {
    ENTER;
}

@end

@implementation TTWebviewAntiHijackManager

+ (void)startWebviewAntiHijack {
    ENTER;
    if ([TTWebviewAntiHijackServerConfig sharedTTWebviewAntiHijackServerConfig].isEnabled) {
        [NSURLProtocol registerClass:[AntiHijackURLProtocol class]];
    }
}

+ (void)stopWebviewAntiHijack {
    ENTER;
    [NSURLProtocol unregisterClass:[AntiHijackURLProtocol class]];
}

@end


