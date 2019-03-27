//
//  FHIESGeckoManager.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/3/19.
//

#import <Foundation/Foundation.h>

#if DEBUG
static NSString * const kFHIESGeckoKey = @"adc27f2b35fb3337a4cb1ea86d05db7a";
#else
static NSString * const kFHIESGeckoKey = @"7838c7618ea608a0f8ad6b04255b97b9";
#endif

NS_ASSUME_NONNULL_BEGIN

@interface FHIESGeckoManager : NSObject

+ (void)configGeckoInfo;

+ (void)configIESWebFalcon;

@end

NS_ASSUME_NONNULL_END
