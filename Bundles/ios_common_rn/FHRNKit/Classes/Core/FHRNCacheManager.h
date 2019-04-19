//
//  FHRNCacheManager.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/4/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHRNCacheManager : NSObject

@property(nonatomic,strong)NSMutableDictionary *channelCache;

+(instancetype)sharedInstance;

- (void)addObjectCountforChannel:(NSString *)channel;

- (void)removeCountChannel:(NSString *)channel;

- (BOOL)isNeedCleanCacheForChannel:(NSString *)channel;

@end

NS_ASSUME_NONNULL_END
