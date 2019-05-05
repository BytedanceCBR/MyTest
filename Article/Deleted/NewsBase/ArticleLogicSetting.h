//
//  ArticleLogicSetting.h
//  Article
//
//  Created by Hu Dianwei on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommonURLSetting.h"
#import "ListDataHeader.h"
#import "UIScreen+Addition.h"

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




DEPRECATED_MSG_ATTRIBUTE("废弃")
@interface ArticleLogicSetting : NSObject {
@private
}



+ (float)cacheSize;
+ (void)tryClearCache:(BOOL)force;
+ (void)clearCache;
+ (void)clearAllListData;
+ (void)clearNewsLocalData __deprecated_msg("废弃");     // 切换城市之后删除上一城市的news_local分类数据
+ (void)clearFavoriteData;
+ (BOOL)needClearCoreData;
+ (void)setNeedClearCoreData:(BOOL)need;
@end