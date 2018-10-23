//
//  TTCommentDetailReplyCommentModelProtocol.h
//  Article
//
//  Created by pei yun on 2017/8/14.
//
//

// TODO 视频接入评论时去除

#ifndef TTCommentDetailReplyCommentModelProtocol_h
#define TTCommentDetailReplyCommentModelProtocol_h

@class SSUserModel;
@protocol TTCommentDetailReplyCommentModelProtocol <NSObject>

@property (nonatomic, strong, readonly) NSString *commentID;
@property (nonatomic, strong, readonly) SSUserModel *user;
@property (nonatomic, strong, readonly) NSString *content;
@property (nonatomic, strong, readonly) NSString *contentRichSpanJSONString;
@property (nonatomic, strong, readonly) NSString *qutoedCommentModel_commentID;
@property (nonatomic, strong, readonly) NSString *qutoedCommentModel_userName;
@property (nonatomic, strong, readonly) NSString *qutoedCommentModel_userID;
@property (nonatomic, strong, readonly) NSString *qutoedCommentModel_commentContent;
@property (nonatomic, strong, readonly) NSString *qutoedCommentModel_commentContentRichSpan;

@optional
- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err;

@end

#endif /* TTCommentDetailReplyCommentModelProtocol_h */
