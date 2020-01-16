//
//  FHCookieManager.h
//  Article
//
//  Created by yangning on 2017/5/15.
//
//

#import <Foundation/Foundation.h>
#import <TTLocationManager/TTCookieManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTCookieManager (FHLocationCookieDomain)
+ (void)setLocationCookieDomains:(NSArray<NSString *> *)domains;
@end

NS_ASSUME_NONNULL_END
