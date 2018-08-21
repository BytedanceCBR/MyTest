//
//  TTVCommentListReplyTableViewCell.h
//  Article
//
//  Created by lijun.thinker on 2017/5/25.
//
//

#import "SSThemed.h"
#import "TTVCommentListReplyModel.h"

#define kMaxlineNumber   3
#define kVMargin      [TTDeviceUIUtils tt_newPadding:6.f]
#define kHMargin      12.f

typedef void(^TTVCommentReplyActionBlock)(TTVCommentListReplyModel *replyModel);

@interface TTVCommentListReplyTableViewCell : SSThemedTableViewCell

- (void)refreshWithModel:(TTVCommentListReplyModel *)replyModel width:(CGFloat)width;
- (void)handleUserClickActionWithBlock:(TTVCommentReplyActionBlock)block;
+ (CGFloat)tt_fontSize;
+ (CGFloat)tt_lineHeight;
+ (CGFloat)heightForReplyModel:(TTVCommentListReplyModel *)replyModel width:(CGFloat)width;

@end
