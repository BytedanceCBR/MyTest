//
//  TTProfileNameContainerView.m
//  Article
//
//  Created by liuzuopeng on 9/5/16.
//
//

#import "TTProfileNameContainerView.h"
#import "TTProfileThemeConstants.h"
#import "TTProfileHeaderView.h"
#import "TTFollowingViewController.h"
#import "TTFollowedViewController.h"
#import "TTVisitorViewController.h"
#import "TTRelationshipViewController.h"
//#import "TTCommonwealHasLoginEntranceView.h"
//#import "TTCertificationConst.h"
#import "TTPersonalHomeManager.h"
#import "TTPersonalHomeUserInfoResponseModel.h"
#import <TTVerifyKit/TTVerifyIconHelper.h>
#import "SSCommonLogic.h"
#import <TTAccountBusiness.h>



@interface TTNameContainerView ()
@property (nonatomic, assign) NSUInteger maxWidth;
@property (nonatomic, assign) BOOL shouldShowVerifyEntrance;
@property (nonatomic, assign) BOOL isRealNameAuthUser;
@end
@implementation TTNameContainerView
- (instancetype)init {
    if ((self = [super init])) {
        
        if ([SSCommonLogic commonwealEntranceEnable]) {
            _maxWidth = [TTUIResponderHelper screenSize].width - kTTProfileAvatarLeftMargin - kTTProfileUserAvatarWidth - kTTProfileMoreButtonRightMargin - [TTDeviceUIUtils tt_newPadding:10];
        } else {
            _maxWidth = [TTUIResponderHelper screenSize].width - kTTProfileAvatarLeftMargin - kTTProfileUserAvatarWidth - kTTProfileMoreButtonRightMargin - [TTDeviceUIUtils tt_newPadding:50.f];
        }
        
        self.clipsToBounds = NO;
        [self addSubview:self.nameLabel];
        // [self addSubview:self.verifiedUserImageView];
        [self addSubview:self.toutiaohaoUserImageView];
        [self addSubview:self.rightArrowImageView];
        [self addSubview:self.showInfoLabel];
        [self addSubview:self.followersButton];
        [self addSubview:self.visitorButton];
//        [self addSubview:self.addAuthLabel];
//        [self addSubview:self.addAuthImageView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_nameLabel sizeToFit];
    CGFloat maxHeight = _nameLabel.height;
    CGFloat realWidth = _nameLabel.width;
    CGFloat maxWidth = 0;
    //    if (!_verifiedUserImageView.hidden) {
    //        maxHeight = ceilf(MAX(maxHeight, _verifiedUserImageView.height));
    //        realWidth += ceilf([TTDeviceUIUtils tt_newPadding:6.f/2] + _verifiedUserImageView.width);
    //    }
    
    if (![SSCommonLogic commonwealEntranceEnable]) {
        if (!_toutiaohaoUserImageView.hidden) {
            maxHeight = ceilf(MAX(maxHeight, _toutiaohaoUserImageView.height));
            realWidth += ceilf([TTDeviceUIUtils tt_newPadding:8.f/2] + _toutiaohaoUserImageView.width);
        }
    }
    
    CGFloat offsetX = 0;
    
    if (!isEmptyString(_nameLabel.text)) {
        _nameLabel.frame = CGRectMake(offsetX, (maxHeight - _nameLabel.height)/2, ceilf(_nameLabel.width - MAX(0, realWidth - _maxWidth)),ceilf( _nameLabel.height));
//        if (!_addAuthImageView.hidden) {
//            _addAuthImageView.top = _nameLabel.bottom + [TTDeviceUIUtils tt_newPadding:10.f];
//            _addAuthImageView.left = _nameLabel.left;
//            offsetX = ceilf(MAX(_nameLabel.right, _nameLabel.right));
//            maxWidth = offsetX;
//            maxHeight = _addAuthImageView.bottom;
//        } else {
            offsetX = self.nameLabel.right;
            maxWidth = self.nameLabel.right;
//        }
    }
    
    //    if (!_verifiedUserImageView.hidden) {
    //        offsetX += [TTDeviceUIUtils tt_newPadding:6.f/2];
    //
    //        _verifiedUserImageView.left = offsetX;
    //        _verifiedUserImageView.centerY = maxHeight / 2;
    //
    //        offsetX = _verifiedUserImageView.right;
    //    }
    
//    if ([SSCommonLogic commonwealEntranceEnable]) {
//        if (!_toutiaohaoUserImageView.hidden) {
//            _toutiaohaoUserImageView.left = _nameLabel.left;
//            _toutiaohaoUserImageView.top = _nameLabel.bottom + [TTDeviceUIUtils tt_newPadding:8];
//            maxWidth = MAX(maxWidth, _toutiaohaoUserImageView.right);
//            maxHeight = _toutiaohaoUserImageView.bottom;
//            if (!_addAuthLabel.hidden) {
//                _addAuthLabel.left = _nameLabel.left;
//                _addAuthLabel.top = _toutiaohaoUserImageView.bottom + [TTDeviceUIUtils tt_newPadding:6];
//                maxWidth = MAX(maxWidth, _addAuthLabel.right);
//                maxHeight = _addAuthLabel.bottom;
//            }
//        }
//    } else {
        if (!_toutiaohaoUserImageView.hidden) {
            offsetX += [TTDeviceUIUtils tt_newPadding:8.f/2];
            
            _toutiaohaoUserImageView.left = offsetX;
            _toutiaohaoUserImageView.centerY = maxHeight / 2;
            offsetX = _toutiaohaoUserImageView.right;
        }
//    }
    
    if (![SSCommonLogic commonwealEntranceEnable]) {
        offsetX += [TTDeviceUIUtils tt_newPadding:8.f/2];
        self.rightArrowImageView.left = offsetX;
//        if (!_addAuthImageView.hidden) {
//            self.rightArrowImageView.centerY = ceilf(_nameLabel.centerY + _addAuthImageView.centerY / 2);
//        } else {
            self.rightArrowImageView.centerY = _nameLabel.centerY;
//        }
        offsetX = self.rightArrowImageView.right;
    }
    
//    if ([SSCommonLogic commonwealEntranceEnable]) {
//        if (!_showInfoLabel.hidden) {
//            if (!isEmptyString(_showInfoLabel.text)) {
//                CGFloat showInfoLabelMaxWidth = 0;
//                if (!_toutiaohaoUserImageView.hidden) {
//                    showInfoLabelMaxWidth = _maxWidth - self.toutiaohaoUserImageView.size.width - [TTDeviceUIUtils tt_newPadding:4.5];
//                } else {
//                    showInfoLabelMaxWidth = _maxWidth;
//                }
//                _showInfoLabel.width = _showInfoLabel.width <= showInfoLabelMaxWidth  ? _showInfoLabel.width : showInfoLabelMaxWidth;
//            }
//
//            _showInfoLabel.left = _toutiaohaoUserImageView.hidden ?_nameLabel.left : _toutiaohaoUserImageView.right + [TTDeviceUIUtils tt_newPadding:4.5];
//            _showInfoLabel.centerY = _toutiaohaoUserImageView.centerY;
//            if (!_addAuthLabel.hidden) {
//                maxHeight = _addAuthLabel.bottom;
//            } else {
//                maxHeight = _toutiaohaoUserImageView.bottom;
//            }
//            maxWidth = MAX(maxWidth, _showInfoLabel.right);
//        }
//
//    } else {
        if (!_showInfoLabel.hidden) {
            if (!isEmptyString(_showInfoLabel.text)) {
                _showInfoLabel.width = _showInfoLabel.width <= _maxWidth ? _showInfoLabel.width : _maxWidth;
            }
            
            _showInfoLabel.left = _nameLabel.left;
            _showInfoLabel.top = _nameLabel.bottom + ([self useTemporaryLayout] ? kTTProfileShowInfoTemporaryTopOffset : kTTProfileShowInfoTopOffset);
            offsetX = MAX(ceilf(offsetX), ceilf(_showInfoLabel.width));
            maxHeight += ([self useTemporaryLayout] ? kTTProfileShowInfoTemporaryTopOffset : kTTProfileShowInfoTopOffset) + _showInfoLabel.height;
            
//            if (!_addAuthLabel.hidden) {
//                _addAuthLabel.left = _showInfoLabel.left;
//                _addAuthLabel.top = _showInfoLabel.bottom + [TTDeviceUIUtils tt_newPadding:6];
//                offsetX = MAX(ceilf(offsetX), ceilf(_addAuthLabel.width));
//                maxHeight += _addAuthLabel.height;
//            }
        }
//    }
    
    if (![SSCommonLogic commonwealEntranceEnable]) {
        if (!_followersButton.hidden && !_visitorButton.hidden) {
            _followersButton.left = _nameLabel.left - (_followersButton.width - _followersButton.titleLabel.width)/2;
            _followersButton.top = _showInfoLabel.hidden? _nameLabel.bottom + kTTProfileUsernameTemporaryBottomOffset: _showInfoLabel.bottom + kTTProfileFollowersButtonTopOffset;
            _followersButton.top -= (_followersButton.height - _followersButton.titleLabel.height)/2;
            
            _visitorButton.left = _followersButton.right + [TTDeviceUIUtils tt_newFontSize:20.f] - (_visitorButton.width - _visitorButton.titleLabel.width)/2;;
            _visitorButton.bottom = _followersButton.bottom;
            
            offsetX = MAX(ceilf(offsetX), ceilf(_visitorButton.right));
            maxHeight += (_followersButton.titleLabel.height + (_showInfoLabel.hidden? kTTProfileUsernameTemporaryBottomOffset : kTTProfileFollowersButtonTopOffset));
        }
    }
    
    
    if ([SSCommonLogic commonwealEntranceEnable]) {
        self.width = maxWidth;
    } else {
        self.width = ceilf(offsetX);
    }
    self.height = ceilf(maxHeight);
}

- (void)refreshContainerView
{
    if (!TTAccountManager.userName) return;
    
    self.nameLabel.text = TTAccountManager.userName;
    [self.nameLabel sizeToFit];
    
    self.toutiaohaoUserImageView.hidden = [TTAccountManager accountUserType] != TTAccountUserTypePGC;
//    self.addAuthImageView.hidden = !self.toutiaohaoUserImageView.hidden;
//    self.addAuthLabel.hidden = self.toutiaohaoUserImageView.hidden;
    self.showInfoLabel.hidden = isEmptyString([TTAccountManager showInfo]);
    self.rightArrowImageView.hidden = YES;
    self.followersButton.hidden = YES;
    self.visitorButton.hidden = YES;
    
    BOOL shouldShowVerifyEntrance = NO;
    NSString *verifyInfo = [TTAccountManager userAuthInfo];
    if (isEmptyString(verifyInfo)) {
        //未实名认证
        shouldShowVerifyEntrance = YES;
        self.isRealNameAuthUser = NO;
    } else {
        NSString *verifyType = [TTVerifyIconHelper verifyTypeOfVerifyInfo:verifyInfo];
        self.isRealNameAuthUser = YES;
        if ([verifyType isEqualToString:KTTVerifyNoVVerifyType]) {
            //已实名认证 未加V
            shouldShowVerifyEntrance = YES;
        } else {
            shouldShowVerifyEntrance = NO;
        }
    }
    
//    if (!shouldShowVerifyEntrance) {
//        self.addAuthLabel.hidden = YES;
//        self.addAuthImageView.hidden = YES;
//    }
    
//    if (!self.addAuthImageView.hidden) {
//        NSDictionary *dict = @{};
//        if (!self.isRealNameAuthUser) {
//            dict = [[SSCommonLogic HomePageAddAuthSettings] tt_dictionaryValueForKey:@"image"];
//        } else {
//            dict = [[SSCommonLogic HomePageAddVSettings] tt_dictionaryValueForKey:@"image"];
//        }
//        NSString *imageUrl = [dict tt_stringValueForKey:@"url"];
//        if (isEmptyString(imageUrl)) {
//            self.addAuthImageView.hidden = YES;
//        } else {
//            [self.addAuthImageView setImageWithURLString:imageUrl];
//            CGFloat height = [dict tt_floatValueForKey:@"height"];
//            CGFloat width = [dict tt_floatValueForKey:@"width"];
//            self.addAuthImageView.frame = CGRectMake(0, 0, width/3.f, height/3.f);
//        }
//    }
//
//    if (!self.addAuthLabel.hidden) {
//        NSString *text = @"";
//        if (!self.isRealNameAuthUser) {
//            text = [[SSCommonLogic HomePageAddAuthSettings] tt_stringValueForKey:@"title"];
//        } else {
//            text = [[SSCommonLogic HomePageAddVSettings] tt_stringValueForKey:@"title"];
//        }
//        if (isEmptyString(text)) {
//            self.addAuthLabel.hidden = YES;
//        }
//        [self.addAuthLabel setText:text];
//        [self.addAuthLabel sizeToFit];
//    }
    
    if (!self.showInfoLabel.hidden) {
        [self.showInfoLabel setText:[TTAccountManager showInfo]];
        [self.showInfoLabel sizeToFit];
    }
    if (!self.followersButton.hidden) {
        [self.followersButton setAttributedTitle:[[self class] followersButtonString] forState:UIControlStateNormal];
        [self.followersButton sizeToFit];
    }
    if (!self.visitorButton.hidden) {
        [self.visitorButton setAttributedTitle:[[self class] visitorButtonString] forState:UIControlStateNormal];
        [self.visitorButton sizeToFit];
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (SSThemedLabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(15, 10, 60, 60)];
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont systemFontOfSize:kTTProfileUsernameFontSize];
        _nameLabel.textColorThemeKey = kTTProfileUsernameColorKey;
    }
    return _nameLabel;
}

- (SSThemedImageView *)rightArrowImageView {
    if (!_rightArrowImageView) {
        _rightArrowImageView = [SSThemedImageView new];
        _rightArrowImageView.backgroundColor = [UIColor clearColor];
        _rightArrowImageView.imageName = @"profile_name_arrow";
        _rightArrowImageView.frame = CGRectMake(0, 0, ceilf(_rightArrowImageView.image.size.width), ceilf(_rightArrowImageView.image.size.height));
    }
    return _rightArrowImageView;
}

- (SSThemedLabel *)showInfoLabel {
    if (!_showInfoLabel) {
        _showInfoLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _showInfoLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        _showInfoLabel.backgroundColor = [UIColor clearColor];
        _showInfoLabel.font = [UIFont systemFontOfSize:kTTProfileNameContainerSubtitleFontSize];
        _showInfoLabel.textColorThemeKey = kColorText10;
        _showInfoLabel.alpha = 0.5f;
    }
    return _showInfoLabel;
}

- (SSThemedImageView *)toutiaohaoUserImageView {
    if (!_toutiaohaoUserImageView) {
        _toutiaohaoUserImageView = [SSThemedImageView new];
        _toutiaohaoUserImageView.userInteractionEnabled = NO;
        _toutiaohaoUserImageView.imageName = @"toutiaohao";
        _toutiaohaoUserImageView.frame = CGRectMake(0, 0,ceilf(_toutiaohaoUserImageView.image.size.width), ceilf(_toutiaohaoUserImageView.image.size.height));
        _toutiaohaoUserImageView.hidden = YES;
    }
    return _toutiaohaoUserImageView;
}

- (TTAlphaThemedButton *)followersButton {
    if (!_followersButton) {
        _followersButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _followersButton.enableHighlightAnim = YES;
        [_followersButton setHitTestEdgeInsets:UIEdgeInsetsMake(-15.f, -10.f, -15.f, -10.f)];
        [_followersButton addTarget:self action:@selector(didTapFollowersButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _followersButton;
}

- (TTAlphaThemedButton *)visitorButton {
    if (!_visitorButton) {
        _visitorButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _visitorButton.enableHighlightAnim = YES;
        [_visitorButton setHitTestEdgeInsets:UIEdgeInsetsMake(-15.f, -10.f, -15.f, -10.f)];
        [_visitorButton addTarget:self action:@selector(didTapVisitorButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _visitorButton;
}

//- (TTImageView *)addAuthImageView {
//    if(!_addAuthImageView) {
//        _addAuthImageView = [TTImageView new];
//        _addAuthImageView.userInteractionEnabled = YES;
//        _addAuthImageView.frame = CGRectZero;
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addCertification)];
//        [_addAuthImageView addGestureRecognizer:tap];
//        _addAuthImageView.hidden = YES;
//    }
//    return _addAuthImageView;
//}

//- (SSThemedLabel *)addAuthLabel {
//    if (!_addAuthLabel) {
//        _addAuthLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
//        [_addAuthLabel setBackgroundColor:[UIColor clearColor]];
//        _addAuthLabel.textColorThemeKey = kTTProfileUsernameColorKey;
//        _addAuthLabel.font = [UIFont systemFontOfSize:kTTProfileAddAuthFontSize];
//        _addAuthLabel.hidden = YES;
//        _addAuthLabel.userInteractionEnabled = YES;
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addCertification)];
//        [_addAuthLabel addGestureRecognizer:tap];
//    }
//    return _addAuthLabel;
//}

+ (NSAttributedString *)followersButtonString {
    NSMutableAttributedString *followerString = nil;
    
    if (!isEmptyString([TTAccountManager followerString])) {
        followerString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ",[TTAccountManager followerString]] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12.f]],NSForegroundColorAttributeName:[SSGetThemedColorWithKey(kColorText10) colorWithAlphaComponent:0.5f]}];
        
        NSAttributedString *followerNumberString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lld", [TTAccountManager currentUser].followersCount] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]],NSForegroundColorAttributeName:SSGetThemedColorWithKey(kColorText10)}];
        [followerString appendAttributedString:followerNumberString];
    } else {
        followerString = [[NSMutableAttributedString alloc] initWithString:@"--" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]],NSForegroundColorAttributeName: SSGetThemedColorWithKey(kColorText10)}];
    }
    
    return followerString.copy;
}

+ (NSAttributedString *)visitorButtonString {
    NSMutableAttributedString *visitorString = nil;
    
    if (!isEmptyString([TTAccountManager visitorString])) {
        visitorString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: ",[TTAccountManager visitorString]] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12.f]],NSForegroundColorAttributeName:[SSGetThemedColorWithKey(kColorText10) colorWithAlphaComponent:0.5f]}];
        
        NSAttributedString *visitorNumberString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lld", [TTAccountManager currentUser].visitCountRecent] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]],NSForegroundColorAttributeName:SSGetThemedColorWithKey(kColorText10)}];
        [visitorString appendAttributedString:visitorNumberString];
    } else {
        visitorString = [[NSMutableAttributedString alloc] initWithString:@"--" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]],NSForegroundColorAttributeName: SSGetThemedColorWithKey(kColorText10)}];
    }
    
    return visitorString.copy;
}

#pragma mark - Helper

- (BOOL)useTemporaryLayout {
    return !self.followersButton.hidden && !self.visitorButton.hidden;
}

#pragma mark - Touch Action

- (void)didTapFollowersButton:(id)sender {
    [self openSocialViewControllerWithSelectedIndex:1];
}

- (void)didTapVisitorButton:(id)sender {
    [self openSocialViewControllerWithSelectedIndex:2];
}

- (void)openSocialViewControllerWithSelectedIndex:(NSUInteger)selectedIndex {
    NSString *userID = [TTAccountManager userID];
    
    TTFollowingViewController *followingVC = [[TTFollowingViewController alloc] initWithUserID:userID];
    TTFollowedViewController  *followedVC  = [[TTFollowedViewController alloc] initWithUserID:userID];
    TTVisitorViewController   *visitorVC   = [[TTVisitorViewController alloc] initWithUserID:userID];
    TTRelationshipViewController *socialHubVC = [[TTRelationshipViewController alloc] initWithTitles:@[@"关注", @"粉丝", @"访客"] viewControllers:@[followingVC, followedVC, visitorVC]];
    socialHubVC.selectedIndex = selectedIndex;
    
    [self.navigationController pushViewController:socialHubVC animated:YES];
    
    // log
    NSArray *logStrings = @[@"enter_mine_followings", @"enter_mine_followers", @"enter_mine_visitor"];
    if (selectedIndex < [logStrings count]) {
        wrapperTrackEvent(@"mine_tab", [logStrings objectAtIndex:selectedIndex]);
    }
}

#pragma mark - Notification

- (void)themeChanged:(NSNotification *)notification {
    if (!self.followersButton.hidden) {
        [self.followersButton setAttributedTitle:[[self class] followersButtonString] forState:UIControlStateNormal];
    }
    if (!self.visitorButton.hidden) {
        [self.visitorButton setAttributedTitle:[[self class] visitorButtonString] forState:UIControlStateNormal];
    }
}

#pragma mark - add certification
//- (void)addCertification
//{
//    //copy from TTPersonalHomeViewController.m
//    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//    NSString *applyMonth = [userDefaults stringForKey:kCertificaitonMonthApplyMonthKey];
//    NSInteger applyNumber = [userDefaults integerForKey:kCertificaitonMonthApplyDateKey];
//    NSDate *date = [NSDate date];
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyyMM"];
//    NSString *nowMonth = [formatter stringFromDate:date];
//    NSString *schemaString = self.isRealNameAuthUser ? [[SSCommonLogic HomePageAddVSettings] tt_stringValueForKey:@"schema"] : [[SSCommonLogic HomePageAddAuthSettings] tt_stringValueForKey:@"schema"];
//
//    if (!isEmptyString(schemaString) || ![applyMonth isEqualToString:nowMonth] || applyNumber < 2) {//本月申请少于两次或新的月
//        NSURL *url = [NSURL URLWithString:schemaString];
//        [[TTRoute sharedRoute] openURLByPushViewController:url];
//        NSString *event = self.isRealNameAuthUser ? @"certificate_v_apply" : @"certificate_identity";
//        NSDictionary *params = @{@"source": @"mine_tab"};
//        [TTTracker eventV3:event params:params];
//
//    } else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"本月提交认证过于频繁，请核实信息后下月重试" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
//        [alert show];
//    }
//}

@end

