//
//  TTProfileFillFrontView.h
//  Article
//
//  Created by jinqiushi on 2017/10/27.
//

#import "SSThemed.h"
#import "TTProfileFillViewController.h"

@class TTColorAsFollowButton;

@interface TTProfileFillFrontView : SSThemedView

@property (nonatomic, weak) TTProfileFillViewController *profileFillViewController;
@property (nonatomic, strong) SSThemedImageView *topPointerView;
@property (nonatomic, strong) SSThemedImageView *bottomPointerView;
@property (nonatomic, strong) SSThemedView *backgroundView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedImageView *iconImageView;
@property (nonatomic, strong) SSThemedTextField *nameTextField;
@property (nonatomic, strong) SSThemedLabel *indicateCommonLabel;
@property (nonatomic, strong) SSThemedLabel *indicateAlertLabel;
@property (nonatomic, strong) SSThemedButton *saveButton;
@property (nonatomic, strong) SSThemedButton *closeButton;

- (void)setAvatarUrl:(NSString *)avatarUrl;
- (void)setUserName:(NSString *)userName;
//出现之后的操作
- (void)actionsAfterShow;

@end
