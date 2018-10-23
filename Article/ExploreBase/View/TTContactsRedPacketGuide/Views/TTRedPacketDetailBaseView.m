//
//  TTRedPacketDetailBaseView.m
//  Article
//
//  Created by Jiyee Sheng on 8/3/17.
//
//

#import "TTRedPacketDetailBaseView.h"
#import "ExploreAvatarView.h"
#import "TTRoute.h"
#import <TTNavigationController.h>
#import <TTDeviceHelper.h>
#import <UIViewAdditions.h>
#import <TTDeviceUIUtils.h>
#import <TTThemeManager.h>
@implementation TTRedPacketDetailBaseViewModel
@end

#define kTTRedPacketNavBarHeight       44
#define kTTRedPacketContentViewWidth   [TTDeviceUIUtils tt_newPadding:240]
#define kTTRedPacketContentViewHeight  [TTDeviceUIUtils tt_newPadding:300]
#define kTTAvatarViewSize              [TTDeviceUIUtils tt_newPadding:66]

@interface TTRedPacketDetailBaseView ()

@property (nonatomic, strong) TTRedPacketDetailBaseViewModel *viewModel;

@end

static CGFloat kTTRedPacketStatusBarHeight() {
    if ([TTDeviceHelper isIPhoneXDevice]) {
        return 44;
    } else {
        return 20;
    }
}

@implementation TTRedPacketDetailBaseView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
        self.scrollView.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
        
        [self addSubview:self.navBar];
        [self.navBar addSubview:self.navBarLeftButton];
        [self.navBar addSubview:self.navBarTitleLabel];
        
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.curveView];
        [self.scrollView addSubview:self.avatarView];
        [self.scrollView addSubview:self.contentView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.descriptionLabel];
        [self.contentView addSubview:self.moneyLabel];
        [self.contentView addSubview:self.withdrawButton];
        
        self.scrollView.contentSize = CGSizeMake(self.width, kTTRedPacketContentViewHeight);
    }
    
    return self;
}

- (void)backAction:(id)sender {
    if (self.fromPush && [self.viewController.navigationController isKindOfClass:[TTNavigationController class]]) {
        [(TTNavigationController *)self.navigationController panRecognizer].enabled = YES;
    }
    
    [self.viewController dismissViewControllerAnimated:YES completion:^{
        if (self.dismissBlock) {
            self.dismissBlock();
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TTCloseRedPackertNotification" object:nil userInfo:nil];
    }];
}

- (void)withdrawAction:(id)sender {
    if (self.viewModel.withdrawUrl) {
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:self.viewModel.withdrawUrl]];
    }
}

- (void)configWithViewModel:(TTRedPacketDetailBaseViewModel *)viewModel {
    _viewModel = viewModel;
    
    self.nameLabel.text = viewModel.userName ?: @"好友红包";
    self.descriptionLabel.text = viewModel.desc ?: @"发了一个红包，金额随机";
    self.moneyLabel.attributedText = [self moneyLabelAttributedText:viewModel.money];
    [self.withdrawButton setTitle:@"已存入我的红包，可提现" forState:UIControlStateNormal];
    if (!isEmptyString(viewModel.title)) {
        self.navBarTitleLabel.text = viewModel.title;
    }
    
    if (!isEmptyString(viewModel.avatar)) {
        [self.avatarView setImageWithURLString:viewModel.avatar];
    }
    
    if (self.descriptionLabel.hidden) {
        self.moneyLabel.top = self.nameLabel.bottom + [TTDeviceUIUtils tt_newPadding:25];
        self.withdrawButton.top = self.moneyLabel.bottom + [TTDeviceUIUtils tt_newPadding:12];
    } else {
        self.moneyLabel.top = self.descriptionLabel.bottom + [TTDeviceUIUtils tt_newPadding:25];
        self.withdrawButton.top = self.moneyLabel.bottom + [TTDeviceUIUtils tt_newPadding:12];
    }
}

#pragma mark - setter and getter

- (SSThemedView *)navBar {
    if (!_navBar) {
        _navBar = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.width, kTTRedPacketStatusBarHeight() + kTTRedPacketNavBarHeight)];
        NSString *hexString = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight ? @"8A3B37" : @"EF514A";
        _navBar.backgroundColor = [UIColor colorWithHexString:hexString];
    }
    
    return _navBar;
}

- (SSThemedButton *)navBarLeftButton {
    if (!_navBarLeftButton) {
        _navBarLeftButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [_navBarLeftButton setTitle:@"关闭" forState:UIControlStateNormal];
        _navBarLeftButton.backgroundColor = [UIColor clearColor];
        _navBarLeftButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16]];
        _navBarLeftButton.titleColorThemeKey = kColorText12;
        [_navBarLeftButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
        [_navBarLeftButton sizeToFit];
        [_navBarLeftButton setHitTestEdgeInsets:UIEdgeInsetsMake(-8.f, -12.f, -8.f, -12.f)];
        _navBarLeftButton.origin = CGPointMake([TTDeviceUIUtils tt_newPadding:20], kTTRedPacketStatusBarHeight() + (kTTRedPacketNavBarHeight - _navBarLeftButton.height) / 2);
    }
    
    return _navBarLeftButton;
}

- (SSThemedLabel *)navBarTitleLabel {
    if (!_navBarTitleLabel) {
        _navBarTitleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake((self.width - [TTDeviceUIUtils tt_newPadding:200]) / 2, kTTRedPacketStatusBarHeight(), [TTDeviceUIUtils tt_newPadding:200], kTTRedPacketNavBarHeight)];
        _navBarTitleLabel.text = @"爱看红包";
        _navBarTitleLabel.textColorThemeKey = kColorText12;
        _navBarTitleLabel.textAlignment = NSTextAlignmentCenter;
        _navBarTitleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:17]];
    }
    
    return _navBarTitleLabel;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.navBar.bottom, self.width, self.height - self.navBar.height)];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.bounces = NO;
    }
    
    return _scrollView;
}

- (SSThemedView *)curveView {
    if (!_curveView) {
        _curveView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, -2, self.width, [TTDeviceUIUtils tt_newPadding:84])];
        NSString *hexString = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight ? @"8A3B37" : @"EF514A";
        _curveView.backgroundColor = [UIColor colorWithHexString:hexString];
        
        CGFloat maskLayerWidth = self.width;
        CGFloat maskLayerHeight = [TTDeviceUIUtils tt_newPadding:45];
        
        UIBezierPath *strokePath = [UIBezierPath bezierPath];
        [strokePath moveToPoint:CGPointMake(maskLayerWidth, 0)];
        [strokePath addLineToPoint:CGPointMake(0, 0)];
        [strokePath addLineToPoint:CGPointMake(0, maskLayerHeight)];
        [strokePath addQuadCurveToPoint:CGPointMake(maskLayerWidth, maskLayerHeight) controlPoint:CGPointMake(maskLayerWidth / 2, [TTDeviceUIUtils tt_newPadding:84] + 35)]; // 控制点是切线焦点
        [strokePath closePath];
        
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = strokePath.CGPath;
        _curveView.layer.mask = maskLayer;
    }
    
    return _curveView;
}

- (ExploreAvatarView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[ExploreAvatarView alloc] initWithFrame:CGRectMake((self.width - kTTAvatarViewSize) / 2, [TTDeviceUIUtils tt_newPadding:46], kTTAvatarViewSize, kTTAvatarViewSize)];
        _avatarView.enableRoundedCorner = YES;
        _avatarView.highlightedMaskView = nil;
        _avatarView.imageView.layer.borderWidth = 0;
        _avatarView.placeholder = @"default_avatar";
        _avatarView.imageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        
        _coverView = [[UIView alloc] initWithFrame:_avatarView.bounds];
        _coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
        _coverView.layer.cornerRadius = kTTAvatarViewSize / 2;
        _coverView.layer.masksToBounds = YES;
        _coverView.userInteractionEnabled = NO;
        _coverView.layer.borderColor = [SSGetThemedColorWithKey(kColorLine1) CGColor];
        [_avatarView addSubview:_coverView];
    }
    
    return _avatarView;
}

- (SSThemedView *)contentView {
    if (!_contentView) {
        _contentView = [[SSThemedView alloc] initWithFrame:CGRectMake((self.width - kTTRedPacketContentViewWidth) / 2, self.avatarView.bottom + [TTDeviceUIUtils tt_newPadding:12], kTTRedPacketContentViewWidth, kTTRedPacketContentViewHeight)];
    }
    
    return _contentView;
}

- (SSThemedLabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, kTTRedPacketContentViewWidth, [TTDeviceUIUtils tt_newPadding:26])];
        _nameLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newFontSize:19]];
        _nameLabel.textColorThemeKey = kColorText1;
        _nameLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _nameLabel;
}

- (SSThemedLabel *)descriptionLabel {
    if (!_descriptionLabel) {
        _descriptionLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, self.nameLabel.bottom + [TTDeviceUIUtils tt_newPadding:4], kTTRedPacketContentViewWidth, [TTDeviceUIUtils tt_newPadding:44])];
        _descriptionLabel.numberOfLines = 2;
        _descriptionLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
        _descriptionLabel.textAlignment = NSTextAlignmentCenter;
        _descriptionLabel.textColorThemeKey = kColorText1;
        _descriptionLabel.verticalAlignment = ArticleVerticalAlignmentTop;
    }
    
    return _descriptionLabel;
}

- (SSThemedLabel *)moneyLabel {
    if (!_moneyLabel) {
        _moneyLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, self.descriptionLabel.bottom + [TTDeviceUIUtils tt_newPadding:25], kTTRedPacketContentViewWidth, [TTDeviceUIUtils tt_newPadding:57])];
        _moneyLabel.textAlignment = NSTextAlignmentCenter;
        _moneyLabel.textColorThemeKey = kColorText1;
    }
    
    return _moneyLabel;
}

- (SSThemedButton *)withdrawButton {
    if (!_withdrawButton) {
        _withdrawButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _withdrawButton.frame = CGRectMake(0, self.moneyLabel.bottom + [TTDeviceUIUtils tt_newPadding:12], kTTRedPacketContentViewWidth, [TTDeviceUIUtils tt_newPadding:20]);
        _withdrawButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
        _withdrawButton.titleColorThemeKey = kColorText6;
        [_withdrawButton addTarget:self action:@selector(withdrawAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _withdrawButton;
}

- (NSAttributedString *)moneyLabelAttributedText:(NSString *)money {
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:money attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newFontSize:48]]}];
    [attributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" 元" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]]}]];
    
    return [attributedString copy];
}

@end

