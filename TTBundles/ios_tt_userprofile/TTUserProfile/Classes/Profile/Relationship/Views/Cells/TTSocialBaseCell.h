//
//  TTSocialBaseCell.h
//  Article
//
//  Created by liuzuopeng on 8/11/16.
//
//

#import <UIKit/UIKit.h>
#import "TTBaseUserProfileCell.h"
#import "TTFollowedModel.h"
#import "SSAvatarView+VerifyIcon.h"
#import "ArticleFriendModel.h"
#import "TTAlphaThemedButton.h"
#import "ArticleFriends.h"
#import "TTFriendModel.h"
#import "TTIconLabel.h"



/**
 * 别名：关注状态类型
 */
typedef FriendListCellUnitRelationButtonType TTFollowButtonStatusType;


@class TTSocialBaseCell;
@protocol TTSocialBaseCellDelegate <NSObject>
- (void)socialBaseCell:(TTSocialBaseCell *)cell didTapFollowButton:(id)sender;
@end


@interface TTSocialBaseCell <ModelType : TTFriendModel *> : TTBaseUserProfileCell
@property (nonatomic, weak) id<TTSocialBaseCellDelegate> delegate;

@property (nonatomic, strong, readonly) SSAvatarView   *avatarView;

@property (nonatomic, strong, readonly) TTIconLabel  *titleLabel;      // name Label
@property (nonatomic, strong, readonly) SSThemedLabel  *subtitle1Label;  // 共同好友label
@property (nonatomic, strong, readonly) SSThemedLabel  *subtitle2Label;  // 描述label

@property (nonatomic, strong, readonly) TTAlphaThemedButton *followStatusButton; //关注按钮
/**
 * text container, 包含titleLabel, subtitle1Label, subtitle2Label, verifiedImageView, toutiaoImageView
 */
@property (nonatomic, strong, readonly) SSThemedView   *textContainerView;

/**
 *  Model
 */
@property (nonatomic, strong, readonly) ModelType currentFriend;


- (void)reloadWithModel:(ModelType)aModel;
//- (void)refresh; //refresh with current model
- (void)updateFollowButtonStatus;
- (void)updateFollowButtonForType:(TTFollowButtonStatusType)type;
- (void)setAvatarViewStyle:(NSUInteger)style;
- (void)startLoading; // start loading animation
- (void)stopLoading;  // end   loading animation

+ (TTFollowButtonStatusType)friendRelationTypeOfModel:(ModelType)aModel;

+ (NSString *)titleColorThemeKey;
+ (NSString *)subtitle1ColorThemeKey;
+ (NSString *)subtitle2ColorThemeKey;
+ (NSString *)buttonTextColorThemeKey;

+ (CGFloat)titleFontSize;
+ (CGFloat)subtitle1FontSize;
+ (CGFloat)subtitle2FontSize;
+ (CGFloat)buttonTextFontSize;

+ (CGFloat)imageNormalSize;
+ (CGSize)verifyIconSize:(CGSize)standardSize;
+ (CGFloat)imageSize;       // image's width and height is equal
+ (CGFloat)spacingOfTitle;  // spacing between title, subtitle1 and subtitle2
+ (CGFloat)spacingByMargin; // spacing to margin

//针对粉丝列表，第一个cell空出来一些， default is 0
+ (CGFloat)extraInsetTop;

// cell height
+ (CGFloat)cellHeightOfModel:(ModelType)aModel;
@end
