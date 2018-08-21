//
//  TTCommentReplyTableViewCell.h
//  Article
//
//  Created by 冯靖君 on 15/12/3.
//
//

#import <TTThemed/SSThemed.h>
#import "TTCommentReplyModel.h"

#define kMaxlineNumber   3
#define kVMargin      [TTDeviceUIUtils tt_newPadding:6.f]
#define kHMargin      12.f

typedef void(^TTCommentReplyActionBlock)(TTCommentReplyModel *replyModel);

@interface TTCommentReplyTableViewCell : SSThemedTableViewCell

- (void)refreshWithModel:(TTCommentReplyModel *)replyModel width:(CGFloat)width;
- (void)handleUserClickActionWithBlock:(TTCommentReplyActionBlock)block;
+ (CGFloat)tt_fontSize;
+ (CGFloat)tt_lineHeight;
+ (CGFloat)heightForReplyModel:(TTCommentReplyModel *)replyModel width:(CGFloat)width;

@end
