//
//  TTDetailModel.h
//  Article
//
//  Created by Ray on 16/3/31.
//
//

#import <Foundation/Foundation.h>
#import "ExploreDetailManager.h"
#import "ArticleDetailHeader.h"
#import "TTVArticleExtraInfo.h"
#import "TTVideoShareMovie.h"
#import "NewsDetailConstant.h"

@class ExploreOrderedData;
@class Article;
NS_ASSUME_NONNULL_BEGIN
@interface TTDetailModel : NSObject
/**
 * orderedData
 */
@property (nonatomic, strong, nullable) ExploreOrderedData * orderedData;
@property (nonatomic, strong, nullable) TTVArticleExtraInfo *articleExtraInfo;
/**
 * article
 */
@property (nonatomic, retain, nullable) Article * article;
@property (nonatomic, strong, nullable) Article * paidArticle; //付费内容的Article, 通常不会序列化,每次进去重新获取
@property (nonatomic, copy) ExploreDetailManager *(^detailManagerCustomBlock)(BOOL *shouldRetrun);
@property (nonatomic, strong, readonly) ExploreDetailManager * _Nullable detailManager;

@property (nonatomic, strong, nullable) TTVideoShareMovie *shareMovie;

/**
 *  adOpenUrl
 */
@property (nonatomic, copy, nullable)   NSString *adOpenUrl;
/**
 *  paramDicts
 */
@property (nonatomic, copy, nullable)   NSString * adLogExtra;
/**
 *  gdLabel
 */
@property (nonatomic, copy, nullable)   NSString * gdLabel;
/**
 *  adID
 */
@property (nonatomic, strong, nullable) NSNumber * adID;

/**
 msg 消息id 从消息页面跳转进来带上
 */
@property (nonatomic, copy, nullable) NSString *msgID;
/**
 *  relateReadFromGID
 */
@property (nonatomic, strong, nullable) NSNumber * relateReadFromGID;
/**
 *  statParams
 */
@property (nonatomic, strong,nullable)  NSDictionary *statParams;
/**
 *  gdExtJsonDict 对应字段gd_ext_json
 */
@property (nonatomic, strong, nullable) NSDictionary *gdExtJsonDict;

/**
 *  originalSchema 打开的原始schema
 */
@property (nonatomic, strong, nullable) NSString * originalSchema;
/*
 *  进入详情页的频道的categoryID，如__all__
 */
@property (nonatomic, copy, nullable) NSString* categoryID;
/*
 *  进入详情页的click来源，对应字段enter_from，如click_headline
 */
@property (nonatomic, copy, nullable) NSString *clickLabel;

@property(nonatomic, assign)NewsGoDetailFromSource fromSource;

@property (nonatomic, strong, nullable) NSDictionary *logPb;

@property (nonatomic, assign) BOOL isArticleReliable;

@property (nonatomic, assign) BOOL ttDragToRoot; //快速退出. 只有视频在用
@property (nonatomic, assign) BOOL needQuickExit;//是否快速需要快速推出
@property(nonatomic, assign)BOOL isFloatVideoController;

@property (nonatomic, copy, nullable) NSString *dongtaiID; //从动态点进ugc视频详情页时使用
@property (nonatomic, assign)BOOL transitionAnimated; //是否使用动画进入

@property (nonatomic, strong) NSNumber *originalStatusBarHiddenNumber;
@property (nonatomic, strong) NSNumber *originalStatusBarStyleNumber;
//透传到具体详情页
@property (nonatomic,strong) NSDictionary *baseCondition;

@property (nonatomic, copy, nullable) NSString *originalGroupID;
@property (nonatomic, copy, nullable) NSString *rid;

//爱看检测是否需要弹出阅读金币
@property (nonatomic, assign) BOOL needCheckReadBonus;
@property (nonatomic, assign) BOOL readComplete;//阅读完毕
@property (nonatomic, strong, nullable) dispatch_source_t readBonusTimer;
@property (nonatomic, assign) BOOL timmerIsRunning;

- (nullable ExploreDetailManager *)sharedDetailManager;

- (void)sendDetailTrackEventWithTag:(nullable NSString *)tag label:(nullable NSString *)label;

- (void)sendDetailTrackEventWithTag:(nullable NSString *)tag label:(nullable NSString *)label extra:(nullable NSDictionary *)extra;

- (BOOL)isFromList;

- (NSString *)uniqueID;

- (BOOL)tt_isArticleReliable;


/**
如果有付费Article,则优先取之
 
 @return 合适的Article
 */
- (Article *)fitArticle;
@end
NS_ASSUME_NONNULL_END
