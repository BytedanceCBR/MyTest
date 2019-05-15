//
//  TTCommentDetailReplyCommentModel+TTVReplyModelProtocolSupport.m
//  Article
//
//  Created by pei yun on 2017/11/23.
//

#import "TTCommentDetailReplyCommentModel+TTVReplyModelProtocolSupport.h"

@implementation TTCommentDetailReplyCommentModel (TTVReplyModelProtocolSupport)

- (TTQuotedCommentStructModel *)tt_qutoedCommentStructModel
{
    return [[TTQuotedCommentStructModel alloc] initWithDictionary:[self.qutoedCommentModel toDictionary] error:nil];
}

@end
