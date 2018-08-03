//
//  FriendListCellUnit.h
//  Article
//
//  Created by Zhang Leonardo on 13-12-19.
//
//

#import "SSViewBase.h"
#import "ArticleFriends.h"
#import "SSAvatarView.h"

@class ArticleFriendModel;

@interface NewFriendListCellUnit : SSViewBase
@property(nonatomic, strong, readonly)UIButton * relationButton;
@property(nonatomic, strong)ArticleFriendModel *friendModel;
@property(nonatomic, assign)FriendListCellUnitRelationButtonType relationButtonType;
@property(nonatomic, strong)SSAvatarView * avatarView;
@property(nonatomic, assign)CGFloat cellUnitHeight;
- (void)showTipNew:(BOOL)show;
- (CGFloat)calculateHeight;
- (void)refreshFrame;
@end
