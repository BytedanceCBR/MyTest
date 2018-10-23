//
//  TTPersonalHomeHeaderOperationView.m
//  Article
//
//  Created by 王迪 on 2017/3/13.
//
//

#import "TTPersonalHomeHeaderOperationView.h"
#import "TTAsyncCornerImageView+VerifyIcon.h"
#import "NSStringAdditions.h"
#import "TTThemeManager.h"
#import <objc/runtime.h>
#import <Masonry.h>

//最左侧是头像，根据是否是自己，区分为以下两种情况：
//1、自己 从右往左 编辑资料、申请加V（服务端返回，不一定显示）
//2、他人 从右往左 关注卡片展开的指示按钮（不一定显示）、关注按钮、发私信按钮（根据用户显示），下方还有一个指示的三角，三角一直显示，下面会遮上
@interface TTPersonalHomeHeaderOperationView () {
    BOOL _isSpread;
}

@end

@implementation TTPersonalHomeHeaderOperationView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.backgroundColorThemeKey = kColorBackground4;
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview
{
    CGFloat iconViewX = [TTDeviceUIUtils tt_newPadding:15];
    CGFloat iconViewW = [TTDeviceUIUtils tt_newPadding:80];
    CGFloat iconViewH = iconViewW;
    CGFloat iconViewY = -iconViewW * 0.5;
    TTPersonalHomeIconView *iconView = [[TTPersonalHomeIconView alloc] initWithFrame:CGRectMake(iconViewX, iconViewY, iconViewW, iconViewH)];
    iconView.placeHolder = @"default_avatar";
    iconView.userInteractionEnabled = YES;
    [self addSubview:iconView];
    self.iconView = iconView;
    
    
    CGFloat followViewW = [TTDeviceUIUtils tt_newPadding:72];
    CGFloat followViewH = [TTDeviceUIUtils tt_newPadding:28];
    CGFloat followViewY = [TTDeviceUIUtils tt_newPadding:15];
    
    TTFollowThemeButton* followButton = [[TTFollowThemeButton alloc] initWithUnfollowedType:TTUnfollowedType101 followedType:TTFollowedType101 followedMutualType:TTFollowedMutualType101];
    followButton.constWidth = followViewW;
    followButton.constHeight = followViewH;
    followButton.hidden = YES;
    [self addSubview:followButton];
    self.followButton = followButton;
    
    [followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(followViewY);
        make.right.equalTo(self.mas_right).offset(-[TTDeviceUIUtils tt_newPadding:15]);
        make.height.offset(followViewH);
        make.width.offset(followViewW);
    }];
    
    SSThemedButton *operationbtn = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    operationbtn.layer.cornerRadius =  4;
    operationbtn.layer.masksToBounds = YES;
    operationbtn.layer.borderWidth = 1;
    operationbtn.hidden = YES;
    operationbtn.imageName = @"personal_home_arrow";
    operationbtn.backgroundColorThemeKey = kColorBackground4;
    operationbtn.borderColorThemeKey = kColorLine1;
    [operationbtn setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [self addSubview:operationbtn];
    self.recommendViewOperationBtn = operationbtn;
    [operationbtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.offset([TTDeviceUIUtils tt_newPadding:28]);
        make.height.offset([TTDeviceUIUtils tt_newPadding:28]);
        make.centerY.equalTo(followButton.mas_centerY);
        make.right.equalTo(self.mas_right).offset(-[TTDeviceUIUtils tt_newPadding:15]);
    }];
    
    SSThemedButton *beFollowedBtn = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    beFollowedBtn.titleColorThemeKey = kColorText1;
    beFollowedBtn.userInteractionEnabled = NO;
    beFollowedBtn.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
    [self addSubview:beFollowedBtn];
    beFollowedBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    beFollowedBtn.width = [beFollowedBtn.currentTitle sizeWithFontCompatible:beFollowedBtn.titleLabel.font].width;
    beFollowedBtn.alpha = 0;
    beFollowedBtn.height = [TTDeviceUIUtils tt_newPadding:20];
    [self addSubview:beFollowedBtn];
    self.beFollowedBtn = beFollowedBtn;
    
    [beFollowedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(followButton.mas_left).offset(-18);
        make.centerY.equalTo(followButton.mas_centerY);
    }];
    
    TTPersonalHomeFollowButton *unBlockView = [TTPersonalHomeFollowButton buttonWithType:UIButtonTypeCustom];
    unBlockView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    unBlockView.width = [TTDeviceUIUtils tt_newPadding:72];
    unBlockView.height = [TTDeviceUIUtils tt_newPadding:28];
    unBlockView.hidden = YES;
    unBlockView.left = self.width - [TTDeviceUIUtils tt_newPadding:15] - unBlockView.width;
    unBlockView.top = [TTDeviceUIUtils tt_newPadding:15];
    [unBlockView setTitle:@"解除拉黑" forState:UIControlStateNormal];
    [self addSubview:unBlockView];
    self.unBlockView = unBlockView;
    
    TTPersonalHomeFollowButton *profileView = [TTPersonalHomeFollowButton buttonWithType:UIButtonTypeCustom];
    profileView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [profileView setTitle:@"编辑资料" forState:UIControlStateNormal];
    profileView.hidden = YES;
    profileView.frame = unBlockView.frame;
    [self addSubview:profileView];
    self.profileView = profileView;
    
//    SSThemedButton *certificationBtn = [SSThemedButton buttonWithType:UIButtonTypeCustom];
//    certificationBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//    certificationBtn.titleColorThemeKey = kColorText5;
//    certificationBtn.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
//    certificationBtn.hidden = YES;
//    [self addSubview:certificationBtn];
////    self.certificationBtn = certificationBtn;
    
    SSThemedImageView *sanjiaoIcon = [[SSThemedImageView alloc] init];
    sanjiaoIcon.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    sanjiaoIcon.imageName = @"sanjiao";
    sanjiaoIcon.width = 12;
    sanjiaoIcon.height = 5;
    sanjiaoIcon.hidden = YES;
    sanjiaoIcon.centerX = self.width - [TTDeviceUIUtils tt_newPadding:15] - [TTDeviceUIUtils tt_newPadding:14];
    [self addSubview:sanjiaoIcon];
    self.sanjiaoIcon = sanjiaoIcon;
    
    self.height = followViewH + followViewY + [TTDeviceUIUtils tt_newPadding:6] + sanjiaoIcon.height;
    sanjiaoIcon.top = self.height - sanjiaoIcon.height;
    
}

- (void)setInfoModel:(TTPersonalHomeUserInfoDataResponseModel *)infoModel
{
    _infoModel = infoModel;
    [self setupSubviewData];
}

- (void)setupSubviewData {
    [self.iconView setImageWithURL:self.infoModel.avatar_url];
    [self.iconView setDecoratorWithURL:self.infoModel.user_decoration userID:self.infoModel.user_id];
    if([self.infoModel.current_user_id isEqualToString:self.infoModel.user_id]) {
        self.profileView.hidden = NO;
        self.followButton.hidden = YES;
        self.unBlockView.hidden = YES;
//        self.certificationBtn.hidden = NO;
//        [self.certificationBtn setTitle:self.infoModel.apply_auth_entry_title forState:UIControlStateNormal];
//        self.certificationBtn.width = [self.certificationBtn.currentTitle sizeWithFontCompatible:self.certificationBtn.titleLabel.font].width;
//        self.certificationBtn.height = [TTDeviceUIUtils tt_newPadding:20];
//        self.certificationBtn.centerY = self.profileView.centerY;
//        self.certificationBtn.right = self.profileView.left - 18;

    } else {
        self.profileView.hidden = YES;
//        self.certificationBtn.hidden = YES;
        self.followButton.followed = [self.infoModel.is_following boolValue];
        self.followButton.beFollowed = [self.infoModel.is_followed boolValue];
        if(self.infoModel.is_blocking.integerValue == 1) {
            self.followButton.hidden = YES;
            self.unBlockView.hidden = NO;
        } else {
            self.followButton.hidden = NO;
            self.unBlockView.hidden = YES;
        }
    }
    
    if (!isEmptyString(self.infoModel.followed_desc) && self.infoModel.is_followed.boolValue && !self.infoModel.is_following.boolValue) {
        [self.beFollowedBtn setTitle:self.infoModel.followed_desc forState:UIControlStateNormal];
        self.beFollowedBtn.hidden = NO;
    } else {
        self.beFollowedBtn.hidden = YES;
    }
    
    if ([self.infoModel.activity.redpack isKindOfClass:[FRRedpackStructModel class]]) {
        FRRedpackStructModel* redpacketModel = self.infoModel.activity.redpack;
        self.followButton.unfollowedType = [TTFollowThemeButton redpacketButtonUnfollowTypeButtonStyle:redpacketModel.button_style.integerValue defaultType:TTUnfollowedType201];

        if (self.followButton.hidden == NO && self.followButton.followed == NO) { //未关注同时关注按钮出现了，发送埋点
            NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObject:@"profile" forKey:@"category_name"];
            [dic setValue:@"show" forKey:@"action_type"];
            [dic setValue:self.infoModel.user_id forKey:@"user_id"];
            [dic setValue:self.infoModel.media_id forKey:@"media_id"];
            [dic setValue:@"profile" forKey:@"source"];
            [TTTrackerWrapper eventV3:@"red_button" params:dic];
        }
    } else {
        self.followButton.unfollowedType = TTUnfollowedType101;
    }
    [self.followButton refreshUI];
    
    [self setPrivateMessage];
    
    if([TTVerifyIconHelper isVerifiedOfVerifyInfo:self.infoModel.user_auth_info]) {
        self.hasVerified = YES;
    }
    
    [self.iconView showPersonalVerifyViewWithVerifyInfo:self.infoModel.user_auth_info size:kTTVerifyAvatarVerifyIconSizeBig];
    self.sanjiaoIcon.hidden = NO;
}

- (void)setVerified {
    [self.iconView showPersonalVerifyViewWithVerifyInfo:self.infoModel.user_auth_info size:kTTVerifyAvatarVerifyIconSizeBig];
}

- (void)clearVerified {
    [self.iconView.avatarVerifyView removeFromSuperview];
    self.iconView.avatarVerifyView = nil;
}

- (void)setPrivateMessage {
    if([self shouldShowPrivateMessage]) {
        self.beFollowedBtn.alpha = 1;
    } else {
        self.beFollowedBtn.alpha = 0;
    }
}

- (BOOL)shouldShowPrivateMessage
{
    if(self.infoModel.show_private_letter.integerValue == 1 && [SSCommonLogic isIMServerEnable] && self.infoModel.is_blocking.integerValue != 1 && ![self.infoModel.user_id isEqualToString:self.infoModel.current_user_id]) {
        return YES;
    }
    return NO;
}

- (void)recommendViewOperationBtnAnimationWithSpread:(BOOL)isSpread {
    if (isSpread == _isSpread) {
        return;
    }
    _isSpread = isSpread;
    if(isSpread) {
        [self layoutIfNeeded];
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            [self.followButton mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.right.equalTo(self.mas_right).offset(-[TTDeviceUIUtils tt_newPadding:15] - 4 - self.recommendViewOperationBtn.width);
//            }];
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
//            self.recommendViewOperationBtn.hidden = !_isSpread;
            self.recommendViewOperationBtn.hidden = YES;
            self.recommendViewOperationBtn.selected = !_isSpread;
            if (_isSpread) {
                self.recommendViewOperationBtn.imageView.transform = CGAffineTransformMakeRotation(0);
            }
        }];
    } else {
        self.recommendViewOperationBtn.hidden = YES;
        [self layoutIfNeeded];
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//            [self.followButton mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.right.equalTo(self.mas_right).offset(-[TTDeviceUIUtils tt_newPadding:15]);
//            }];
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
//            self.recommendViewOperationBtn.hidden = !_isSpread;
            self.recommendViewOperationBtn.hidden = YES;
            self.recommendViewOperationBtn.selected = !_isSpread;
            if (_isSpread) {
                self.recommendViewOperationBtn.imageView.transform = CGAffineTransformMakeRotation(0);
            }
        }];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if(CGRectContainsPoint(self.iconView.frame, point)) {
        return self.iconView;
    }
    return [super hitTest:point withEvent:event];
}


@end
