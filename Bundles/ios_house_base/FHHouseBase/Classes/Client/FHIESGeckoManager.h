//
//  FHIESGeckoManager.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/3/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHIESGeckoManager : NSObject

+ (void)configGeckoInfo;

+ (void)configIESWebFalcon;

+ (BOOL)isHasCacheForChannel:(NSString *)channel;

+ (NSString *)getGeckoKey;
@end

NS_ASSUME_NONNULL_END
