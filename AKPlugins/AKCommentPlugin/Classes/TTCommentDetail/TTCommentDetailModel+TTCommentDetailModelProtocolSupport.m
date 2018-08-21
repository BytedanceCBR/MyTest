//
//  TTCommentDetailModel+TTCommentDetailModelProtocolSupport.m
//  Article
//
//  Created by pei yun on 2017/8/14.
//
//

#import "TTCommentDetailModel+TTCommentDetailModelProtocolSupport.h"

@implementation TTCommentDetailModel (TTCommentDetailModelProtocolSupport)

- (NSString *)userIDStr
{
    return self.user.ID;
}

- (NSString *)userName
{
    return self.user.name;
}

- (NSString *)qutoedCommentModel_userID
{
    return self.qutoedCommentModel.userID;
}

- (NSString *)qutoedCommentModel_userName
{
    return self.qutoedCommentModel.userName;
}

- (NSString *)qutoedCommentModel_commentContent
{
    return self.qutoedCommentModel.commentContent;
}

-(NSString *)qutoedCommentModel_commentContentRichSpan{
    return self.qutoedCommentModel.commentContentRichSpanJSONString;
}

@end
