//
//  ArticleInfoManager.h
//  Article
//
//  Created by Zhang Leonardo on 13-5-6.
//
//
//  详情页获取非静态内容的类(目前只获取js需要的context，和comments).

#import <Foundation/Foundation.h>
#import "Article.h"
#import "TTAdDetailViewDefine.h"

#define kArticleInfoManagerConditionGroupModelKey       @"kArticleInfoManagerConditionGroupModelKey"   //value type is NSString/NSNumber
#define kArticleInfoManagerConditionFlagKey             @"kArticleInfoManagerConditionFlagKey"      //value type is NSNumber(int)
#define kArticleInfoManagerConditionTopCommentIDKey     @"kArticleInfoManagerConditionTopCommentIDKey"
#define kArticleInfoManagerConditionCategoryIDKey       @"kArticleInfoManagerConditionCategoryIDKey"

#define kDetailNatantTagsKey           @"kDetailNatantTags"
#define kDetailNatantAdsKey            @"kDetailNatantAdsKey"
#define kDetailNatantLikeAndReWardsKey @"kDetailNatantLikeAndReWards"
#define kDetailNatantRelatedKey        @"kDetailNatantRelated"
#define kDetailNatantRiskWarning       @"kDetailRiskWarning"
#define kDetailNatantAdminDebug        @"kDetailNatantAdminDebug"

@class TTActivityModel;
@class FRActivityStructModel;

/**
 *  详情页设置,按位判断
 */
typedef NS_ENUM(NSUInteger, ArticleInfoManagerFlags)
{
    /**
     *  默认
     */
    ArticleInfoManagerFlagsNone = 0,
    /**
     *  相关新闻展示图片, 4.4 废弃
     */
    ArticleInfoManagerFlagsShowRelateReadImg = 1,
};

typedef NS_ENUM(NSUInteger, ArticleLikeAndShareFlags)
{
    ArticleShowLike         = 0x1<<0,
    ArticleShowWeixin       = 0x1<<1,
    ArticleShowWeixinMoment = 0x1<<2,
};


@protocol ArticleInfoManagerDelegate;
@class TTDetailModel;

@interface ArticleInfoManager : NSObject <TTAdNatantDataModel>

typedef void(^TTArticleDetailFetchInformationBlock)(ArticleInfoManager *infoManager,
                                                    NSError *error);

@property(nonatomic, weak)id<ArticleInfoManagerDelegate>delegate;

@property(nonatomic, strong) TTDetailModel * detailModel;
/// 统计进入详情页之后进行的页面跳转
@property(nonatomic, copy, readonly) NSString *webViewTrackKey;

/**
 *  按位判断
 *  0x0001: 相关新闻展示图片
 */
@property(nonatomic, retain, readonly)NSNumber * flags;
/**
 *  关键字的keyword
 */
@property(nonatomic, retain, readonly)NSArray * keywordJsons;

/**
 *  文章详情页插入的js脚本
 */
@property(nonatomic, copy, readonly) NSString *insertedJavaScript;
/**
 *  文章详情页插入的context js脚本
 */
@property(nonatomic, copy, readonly) NSString *insertedContextJS;
/**
 *  荐股类文章的风险提示
 */
@property(nonatomic, copy, readonly)NSString * riskWarningTip;

/**
 *  相关视频的article array (包括相关视频，视频专题，视频合辑，视频广告等)
 */
@property(nonatomic, retain, readonly)NSArray * relateVideoArticles;

/**
 *  视频详情页可自定义跳转的入口
 */
@property(nonatomic, strong, readonly)NSDictionary *videoExtendLink;

/**
 *  视频广告落地页 (add 5.4)
 */
@property (nonatomic, copy, readonly) NSString *videoAdUrl;

/**
 *  视频banner (add 5.5)
 */
@property (nonatomic, strong, readonly) NSDictionary *videoBanner;

/**
 *  视频详情页内嵌banner广告 (add 5.6)
 */
@property (nonatomic, strong, readonly) NSDictionary *videoEmbededAdInfo;

/**
 *  相关图集的article array
 */
@property(nonatomic, retain, readonly)NSArray * relateImagesArticles;
/**
 *  问答列表
 */
@property(nonatomic, retain, readonly)NSArray * wendaArray;
/**
 *  视频详情页相关视频分页首页展示视频数
 */
@property(nonatomic, retain, readonly)NSNumber *relateVideoSection;

/**
 *  相关频道入口 json
 */
@property(nonatomic, retain, readonly)NSDictionary * relateEnterJson;

/**
 *  详情页广告Json
 */
@property(nonatomic, retain, readonly)NSDictionary * detailADJsonDict;
/**
 *  原textLink广告，现解耦到管理链接
 */
@property(nonatomic, retain, readonly)NSDictionary * adminDebugInfo;
/**
 *  pgc xxx人收藏入口文案
 */
@property(nonatomic, retain, readonly)NSString * pgcActionEnterTitleStr;
/**
 *  导流视频
 */
@property(nonatomic, retain, readonly)NSDictionary * corperationVideoDict;
/**
 *  讨论区入口
 */
@property(nonatomic, retain, readonly)NSDictionary * forumLinkJson;
/**
 *  web的 相关图集
 */
@property(nonatomic, retain, readonly)NSArray * webRecommandPhotosArray;
/**
 *  视频摘要
 */
@property(nonatomic, copy, readonly)NSString *videoAbstract;

@property(nonatomic, retain, readonly)NSMutableDictionary * ordered_info;

@property(nonatomic, retain, readwrite)NSMutableDictionary *video_detail_tags;

@property(nonatomic, retain, readonly)NSMutableArray * classNameList;

@property(nonatomic, readonly) NSNumber *articlePosition;
/**
 *  文章喜欢和直接分享按钮控制位
 */
@property(nonatomic, assign, readonly)ArticleLikeAndShareFlags likeAndShareFlag;

@property (nonatomic, strong) NSArray *dislikeWords;

/**
 * 开屏广告附加的 分享信息
 */
@property (nonatomic, strong, readonly) NSDictionary *adShareInfo;
/**
 * 文章详情页 号外入口
 */
@property (nonatomic, strong, readonly) TTActivityModel *promotionModel;
/**
 *  相关图集的搜索词
 */
@property(nonatomic, strong, readonly) NSArray *relateSearchWordsArray;


@property (nonatomic, strong, readonly) FRActivityStructModel *activity;

@property(nonatomic, strong, readonly) NSDictionary *logPb;

@property (nonatomic, copy) NSString* ug_install_aid;

- (void)startFetchArticleInfo:(NSDictionary *)condition;
- (void)startFetchArticleInfo:(NSDictionary *)condition
                  finishBlock:(TTArticleDetailFetchInformationBlock)finishBlock;
- (void)cancelAllRequest;

/**
 *  是否应该显示导流视频
 *
 *  @return YES:显示
 */
- (BOOL)needShowCorperationVideoView;
- (BOOL)needShowAdShare;
- (NSMutableDictionary *)makeADShareInfo;
- (id)adNatantDataModel:(NSString *)key4Data;

@end

@protocol ArticleInfoManagerDelegate <NSObject>

@optional
- (void)articleInfoManagerLoadDataFinished:(ArticleInfoManager *)manager;
- (void)articleInfoManager:(ArticleInfoManager *)manager getStatus:(NSDictionary *)dict;
- (void)articleInfoManager:(ArticleInfoManager *)manager fetchedJSContext:(NSString *)jsContext;
- (void)articleInfoManager:(ArticleInfoManager *)manager scriptString:(NSString *)scp;
- (void)articleInfoManagerFetchInfoFailed:(ArticleInfoManager *)manager;

@end
