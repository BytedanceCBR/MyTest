//
//  ExploreLogicSetting.h
//  Article
//
//  Created by Zhang Leonardo on 14-9-18.
//
//

#import <Foundation/Foundation.h>


/**
 *  推荐列表发送给api 的字段，统一为__all__
 */
#define kMainCategoryAPINameKey    @"__all__"

//删除了数据库cache的notification
#define kExploreClearedCoreDataCacheNotification @"kExploreClearedCoreDataCacheNotification"

#define kWillClearCacheNotification             @"kWillClearCacheNotification"
#define kClearCacheFinishedNotification         @"kClearCacheFinishedNotification"
#define kReadModeChangeNotification             @"kReadModeChangeNotification"
#define kImageDisplayModeChangedNotification    @"kImageDisplayModeChangedNotification"
#define kClearFavoritesFinishedNotification     @"kClearFavoritesFinishedNotification"


#define kMomentDidDeleteNotification @"kMomentDidDeleteNotification" //动态被删除通知
#define kDeleteArticleNotification  @"kDeleteArticleNotification" //删除article
#define kPadFlipUpdateViewRemainKey @"kPadFilpProfileUpdateViewRemainKey"//动态
#define kPadFlipUserUpdateViewRemainKey @"kPadFilpProfileUserUpdateViewRemainKey"//消息、用户动态
#define kPadFlipProfileRelationViewRemainKey @"kPadFlipProfileRelationViewRemainKey"
#define kPadFlipInviteFriendViewKey    @"kPadFlipInviteFriendViewKey" //告诉朋友

// tabbar style，当前显示列表页的时候，再次点击列表tab
extern NSString *const kMainTabbarClickedNotificationUserInfoHasTipKey;
extern NSString *const kMainTabbarClickedNotificationUserInfoShowFriendLabelKey;
extern NSString *const kMainTabbarKeepClickedNotification;
extern NSString *const kMomentTabbarKeepClickedNotification;
extern NSString *const kMineTabbarKeepClickedNotification;
extern NSString *const kVideoTabbarKeepClickedNotification;
extern NSString *const kPhotoTabbarKeepClickedNotification;
extern NSString *const kWeitoutiaoTabbarClickedNotification;
extern NSString *const kTSVTabbarContinuousClickNotification;
extern NSString *const kHTSTabbarClickedNotification;

extern NSString *const kCategoryManagementViewCategorySelectedNotification;
extern NSString *const kCategoryManagerViewWillHideNotification;
extern NSString *const kChangeExploreTabBarBadgeNumberNotification;
extern NSString *const kExploreTabBarItemIndentifierKey;
extern NSString *const kExploreTabBarBadgeNumberKey;
extern NSString *const kExploreTabBarDisplayRedPointKey;

extern NSString *const kExploreTabBarClickNotification;
extern NSString *const kExploreTopVCChangeNotification;

extern NSString *const kExploreMixedListRefreshTypeNotification;

typedef NS_ENUM(NSUInteger, ExploreMixedListRefreshType)
{
    ExploreMixedListRefreshTypeDefault = 0,
    ExploreMixedListRefreshTypeUserPull = 1,
    ExploreMixedListRefreshTypeClickHome = 2,
    ExploreMixedListRefreshTypeClickLastRead = 3,
    ExploreMixedListRefreshTypeClickChannel = 4,
    ExploreMixedListRefreshTypeAutoRefresh = 5,
    ExploreMixedListRefreshTypeBack = 6
};


/**
 *  是否是因为分享内容到社交频道而跳转的
 */

extern BOOL isShareToPlatformEnterBackground;


@interface ExploreLogicSetting : NSObject

/**
 *  删除指定的OrderedData
 *
 *  @param array ExploreOrderedData 的数组
 *  @param save  是否保存
 */
+ (void)removeOrderedDatas:(NSArray *)array save:(BOOL)save;

/**
 *  删除本地频道数据
 *
 *  @param save 是否保存
 */
+ (void)clearDBNewsLocalDataSave:(BOOL)save;

/**
 *  累计总的缓存
 */
+ (void)addUpCacheSizeWithImage:(BOOL)imageSize http:(BOOL)httpSize coreData:(BOOL)coreDataSize wendaDraft:(BOOL)wendaDraft shortVideo:(BOOL)shortVideoSize completion:(void(^)(NSInteger))completionBlock;

/**
 *  清除所有数据, 有时间开销
 */
+ (void)clearCache;

/**
 *  尝试删除Core data文件
 */
+ (void)tryClearCoreDataCache;


/**
 *  删除临时视频和音频文件
 */
+ (void)clearTempVideoAudioFileCache;

+ (float)cacheSizeWithTempVideoAudioFile;


/**
 *  删除数据库
 */
+ (void)clearCoreDataCache;

/**
 *  删除收藏数据
 */
+ (void)clearFavoriteCoreData;

/**
 *  删除阅读历史数据
 */
+ (void)clearReadHistoryCoreData;
/**
 *  删除推送历史数据
 */
+ (void)clearPushHistoryCoreData;
/**
 *  判断是否是升级用户
 *
 *  @return YES：升级用户； NO：非升级用户
 */
+ (BOOL)isUpgradeUser;

/**
 *  存数是否是升级用户
 *
 *  @param upgrade YES：升级用户； NO：非升级用户
 */
+ (void)setIsUpgradeUser:(BOOL)upgrade;


/**
 *  是否需要清空数据库
 *
 *  @return YES：清空； NO：不清空
 */
+ (BOOL)isNeedCleanOldCache;

@end
