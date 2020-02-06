//  FHRNCacheManager.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/4/19.
//

#import <Foundation/Foundation.h>
#import "TTRoute.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHRNHelper : NSObject

@property(nonatomic,strong)NSMutableDictionary *channelCache;
@property(nonatomic,strong)NSMutableDictionary *rnPreloadCache;


+(instancetype)sharedInstance;

- (void)addObjectCountforChannel:(NSString *)channel;

- (void)removeCountChannel:(NSString *)channel;

- (BOOL)isNeedCleanCacheForChannel:(NSString *)channel;

//打开经纪人详情请页
+ (void)openRealtorModule:(NSString *)realtorId andReportParams:(NSDictionary *)reportParams andImPrams:(NSDictionary *)imParams;

//Gecko Channels
+ (NSArray *)fhGeckoChannels;
//预加载的渠道
+ (NSArray *)fhRNPreLoadChannels;
//可用的渠道
+ (NSArray *)fhRNEnableChannels;

//开始缓存RN对象
- (void)addCacheViewOpenUrl:(NSString *)url andCacheKey:(NSInteger)cacheKey;

//开始缓存RN对象
- (void)addCacheViewOpenUrl:(NSString *)url andUserInfo:(TTRouteUserInfo *)userInfo andCacheKey:(NSInteger)cacheKey;

//获取缓存RN对象
- (TTRouteObject *)getRNCacheForCacheKey:(NSInteger)cacheKey;

//清理某个缓存RN对象的资源
- (void)clearCacheForCacheKey:(NSInteger)cacheKey;

@end

NS_ASSUME_NONNULL_END
