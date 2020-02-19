//
//  FHCookieManager.m
//  Article
//
//  Created by yangning on 2017/5/15.
//
//

#import "FHCookieManager.h"
#import "TTLocationManager.h"
#import "NSString+URLEncoding.h"
#import "TTBaseMacro.h"

static NSString *const kLocationCookieDomainsKey = @"tt_third_party_url_white_list";

@implementation TTCookieManager (FHLocationCookieDomain)

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
