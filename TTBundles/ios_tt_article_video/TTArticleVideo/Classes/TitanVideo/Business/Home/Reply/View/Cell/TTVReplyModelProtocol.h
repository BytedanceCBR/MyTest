//
//  TTVReplyModelProtocol.h
//  Article
//
//  Created by lijun.thinker on 2017/6/1.
//
//

#import "TTPCHHeader.h"
#import "SSUserModel.h"

@protocol TTVReplyModelProtocol <NSObject>

@property (nonatomic, strong, readonly) NSString *commentID;
@property (nonatomic, strong, readonly) NSString *groupID; //手动添加的groupID
@property (nonatomic, strong, readonly) NSString *content;
@property (nonatomic, strong, readonly) NSString *contentRichSpanJSONString;
@property (nonatomic, strong, readonly) TTQuotedCommentStructModel *tt_qutoedCommentStructModel;
@property (nonatomic, strong, readonly) SSUserModel *user;
@property (nonatomic, assign, readonly) NSTimeInterval createTime;
@property (nonatomic, assign) NSInteger diggCount;
@property (nonatomic, assign) BOOL userDigg;
@property (nonatomic, assign, readonly) BOOL isPgcAuthor;
@property (nonatomic, assign, readonly) BOOL isOwner;
- (NSString *)userRelationDescription;

@end


