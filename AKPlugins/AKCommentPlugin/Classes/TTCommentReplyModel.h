//
//  TTCommentReplyModel.h
//  Article
//
//  文章详情页评论的回复，轻量级model
//
//  Created by 冯靖君 on 15/12/3.


#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@protocol TTCommentReplyModel <NSObject>
@end

@interface TTCommentReplyModel : JSONModel

@property(nonatomic, copy) NSString *replyID;
@property(nonatomic, copy) NSString<Optional> *commentID;
@property(nonatomic, copy) NSString *userID;
@property(nonatomic, copy) NSString *replyUserName;
@property(nonatomic, copy) NSString *replyContent;
@property(nonatomic, copy) NSString *replyContentRichSpanJSONString;
@property(nonatomic, assign) BOOL isArticleAuthor;
@property(nonatomic, copy) NSString<Optional> *userAuthInfo;
@property(nonatomic, copy) NSArray <Optional> *authorBadge;
@property(nonatomic, assign)BOOL  notReplyMsg;//不是回复，主要是和查看全部回复那条信息区分

+ (instancetype)replyModelWithDict:(NSDictionary *)dict forCommentID:(NSString *)commentID;

/**
 * 是否是用户回复
 * @return
 */
- (BOOL)isUserReplyModel;

/**
 * 高亮链接地址
 * @return
 */
- (NSURL *)highlightedSelectURL;

@end
