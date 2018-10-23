//
//  TTAuthorizeModel.h
//  Article
//
//  Created by Chen Hong on 15/4/16.
//
//

#import <Foundation/Foundation.h>



typedef NS_ENUM(NSInteger, TTPushNoteGuideFireReason) {
    TTPushNoteGuideFireReasonNone = 0,
    
    TTPushNoteGuideFireReasonReadTopArticle    = 1, // 读`热`文
    TTPushNoteGuideFireReasonFollow            = 2, // 关注 /2/relation/follow/v2
    TTPushNoteGuideFireReasonPublishComment    = 3, // /2/data/post_message
    
    TTPushNoteGuideFireReasonWDFollow          = 10, // /wenda/v1/commit/followquestion
    TTPushNoteGuideFireReasonWDPublishAnswer   = 11, // 问答发表答案 /wenda/v1/commit/postanswer
    TTPushNoteGuideFireReasonWDPublishQuestion = 12, // 问答发文(提问) /wenda/v1/commit/postquestion
    TTPushNoteGuideFireReasonWDPublishComment  = 13, // 问答发表评论 /wenda/v1/commit/postcomment
    
    TTPushNoteGuideFireReasonUGCFollow         = 20, // 不好区分，没有使用 /2/relation/follow/v2
    TTPushNoteGuideFireReasonUGCPublishComment = 21, // 不好区分，没有使用，直接使用TTPushNoteGuideFireReasonPublishComment
    TTPushNoteGuideFireReasonUGCPublishCard    = 22, // UGC发帖 /concern/v1/commit/publish/
    
    TTPushNoteGuideFireReasonHTSFollow         = 30, // /2/relation/follow/v2,/hotsoon/user/**/_follow/
    TTPushNoteGuideFireReasonHTSComment        = 31, // /hotsoon/item/comment/
    
    TTPushNoteGuideFireReasonUserMultiFollows  = 40, // /user/relation/multi_follow
    
    TTPushNoteGuideFireReasonLiveFollow        = 50, // /live_talk/follow/
};


@interface TTAuthorizeModel : NSObject

/**
 *  上次同类弹窗弹出时间
 */
@property(nonatomic,assign)NSInteger lastTimeShowLogin;
@property(nonatomic,assign)NSInteger lastTimeShowPush;
@property(nonatomic,assign)NSInteger lastTimeShowLocation;
@property(nonatomic,assign)NSInteger lastTimeShowAddressBook;

/**
 *  自有弹窗出现次数
 */
@property(nonatomic,assign)NSInteger showLocationAuthorizeHintTimes;
@property(nonatomic,assign)NSInteger showPushAuthorizeHintTimes;
/**
 * 自有弹窗出现时间
 */
@property(nonatomic,assign)NSInteger lastTimeShowLocationAuthorizeHint;
@property(nonatomic,assign)NSInteger lastTimeShowPushAuthorizeHint;

/**
 * 保存用户是否决定过弹窗控制权限
 */
@property(nonatomic,assign)BOOL isPushAuthorizeDetermined;

/**
 *  各类型弹窗出现的次数
 */
@property(nonatomic,assign)NSInteger showLoginTimesDetailFavorite;
@property(nonatomic,assign)NSInteger showLoginTimesDetailComment;
@property(nonatomic,assign)NSInteger showPushTimes;
@property(nonatomic,assign)NSInteger showLocationTimesLocalCategory;
@property(nonatomic,assign)NSInteger showLocationTimesLocationChanged;
@property(nonatomic,assign)NSInteger showAddressBookTimesAddFriendPage;
@property(nonatomic,assign)NSInteger showAddressBookTimesAddFriendAction;
@property(nonatomic,assign)NSInteger showAddressBookTimesMomentPage;

/**
 *  服务端可控参数
 */

/* 和其他类型弹窗间隔c天 */
@property(nonatomic,assign)NSInteger showAlertInterval;

/* 登录授权 */
/* 距上次同类弹窗时间k天 */
@property(nonatomic,assign)NSInteger showLoginTimeInterval;

/* 详情页-点击「收藏」最多弹l次 */
@property(nonatomic,assign)NSInteger showLoginMaxTimesDetailFavorite;

/* 详情页-点击/滑动 进入「评论」最多弹n次 */
@property(nonatomic,assign)NSInteger showLoginMaxTimesDetailComment;


/* 推送权限 */
/* 距上次同类弹窗时间i天。*/
@property(nonatomic,assign)NSInteger showPushTimeInterval;
/* 推送提示文案 */
@property(nonatomic,copy)NSString *showPushHintText;

/* 最多弹j次 */
@property(nonatomic,assign)NSInteger showPushMaxTimes;

/** 通过点击`热`文最多显示推送引导次数 */
@property (nonatomic, assign) NSInteger showPushTimesByTopArticle;

/** 通过点击`关注`已显示推送引导次数 */
@property (nonatomic, assign) NSInteger showPushTimesByFollow;

/** 通过点击`互动`（评论或发帖）已显示推送引导次数 */
@property (nonatomic, assign) NSInteger showPushTimesByInteraction;

@property (nonatomic, assign) TTPushNoteGuideFireReason pushFireReason;


/* 定位权限 */
/* 距上次同类弹窗时间i天。*/
@property(nonatomic,assign)NSInteger showLocationTimeInterval;

/* 最多弹j次 */
@property(nonatomic,assign)NSInteger showLocationMaxTimesLocalCategory;
@property(nonatomic,assign)NSInteger showLocationMaxTimesLocationChanged;


/* 通讯录权限 */
/* 距上次同类弹窗时间i天。*/
@property(nonatomic,assign)NSInteger showAddressBookTimeInterval;

/* 最多弹j次 */
@property(nonatomic,assign)NSInteger showAddressBookMaxTimesAddFriendPage;
@property(nonatomic,assign)NSInteger showAddressBookMaxTimesAddFriendAction;
@property(nonatomic,assign)NSInteger showAddressBookMaxTimesMomentPage;


/**
 *  数据持久化
 */
- (void)loadData;

- (void)saveData;

/**
 *  其他类型弹窗最大时间
 *
 *  @param lastTime 当前弹窗的时间
 *
 *  @return 其他类型弹窗最大时间
 */
- (NSInteger)maxLastTimeExcept:(NSInteger)lastTime;

@end
