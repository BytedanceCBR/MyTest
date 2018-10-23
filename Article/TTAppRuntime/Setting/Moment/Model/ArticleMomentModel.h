//
//  SSTrendsModel.h
//  Article
//
//  Created by Dianwei on 14-5-21.
//
//
#import <Foundation/Foundation.h>
#import "SSBaseModel.h"
#import "TTImageInfosModel.h"
#import "TTQutoedCommentModel.h"
#import "ArticleMomentGroupModel.h"
#import "TTUGCDefine.h"

#define kArticleMomentModelContentDeletedTip NSLocalizedString(@"此内容已被删除", nil)
#define kArticleMomentCommentChangeNotification "kArticleMomentCommentChangeNotification"
typedef NS_ENUM(NSInteger, kMomentModelDiggUserLimit)
{
    kMomentModelDiggUserLimitZero = -1,              //动态列表"顶用户"显示的极限为0
    kMomentModelDiggUserLimitMax = 0,           //动态列表"顶用户"显示的极限为默认最大值
};
@class SSUserModel;
@class ArticleMomentGroupModel;
@class ArticleMomentCommentModel;
@class SSUserBaseModel;
/**
 *  动态cell的类型， 当cell_type为1的时候， 才看这个
 */
typedef NS_ENUM(NSUInteger, MomentItemType)
{
    /**
     *  未返回值， 将忽略不返回类型的item
     */
    MomentItemTypeNone = 0,
    /**
     *  200: 含文章动态（同老动态）
     */
    MomentItemTypeArticle = 110,
    /**
     *  201：用户发表的非话题动态
     */
    MomentItemTypeNoForum = 111,
    /**
     *  202：转发的动态；
     */
    MomentItemTypeForward = 112,
    /**
     *  200：含话题动态（话题列表页中只有200返回结果）
     */
    MomentItemTypeForum = 200,
    /*
     * 300:用户发布的IES小视频
     */
    MomentItemTypeIESVideo = 300,
    /**
     *  201:再增加201类型，仅话题可见帖子，客户端展示样式同200
     */
    MomentItemTypeOnlyShowInForum = 201,
    
    /*
     * 211:转发文章形成的帖子
     */
    MomentItemTypeRepostedArticle = 211,
    /*
     * 212:转发帖子形成的帖子
     */
    MomentItemTypeRepostedThread = 212,
    /*
     * 213:转发ugc小视频形成的帖子
     */
    MomentItemTypeRepostedIESVideo = 213,
    
    MomentItemTypeUGCVideo = 150,
    MomentItemTypePGCArticle = 151,
};
typedef NS_ENUM(NSUInteger, MomentDeviceType){
    MomentDeviceNone         = 0,
    MomentDeviceAndroidPhone = 1,
    MomentDeviceAndroidPad   = 2,
    MomentDeviceIphone       = 3,
    MomentDeviceIpad         = 4
};
typedef NS_ENUM(NSUInteger, MomentFlagType){
    MomentFlagNone          =   0x00,
    /**推荐类型*/
    MomentFlagRecommend     =   0x01,
};
// 动态中cell类型
typedef NS_ENUM(NSUInteger, MomentListCellType) {
    MomentListCellTypeNone              = 0,
    MomentListCellTypeMoment            = 1, // 动态cell
    MomentListCellTypeRecommendUser     = 2, // 推荐好友cell --已废弃
    MomentListCellTypeMomo              = 3, // 陌陌类型Cell
};
@interface ArticleMomentModel : SSBaseModel<NSCoding>
+ (NSArray*)momentsWithArray:(NSArray*)array;
- (instancetype)initWithDictionary:(NSDictionary*)dict;
/**
 更新moment，如果dict包含某key，则更新
 */
- (void)updateWithDictionary:(NSDictionary*)dict;
/**
 如果这条动态是一条帖子，则可能有threadID
 */
@property (nonatomic, copy) NSString *threadID;
@property(nonatomic, assign)NSTimeInterval cursor;
@property(nonatomic, assign)NSTimeInterval createTime;
@property(nonatomic, retain)SSUserModel *user;
@property(nonatomic, retain)ArticleMomentGroupModel *group;
@property(nonatomic, copy)NSString *content;
@property(nonatomic, copy)NSString *contentUnescape;//未经转义的内容
@property(nonatomic, copy)NSString *contentRichSpan;//高亮标记，请使用TTRichSpanText
@property(nonatomic, assign, getter = isDigged)BOOL digged;
@property(nonatomic, retain)NSMutableOrderedSet *diggUsers;
@property(nonatomic, assign)int diggsCount;
@property(nonatomic, assign)int diggLimit;
@property(nonatomic, copy) NSString *shareURL;
@property(nonatomic, copy) NSString *momentURL;
@property(nonatomic, assign)int commentsCount;
@property(nonatomic, assign)int visibleCommentsCount;
@property(nonatomic, retain, readonly)NSMutableOrderedSet *comments;
@property(nonatomic, assign)MomentFlagType flags;
@property(nonatomic, retain)NSString *actionDescription;
@property(nonatomic, assign)int type;
@property(nonatomic, assign)NSTimeInterval modifyTime;
@property(nonatomic, assign)MomentDeviceType deviceType;
@property(nonatomic, retain)NSString *deviceModelString;
@property(nonatomic, assign)BOOL isDeleted;
@property(nonatomic, retain)NSString *reason;
@property(nonatomic, assign)MomentListCellType cellType;
@property(nonatomic, assign)MomentItemType itemType;
@property(nonatomic, retain)NSArray * largeImgeDicts;
@property(nonatomic, retain)NSArray * thumbImgeDicts;
@property(nonatomic, strong)TTQutoedCommentModel *qutoedCommentModel;
@property(nonatomic, strong)NSNumber *showOrigin;
@property(nonatomic, copy)NSString *showTips;
//5.5 统计参数
// 回复推荐者的评论（只记实际发送成功）——发回gid、作者mid、uid
@property(nonatomic, copy)NSString *mediaId;
/*
 "distance": "12496.2",
 "sname": "\u53f3\u5916\u5927\u8857",
 "name": "\u8fc8\u963f\u5bc6\u591c\u603b\u4f1a",
 "url": "http://www.immomo.com/invitegroup/29372269?d=a&v=0&mark=group&market=toutiao&t=1415616215",
 "sign": "\u8fc8\u963f\u5bc6\u591c\u603b\u4f1a\u79c1\u4eba\u4f1a\u6240\u2026\u2026\u60f3\u53bb\u4f1a\u6240\u79c1\u804a\u2026\u2026\u672c\u4f1a\u6240\u5145\u4f1a\u5458\u53ef\u4ee5\u5e26\u4e00\u4e2a\u670b\u53cb\u2026\u2026\u7ea2\u9152\u514d\u8d39\u4e00\u676f",
 "gid": "29372269",
 "avatar"
 */
@property(nonatomic, copy) NSString *distance;
@property(nonatomic, copy) NSString *sname;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *url;
@property(nonatomic, copy) NSString *sign;
@property(nonatomic, copy) NSString *gid;
@property(nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *commentID;

/**
 *  原始动态
 *  当item_type是202时，解析该字段获取原始对应动态
 *  该字段数结构同动态item结构,  刚字段需要外部设置
 */
@property(nonatomic, retain)ArticleMomentModel * originItem;
/**
 当item_type是212时，解析该字段获取原帖
 */
@property (nonatomic, strong) ArticleMomentModel *originThread;
/**
 当item_type是211时，解析该字段获取原文
 */
@property (nonatomic, strong) ArticleMomentGroupModel *originGroup;
@property (nonatomic, assign) FRThreadEntityStatusType threadStatus;
/**
 *  动态转发数
 */
@property(nonatomic, retain)NSNumber * forwardNum;
/**
 *  表示文本是否完整
 */
@property(nonatomic, assign)BOOL contentIncomplete;
/**
 *  话题帖子,
 *  当item_type是300和201时，解析该字段
 */
@property(nonatomic, retain)NSDictionary * talkItem;
/**
 *  是否为管理源
 */
@property(nonatomic, assign)BOOL isAdmin;
/**
 *  大图url地址,每个url按照定义URL对象打包
 *
 *  @return 大图url地址
 */
- (NSArray *)largeImageList;
/**
 *  缩略图url地址,每个url按照定义URL对象打包
 *
 *  @return 缩略图url地址
 */
- (NSArray *)thumbImageList;
/**
 *  缩略图对应的大图的文件类型
 *
 *  @return dict：
 *  {
 *     '${thumbImageUri1}':  0,
 *     '${thumbImageUri2}':  1
 *  }
 *
 *   JPEG	1
 *   GIF	2
 *   BMP    3
 *   PNG	4
 *
 */
//- (NSDictionary *)imageTypes;
/**
 *  话题id,如果item_type为300时需要该字段
 *
 *  @return 话题id
 */
- (long long)forumID;
/**
 *  话题名字,如果item_type为300时需要该字段
 *
 *  @return 话题名字
 */
- (NSString *)forumName;
/**
 *  话题跳转schema
 *
 *  @return 跳转schema
 */
- (NSString *)openURL;
/**
 will KVO, unless insert existing one
 */
- (void)insertComment:(ArticleMomentCommentModel*)comment;
/**
 will KVO, unless delete non-existing one
 */
- (void)deleteComment:(ArticleMomentCommentModel*)comment;
/**
 will KVO, unless insert existing one
 */
- (void)insertDiggUser:(SSUserBaseModel*)user;
/**
 *  删除model的内容
 */
- (void)deleteModelContent;
- (NSString *)impressionDescription;
- (BOOL)isThreadDeleted;
@end
