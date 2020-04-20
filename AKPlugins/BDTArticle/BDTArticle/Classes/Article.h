//
//  Article.h
//  Article
//
//  Created by Hu Dianwei on 6/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExploreOriginalData.h"
#import "ArticleHeader.h"
#import "TTImageInfosModel.h"
#import "TTGroupModel.h"
#import "TTAdConstant.h"
#import "FRActionDataService.h"

//图片Model在详情大图数组，小图数组，列表大图数组的顺序key
#define kArticleImgsIndexKey    @"kArticleImgsIndexKey"
#define kArticleGroupFlagsHasVideo 0x1
#define kArticleGroupFlagsOpenUseWebViewInList 0x4
#define kArticleGroupFlagsClientEscape 0x10

//控制详情页相关阅读或相关视频是否显示图片
#define kArticleGroupFlagsDetailRelateReadShowImg 0x20
#define kArticleGroupFlagsDetailTypeVideoSubject  (0x40)

#define kArticleGroupFlagsDetailTypeNoComment 0x1000
#define kArticleGroupFlagsDetailTypeNoToolBar 0x2000
#define kArticleGroupFlagsDetailTypeSimple 0x4000

#define kArticleGroupFlagsDetailTypeSchemaImageSubject (0x10000)
#define kArticleGroupFlagsDetailTypeImageSubject (0x20000)
#define kArticleGroupFlagsDetailTypeWenDaSubject (0x40000)
#define kArticleGroupFlagsDetailTypeArticleSubject (0x80000)


#define VideoPGCAvatarUrlKey            @"avatar_url"               //视频pgc 头像
#define VideoPGCNameKey                 @"name"                     //视频pgc 昵称
#define VideoInfoIDKey                  @"video_id"                 //视频ID
#define VideoInfoBookIDKey              @"col_no"                   //合辑ID
#define VideoInfoImageDictKey           @"detail_video_large_image" //视频详情页视频大图列表
#define VideoInfoDirectPlayKey          @"direct_play"              //进入详情页是否直接播放视频
#define VideoWatchCountKey              @"video_watch_count"        //视频播放数
#define VideoInfoShowPGCSubscribeKey    @"show_pgc_subscribe"       //文章进入视频详情页后是否显示PGC订阅View

#define kArticleInfoRelatedVideoCardTypeKey  @"card_type"
#define kArticleInfoRelatedVideoAutoLoadKey  @"auto_load"
#define kArticleInfoRelatedVideoSubjectIDKey @"video_subject_id"
#define kArticleInfoRelatedVideoAdIDKey      @"ad_id"
#define kArticleInfoRelatedVideoTagKey       @"show_tag"
#define kArticleInfoRelatedVideoLogExtraKey  @"log_extra"

#define kArticlePreloadVideoFlagKey @"video_preloading_flag"

NS_ASSUME_NONNULL_BEGIN

/**
 *  发布评论时要记录文章阅读质量，包括当前页面停留时长和阅读进度
 *  阅读进度：文章为位置，图集为当前所在第n张/总张数，视频为播放进度
 */
@interface TTArticleReadQualityModel : NSObject

@property(nonatomic, strong) NSNumber *stayTimeMs;
@property(nonatomic, strong) NSNumber *readPct;

@end

@class TTAdVideoRelateAdModel;

// 文章内容
@interface ArticleDetail : TTEntityBase
@property (nonatomic, copy, nullable) NSString       *primaryID;
@property (nonatomic, copy, nullable) NSString       *content;
@property (nonatomic) double updateTime;
@end

@interface Article : ExploreOriginalData

@property (nonatomic, retain, nullable) NSString       *primaryID;
@property (nonatomic, retain, nullable) NSString       *abstract;
@property (nonatomic, retain, nullable) NSNumber       *articleDeleted;
@property (nonatomic, assign) ArticleSubType           articleSubType;
@property (nonatomic, assign) ArticleType              articleType;
@property (nonatomic, retain, nullable) NSString       *articleURLString;
@property (nonatomic, assign) BOOL                     banComment;
@property (nonatomic, retain, nullable) NSDictionary   *comment;
@property (nonatomic, retain, nullable) NSArray        *comments;
@property (nonatomic, retain, nullable) NSArray        *zzComments;// 转载
@property (nonatomic, retain, nullable) NSNumber       *detailNoComments;
@property (nonatomic, retain, nullable) NSString       *displayTitle;
@property (nonatomic, retain, nullable) NSString       *displayURL;
@property (nonatomic, retain, nullable) NSString       *openURL;
@property (nonatomic, retain, nullable) NSNumber       *goDetailCount;
@property (nonatomic, retain, nullable) NSNumber       *groupType;
@property (nonatomic) BOOL hasImage;
@property (nonatomic, retain, nullable) NSNumber       *hasVideo;
@property (nonatomic, retain, nullable) NSString       *imageDetailListString;
@property (nonatomic, retain, nullable) NSNumber       *itemVersion;    //已废弃
@property (nonatomic, retain, nullable) NSString       *keywords;
@property (nonatomic, retain, nullable) NSArray        *filterWords;

@property (nonatomic, retain, nullable) NSArray        *galleries;
@property (nonatomic, retain, nullable) NSArray        *galleryAdditional;
@property (nonatomic, retain, nullable) NSNumber       *ignoreWebTranform;//added 5.4:导流页是否禁用服务端转码缓存，默认启用
@property (nonatomic, retain, nullable) NSNumber       *isOriginal;

@property (nonatomic, strong, nullable) NSDictionary   *embededAdInfo;//added 5.6: 视频文章内嵌广告数据
@property (nonatomic, copy, nullable) NSString       *adPromoter;
@property (nonatomic, strong, nullable) NSDictionary   *raw_ad_data;

/*
 *  added 5.0:图集feed流增加字段, gallaryFlag为0或不传表示走以前的图片逻辑；否则，1 单张大图，2 中图在左， 3 中图在右
 *  gallaryImageCount表示图集的总张数
 */
@property (nonatomic, retain, nullable) NSNumber *gallaryFlag;
@property (nonatomic, retain, nullable) NSNumber *gallaryImageCount;

@property (nonatomic, copy, nullable  ) NSString *itemID;
@property (nonatomic, retain, nullable) NSNumber *aggrType;

@property (nonatomic, strong) NSNumber  *picDisplayType;

@property (nonatomic, assign) BOOL  detailShowFlags;
@property (nonatomic, assign) long long  readCount;

///...
/**
 *  实体词
 */

@property (nonatomic, strong, nullable) NSDictionary *entityWordInfoDict;
#define kEntityId           @"entity_id"
#define kEntityText         @"entity_text"
#define kEntityWord         @"entity_word"
#define kEntityScheme       @"entity_scheme"
#define kEntityFollowed     @"entity_followed"
#define kEntityStyle        @"entity_style"
#define kEntityMark         @"entity_mark"
#define kEntityConcernID    @"concern_id"

/**
 *  列表大图，对应api字段large_image_list
 */
@property (nonatomic, retain, nullable) NSDictionary *largeImageDict;
/**
 *  列表中图，对应api字段middle_image
 */
@property (nonatomic, retain, nullable) NSDictionary *middleImageDict;
/**
 *  added v5.0:视频详情页信息，目前包含videoID和videoLargeImageDict字段
 *  为兼容之前版本，不会干掉已经单独下发的videoID和videoDuration字段,这些字段依然在列表页独立使用
 */
@property (nonatomic, retain, nullable) NSDictionary *videoDetailInfo;
@property (nonatomic, retain, nullable) NSDictionary *videoPlayInfo;

/**
 *  UGC u13样式的视频封面切图
 */
@property (nonatomic, retain, nullable) NSDictionary *ugcVideoCover;

/**
 *  相关视频广告，将广告数据全存在此属性内
 */
@property (nonatomic, retain, nullable) TTAdVideoRelateAdModel *videoAdExtra;

/**
 *  视频详情页给出可自定义跳转的入口
 */
@property (nonatomic, retain, nullable) NSDictionary *videoExtendLink;

/**
 *  浮层方案
 */
@property (nonatomic, retain, nullable) NSNumber *natantLevel;
/**
 *  是否预加载web类型网页
 */
@property (nonatomic) ArticlePreloadWebType preloadWeb;

@property (nonatomic, retain, nullable) NSString       *source;
@property (nonatomic, retain, nullable) NSString       *sourceURL;
@property (nonatomic, retain, nullable) NSString       *tcHeadText;
@property (nonatomic, retain, nullable) NSString       *thumbnailListString;
@property (nonatomic, retain, nullable) NSString       *title;
@property (nonatomic, copy,   nullable) NSString       *subtitle;
@property (nonatomic, retain, nullable) NSString       *contentDecoration;
@property (nonatomic, retain, nullable) NSNumber       *imageMode;
/**
 *  专题中第一篇文章的GID
 */
@property (nonatomic, retain, nullable) NSNumber *topicGroupId;

/**
 *  列表组图，对应api字段image_list
 */
@property (nonatomic, retain, nullable) NSArray *listGroupImgDicts;

/**
 *  列表来源icon，对应api字段source_icon(日间),source_icon_night(夜间)
 */
@property (nonatomic, retain, nullable) NSDictionary *sourceIconDict;
@property (nonatomic, retain, nullable) NSDictionary *sourceIconNightDict;

@property (nonatomic, retain, nullable) NSString     *videoID;
@property (nonatomic, retain, nullable) NSNumber     *videoDuration;
@property (nonatomic, retain, nullable) NSNumber     *videoType;
@property (nonatomic, retain, nullable) NSDate       *createdTime;//article生成时间,如果过了一个小时,就忽略video_info,使用videoid来请求视频url

/**
 *  PGC文章来源
 */
@property (nonatomic, retain, nullable) NSString     *mediaName;//订阅号名称
@property (nonatomic, retain, nullable) NSDictionary *mediaInfo;//订阅号信息
@property (nonatomic, strong, nullable) NSDictionary *detailMediaInfo;//详情页订阅号信息，非持久化，用于视频专题 add by 5.5
@property (nonatomic, strong, nullable) NSDictionary *relatedVideoExtraInfo;//相关视频数据特殊数据（视频专题、视频合辑、视频推广等），非持久化 add by 5.6

/**
 *  客户端对导流页请求添加此字段中header, 无此字段或空的时候不加(5.1版，streamVersion=31)
 */
@property (nonatomic, copy, nullable) NSDictionary *wapHeaders;

/**
 *  h5_extra, 转码页js使用
 */
@property (nonatomic,copy, nullable) NSDictionary *h5Extra;

/**
 *  wenda_txtra, 问答详情页使用
 */
@property (nonatomic, copy, nullable) NSDictionary *wendaExtra;

/**
 *  用于列表显示时间
 */
@property (nonatomic) double articlePublishTime;

/**
 *  点击来源跳转链接(pgc文章跳pgc账号页，其他文章跳搜索页，关键词为来源），5.4版
 */
@property (nonatomic, copy, nullable) NSString *sourceOpenUrl;

/**
 *  来源描述（所属类别等信息），关心词、话题名 等，5.4版
 */
@property (nonatomic, copy, nullable) NSString *sourceDesc;

/**
 *  点击source_desc跳转链接，关心页、话题页 等，5.4版
 */
@property (nonatomic, copy, nullable) NSString *sourceDescOpenUrl;

/** 非PGC头像 5.4版 */
@property (nonatomic, copy, nullable) NSString *sourceAvatar;

/** 是否订阅PGC */
@property (nonatomic, retain, nullable) NSNumber *isSubscribe;

/**
 *  来源头像底色，[1，2，3]，5.4版
 */
@property (nonatomic, nullable) NSNumber *sourceIconStyle;

/**
 *  added 5.7 连载小说信息, content/full接口下发
 */
@property (nonatomic, strong, nullable) NSDictionary *novelData;

@property (nonatomic, strong, nullable) NSNumber *articlePosition;

/**
 *
 *  added 5.8.5 视频cell 控制全屏播放时竖屏播放，huoshan,ugc_video,pgc_video
 */
@property (nonatomic, copy, nullable) NSString *videoSource;

/**
 *  added 5.8.5 视频cell 控制在列表页视频tab视频cell显示的宽高比例
 */
@property (nonatomic, strong, nullable) NSNumber *videoProportion;

/**
 *  added coredata版本25 iOS5.8.5 控制详情页视频宽高比例
 */
@property (nonatomic, strong, nullable) NSNumber *detailVideoProportion;

/**
 *  added coredata版本25 iOS5.8.5 控制在列表页视频tab视频cell内视频全屏播放下竖屏播放
 */
@property (nonatomic, assign) BOOL showPortrait;

/**
 *  added coredata版本25 iOS5.8.5 控制在详情页视频全屏播放下竖屏播放
 */
@property (nonatomic, assign) BOOL detailShowPortrait;

/**
 *  added 5.8.5 视频cell 用户信息
 */
@property (nonatomic, strong, nullable) NSDictionary *userInfo;
/**
 *  added 5.8.5 视频详情页 用户信息 非持久化
 */
@property (nonatomic, strong, nullable) NSDictionary *detailUserInfo;

/**
 *  added coredata版本25 本地视频url 客户端自己加的字段
 */
@property (nonatomic, copy, nullable) NSString *videoLocalURL;

/**
 *  coredata版本27 详情页content接口单独返回media_user_id
 */
@property (nonatomic, copy, nullable) NSString *mediaUserID;

/**
 *  added u11,推荐理由
 */
@property (nonatomic, strong, nullable) NSString *recommendReason;
/**
 *  added UGC推荐理由
 */
@property (nullable, nonatomic, retain) NSDictionary *recommendDict;//推荐理由

/**
 *  added u11,c2回答问题的用户
 */
@property (nonatomic, strong, nullable) NSDictionary *userRelation;

/**
 *  added u11,c6赞了文章的用户
 */
@property (nonatomic, strong, nullable) NSDictionary *ugcInfo;

/**
 *  added 6.0.5 banBury：禁止踩，banDigg：禁止顶
 */
@property (nonatomic, retain, nullable) NSNumber *banBury;
@property (nonatomic, retain, nullable) NSNumber *banDigg;
/**
 *  图片来源信息 by xsm
 */
@property (nonatomic, strong, nullable) NSDictionary *happyKnocking;


@property (nonatomic, copy, nullable) NSString * schema;

/**
 * added 视频cell分享数
 */
@property (nonatomic, strong, nullable) NSNumber *share_count;

/**
 *  作为内嵌内容，被点击时的跳转
 */
@property (nonatomic, strong, nullable) NSString *articleOpenURL;

/**
 *  回答的内容，展示的最大条数
 */
@property (nonatomic, strong, nullable) NSNumber *showMaxLine;

@property (nonatomic, strong, nullable) NSArray *commoditys;//视频特卖

@property (nonatomic, strong, nullable) NSDictionary *payStatus;

@property (nonatomic, copy, nullable) NSString *titleRichSpanJSONString;

@property (nonatomic, strong, nullable) id<FRActionDataProtocol> actionDataModel;
/**
 * 导航栏显示品牌类型
 */
@property (nonatomic, copy, nullable) NSString *navTitleType;

/**
 * 导航栏显示品牌logo图标图片
 */
@property (nonatomic, copy, nullable) NSString *navTitleUrl;
/**
 * 导航栏显示品牌logo图标夜间模式
 */
@property (nonatomic, copy, nullable) NSString *navTitleNightUrl;

/**
 * 导航栏显示品牌logo图标图片跳转url
 */
@property (nonatomic, copy, nullable) NSString *navOpenUrl;


/**
 *  之前存在orderedData中，为了避免article中用到adId和logExtra时需要查询数据库，在article中也存一份adID和logExtra
 */
@property (nonatomic, copy, nullable) NSString *adIDStr;
@property (nonatomic, copy, nullable) NSString *logExtra;


// 使用同一个的主键构建方法，便于更改时漏改
+ (NSString *)primaryIDByUniqueID:(int64_t)uniqueID
                           itemID:(nullable NSString *)itemID
                             adID:(nullable NSString *)adID;

+ (NSString *)primaryIDFromDictionary:(NSDictionary *)dictionary;

- (void)digg;
- (void)bury;

/**
 判断是否是客户端转码类型
 */
- (BOOL)isClientEscapeType;
/**
 *  判断是否需要再调用content接口获取正文
 */
- (BOOL)isContentFetchedWithForceLoadNative:(BOOL)forceLoadNative;
/**
 判断article是否已经获取过内容
 */
- (BOOL)isContentFetched;
- (BOOL)isImageSubject;
- (BOOL)isVideoSubject;
- (BOOL)isWenDaSubject;
- (BOOL)isGroupGallery;
- (NSString *)videoThirdMonitorUrl;

/**
 *  是否要设置UA
 */
- (BOOL)shouldUseCustomUserAgent;

- (nonnull NSString*)commentContent;


/**
 *  返回列表组图的Models, 使用listGroupImgDicts转换
 *
 *  @return
 */
- (nullable NSArray *)listGroupImgModels;
/**
 *  列表中图Model， 使用middleImageDict转换
 *
 *  @return
 */
- (nullable TTImageInfosModel *)listMiddleImageModel;
/**
 *  列表大图Model， 使用largeImageDict转换
 *
 *  @return
 */
- (nullable TTImageInfosModel *)listLargeImageModel;

/**
 *  详情页大图Model array
 *
 */
- (nullable NSArray *)detailLargeImageModels;

/**
 *  详情页小图Model array
 *
 */
- (nullable NSArray *)detailThumbImageModels;

/**
 *  判断是否是专题
 *
 *  @return YES：专题
 */
- (BOOL)isTopic;

/**
 *  列表来源icon Model，使用sourceIconDict转换
 */
- (nullable TTImageInfosModel *)listSourceIconModel;
- (nullable TTImageInfosModel *)listSourceIconNightModel;

- (nonnull TTGroupModel *)groupModel;

/** 来源图标背景色 */
- (nonnull NSArray *)sourceIconBackgroundColors;

- (BOOL)directPlay;

/** 优先显示推荐转载评论，没有时显示普通评论 */
- (nullable NSDictionary *)displayComment;

- (nullable NSString *)zzCommentsIDString;

- (nullable NSString *)firstZzCommentMediaId;

- (NSUInteger)relatedVideoType;
- (nullable NSString *)relatedLogExtra;
- (nullable NSNumber *)relatedAdId;
- (BOOL)shouldDirectShowVideoSubject;
- (BOOL)hasVideoSubjectID;
- (BOOL)hasVideoBookID;
- (BOOL)hasVideoID;
- (nullable NSString *)videoSubjectID;
- (BOOL)isPreloadVideoEnabled;
- (nullable NSString *)waterMarkURLString;
//过了一个小时,VideoUrl就失效
- (BOOL)isVideoUrlValid;
//视频列表需要确定article创建的时间,以来定位返回的视频url是否过期了
- (void)settingArticleCreatedTime;
// feed接口重新下发Article数据时清楚之前缓存的model
- (BOOL)hasVideoPlayInfoUrl;
- (BOOL)showExtendLink;
//是否是火山短时频或者ugc短视频
- (BOOL)isVideoSourceUGCVideoOrHuoShan;
- (BOOL)isVideoSourceUGCVideo;
- (BOOL)isVideoSourceHuoShan;
//u11同步关注
- (BOOL)isFollowed;//关注
- (BOOL)userIsFollowed;//被关注
- (void)updateFollowed:(BOOL)followed;
//u11 C2回答了问题user_info
- (nullable NSDictionary *)userInfoForAction;
//u11头像
- (nullable NSString *)userImgaeURL;
//u11用户名
- (nullable NSString *)userName;

- (nullable NSString *)userDecoration;
//u11认证信息
//- (nullable NSString *)userVerifiedContent;
//U11动作的用户id
- (nullable NSString *)userIDForAction;
//u11认证展现信息
- (nullable NSString *)userAuthInfo;
//u11推荐理由(ugc动作)
- (nullable NSString *)recommendReasonForActivity;
//副标题推荐理由
- (nullable NSString *)recommendReasonSecondLine;
- (ArticleDetail *)detail;

- (TTAdFeedDataDisplayType)articlePictureDidsplayType;

@end

NS_ASSUME_NONNULL_END

