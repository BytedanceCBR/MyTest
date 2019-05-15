//
//  ExploreCommentCell.h
//  Article
//
//  Created by Zhang Leonardo on 14-10-21.
//
//

#import <Foundation/Foundation.h>
#import "SSCommentModel.h"
#import "SSThemed.h"

@protocol ExploreCommentViewCellBaseDelegate;

@interface ExploreCommentCell : SSThemedTableViewCell

@property(nonatomic, strong, readonly)SSCommentModel * commentModel;
@property(nonatomic, assign) BOOL hasShown;     //带话题时发送show事件

@property(nonatomic, weak)id<ExploreCommentViewCellBaseDelegate> delegate;

// for bug fix
@property(nonatomic, strong)UIButton * commentButton;

+ (CGFloat)heightForModel:(SSCommentModel *)model width:(CGFloat)width;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier frame:(CGRect)frame isEssay:(BOOL)isEssay;

- (void)refreshCondition:(SSCommentModel *)model;

- (void)shouldHideBottomline:(BOOL)shouldHide;

@end

@protocol ExploreCommentViewCellBaseDelegate <NSObject>

@optional

- (void)commentViewCellBase:(ExploreCommentCell *)view replyButtonClickedWithModel:(SSCommentModel *)model;
- (void)commentViewCellBase:(ExploreCommentCell *)view avatarTappedWithCommentModel:(SSCommentModel *)model;
- (void)commentViewCellBase:(ExploreCommentCell *)view deleteCommentWithCommentModel:(SSCommentModel *)model;

- (void)commentViewCellBase:(ExploreCommentCell *)view showMoreButtonClickedWithModel:(SSCommentModel *)model;
- (void)commentViewCellBase:(ExploreCommentCell *)view replyListClickedWithModel:(SSCommentModel *)model;

- (void)commentViewCellBase:(ExploreCommentCell *)view replyListAvatarClickedWithUserID:(NSString *)userID commentModel:(SSCommentModel *)model;

@end

