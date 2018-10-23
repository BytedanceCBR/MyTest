//
//  TTUniversalCommentCellLite.h
//  文章 图集 视频 一级评论
//  Article
//
//  Created by zhaoqin on 14/11/2016.
//
//

#import <TTThemed/SSThemed.h>
#import "TTCommentModelProtocol.h"
#import "TTCommentDefines.h"

#pragma mark - TTCommentCellDelegate

@protocol TTCommentCellDelegate <NSObject>

@optional

- (void)tt_commentCell:(nonnull UITableViewCell *)view replyButtonClickedWithModel:(nonnull id<TTCommentModelProtocol>)model;
- (void)tt_commentCell:(nonnull UITableViewCell *)view avatarTappedWithCommentModel:(nonnull id<TTCommentModelProtocol>)model;
- (void)tt_commentCell:(nonnull UITableViewCell *)view deleteCommentWithCommentModel:(nonnull id<TTCommentModelProtocol>)model;
- (void)tt_commentCell:(nonnull UITableViewCell *)view digCommentWithCommentModel:(nonnull id<TTCommentModelProtocol>)model;
- (void)tt_commentCell:(nonnull UITableViewCell *)view showMoreButtonClickedWithModel:(nonnull id<TTCommentModelProtocol>)model;
- (void)tt_commentCell:(nonnull UITableViewCell *)view replyListClickedWithModel:(nonnull id<TTCommentModelProtocol>)model;
- (void)tt_commentCell:(nonnull UITableViewCell *)view replyListAvatarClickedWithUserID:(nonnull NSString *)userID commentModel:(nonnull id<TTCommentModelProtocol>)model;
- (void)tt_commentCell:(nonnull UITableViewCell *)view nameViewonClickedWithCommentModel:(nonnull id<TTCommentModelProtocol>)model;
- (void)tt_commentCell:(nonnull UITableViewCell *)view quotedNameViewonClickedWithCommentModel:(nonnull id<TTCommentModelProtocol>)model;
- (void)tt_commentCell:(nonnull UITableViewCell *)view contentUnfoldWithCommentModel:(nonnull id<TTCommentModelProtocol>)model;
- (void)tt_commentCell:(nonnull UITableViewCell *)view tappedWithUserID:(nonnull NSString *)userID;
- (void)tt_commentCell:(nonnull UITableViewCell *)view superUserNameTappedWithCommentModel:(nonnull id<TTCommentModelProtocol>)model withSchema:(nullable NSString *)schema;

@end

@class TTUniversalCommentLayout;

@interface TTUniversalCommentCellLite : SSThemedTableViewCell

@property (nonatomic, strong) id<TTCommentModelProtocol> commentModel;
@property (nonatomic, weak) id<TTCommentCellDelegate> delegate;
@property (nonatomic, assign) BOOL impressionShown;

- (void)tt_refreshConditionWithLayout:(TTUniversalCommentLayout *)layout model:(id<TTCommentModelProtocol>)model;

@end
