//
//  TTKitchenManager+TTFeedModule.m
//  TTFeedModule
//
//  Created by zhxsheng on 2019/5/15
//

#import <TTBaseLib/NSObject+TTAdditions.h>
#import <TTBaseLib/TTBaseMacro.h>
#import "TTKitchenManager+TTFeedModule.h"
#import <TTGaiaExtension/GAIAEngine+TTBase.h>

NSString * const TTClientImprRecycleEnableKey = @"tt_client_impr_recycle_settings.is_enable";
NSString * const TTImprRecycleTimeCaculateType = @"tt_client_impr_recycle_settings.time_caculate_type";
NSString * const TTClientImprRecycleTimeLimit = @"tt_client_impr_recycle_settings.time_limit_ms";

NSString * const TTFeedLoadMoreWithNewData = @"tt_feed_refresh_settings.load_more_new_data";

NSString * const TTFeedRefreshClearAllEnable = @"tt_feed_refresh_settings.refresh_clear_all_enable";
NSString * const TTFeedRefreshCategoryWhiteList = @"tt_feed_refresh_settings.category_white_list";

NSString * const TTFeedVideoAutoPlayFlag = @"video_auto_play_flag";
NSString * const TTFeedVideoPlayContinueFlag = @"video_play_continue_flag";

NSString * const TTUseFeedStickyProtection = @"feed_sticky_protection.useFeedStickyProtection";

NSString * const TTFeedDecoupleEnabled = @"tt_ios_feed_decouple_enabled";

NSString * const TTTouTiaoQuanTabTips = @"toutiaoquan_tab_tips";

NSString * const kTTKUGCPostThreadInsertEnable = @"tt_insert_post_thread_data";//发布帖子后是否插入数据

NSString * const kTTKUGCFollowAutoRefreshWithNotifyInterval = @"tt_ugc_follow_notify_refresh_interval.refresh_interval_from_notify";//关注频道有红点时满足的刷新时间间隔

NSString * const kTTFeedSaveDatabaseAsync = @"tt_feed_save_database_async"; //feed存数据库过程是否是异步丢到数据库操作队列中
NSString * const TTFeedPreloadThreshold = @"tt_pre_load_more_out_screen_number";

NSString * const kTTFeedRefactorConfig = @"tt_feed_refactor_config";
NSString * const kTTFeedLoadDelayTime = @"tt_core_data_test.feed_load_delay_time";

@implementation TTKitchenManager (TTFeedModule)

TTRegisterKitchenFunction() {
    TTKitchenRegisterBlock(^{
        TTKConfigBOOL(TTClientImprRecycleEnableKey, @"", NO);
        TTKConfigFloat(TTImprRecycleTimeCaculateType, @"", 0);
        TTKConfigFloat(TTClientImprRecycleTimeLimit, @"", 0);
        
        TTKConfigBOOL(TTFeedLoadMoreWithNewData, @"", NO);
        
        TTKConfigBOOL(TTFeedRefreshClearAllEnable, @"", NO);
        TTKConfigString(TTFeedRefreshCategoryWhiteList, @"", @"");
        
        TTKConfigFreezedBOOL(TTUseFeedStickyProtection, @"", YES);
        TTKConfigFreezedDictionary(TTFeedDecoupleEnabled, @"", @{});
        
        TTKConfigFloat(TTTouTiaoQuanTabTips, @"", 0);
        TTKConfigBOOL(kTTKUGCPostThreadInsertEnable, @"帖子发布之后是否需要插入关注推荐微头条",YES);
        TTKConfigFloat(kTTKUGCFollowAutoRefreshWithNotifyInterval, @"关注频道有红点时满足的刷新时间间隔", (1 * 60 * 60));
        
        TTKConfigBOOL(kTTFeedSaveDatabaseAsync, @"feed存数据库过程是否是异步丢到数据库操作队列中", NO);
        
        TTKConfigFloat(TTFeedPreloadThreshold, @"预加载的阈值", 0);
        
        TTKConfigFreezedDictionary(kTTFeedRefactorConfig, @"重构feed过程中使用的Feed配置", @{});
        TTKConfigInt(kTTFeedLoadDelayTime, @"feed加载延迟时间", 0);
    });
}

TTKitchenDidUpdateFunction() {
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"KSSCommonLogicImageTransitionAnimationEnableKey"];
}

@end

