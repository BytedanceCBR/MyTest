//
//  ExploreMixListDefine.h
//  Article
//
//  Created by Zhang Leonardo on 14-9-14.
//
//

#ifndef ExploreMixListDefine_h
#define ExploreMixListDefine_h

//item 删除 notification
#define kExploreMixListItemDeleteNotification @"kExploreMixListItemDeleteNotification"
//传ordered data
#define kExploreMixListDeleteItemKey @"kExploreMixListDeleteItemKey"
//刚刚在文章发表了带推荐给粉丝的评论
#define kTTPublishCommentSuccessWithZZNotification  @"kTTPublishCommentSuccessWithZZNotification"
//删除了推荐给粉丝的评论
#define kTTDeleteZZCommentNotification              @"kTTDeleteZZCommentNotification"

//需要刷新某个Cell
#define kTTRefreshCellNotification              @"kTTRefreshCellNotification"
#define kTTRefreshItemKey                       @"kTTRefreshItemKey"

/**
 *  不感兴趣notification
 */
#define kExploreMixListNotInterestNotification @"kExploreMixListNotInterestNotification"

/**
 *  不感兴趣key；持久化的item传ExploreOrderedData
 */
#define kExploreMixListNotInterestItemKey @"kExploreMixListNotInterestItemKey"
/**
 *  不感兴趣的orderData的频道名称categoryID
 */
#define kExploreMixListCategoryIDOfNotInterestItemKey @"kExploreMixListCategoryIDOfNotInterestItemKey"
/**
 *  不感兴趣的orderData的关心列表频道名称concernID
 */
#define kExploreMixListConcernIDOfNotInterestItemKey @"kExploreMixListConcernIDOfNotInterestItemKey"

/**
 *  不感兴趣是否需要向服务端发送请求，目前只有详情页的dislike不发送请求
 */
#define kExploreMixListShouldSendDislikeKey @"kExploreMixListShouldSendDislikeKey"
/**
 *  不感兴趣key；WebCell
 */
#define kExploreMixListDislikeWebCellNotification @"kExploreMixListDislikeWebCellNotification"

/**
 *  关闭WebCell
 */
#define kExploreMixListCloseWebCellNotification @"kExploreMixListCloseWebCellNotification"

/**
 *  显示不感兴趣菜单
 */
#define kExploreMixListShowDislikeNotification @"kExploreMixListShowDislikeNotification"

/**
 *  不感兴趣filterWords
 */
#define kExploreMixListNotInterestWordsKey @"kExploreMixListNotInterestWordsKey"

#define kExploreMixListNotDisplayTipKey @"kExploreMixListNotDisplayTipKey"


///...
/**
 *  实时下架下拉刷新广告
 */
#define kExploreMixListRefreshADItemDeleteNotification @"kExploreMixListRefreshADItemDeleteNotification"
#define kExploreMixListDeleteRefreshADItemsKey @"kExploreMixListDeleteRefreshADItemsKey"

#endif
