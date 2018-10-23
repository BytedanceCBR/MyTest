//
//  FriendListCellUnit.h
//  Article
//
//  Created by Zhang Leonardo on 13-12-19.
//
//

#import "SSViewBase.h"
#import "SSAvatarView.h"
#import "ArticleFriends.h"

#define FriendListCellUnitHeight 66.f


@interface FriendListCellUnit : SSViewBase
@property(nonatomic, retain, readonly)UIButton * relationButton;
@property(nonatomic, assign)FriendListCellUnitVerifyType verifyType;
@property(nonatomic, assign)FriendListCellUnitRelationButtonType relationButtonType;

- (void)setTitleText:(NSString *)title;
- (void)setDesc:(NSString *)desc;
- (void)setAvatarURLString:(NSString *)avatarURLString;
- (void)setPlatformType:(FriendListCellUnitPlatformType)platformType;
- (void)showTipNew:(BOOL)show;
- (void)refreshFrame;

@end
