//
//  TTVCommentListReplyModel.h
//  Article
//
//  Created by lijun.thinker on 2017/5/25.
//
//

#import <Foundation/Foundation.h>

@protocol TTVCommentModelProtocol;
@interface TTVCommentListReplyModel : NSObject

@property(nonatomic, copy) NSString *replyID;
@property(nonatomic, copy) NSString<Optional> *commentID;
@property(nonatomic, copy) NSString *userID;
@property(nonatomic, copy) NSString *replyUserName;
@property(nonatomic, copy) NSString *replyContent;
@property(nonatomic, copy) NSString *replyContentRichSpanJSONString;
@property(nonatomic, copy) NSString<Optional> *userAuthInfo;
@property(nonatomic, copy) NSArray <Optional> *authorBadge;
@property(nonatomic, assign) BOOL isArticleAuthor;
@property(nonatomic, assign) BOOL notReplyMsg;

+ (instancetype)replyModelWithComment:(id <TTVCommentModelProtocol>)comment replyAtIndex:(NSUInteger)index;

+ (NSArray <TTVCommentListReplyModel *> *)replyListForComment:(id <TTVCommentModelProtocol>)comment;

//是否是用户回复
- (BOOL)isUserReplyModel;
- (NSURL *)highlightedSelectURL;

@end
