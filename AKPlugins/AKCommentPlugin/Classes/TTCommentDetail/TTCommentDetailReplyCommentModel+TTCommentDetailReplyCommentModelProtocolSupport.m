//
//  TTCommentDetailReplyCommentModel+TTCommentDetailReplyCommentModelProtocolSupport.m
//  Article
//
//  Created by pei yun on 2017/8/14.
//
//

#import "TTCommentDetailReplyCommentModel+TTCommentDetailReplyCommentModelProtocolSupport.h"

@implementation TTCommentDetailReplyCommentModel (TTCommentDetailReplyCommentModelProtocolSupport)

- (NSString *)qutoedCommentModel_commentID {
    return self.qutoedCommentModel.commentID;
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

- (NSString *)qutoedCommentModel_commentContentRichSpan{
    return self.qutoedCommentModel.commentContentRichSpanJSONString;
}

@end
