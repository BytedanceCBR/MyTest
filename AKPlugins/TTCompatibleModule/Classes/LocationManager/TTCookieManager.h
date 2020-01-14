//
//  TTCookieManager.h
//  Article
//
//  Created by yangning on 2017/5/15.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTCookieManager : NSObject

+ (instancetype)sharedManager;

- (void)updateLocationCookie;
- (nullable NSString *)locationFromCookie;
- (void)deleteLocationCookie;



@end

@interface TTCookieManager (LocationCookieDomain)
+ (NSArray<NSString *> *)locationCookieDomains;
+ (void)setLocationCookieDomains:(NSArray<NSString *> *)domains;
@end

NS_ASSUME_NONNULL_END
