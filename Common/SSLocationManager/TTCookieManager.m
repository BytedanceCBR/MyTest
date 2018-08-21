//
//  TTCookieManager.m
//  Article
//
//  Created by yangning on 2017/5/15.
//
//

#import "TTCookieManager.h"
#import "TTLocationManager.h"
#import "NSString+URLEncoding.h"

static NSString *const kLocationCookieKey = @"toutiaocity";

@implementation TTCookieManager

+ (instancetype)sharedManager
{
    static TTCookieManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[TTCookieManager alloc] init];
    });
    return _sharedInstance;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveCityChangedNotification:)
                                                     name:TTLocationManagerCityDidChangedNotification
                                                   object:nil];
    }
    return self;
}

- (void)updateLocationCookie
{
    NSArray *domains =  [self locationCookieDomains];
    NSString *cityInfo = [self cityInfo];
    if (!cityInfo) {
        [self deleteLocationCookie];
        return;
    }
    
    for (NSString *domain in domains) {
        [self setCityToCookie:cityInfo forDomain:domain];
    }
}

- (NSString *)locationFromCookie
{
    for(NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if([cookie.name isEqualToString:@"toutiaocity"]) {
            return cookie.value;
        }
    }
    
    return nil;
}

- (void)deleteLocationCookie
{
    NSArray *domains = [self locationCookieDomains];
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookies){
        for (NSString *domain in domains) {
            if ([cookie.domain isEqualToString:domain] && [cookie.name isEqualToString:kLocationCookieKey]) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }
        }
    }
}

- (NSArray<NSString *> *)locationCookieDomains
{
    return [TTCookieManager locationCookieDomains];
}

- (NSString *)cityInfo
{
    if (isEmptyString([TTLocationManager sharedManager].province) || isEmptyString([TTLocationManager sharedManager].city)) {
        return nil;
    }
    return [[NSString stringWithFormat:@"%@,%@", [TTLocationManager sharedManager].province, [TTLocationManager sharedManager].city] URLEncodedString];
}

- (void)setCityToCookie:(NSString *)city forDomain:(NSString *)domain
{
    if (isEmptyString(city) || isEmptyString(domain)) {
        return;
    }
    
    NSMutableDictionary *cookieProperty = [NSMutableDictionary dictionary];
    [cookieProperty setObject:domain forKey:NSHTTPCookieDomain];
    [cookieProperty setObject:kLocationCookieKey forKey:NSHTTPCookieName];
    [cookieProperty setObject:city forKey:NSHTTPCookieValue];
    [cookieProperty setObject:@"/" forKey:NSHTTPCookiePath];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperty];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}

- (void)didReceiveCityChangedNotification:(NSNotification *)notification
{
    [self updateLocationCookie];
}

@end

static NSString *const kLocationCookieDomainsKey = @"tt_third_party_url_white_list";

@implementation TTCookieManager (LocationCookieDomain)

+ (NSArray<NSString *> *)locationCookieDomains
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLocationCookieDomainsKey];
}

+ (void)setLocationCookieDomains:(NSArray<NSString *> *)domains
{
    if ([[self locationCookieDomains] isEqualToArray:domains]) {
        return;
    }
    
    [[TTCookieManager sharedManager] deleteLocationCookie];
    if (domains.count == 0) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLocationCookieDomainsKey];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:domains forKey:kLocationCookieDomainsKey];
        [[TTCookieManager sharedManager] updateLocationCookie];
    }
}
@end
