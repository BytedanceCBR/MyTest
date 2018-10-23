//
//  WDCommonURLSetting.m
//  Article
//
//  Created by xuzichao on 2017/5/22.
//
//

#import "WDCommonURLSetting.h"
#import "TTURLDomainHelper.h"

@interface WDCommonURLSetting ()

@property (nonatomic, copy) NSString *baseUrl;

@end

@implementation WDCommonURLSetting

+ (void)load
{
    
}

+ (NSString *)baseURL
{
    return [[WDCommonURLSetting sharedInstance] baseUrl];
}

+ (NSString*)searchWebURLString {
    return [NSString stringWithFormat:@"%@/2/wap/search/", [self baseURL]];
}

+ (instancetype)sharedInstance
{
    static WDCommonURLSetting * shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[WDCommonURLSetting alloc] init];
    });
    return shareInstance;
}

- (void)setDomainBaseURL:(NSString *)baseUrl
{
    _baseUrl = baseUrl;
}

- (NSString *)baseUrl
{
    if (!_baseUrl) {
        NSString *url = [[TTURLDomainHelper shareInstance] domainFromType:TTURLDomainTypeNormal];
        if (([url rangeOfString:@"http://" options:NSCaseInsensitiveSearch range:NSMakeRange(0, url.length)].length == 0) && [url rangeOfString:@"https://" options:NSCaseInsensitiveSearch range:NSMakeRange(0, url.length)].length == 0) {
            url = [@"http://" stringByAppendingString:url];
        }
        _baseUrl = url;
    }
    return _baseUrl;
}

+ (NSString *)uploadImageURL
{
    return [NSString stringWithFormat:@"%@/wenda/v1/upload/image/", [WDCommonURLSetting baseURL]];
}


@end
