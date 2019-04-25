//
//  ExploreCellHelper.h
//  Article
//
//  Created by Chen Hong on 14-9-12.
//
//

#import <Foundation/Foundation.h>
#import "ExploreCellBase.h"
#import "SSThemed.h"
#import "ExploreOrderedData+TTBusiness.h"

/*
 * label_style, group_flags
 * http://wiki.bytedance.com/pages/viewpage.action?pageId=2688146
 */

typedef enum ArticleLabelType {
    ArticleLabelTypeNone        = 0,                   //无
    ArticleLabelTypeTopic       = 1,                   //专题
    ArticleLabelTypeHeadline    = 2,                   //要闻
    ArticleLabelTypePromote     = 3,                   //推广
    ArticleLabelTypeComics      = 4,                   //漫画
    ArticleLabelTypeEssay       = 5,                   //段子
    ArticleLabelTypeGIF         = 6,                   //GIF
    ArticleLabelTypeCity        = 7,                   //地方
    ArticleLabelTypePicture     = 8,                   //美图
    ArticleLabelTypeUnkown      = 100,
}ArticleLabelType;

typedef enum ArticleGroupFlagsType {
    ArticleGroupFlagsTypeAudio         = 1,             //视频
    ArticleGroupFlagsTypeMultiPic      = 2,             //多图
    ArticleGroupFlagsTypeWebViewOpen   = 4,             //使用webview打开文章
    ArticleGroupFlagsTypeGif           = 8              //gif
}ArticleGroupFlagsType;

typedef NS_ENUM(NSUInteger, ExploreCellViewType) {
    ExploreCellViewTypeNotSupport,                   //未支持样式
    ExploreCellViewTypeArticlePureTitle,             //文章 纯title样式
    ExploreCellViewTypeArticleTitleRightPic,         //文章 title + 右图
    ExploreCellViewTypeArticleTitleRightPicLive,     //文章 title + 右图 + 直播cell
    ExploreCellViewTypeArticleTitleLargePic,         //文章 title + 大图
    ExploreCellViewTypeArticleTitleMultiPic,         //文章 title + 多图
    ExploreCellViewTypeArticleTtileLoopPic,          //文章（广告）title + 轮播图
    ExploreCellViewTypeArticleTitlePlayVideo,        //文章 title + 列表直接播放的视频
    ExploreCellViewTypeArticleTitlePlayLiveVideo,        //文章 title + 列表直接播放的直播视频
    ExploreCellViewTypeArticleFullView,
    ExploreCellViewTypeArticle3DFullView,
    ExploreCellViewTypeVideoTabBaseCell,                  //视频频道里的视频 (显示pgc头像、名称，显示评论，更多按钮)
    ExploreCellViewTypeEssayTextPic,                 //段子 文字 + 图片
    ExploreCellViewTypeEssayGif,                     //段子 Gif
    ExploreCellViewTypeCard,                         //卡片
    ExploreCellViewTypeWeb,                          //Web
    ExploreCellViewTypeGallaryGroupPic,              //图片频道多图
    ExploreCellViewTypeGallaryLargePic,              //图片频道大图
    ExploreCellViewTypeLiveStar,                     //明星直播
    ExploreCellViewTypeLiveMatch,                    //比赛直播
    ExploreCellViewTypeLiveVideo,                    //视频直播
    ExploreCellViewTypeLiveSimple,                   //通用直播
    ExploreCellViewTypeStock,                        //股票
    ExploreCellViewTypeVideoTabLiveCell,             //视频频道直播
    ExploreCellViewTypeVideoTabHuoShan,              //视频频道火山直播
    ExploreCellViewTypeArticleTitleLargePicHuoShan,  //Feed频道火山直播
    ExploreCellViewTypeMeiNvHuoShan,                 //美女频道火山直播
    ExploreCellViewTypeLianZai,                      //连载类型
    ExploreCellViewTypeLastRead,                     //上次看到这
    ExploreCellViewTypeRN,                           //ReactNative
    ExploreCellViewTypeAddToFirstPageCell,           //添加到首屏的cell
    ExploreCellViewTypeCollectionBookCell,           //卡片内推多本小说cell
    ExploreCellViewTypeCardRecommendUser,            //u11 c7推荐人
    ExploreCellViewTypeCardRecommendUserCardCell,    //和关注频道一起上线的推人卡片
    ExploreCellViewTypeHorizontalCard,               //水平卡片
    ExploreCellViewTypeShortVideoCell,                 //抖音cell
    ExploreCellViewTypeWenDaLayOutCell,              //u11问答cell,关注的问题有了新回答
    ExploreCellViewTypeResurface,                    //换肤引导Cell
    ExploreCellViewTypeRecommendUserLargeCardCell,   //列表猛烈推人卡片
    ExploreCellViewTypeRecommendRedPacketCell,       //猛烈推人，红包卡片二期
    ExploreCellViewTypeMomentsRecommendUserCell,     //好友动态推人卡片
    ExploreCellViewTypeDynamicRN,                    //动态数据ReactNative cell
    ExploreCellViewTypeEssayADTypeCell,              //段子页同类似导流cell
    ExploreCellViewTypeFantasyCardCell,              //Fantasy活动入口cell
    ExploreCellViewTypeHashtagRightPicCell,          //hash tag右图cell
    ExploreCellViewTypeXiguaHorizontalCell,          //水平双卡
    ExploreCellViewTypeXiguaRecommendCell,
    ExploreCellViewTypeXiguaLargePicCell,            //西瓜大图直播cell
    ExploreCellViewTypeSurveyListCell,               //调研卡片List样式cell
    ExploreCellViewTypeSurveyPairCell,               //调研卡片Pair样式cell
    ExploreCellViewTypeRecommendUserStoryCardCell,   //列表推荐用户Story卡片
    ExploreCellViewTypeRecommendStoryCoverCardCell,  //列表推荐用户内容封面Story卡片
    ExploreCellViewTypePopularHashtagCell,           //热门话题
    ExploreCellViewTypeTSVStoryCell,                 //小视频story cell
    ExploreCellViewTypeHotNews,                      //置顶热点新闻cell
    ExploreCellViewTypeArticleHotNews,                 //置顶热点新闻卡片cell
    ExploreCellViewTypeLoadmoreTipCell,              // Loadmore加载提示信息
    ExploreCellViewTypeHomeHeaderTableViewCell,      // 首页推荐频道头部cell
    ExploreCellViewTypeFHHouseItemCell,              // 房源卡片

};

@interface ExploreCellHelper : NSObject

@property(nonatomic,assign,readonly) NSTimeInterval midInterval;

+ (instancetype)sharedInstance;

+ (void)registerCellBridge;

+ (void)registerAllCellClassWithTableView:(UITableView *)tableView;
+ (ExploreCellBase *)dequeueTableCellForData:(id)data tableView:(UITableView *)view atIndexPath:(NSIndexPath *)indexPath refer:(NSUInteger)refer;
+ (ExploreCellViewBase *)dequeueTableCellViewForData:(id)data;
+ (void)recycleCellView:(ExploreCellViewBase *)cellView;
+ (void)refreshFontSizeForRecycleCardViews;
+ (NSString *)identifierForData:(id)data;

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType;

+ (BOOL)shouldDisplayAbstract:(Article*)article listType:(ExploreOrderedDataListType)listType;
+ (BOOL)shouldDisplayComment:(Article*)article listType:(ExploreOrderedDataListType)listType;
+ (CGSize)updateAbstractSize:(Article*)article cellWidth:(CGFloat)cellWidth;
+ (CGSize)updateCommentSize:(NSString*)commentContent cellWidth:(CGFloat)cellWidth;

+ (CGFloat)heightForImageWidth:(CGFloat)width height:(CGFloat)height constraintWidth:(CGFloat)cWidth;
+ (CGFloat)heightForLoopImageWidth:(CGFloat)width height:(CGFloat)height constraintWidth:(CGFloat)cWidth;
+ (float)heightForVideoImageWidth:(float)width height:(float)height constraintWidth:(float)cWidth;

+ (CGFloat)largeImageWidth:(CGFloat)cellWidth;

// 组图cell在>=iPhone6上图的大小可变
+ (CGSize)resizablePicSizeByWidth:(CGFloat)width;

//评论列表话题帖子图片大小
+ (CGSize)commentMomentCellPicSize;
// 单张图片大小
+ (CGSize)singlePicSize;
// 右图cell不感兴趣按钮与右图的间隔调整
+ (CGFloat)paddingBetweenInfoBarAndPic;

// 更新当前0点timeInterval
+ (void)refreshMidnightInterval;

+ (void)layoutTypeLabel:(UILabel *)typeLabel
        withOrderedData:(ExploreOrderedData *)orderedData;

+ (void)colorTypeLabel:(UILabel *)typeLabel orderedData:(id)orderedData;

// 是否自动下载图片
+ (BOOL)shouldDownloadImage;

// 短内容cell是否显示底部按钮栏
+ (BOOL)shouldShowEssayActionButtons:(NSString *)categoryID;

// 视频频道顶踩全局控制
+ (BOOL)isShowListDig;
+ (void)setShowListDig:(NSInteger)bShow;

/**
 *  用户是否在高级调试中手动设置过Feed UGC样式开关
 *
 *  @return
 */
+ (BOOL)userDidSetFeedUGCTest;

/**
 *  获取Feed UGC值
 *
 *  @return
 */
+ (BOOL)getFeedUGCTest;

/**
 *  设置FeedUCGTest
 *
 *  @param abTest
 */
+ (void)setFeedUGCTest:(BOOL)abTest;

/**
 *  获取NSUserDefaults中的ExploreArticleCellViewSourceImgTest
 *
 *  @return Yes or No
 */
+ (BOOL)getSourceImgTest;

/**
 *  设置ExploreArticleCellViewSourceImgTest值
 *
 *  @param abTest
 */
+ (void)setSourceImgTest:(BOOL)abTest;

/**
 * 根据类型返回Cell Type
*/
+ (Class)cellClassFromCellViewType:(ExploreCellViewType)cellViewType data:(id)data;

/**
 * 根据配置数据计算头部高度
 */
+ (CGFloat)heightForFHHomeHeaderCellViewType;
@end
