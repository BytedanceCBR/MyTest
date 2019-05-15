//
//  TTVCommentListReplyView.h
//  Article
//
//  Created by lijun.thinker on 2017/5/25.
//
//

#import "SSThemed.h"
#import "TTVCommentModelProtocol.h"
#import "TTVCommentListReplyTableViewCell.h"
#import "TTVCommentListReplyModel.h"

@interface TTVCommentListReplyView : SSThemedView

- (instancetype)initWithWidth:(CGFloat)width
                    toComment:(id <TTVCommentModelProtocol>)toComment NS_DESIGNATED_INITIALIZER;
- (void)refreshReplyListWithComment:(id <TTVCommentModelProtocol>)commentItem;
- (void)refreshReplyListBackgroundColors;
- (void)refreshFramesWithWidth:(CGFloat)width;
- (void)didClickReplyToMakeAction:(TTVCommentReplyActionBlock)block;
- (void)didClickReplyToViewUser:(TTVCommentReplyActionBlock)block;
+ (CGFloat)heightForListViewWithReplyArr:(NSArray<TTVCommentListReplyModel *> *)replyArr width:(CGFloat)width toComment:(id <TTVCommentModelProtocol>)toComment;
+ (BOOL)shouldShowMoreReplyCellForReplyArr:(NSArray *)replyArr toComment:(id <TTVCommentModelProtocol>)toComment;
@end
