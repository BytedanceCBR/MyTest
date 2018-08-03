//
//  TTCommentDetailCell.h
//  二级评论详情页
//  Article
//
//  Created by muhuai on 08/01/2017.
//
//

#import <TTThemed/SSThemed.h>
#import "TTCommentDetailCellLayout.h"
#import "TTCommentDefines.h"


extern NSString *const kTTCommentDetailCellIdentifier;

@protocol TTCommentDetailCellDelegate <NSObject>

@optional

- (void)tt_commentCell:(UITableViewCell *)view replyButtonClickedWithModel:(TTCommentDetailReplyCommentModel *)model;
- (void)tt_commentCell:(UITableViewCell *)view avatarTappedWithCommentModel:(TTCommentDetailReplyCommentModel *)model;
- (void)tt_commentCell:(UITableViewCell *)view deleteCommentWithCommentModel:(TTCommentDetailReplyCommentModel *)model;
- (void)tt_commentCell:(UITableViewCell *)view digCommentWithCommentModel:(TTCommentDetailReplyCommentModel *)model;
- (void)tt_commentCell:(UITableViewCell *)view nameViewonClickedWithCommentModel:(TTCommentDetailReplyCommentModel *)model;
- (void)tt_commentCell:(UITableViewCell *)view quotedNameOnClickedWithCommentModel:(TTCommentDetailReplyCommentModel *)model;

@end


@interface TTCommentDetailCell : SSThemedTableViewCell

@property (nonatomic, weak) id<TTCommentDetailCellDelegate> delegate;
@property (nonatomic, assign) BOOL impressionShown;
@property (nonatomic, assign) BOOL isBanShowAuthor;
@property (nonatomic, copy) NSString *source;

- (void)tt_refreshConditionWithLayout:(TTCommentDetailCellLayout *)layout model:(TTCommentDetailReplyCommentModel *)model;
@end
