//
//  TTUGCDefine.h
//  Article
//
//  Created by 王霖 on 2017/8/30.
//
//

#ifndef TTUGCDefine_h
#define TTUGCDefine_h

#pragma mark - Notification

//Post thread
#define kTTForumPostingThreadNotification @"TTForumPostingThreadNotification"//正在发帖
#define kTTForumResumeThreadNotification @"kTTForumResumeThreadNotification"//恢复发帖
#define kTTForumPostThreadFailNotification @"TTForumPostThreadFailNotification"//发帖失败
#define kTTForumThreadProgressUpdateNotification @"kTTForumThreadProgressUpdateNotification"//发帖进度
#define kTTForumPostThreadSuccessNotification @"kTTForumPostThreadSuccessNotification"//发帖成功
#define kTTForumRePostThreadSuccessNotification @"kTTForumRePostThreadSuccessNotification"//转发成功
#define kTTForumRePostAndCommentThreadSuccessNotification @"kTTForumRePostAndCommentThreadSuccessNotification"//转发并评论成功
#define kTTForumRePostAndReplyThreadSuccessNotification @"kTTForumRePostAndReplyThreadSuccessNotification"//转发并回复成功

#define kTTForumDeleteFakeThreadNotification @"TTForumDeleteFakeThreadNotification"//删除fake thread

//Thread operation
#define kTTForumDeleteThreadNotification @"kTTForumDeleteThreadNotification"//删除thread
#define kFRSetThreadOnlyDoneNotification @"kFRSetThreadOnlyDoneNotification"//设置帖子自见

//Thread change
#define kFRThreadEntityDeleteCommentNotification @"kFRThreadEntityDeleteCommentNotification"
#define kFRThreadEntityDigNotification @"kFRThreadEntityDigNotification"
#define kFRThreadEntityCancelDigNotification @"kFRThreadEntityCancelDigNotification"

#define kFRCommentEntityDigNotification @"kFRCommentEntityDigNotification"
#define kFRCommentEntityCancelDigNotification @"kFRCommentEntityCancelDigNotification"

#define kTTForumPostingThreadActionFinishNotification @"kTTForumPostingThreadActionFinishNotification" //发布帖子点击发布按钮完成

#define kTTForumPostingThreadActionCancelledNotification @"kTTForumPostingThreadActionCancelledNotification" //取消发布帖子或无效cid
#define kTTUGCStoryScrollToIndexNotification @"kTTUGCStoryScrollToIndexNotification" // Story主页面横向滚动到index的通知
#define kTTUGCStoryVerticalScrollToIndexNotification @"kTTUGCStoryVerticalScrollToIndexNotification" // 混排Story竖向滚动到对应cell的通知

#pragma mark - Key

#define kTTForumThreadID @"kTTForumThreadID"
#define kTTFourmThreadExploreOrderedData @"TTFourmThreadExploreOrderedData"

//Post thread key
#define kTTForumPostThreadFakeThreadID @"TTForumPostThreadFakeThreadID"
#define kTTForumPostThreadConcernID @"TTForumPostThreadConcernID"
#define kTTForumPostThreadInsertMixCardID @"kTTForumPostThreadInsertMixCardID"
#define kTTForumPostThreadRelatedForumSubjectID @"kTTForumPostThreadRelatedForumSubjectID"
#define kTTForumPostThreadChallengeGroupID @"TTForumPostThreadChallengeGroupID"

#define kTopThreadNotificationKey @"topThreadNotificationKey"

#define kFRThreadIDKey @"kFRThreadIDKey"
#define kFRCommentIDKey @"kFRCommentIDKey"
#define kFRCommentKey @"kFRCommentKey"

#define kFRPostThreadSucessTime @"kFRPostThreadSucessTime"
#define kFRPostThreadIsRepost @"kFRPostThreadIsRepost"

//转发发布通知
#define kkRepostActionNotificationKey   @"kkRepostActionNotificationKey"


// UGC Story Category ID
#define kStoryCategoryID @"ugc_story" // Story的categoryID
#define kMixStoryCategoryID @"follow_in_feed" // 混排Story的categoryID

#define kFetchListConditionCategoryIDKey @"kFetchListConditionCategoryIDKey"            // 用于混排请求接口参数key
#define kFetchListConditionLoadMoreCountKey @"kFetchListConditionLoadMoreCountKey"      // 用于混排请求接口参数key

#pragma mark - Enum

typedef NS_ENUM(NSInteger, TTRequestRedPacketType) {
    TTRequestRedPacketTypeNone = -1,   //不请求红包
    TTRequestRedPacketTypeDefault = 0, //默认
    TTRequestRedPacketTypeFestival = 1, //春节活动
};

typedef NS_ENUM(NSUInteger, TTPostUGCEnterFrom) {
    TTPostUGCEnterFromCategory = 1,
    TTPostUGCEnterFromConcernHomepage = 2,
    TTPostUGCEnterFromWeitoutiaoTabTopEntrance = 3,
    TTPostUGCEnterFromSpringFestival = 4,//春节活动
    TTPostUGCEnterFromMusicCollection = 5,//音乐合集
    TTPostUGCEnterFromShortVideoDetail = 6,//小视频详情页
    TTPostUGCEnterFromAuthInterest = 7,//兴趣认证页
    TTPostUGCEnterFromOther = 8,//其他业务调用
//    TTPostUGCEnterFromMicroAppShare = 9,
//    TTPostUGCEnterFromMicroGameShare = 10,
    TTPostUGCEnterFromShareMicroApp = 26,//小程序分享
    TTPostUGCEnterFromShareMicroGame = 27,//小游戏分享
};

/**
 *  帖子实体的状态
 */
typedef NS_ENUM(NSUInteger, FRThreadEntityType){
    /**
     *  正常的帖子，正常的帖子
     */
    FRThreadEntityTypeNormal = 0,
    /**
     *  自己构造的假数据并且处在发送状态，不能进行相关操作
     */
    FRThreadEntityTypeFakePosting = 1,
    /**
     *  自己构造的假数据并且处在发送失败状态，不能进行相关操作，但是可以进行重新发送和删除操作
     */
    FRThreadEntityTypeFakeError = 2
};

/**
 *  帖子的状态，关联服务器的帖子状态
 */
typedef NS_ENUM(NSUInteger, FRThreadEntityStatusType){
    /**
     *  帖子已经删除，已经删除的帖子不应该出现在列表中
     */
    FRThreadEntityStatusTypeDelete = 0,
    /**
     *  帖子是所有人可见状态
     */
    FRThreadEntityStatusTypeAll = 1,
    /**
     *  帖子是仅自己可见状态
     */
    FRThreadEntityStatusTypeOnly = 2,
    /**
     *  帖子正在审核中
     */
    FRThreadEntityStatusTypeAudit = 4,
};

#endif /* TTUGCDefine_h */
