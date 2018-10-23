//
//  TTCommentAction.h
//  Article
//
//  Created by muhuai on 16/8/21.
//
//

#import <Foundation/Foundation.h>
#import "TTCommentModelProtocol.h"
#import "TTCommentDetailModel.h"
#import "TTCommentDetailReplyCommentModel.h"
#import "TTRedux.h"
#import <BDTArticle/Article.h>


typedef enum : NSUInteger {
    TTMomentDetailActionTypeReplyCommentDig,   //回复评论的点赞
    TTMomentDetailActionTypeCommentDig,        //主体评论点赞
    TTMomentDetailActionTypePublishComment,    //发表评论
    TTMomentDetailActionTypeDeleteComment,     //删除评论
    TTMomentDetailActionTypeShare,             //评论分享
    TTMomentDetailActionTypeUnblock,           //去掉拉黑
    TTMomentDetailActionTypeFollowNotify,      //响应关注通知
    TTMomentDetailActionTypeFollow,            //关注
    TTMomentDetailActionTypeUnfollow,
    TTMomentDetailActionTypeReport,            //举报
    TTMomentDetailActionTypeEnterProfile,      //进入主页
    TTMomentDetailActionTypeEnterDiggList,     //进入点赞列表
    TTMomentDetailActionTypeInit,              //初始化详情主页
    TTMomentDetailActionTypeRefreshComment,     //刷新评论区layout
    TTMomentDetailActionTypeWillAppear,        //刷新页面
    TTMomentDetailActionTypeDidAppear,
    TTMomentDetailActionTypeWillDisappear,
    TTMomentDetailActionTypeLoadComment,        //加载评论
    TTMomentDetailActionTypeLoadDig,            //加载点赞列表
    TTMomentDetailActionTypeBanEmojiInput       //禁用表情
} TTMomentDetailActionType;

typedef NS_ENUM(NSUInteger, TTCommentDetailSourceType) { //从哪里进入
    TTCommentDetailSourceTypeUnknown,
    TTCommentDetailSourceTypeDetail = 5,
    TTCommentDetailSourceTypeMessage = 7,
    TTCommentDetailSourceTypeThread = 10
};

typedef enum : NSUInteger {
    TTMomentDetailActionSourceTypeHeader,      //头部
    TTMomentDetailActionSourceTypeComment,     //评论区
    TTMomentDetailActionSourceTypeDig,          //点赞区
    TTMomentDetailActionSourceTypeBottom
} TTMomentDetailActionSourceType;

@interface TTMomentDetailAction : Action

@property (nonatomic, assign) TTMomentDetailActionType type;
@property (nonatomic, assign) TTMomentDetailActionSourceType source;
@property (nonatomic, assign) TTCommentDetailSourceType from;
@property (nonatomic, strong) id<TTCommentModelProtocol> commentModel;
@property (nonatomic, strong) TTCommentDetailModel *commentDetailModel;
@property (nonatomic, strong) TTCommentDetailReplyCommentModel *replyCommentModel;
@property (nonatomic, strong) Article *group;
@property (nonatomic, strong) NSDictionary *payload;

+ (instancetype)actionWithType:(TTMomentDetailActionType)type payload:(NSDictionary *)payload;
+ (instancetype)actionWithType:(TTMomentDetailActionType)type comment:(id<TTCommentModelProtocol>)commentModel;

+ (instancetype)enterProfileActionWithUserID:(NSString *)userID;

+ (instancetype)digActionWithReplyCommentModel:(TTCommentDetailReplyCommentModel *)model;

+ (instancetype)digActionWithCommentDetailModel:(TTCommentDetailModel *)model;

@end
