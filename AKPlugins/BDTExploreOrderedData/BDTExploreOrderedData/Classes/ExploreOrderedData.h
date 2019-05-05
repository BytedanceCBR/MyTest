//
//  ExploreOrderedData.h
//  Article
//
//  Created by Hu Dianwei on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTEntityBase.h"
#import "Article.h"
#import "TTCategoryDefine.h"
#import "ExploreOrderedData_Enums.h"

//虚拟出来的ID，用于收藏列表
#define kExploreFavoriteListIDKey      @"_favorite"
//虚拟出来的ID，用于搜索列表
#define kExploreSearchListIDKey        @"_search"
//视频列表
#define kExploreVideoListIDKey        @"video"
//cursor
#define kExploreOrderedDataCursorKey    @"cursor"

typedef NS_OPTIONS(NSUInteger, ExploreOrderedDataFromOption) {
    ExploreOrderedDataFromOptionPullDown  = 1 << 0,
    ExploreOrderedDataFromOptionPullUp    = 1 << 1,
    ExploreOrderedDataFromOptionMemory    = 1 << 2,
    ExploreOrderedDataFromOptionFile      = 1 << 3
};

typedef NS_ENUM(NSInteger, ExploreOrderedDataVideoStyle)
{
    ExploreOrderedDataVideoStyle0 = 0,   // 不可播放，小图
    ExploreOrderedDataVideoStyle1 = 1,   // 不可播放，大图
    ExploreOrderedDataVideoStyle2 = 2,   // 可播放，大图，主Feed样式
    ExploreOrderedDataVideoStyle8 = 8,   // 可播放，大图，视频频道样式 (顶踩禁用，显示出处，pgc头像)
};

// feed信息栏显示来源，时间，评论显示后端可控(显示推荐理由时不显示其他)
typedef NS_ENUM(NSInteger, ExploreOrderedDataCellFlag) {
    ExploreOrderedDataCellFlagShowCommentCount = 1 << 0,        // 显示评论数
    ExploreOrderedDataCellFlagShowTime = 1 << 1,                // 显示时间
    ExploreOrderedDataCellFlagShowRecommendReason = 1 << 2,     // 显示推荐理由
    ExploreOrderedDataCellFlagShowSource = 1 << 3,              // 显示来源
    ExploreOrderedDataCellFlagVideoPGCCard = 1 << 4,            // 视频pgc卡片定制UI
    // 第 6 位(32) ，表示是否展示 pgc 用户的圆头像（Android专用);
    ExploreOrderedDataCellFlagShowSourceImage = 1 << 5,         // 显示头像
    ExploreOrderedDataCellFlagPlayInDetailView = 1 << 6,        // 列表上点击视频后进入详情页播放
    ExploreOrderedDataCellFlagSourceAtTop = 1 << 7,             // 来源信息在顶部(显示头像)
    ExploreOrderedDataCellFlagShowDig = 1 << 8,                 // 显示赞
    ExploreOrderedDataCellFlagAutoPlay = 1 << 9,                // 是否自动播放
    ExploreOrderedDataCellFlagShowAbstract = 1 << 10,           // 是否显示摘要
    
    ExploreOrderedDataCellFlagHuoShanViewCount = 1 << 14,       //火山直播观看人数
    ExploreOrderedDataCellFlagHuoShanUserInfo = 1 << 15,        //火山直播账号
    ExploreOrderedDataCellFlagHuoShanTitle = 1 << 16,           //火山直播标题
    ExploreOrderedDataCellFlagU11ShowPadding = 1 << 17,            //u11的cell上是否显示上下padding
    ExploreOrderedDataCellFlagU11ShowFollowItem = 1 << 18,         //u11的cell上是否展示关注信息
    ExploreOrderedDataCellFlagU11ShowRecommendReason = 1 << 19,    //u11的cell上是否显示推荐理由
    ExploreOrderedDataCellFlagU11ShowTimeItem = 1 << 20,           //u11的cell上顶部是否显示时间
    
    ExploreOrderedDataCellFlagU11ShowFollowButton = 1 << 22,       //U11的cell上是否显示关注按钮
    
    ExploreOrderedDataCellFlagIsFakePlayCount = 1 << 23,         //判断是否fake播放数为阅读数
    
};

// feed上使用layout布局的cell枚举类型
typedef NS_ENUM(NSInteger, TTLayOutCellUIType) {
    //u1纯标题
    TTLayOutCellUITypePlainCellPureTitleS0,   // 纯标题 无头像 cell_layout_style != 6/7
    TTLayOutCellUITypePlainCellPureTitleS1,   // 纯标题 头像在上、头像旁边一行信息 cell_layout_style = 6
    TTLayOutCellUITypePlainCellPureTitleS2,   // 纯标题 头像在上、头像旁边两行信息 cell_layout_style = 7
    //u1右图
    TTLayOutCellUITypePlainCellRightPicS0,    // 右图 无头像 cell_layout_style != 6/7
    TTLayOutCellUITypePlainCellRightPicS1,    // 右图 头像在上、头像旁边一行信息 cell_layout_style = 6
    TTLayOutCellUITypePlainCellRightPicS2,    // 右图 头像在上、头像旁边两行信息 cell_layout_style = 7
    //u1组图
    TTLayOutCellUITypePlainCellGroupPicS0,    // 组图 无头像 cell_layout_style != 6/7
    TTLayOutCellUITypePlainCellGroupPicS1,    // 组图 头像在上、头像旁边一行信息 cell_layout_style = 6
    TTLayOutCellUITypePlainCellGroupPicS2,    // 组图 头像在上、头像旁边两行信息 cell_layout_style = 7
    //u1大图
    TTLayOutCellUITypePlainCellLargePicS0,    // 大图 无头像 cell_layout_style != 6/7
    TTLayOutCellUITypePlainCellLargePicS1,    // 大图 头像在上、头像旁边一行信息 cell_layout_style = 6
    TTLayOutCellUITypePlainCellLargePicS2,    // 大图 头像在上、头像旁边两行信息 cell_layout_style = 7
    
    //u3
    TTLayOutCellUITypeUGCCellPureTitle,    // 纯标题
    //创意广告
    TTLayOutCellUITypeUnifyADCellRightPic,  // 右图
    TTLayOutCellUITypeUnifyADCellGroupPic,  // 组图
    TTLayOutCellUITypeUnifyADCellLargePic,  // 大图
    //u11 带顶踩的大图视频
    TTLayOutCellUITypeUFCellLargePicS0,      //顶、评论在左下角                 cell_layout_style = 5
    TTLayOutCellUITypeUFCellLargePicS1,      //头像旁一行信息顶、评论在下面居中    cell_layout_style = 8
    TTLayOutCellUITypeUFCellLargePicS2,      //头像旁两行信息顶、评论在下面居中    cell_layout_style = 9
    //u11 带顶踩的右图视频
    TTLayOutCellUITypeUFCellRightPicS0,      //顶、评论在左下角                 cell_layout_style = 5
    TTLayOutCellUITypeUFCellRightPicS1,      //头像旁一行信息顶、评论在下面居中    cell_layout_style = 8
    TTLayOutCellUITypeUFCellRightPicS2,      //头像旁两行信息顶、评论在下面居中    cell_layout_style = 9
    //u11 评论文章样式 图在左
    TTLayOutCellUITypeUFCellCommentS0,       //顶、评论在左下角                 cell_layout_style = 5
    TTLayOutCellUITypeUFCellCommentS1,       //头像旁一行信息顶、评论在下面居中    cell_layout_style = 8
    TTLayOutCellUITypeUFCellCommentS2,       //头像旁两行信息顶、评论在下面居中    cell_layout_style = 9
    //u11 评论文章样式 图在右
    TTLayOutCellUITypeUFCellCommentS3,       //顶、评论在左下角                 cell_layout_style = 5
    TTLayOutCellUITypeUFCellCommentS4,       //头像旁一行信息顶、评论在下面居中    cell_layout_style = 8
    TTLayOutCellUITypeUFCellCommentS5,       //头像旁两行信息顶、评论在下面居中    cell_layout_style = 9
    
    TTLayOutCellUITypeWenDaCell,            //无头像，一行信息，无评论、点赞
    
    TTLayOutCellUITypePlainCellLoopPic,       // 轮播图 title + 轮播图 + info 
};

// feed上使用layout布局的cell枚举类型
typedef NS_ENUM(NSInteger, TTLayOutCellLayOutStyle) {
    TTLayOutCellLayOutStyleNone,//非u11样式
    TTLayOutCellLayOutStyle5 = 5,   //u11样式，顶踩在左下角,头像右边一行文字  //张晓东确认，测试已结束，全部采用TTLayOutCellLayOutStyle9样式
    TTLayOutCellLayOutStyle6 = 6,   //u11样式，无顶踩按钮，头像右边一行文字
    TTLayOutCellLayOutStyle7 = 7,   //u11样式，无顶踩,头像右边两行文字
    TTLayOutCellLayOutStyle8 = 8,   //u11样式，顶踩在下居中，头像右边一行文字  //张晓东确认，测试已结束，全部采用TTLayOutCellLayOutStyle9样式
    TTLayOutCellLayOutStyle9 = 9,   //u11样式，顶踩在下居中，头像右边两行文字
    
    TTLayOutCellLayOutStyle10 = 10, //u11的问答cell样式,关注的问题有了新回答

    TTLayOutCellLayOutStyle11 = 11, //u12 instagram样式
    
    TTLayOutCellLayOutStyle24 = 24, //u13 facebook样式
    
    TTLayoutCellLayOutStyle25 = 25, //U13关注频道文章大图
    TTLayoutCellLayOutStyle26 = 26, //U13关注频道文章右图
    TTLayoutCellLayOutStyle27 = 27, //U13关注频道文章无图
    TTLayoutCellLayOutStyle28 = 28, //U13关注频道文章组图(图集)
    
    TTLayoutCellLayOutStyle201 = 201, //热点要闻卡片 article in-card cell style with avatar pic
    TTLayoutCellLayOutStyle202 = 202, //热点要闻卡片 article in-card cell style with tiny red dot
};

typedef NS_OPTIONS(NSUInteger, TTInnerUIFlag) {
    TTInnerUIFlagSinglePicSmall = 1 << 0,
    TTInnerUIFlagDoublePicSmall = 1 << 1,
    TTInnerUIFlagTreblePicSmall = 1 << 2,
    TTInnerUIFlagQuickScan = 1 << 5,
    TTInnerUIFlagU12ThreePic = 1 << 6,
};

@interface ExploreOrderedData : TTEntityBase {
    CGFloat _cacheCellHeight[ExploreOrderedDataListTypeTotalCount];
    
    // cell各自定义的类型，比如同一个orderedData对应的段子cell
    // 在段子频道里和在新闻类频道里UI是不同的，所以需要定义两个不同的类型来区分
    NSUInteger _exploreCellType;
    
    NSArray <NSMutableDictionary *>*_cellItemHeightInfos;
    
    NSNumber *_maxTextLine;
    NSNumber *_defaultTextLine;
    NSString *_openURL;
}

@property (nonatomic, retain, nullable) NSString * primaryID;
@property (nonatomic, retain, nullable) NSString * uniqueID;
@property (nonatomic, copy, nullable  ) NSString * itemID;

/**
 *  第三方文章trackURL(5.3版 stream apiVersion=33)
 */
@property (nonatomic, copy, nonnull)NSArray *statURLs;

/**
 *  此adID为group类型的广告的adID，非下载广告等类型的adID
 *  下载广告的adID为originaldata.uniqueID
 */
@property (nonatomic, retain, nullable) NSNumber * adID;

// NSString类型的adID，后续把adID改成NSString，去掉adIDStr
@property (nonatomic, retain, nullable) NSString * adIDStr;

//Article
@property (nonatomic, strong, nullable) Article *article;

@property (nonatomic, retain, nullable) NSString * adLabel;
@property (nonatomic, retain, nullable) NSString * adTrackURL;
@property (nonatomic, retain, nullable) NSArray  * adVideoClickTrackURLs;
@property (nonatomic, retain, nullable) NSArray  * adTrackURLs;
@property (nonatomic, retain, nullable) NSString * adClickTrackURL;
@property (nonatomic, retain, nullable) NSArray  * adClickTrackURLs;
@property (nonatomic, strong ,nullable ) NSArray  * adPlayTrackUrls;
@property (nonatomic, strong ,nullable ) NSArray  * adPlayActiveTrackUrls;
@property (nonatomic, strong ,nullable ) NSArray  * adPlayEffectiveTrackUrls;
@property (nonatomic, strong ,nullable ) NSArray  * adPlayOverTrackUrls;
@property (nonatomic, assign)           CGFloat    effectivePlayTime;
@property (nonatomic,assign)             NSInteger trackSDK;
@property (nonatomic) double behotTime;
@property (nonatomic, retain, nullable) NSString * logExtra;
@property (nonatomic, retain, nullable) NSString * categoryID;
@property (nonatomic, retain, nullable) NSString * concernID;

// 广告过期时间间隔
@property (nonatomic) double adExpireInterval;

// 接口下发该条数据的时间
@property (nonatomic) double requestTime;

/**
 *  区分类型
 *      可能是文章、段子、帖子、还是持久化的广告等
 */
@property (nonatomic) ExploreOrderedDataCellType cellType;
@property (nonatomic, retain, nullable) NSString * label;
@property (nonatomic) NSInteger labelStyle;
@property (nonatomic) NSUInteger listType;
@property (nonatomic) NSUInteger listLocation;

/**
 *  用于列表排序
 *  *客户端添加的属性（非服务端传回）
 *  该值暂时与cursor或behotTime*1000相同
 */
@property (nonatomic) double orderIndex;
/**
 *  用于列表显示时间
 */
//@property (nonatomic, retain, nullable) NSNumber * publishTime DEPRECATED_ATTRIBUTE; 

@property (nonatomic) NSInteger tip;
@property (nonatomic, retain, nullable) NSNumber * showDislike;

@property (nonatomic, assign) BOOL witnessed;

/**
 *  不感兴趣动作回传extra字段给接口
 */
@property (nonatomic, copy, nullable) NSString * actionExtra;
/**
 * 记录当前对象的下一个对象的cellType（非服务端返回，不序列化）
 * 适用于cell的UI显示与相邻cell类型相关的情况，如卡片cell
 */
@property(nonatomic, assign)ExploreOrderedDataCellType nextCellType;

/**
 * 记录当前对象的上一个对象的cellType（非服务端返回，不序列化）
 * 适用于cell的UI显示与相邻cell类型相关的情况，如卡片cell
 */
@property(nonatomic, assign)ExploreOrderedDataCellType preCellType;
/**
 * 记录当前对象的下一个对象的是否有topPadding,如果下一个有，那么隐藏自己的底部的padding
 */
@property(nonatomic, assign) BOOL nextCellHasTopPadding;

/**
 * 记录当前对象的上一个对象的cellType（非服务端返回，不序列化）如果上一个是lastread或者null那么需要隐藏自己的顶部padding
 */
@property(nonatomic, assign) BOOL preCellHasBottomPadding;

/**
 * 记录当前对象的是否显示顶部padding（非服务端返回，不序列化）
 */
@property(nonatomic, assign) BOOL hasTopPadding;

/**
 *  元数据的引用，即ExploreArticle, ExploreEssay...
 *  *客户端添加的属性（非服务端传回）
 */
//@property (nonatomic, retain, nullable, readonly) ExploreOriginalData * originalData;

/**
 *  stream返回列表数据中is_deleted=YES，删除列表中cell
 */
@property (nonatomic) BOOL cellDeleted;

/**
 *  video_style视频样式（4.7版），默认值-1
 */
@property(nonatomic) ExploreOrderedDataVideoStyle videoStyle;

/*
 *  cell_flag
 */
@property(nonatomic) ExploreOrderedDataCellFlag cellFlag;

/*
 *  推荐理由
 */
@property(nonatomic, copy, nullable) NSString *recommendReason;

/**
 *  推荐点击打开url(5.4版)
 */
@property(nonatomic, copy, nullable) NSString *recommendUrl;

/*
 *  webCell高度
 */
@property (nonatomic) float cellHeight;

/*
 *  用户操作后webCell的高度
 */
@property (nonatomic) float cellHeightChanged;

/*
 *  是否置顶 注意！！ 这个isStick 不能用来判断是否是置顶，判断置顶请用stickStyle>0, 这个字段用于本地逻辑
 */
@property (nonatomic) BOOL isStick;

/*
 *  置顶样式 0:非置顶，1:置顶但不使用置顶cell,2:置顶且使用置顶cell
 */
@property (nonatomic) NSInteger stickStyle;

/*
 *  置顶文案，只在置顶时显示置顶文案
 */
@property (nonatomic, retain, nullable) NSString * stickLabel;

///...
/*
 *  图集样式，0或无: 图片频道样式；1: 非图片频道样式
 */
@property (nonatomic) NSInteger gallaryStyle;

/**
 *  (5.4版, 不持久化)记录article类型cell的类型，网络变化时已经加载过得cell数据保持加载时的cellType
 */
@property (nonatomic, assign) NSUInteger cellTypeCached;

/**
 *  (5.4新增)视频cell是否允许自动播放
 */
//@property (nonatomic, strong, nullable) NSNumber *autoPlayFlag;

/*
 *  右上方点击菜单里的展示项（5.4版）
 */
@property (nonatomic, retain, nullable) NSArray *actionList;

/**
 *  同一篇帖子在新闻tab下和关心tab下的列表样式不一样，1-文章样式，2-内容样式
 */
@property (nonatomic) ExploreOrderedDataThreadUIType uiType;

@property (nonatomic) BOOL isInCard;
/**
 *  卡片里的每一条数据持有卡片的primaryID
 */
@property (nonatomic, retain, nullable) NSString *cardPrimaryID;
/**
 *  视频频道大图广告用TTUnifyADVideoCategoryLargePicCell
 */
@property (nonatomic) NSInteger videoChannelADType;

@property (nonatomic) TTLayOutCellUIType layoutUIType;

/**
 *  列表大图，对应api字段large_image_list
 */
@property (nonatomic, strong, nullable) NSDictionary *largeImageDict;

/**
 *  不同频道使用不同的open_url
 */
@property (nonatomic, retain, nullable) NSString       *openURL;

/**
 *  5.8.3图片频道大图广告样式升级,区分普通频道大图和图片频道创意通投大图
 */
@property (nonatomic) NSInteger largePicCeativeType;
/**
 *  沉浸式、下载、电话等type
 */
@property (nonatomic, strong, nullable) NSString* type;
/**
 *  u11相关字段
 *  cellLayoutStyle 对应服务端 cell_layout_style 5和6分别对应列表页是否能直接点赞
 */
@property (nonatomic, strong, nullable) NSNumber *cellLayoutStyle;

/**
 *  第一位控制帖子U3单图样式和U11单图样式（C8、C9）
 *  第二位控制帖子U11两图样式（C10、C11）
 *  第三位控制帖子U11三图样式（C12、C13）
 */
@property (nullable, nonatomic, retain) NSNumber *innerUiFlag;

@property (nonatomic, strong, nullable) NSNumber * maxTextLine;

@property (nullable, nonatomic, retain) NSNumber * defaultTextLine;
/**
 * u11相关字段
 * 如果展示了关注按钮，通过这个字段记录下，之后无论关注转态是否发生变化，依然显示关注按钮
 */
@property (nonatomic, strong, nullable) NSNumber * showFollowButton;
@property (nonatomic, strong, nullable) NSNumber *followButtonStyle;

/**
 *  added u11上用来作为统计
 */
@property (nonatomic, strong, nullable) NSString *cellUIType;

/**
 *  内容来源 UGC:15 火山:16 抖音:19
 */
@property (nonatomic, strong, nullable) NSNumber *groupSource;

/*
 * 商业化统计 ExploreOrderedData 来源状态，不入数据库
 */
@property (nonatomic, assign) ExploreOrderedDataFromOption comefrom;

/**
 *  是否是新插入到库里的数据
 *  使用objectWithDictionary构造ExploreOrderedData时，先查询数据库，
 *  如果查到了, isFirstCached = NO
 *  没查到, isFirstCached = YES
 */
@property (nonatomic, assign) BOOL isFirstCached;

@property (nonatomic, assign) BOOL showFeedFollowedBtn; // 视频feed 是否展示已关注

@property (nonatomic, strong, nullable) NSDictionary *logPb;

@property (nonatomic, strong, nullable) NSDictionary * activity;

@property (nonatomic, assign,readonly) BOOL isFakePlayCount;  //是否替换播放数为阅读数

@property (nonatomic, strong, nullable) NSString *rid;

@property (nonatomic, strong, nullable) NSDictionary *cellCtrls;// cell的样式控制

@property (nonatomic, strong, nullable) NSNumber *followRecommendEnabled;

/**
 * 广告server推： 广告数据集中打包管理 与 业务数据分离
 * raw_ad_data 与 同级 ad_id log_extra track_url_list click_track_url_list 互斥存在
 * 2017-07-10 UGC 支持 raw_ad_data
 * ad_data (普通广告创意数据）, ad_button （视频频道广告创意数据）, raw_ad_data（广告基本信息） 三者关系 没关系
 * 一条完整的广告 = 广告基本数据 + 业务数据 + [创意数据]
 */
@property (nonatomic, strong, nullable) NSDictionary *raw_ad_data;

/*
 *使用article初始化
 */

@property (nonatomic,assign)CGPoint PicCollecionViewOffset;

- (instancetype _Nonnull)initWithArticle:( Article * _Nonnull )article;

- (void)registNotifications;

@end
