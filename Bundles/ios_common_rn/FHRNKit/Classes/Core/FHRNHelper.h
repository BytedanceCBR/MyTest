//  FHRNCacheManager.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/4/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHRNHelper : NSObject

@property(nonatomic,strong)NSMutableDictionary *channelCache;

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
@end

NS_ASSUME_NONNULL_END
