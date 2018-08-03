//
//  TTVReplyModel.h
//  Article
//
//  Created by lijun.thinker on 2017/6/2.
//
//

#import <Foundation/Foundation.h>
#import "TTVReplyModelProtocol.h"
#import <JSONModel/JSONModel.h>
#import "TTCommentDetailReplyCommentModelProtocol.h"

@interface TTVReplyModel : JSONModel <TTVReplyModelProtocol, TTCommentDetailReplyCommentModelProtocol>
@property (nonatomic, strong) NSString *commentID;
@property (nonatomic, strong) NSString<Ignore> *groupID; //手动添加的groupID
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *contentRichSpanJSONString;
@property (nonatomic, strong) TTQuotedCommentStructModel<Ignore> *qutoedCommentModel;
@property (nonatomic, strong) SSUserModel<Ignore> *user;
@property (nonatomic, assign) NSTimeInterval createTime;
@property (nonatomic, assign) NSInteger diggCount;
@property (nonatomic, assign) BOOL userDigg;
@property (nonatomic, assign) BOOL isPgcAuthor;
@property (nonatomic, assign) BOOL isOwner;
@end
