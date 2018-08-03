//
//  TTCommentReplyListView.h
//  Article
//
//  Created by 冯靖君 on 15/12/3.
//
//

#import <TTThemed/SSThemed.h>
#import "TTCommentReplyTableViewCell.h"
#import "TTCommentModelProtocol.h"

@class TTCommentReplyModel;

@interface TTCommentReplyListView : SSThemedView

- (instancetype)initWithWidth:(CGFloat)width toComment:(id<TTCommentModelProtocol>)toComment NS_DESIGNATED_INITIALIZER;
- (void)refreshReplyListWithComment:(id<TTCommentModelProtocol>)commentModel;
- (void)refreshReplyListBackgroundColors;
- (void)refreshFramesWithWidth:(CGFloat)width;
- (void)didClickReplyToMakeAction:(TTCommentReplyActionBlock)block;
- (void)didClickReplyToViewUser:(TTCommentReplyActionBlock)block;
+ (CGFloat)heightForListViewWithReplyArr:(NSArray<TTCommentReplyModel *> *)replyArr width:(CGFloat)width toComment:(id<TTCommentModelProtocol>)toComment;
+ (BOOL)shouldShowMoreReplyCellForReplyArr:(NSArray *)replyArr toComment:(id<TTCommentModelProtocol>)toComment;

@end
