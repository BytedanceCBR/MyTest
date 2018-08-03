//
//  BDTDefaultHTTPRequestSerializer.m
//  Article
//
//  Created by zuopengliu on 27/2/2018.
//

#import "BDTDefaultHTTPRequestSerializer.h"
#import <TTNetworkManager.h>
#import <TTAccountSDK.h>



@interface BDTDefaultHTTPRequestSerializer()

@property (nonatomic, copy) NSString *defaultUserAgent;

@end

@implementation BDTDefaultHTTPRequestSerializer

- (TTHttpRequest *)URLRequestWithURL:(NSString *)URL
                              params:(NSDictionary *)params
                              method:(NSString *)method
               constructingBodyBlock:(TTConstructingBodyBlock)bodyBlock
                        commonParams:(NSDictionary *)commonParam
{
    NSURL *origURL = [NSURL URLWithString:URL];
    NSURL *convertUrl = [self _transferedURL:origURL];
    TTHttpRequest *mutableURLRequest = [super URLRequestWithURL:convertUrl.absoluteString params:params method:method constructingBodyBlock:bodyBlock commonParams:commonParam];
    
    //我们自己的 一些Header 在这一步加入
    [self buildRequestHeaders:mutableURLRequest parameters:params];
    
    return mutableURLRequest;
}

- (TTHttpRequest *)URLRequestWithURL:(NSString *)URL
                         headerField:(NSDictionary *)headField
                              params:(NSDictionary *)params
                              method:(NSString *)method
               constructingBodyBlock:(TTConstructingBodyBlock)bodyBlock
                        commonParams:(NSDictionary *)commonParam
{
    NSURL *origURL = [NSURL URLWithString:URL];
    NSURL *convertUrl = [self _transferedURL:origURL];
    
    TTHttpRequest *mutableURLRequest = [super URLRequestWithURL:convertUrl.absoluteString headerField:headField params:params method:method constructingBodyBlock:bodyBlock commonParams:commonParam];
    
    //我们自己的 一些Header 在这一步加入
    [self buildRequestHeaders:mutableURLRequest parameters:params];
    
    return mutableURLRequest;
}

- (TTHttpRequest *)URLRequestWithRequestModel:(TTRequestModel *)requestModel commonParams:(NSDictionary *)commonParam
{
    //规范一下 requestModel;
    NSURLComponents *urlComponents = [NSURLComponents componentsWithString:requestModel._requestURL.absoluteString];
    requestModel._uri = urlComponents.path;
    requestModel._host = [urlComponents.scheme stringByAppendingFormat:@"://%@", urlComponents.host];
    
    NSURL *origURL = [requestModel._requestURL copy];
    NSURL *convertUrl = [self _transferedURL:origURL];
    
    requestModel._host = [convertUrl.scheme stringByAppendingFormat:@"://%@", convertUrl.host];
    
    TTHttpRequest *mutableURLRequest = [super URLRequestWithRequestModel:requestModel commonParams:commonParam];
    
    //我们自己的 一些Header 在这一步加入
    [self buildRequestHeaders:mutableURLRequest parameters:requestModel._requestParams];
    
    return mutableURLRequest;
}

- (NSURL *)_transferedURL:(NSURL *)url
{
    return [[TTNetworkManager shareInstance] transferedURL:url];
}

+ (instancetype)serializer
{
    return [[[self class] alloc] init];
}

- (void)buildRequestHeaders:(TTHttpRequest *)request
{
    [self buildRequestHeaders:request parameters:nil];
}

- (void)buildRequestHeaders:(TTHttpRequest *)request parameters:(id)parameters
{
    if (!request || !request.URL) {
        return;
    }
    [self applyCookieHeader:request];
    
    // Build and set the user agent string if the request does not already have a custom user agent specified
    if (![[request allHTTPHeaderFields] objectForKey:@"User-Agent"]) {
        
        NSString *tempUserAgentString = [self defaultUserAgentString];
        if (tempUserAgentString) {
            [request setValue: tempUserAgentString forHTTPHeaderField:@"User-Agent"];
        }
    }
    
    // 加上request time
    NSUInteger requestTime = [[NSDate date] timeIntervalSince1970] * 1000;
    [request setValue:[@(requestTime) stringValue] forHTTPHeaderField:@"tt-request-time"];
    
    // add other http header info
    [self applySessionKeyXToRequest:request];
}

#pragma mark get user agent

- (NSString *)defaultUserAgentString
{
    if (!self.defaultUserAgent) {
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        // Attempt to find a name for this application
        NSString *appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
        
        NSData *latin1Data = [appName dataUsingEncoding:NSUTF8StringEncoding];
        appName = [[NSString alloc] initWithData:latin1Data encoding:NSISOLatin1StringEncoding];
        
        // If we couldn't find one, we'll give up (and ASIHTTPRequest will use the standard CFNetwork user agent)
        if (!appName) {
            return nil;
        }
        
        NSString *appVersion = nil;
        NSString *marketingVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString *developmentVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
        if (marketingVersionNumber && developmentVersionNumber) {
            if ([marketingVersionNumber isEqualToString:developmentVersionNumber]) {
                appVersion = marketingVersionNumber;
            } else {
                appVersion = [NSString stringWithFormat:@"%@ rv:%@", marketingVersionNumber, developmentVersionNumber];
            }
        } else {
            appVersion = (marketingVersionNumber ? marketingVersionNumber : developmentVersionNumber);
        }
        
        NSString *deviceName;
        NSString *OSName;
        NSString *OSVersion;
        NSString *locale = [[NSLocale currentLocale] localeIdentifier];
        
#if TARGET_OS_IPHONE
        UIDevice *device = [UIDevice currentDevice];
        deviceName = [device model];
        OSName = [device systemName];
        OSVersion = [device systemVersion];
#else
        deviceName = @"Macintosh";
        OSName = @"Mac OS X";
        
        // From http://www.cocoadev.com/index.pl?DeterminingOSVersion
        // We won't bother to check for systems prior to 10.4, since ASIHTTPRequest only works on 10.5+
        OSErr err;
        SInt32 versionMajor, versionMinor, versionBugFix;
        err = Gestalt(gestaltSystemVersionMajor, &versionMajor);
        if (err != noErr) return nil;
        err = Gestalt(gestaltSystemVersionMinor, &versionMinor);
        if (err != noErr) return nil;
        err = Gestalt(gestaltSystemVersionBugFix, &versionBugFix);
        if (err != noErr) return nil;
        OSVersion = [NSString stringWithFormat:@"%u.%u.%u", versionMajor, versionMinor, versionBugFix];
#endif
        
        // Takes the form "My Application 1.0 (Macintosh; Mac OS X 10.5.7; en_GB)"
        self.defaultUserAgent = [NSString stringWithFormat:@"%@ %@ (%@; %@ %@; %@)", appName, appVersion, deviceName, OSName, OSVersion, locale];
    }
    return self.defaultUserAgent;
}

- (void)applyCookieHeader:(TTHttpRequest *)request
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[[request URL] absoluteURL]];
    
    if ([cookies count] > 0) {
        NSString *cookieHeader = nil;
        for (NSHTTPCookie *cookie in cookies) {
            if (!cookieHeader) {
                cookieHeader = [NSString stringWithFormat:@"%@=%@", [cookie name], [cookie value]];
            } else {
                cookieHeader = [NSString stringWithFormat:@"%@; %@=%@", cookieHeader, [cookie name], [cookie value]];
            }
        }
        if (cookieHeader) {
            [request setValue:cookieHeader forHTTPHeaderField:@"Cookie"];
            [request setValue:cookieHeader forHTTPHeaderField:@"X-SS-Cookie"];
        }
    }
}

- (void)applyCookieHeaderFrom:(NSURL *)url toRequest:(TTHttpRequest *)toRequest
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[url absoluteURL]];
    
    if ([cookies count] > 0) {
        NSString *cookieHeader = nil;
        for (NSHTTPCookie *cookie in cookies) {
            if (!cookieHeader) {
                cookieHeader = [NSString stringWithFormat:@"%@=%@", [cookie name], [cookie value]];
            } else {
                cookieHeader = [NSString stringWithFormat:@"%@; %@=%@", cookieHeader, [cookie name], [cookie value]];
            }
        }
        if (cookieHeader) {
            [toRequest setValue:cookieHeader forHTTPHeaderField:@"Cookie"];
            [toRequest setValue: cookieHeader forHTTPHeaderField:@"X-SS-Cookie"];
        }
    }
}

- (void)applySessionKeyXToRequest:(TTHttpRequest *)toRequest
{
    [toRequest setValue:[TTAccount sharedAccount].sessionKey forHTTPHeaderField:@"x-ss-sessionid"];
}

@end
