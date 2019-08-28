//
//  TTKitchenManager+TTFeedModule.h
//  TTFeedModule
//
//  Created by zhxsheng on 2019/5/15.
//

#import <TTKitchen/TTKitchen.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString * const TTClientImprRecycleEnableKey;
extern NSString * const TTImprRecycleTimeCaculateType;
extern NSString * const TTClientImprRecycleTimeLimit;

extern NSString * const TTFeedLoadMoreWithNewData;

extern NSString * const TTFeedRefreshClearAllEnable;
extern NSString * const TTFeedRefreshCategoryWhiteList;

extern NSString * const TTFeedVideoAutoPlayFlag;
extern NSString * const TTFeedVideoPlayContinueFlag;

extern NSString * const TTUseFeedStickyProtection;
extern NSString * const TTFeedDecoupleEnabled;
extern NSString * const TTTouTiaoQuanTabTips;

extern NSString * const kTTKUGCPostThreadInsertEnable;
extern NSString * const kTTKUGCFollowAutoRefreshWithNotifyInterval;

extern NSString * const kTTFeedSaveDatabaseAsync;
extern NSString * const TTFeedPreloadThreshold;

extern NSString * const kTTFeedRefactorConfig;
extern NSString * const kTTFeedLoadDelayTime;

@interface TTKitchenManager (TTFeedModule)

@end

NS_ASSUME_NONNULL_END
