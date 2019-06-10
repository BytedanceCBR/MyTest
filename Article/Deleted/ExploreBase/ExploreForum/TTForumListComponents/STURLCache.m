//
//  STURLCache.m
//  STKit
//
//  Created by SunJiangting on 15-4-20.
//  Copyright (c) 2015年 SunJiangting. All rights reserved.
//

#import "STURLCache.h"
#import "NSStringAdditions.h"
#import "TTStringHelper.h"

@interface NSURLRequest (STCachedURLRequest)

- (NSURLRequest *)st_cachableRequestIgnoreParameters:(NSArray *)ingoredParameters;
@end

@interface STURLCache ()

@end

@implementation STURLCache

static STURLCache *_defaultURLCache;
+ (instancetype)defaultURLCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultURLCache = [[self alloc] initWithMemoryCapacity:4*1024*1024 diskCapacity:40*1024*1024 diskPath:@"TTDefaultURLCache"];
        _defaultURLCache.ignoredParameters = @[@"channel", @"device_id"];
    });
    return _defaultURLCache;
}

static BOOL _cacheAdaptEnabled = YES;
+ (void)setCacheAdaptEnabled:(BOOL)cacheAdaptEnabled {
    _cacheAdaptEnabled = cacheAdaptEnabled;
}

+ (BOOL)isCacheAdaptEnabled {
    return _cacheAdaptEnabled;
}

- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forRequest:(NSURLRequest *)request {
    NSURLRequest *adapterRequest = request;
    if ([cachedResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)cachedResponse.response;
        if (HTTPResponse.statusCode >= 200 && HTTPResponse.statusCode < 300) {
            if ([self _needRequestAdaptor] && cachedResponse.storagePolicy == NSURLCacheStorageAllowed) {
                adapterRequest = [adapterRequest st_cachableRequestIgnoreParameters:self.ignoredParameters];
            }
        }
    }
    [super storeCachedResponse:cachedResponse forRequest:adapterRequest];
}

- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    NSCachedURLResponse *cachedResponse = [super cachedResponseForRequest:request];
    if (!cachedResponse && [self _needRequestAdaptor]) {
        cachedResponse = [super cachedResponseForRequest:[request st_cachableRequestIgnoreParameters:self.ignoredParameters]];
    }
    return cachedResponse;
}
- (void)storeCachedResponse:(NSCachedURLResponse *)cachedResponse forDataTask:(NSURLSessionDataTask *)dataTask {
    NSURLRequest *request = dataTask.currentRequest;
    if ([self _needRequestAdaptor] && cachedResponse.storagePolicy == NSURLCacheStorageAllowed) {
        request = [request st_cachableRequestIgnoreParameters:self.ignoredParameters];
    }
    [super storeCachedResponse:cachedResponse forRequest:request];
}

- (void)getCachedResponseForDataTask:(NSURLSessionDataTask *)dataTask completionHandler:(void (^) (NSCachedURLResponse *cachedResponse))completionHandler {
    NSURLRequest *request = dataTask.currentRequest;
    NSCachedURLResponse *cachedResponse = [super cachedResponseForRequest:request];
    if (!cachedResponse && [self _needRequestAdaptor]) {
        cachedResponse = [super cachedResponseForRequest:[request st_cachableRequestIgnoreParameters:self.ignoredParameters]];
    }
    completionHandler(cachedResponse);
}

- (BOOL)_needRequestAdaptor {
    if (![[self class] isCacheAdaptEnabled]) {
        return NO;
    }
    if ([TTInfoHelper OSVersionNumber] > 8.1) {
        return YES;
    }
    return NO;
}
@end


@implementation NSURLRequest (STCachedURLRequest)

- (NSURLRequest *)st_cachableRequestIgnoreParameters:(NSArray *)ignoreParameters {
    NSURL *URL = self.URL;
    NSString *absoluteString = URL.absoluteString;
    NSRange range = [absoluteString rangeOfString:@"?"];
    if (!URL || [self.HTTPMethod isEqualToString:@"POST"] || (range.location == NSNotFound)) {
        return self;
    }
    absoluteString = [absoluteString substringToIndex:range.location];
    NSString *query = URL.query;
    NSMutableDictionary *params = [TTStringHelper parametersOfURLString:query];
    [params removeObjectsForKeys:ignoreParameters];
    NSString *sortedQuery = [self _keySortedURLQueryStringWithParameters:params sortSelector:@selector(caseInsensitiveCompare:)];
    if (![absoluteString hasSuffix:@"/"]) {
        absoluteString = [absoluteString stringByAppendingString:@"/"];
    }
    absoluteString = [absoluteString stringByAppendingFormat:@"%@/", sortedQuery.MD5HashString];
    URL = [NSURL URLWithString:absoluteString];
    NSMutableURLRequest *request = [self mutableCopy];
    request.URL = URL;
    return request;
}

- (NSString *)_keySortedURLQueryStringWithParameters:(NSDictionary *)parameters sortSelector:(SEL)sortSelector {
    if (!sortSelector || ![NSString instancesRespondToSelector:sortSelector]) {
        sortSelector = @selector(caseInsensitiveCompare:);
    }
    NSArray *keys = [parameters.allKeys sortedArrayUsingSelector:sortSelector];
    NSMutableString *sortedQuery = [NSMutableString stringWithCapacity:20];
    [keys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
        id obj = parameters[key];
        if ([obj isKindOfClass:[NSString class]]) {
//            [sortedQuery appendFormat:@"%@=%@&", [key st_stringByURLEncoded], [obj st_stringByURLEncoded]];
        } else {
//            [sortedQuery appendFormat:@"%@=%@&", [key st_stringByURLEncoded], obj];
        }
    }];
    if (sortedQuery.length > 0) {
        [sortedQuery deleteCharactersInRange:NSMakeRange(sortedQuery.length - 1, 1)];
    }
    return sortedQuery;
}

@end