//
//  TTVCommentListReplyModel.m
//  Article
//
//  Created by lijun.thinker on 2017/5/25.
//
//

#import "TTVCommentListReplyModel.h"
#import "TTVCommentListItem.h"

@implementation TTVCommentListReplyModel

+ (instancetype)replyModelWithComment:(id <TTVCommentModelProtocol>)comment replyAtIndex:(NSUInteger)index
{
    TTVCommentListReplyModel *replyModel = [TTVCommentListReplyModel new];
    
    TTReplyListStructModel *originModel = (comment.replyList.count > index) ? comment.replyList[index] :nil;
    
    replyModel.commentID = comment.commentIDNum.stringValue;
    replyModel.isArticleAuthor = originModel.is_pgc_author.boolValue;
    replyModel.replyID = originModel.id.stringValue;
    replyModel.userID = originModel.user_id.stringValue;
    replyModel.replyUserName = originModel.user_name;
    replyModel.replyContent = originModel.text;
    replyModel.replyContentRichSpanJSONString = originModel.content_rich_span;
    replyModel.userAuthInfo = originModel.user_auth_info;
    replyModel.authorBadge = originModel.author_badge;
    return replyModel;
}

+ (NSArray<TTVCommentListReplyModel *> *)replyListForComment:(id <TTVCommentModelProtocol>)comment {
    
    NSMutableArray *replyList = [[NSMutableArray alloc] initWithCapacity:comment.replyList.count];
    
    [comment.replyList enumerateObjectsUsingBlock:^(TTReplyListStructModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        TTVCommentListReplyModel *replyModel = [self replyModelWithComment:comment replyAtIndex:idx];
        
        if (replyModel) {
            
            [replyList addObject:replyModel];
        }
    }];
    
    return replyList;
}

- (BOOL)isUserReplyModel
{
    return !isEmptyString(self.commentID) && !isEmptyString(self.userID);
}

- (NSURL *)highlightedSelectURL
{
    NSString *urlString = nil;
    if (!isEmptyString(self.userID)) {
        urlString = [NSString stringWithFormat:@"sslocal://profile?uid=%@", self.userID];
    }
    else if (!isEmptyString(self.commentID)) {
        urlString = [NSString stringWithFormat:@"sslocal://moment?commentid=%@", self.commentID];
    }
    return [TTStringHelper URLWithURLString:urlString];
}

@end
