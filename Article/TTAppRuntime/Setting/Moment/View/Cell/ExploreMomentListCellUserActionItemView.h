//
//  ExploreMomentListCellUserActionItemView.h
//  Article
//
//  Created by Zhang Leonardo on 15-1-16.
//
//  动态cell中的元素， 用于显示用户顶踩评论的动作

#import "ExploreMomentListCellItemBase.h"
@class ArticleMomentModel;

@protocol ExploreMomentListCellUserActionItemDelegate <NSObject>

- (void)didDigMoment:(ArticleMomentModel *)model;
- (void)didSendCommentToMoment:(ArticleMomentModel *)model;

@end

@interface ExploreMomentListCellUserActionItemView : ExploreMomentListCellItemBase

//转发到“我得动态”合并至分享界面
@property(nonatomic, retain)UIButton * forwardButton;
@property (nonatomic, retain) UIButton * commentButton;
@property (nonatomic, weak) id<ExploreMomentListCellUserActionItemDelegate> delegate;

- (void)forwardButtonClicked;

@end
