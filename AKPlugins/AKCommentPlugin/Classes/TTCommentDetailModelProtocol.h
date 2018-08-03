//
//  TTCommentDetailModelProtocol.h
//  Article
//
//  Created by pei yun on 2017/8/14.
//
//

// TODO 视频接入评论时去除

#ifndef TTCommentDetailModelProtocol_h
#define TTCommentDetailModelProtocol_h

@class TTGroupModel;
@protocol TTCommentDetailModelProtocol <NSObject>

@property (nonatomic, strong, readonly) TTGroupModel *groupModel;
@property (nonatomic, strong, readonly) NSString *commentID;
@property (nonatomic, assign, readonly) BOOL banEmojiInput;
@property (nonatomic, assign, readonly) NSString *commentPlaceholder;
@property (nonatomic, strong, readonly) NSString *userIDStr;
@property (nonatomic, strong, readonly) NSString *userName;
@property (nonatomic, strong, readonly) NSString *content;
@property (nonatomic, strong, readonly) NSString *contentRichSpanJSONString;
@property (nonatomic, strong, readonly) NSString *qutoedCommentModel_userName;
@property (nonatomic, strong, readonly) NSString *qutoedCommentModel_userID;
@property (nonatomic, strong, readonly) NSString *qutoedCommentModel_commentContent;
@property (nonatomic, strong, readonly) NSString *qutoedCommentModel_commentContentRichSpan;

@optional
- (NSNumber *)banForwardToWeitoutiao;

@end

#endif /* TTCommentDetailModelProtocol_h */
