//
//  TTCommentWriteViewDefine.h
//  TTUGCFoundation
//
//  Created by ranny_90 on 2018/2/2.
//

#ifndef TTCommentWriteViewDefine_h
#define TTCommentWriteViewDefine_h

#import "TTCommentDetailReplyCommentModelProtocol.h"

//评论发布通知
#define kCommentActionNotificationKey   @"kCommentActionNotificationKey"

//回复发布通知
#define kReplyActionNotificationKey   @"kReplyActionNotificationKey"


@class TTCommentWriteManager,TTCommentWriteView;

typedef void(^TTCommentDetailPublishCommentViewPublishCallback)(id<TTCommentDetailReplyCommentModelProtocol>replyModel , NSError *error);

typedef void(^TTCommentDetailWriteCommentViewLoginCallback)(id<TTCommentDetailReplyCommentModelProtocol>replyModel, NSDictionary *jsonObj, NSError *error);

typedef Class(^TTCommentGetReplyCommentModelClassCallback)();

typedef void(^TTCommentRepostParamsBlock)(NSString **willRepostFwID);

@protocol TTCommentWriteManagerDelegate <NSObject>

@optional
- (void)commentView:(TTCommentWriteView *) commentView cancelledWithCommentWriteManager:(TTCommentWriteManager *)commentWriteManager;
- (void)commentView:(TTCommentWriteView *) commentView sucessWithCommentWriteManager:(TTCommentWriteManager *)commentWriteManager responsedData:(NSDictionary *)responseData;
- (BOOL)commentView:(TTCommentWriteView *)commentView shouldCommitWithCommentWriteManager:(TTCommentWriteManager *)commentWriteManager;


@end


@protocol TTCommentManagerProtocol <NSObject>

@required

@property (nonatomic, strong) NSString *serviceID;            // 评论服务所属 serviceID, 评论接口使用

@property (nonatomic, weak) TTCommentWriteView *commentWriteView;

- (void)commentViewClickPublishButton;

- (void)commentViewShow;

- (void)commentViewDismiss;

- (void)commentViewCancelPublish;

@optional

- (void)commentViewClickRepostButton;

@end


#endif /* TTCommentWriteViewDefine_h */
