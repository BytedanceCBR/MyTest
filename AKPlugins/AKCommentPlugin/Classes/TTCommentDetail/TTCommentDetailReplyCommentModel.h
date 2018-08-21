//
//  TTCommentDetailReplyCommentModel.h
//  Article
//
//  Created by muhuai on 08/01/2017.
//
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>
#import <TTNewsAccountBusiness/SSUserModel.h>
#import "TTQutoedCommentModel.h"
 
@interface TTCommentDetailReplyCommentModel : JSONModel
@property (nonatomic, strong) NSString *commentID;
@property (nonatomic, strong) NSString<Ignore> *groupID; //手动添加的groupID
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *contentRichSpanJSONString;
@property (nonatomic, strong) TTQutoedCommentModel<Ignore> *qutoedCommentModel;
@property (nonatomic, strong) SSUserModel<Ignore> *user;
@property (nonatomic, assign) NSTimeInterval createTime;
@property (nonatomic, assign) NSInteger diggCount;
@property (nonatomic, assign) BOOL userDigg;
@property (nonatomic, assign) BOOL isPgcAuthor;
@property (nonatomic, assign) BOOL isOwner;
- (NSString *)userRelationDescription;

+ (TTCommentDetailReplyCommentModel *)createReplyCommentModelWithCommentRepostAndReplyDitionary:(NSDictionary *)commentRepostAndReplyDic;

@end
