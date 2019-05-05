//
//  TTContactsRedPacketGuideView.m
//  Article
//
//  Created by Jiyee Sheng on 7/31/17.
//
//

#import "TTContactsRedPacketGuideView.h"
#import "TTUIResponderHelper.h"

#define kTTRedPacketViewWidth          [TTDeviceUIUtils tt_newPadding:300.f]
#define kTTRedPacketViewHeight         [TTDeviceUIUtils tt_newPadding:410.f]
#define kTTCloseButtonSize             [TTDeviceUIUtils tt_newPadding:36.f]
#define kTTSubmitButtonWidth           [TTDeviceUIUtils tt_newPadding:260.f]
#define kTTSubmitButtonHeight          [TTDeviceUIUtils tt_newPadding:44.f]
#define kTTSubmitButtonMargin          [TTDeviceUIUtils tt_newPadding:40.f]
#define kTTSubmitButtonTitleColor      [UIColor colorWithHexString:@"E64D44"]
#define kTTSubmitButtonBackgroundColor [UIColor colorWithHexString:@"E7DBA8"]

@implementation TTContactsRedPacketGuideView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
        self.tintColor = [UIColor clearColor];

        [self addSubview:self.containerView];
        [self.containerView addSubview:self.closeButton];
        [self.containerView addSubview:self.submitButton];

        self.containerView.center = self.center;

        self.closeButton.top = 0;
        self.closeButton.right = self.containerView.width;
        self.submitButton.centerX = self.containerView.width / 2;
        self.submitButton.bottom = self.containerView.height - kTTSubmitButtonMargin;
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.containerView.center = self.center;

    if (self.superview) {
        [self.superview bringSubviewToFront:self];
    }
}

- (void)showInKeyWindowWithAnimation {
    if (self.superview) [self removeFromSuperview];
    UIView *targetView = [TTUIResponderHelper mainWindow];
    if (!targetView) return;
    if ([targetView isKindOfClass:[UIWindow class]]) {
        UIViewController *vc = ((UIWindow *)targetView).rootViewController;
        while (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController *)vc).topViewController;
        }
        targetView = vc.view;
    }
    [targetView addSubview:self];
    [targetView bringSubviewToFront:self];

    self.alpha = 0.3;
    self.hidden = NO;
    __weak typeof(self) wself = self;
    self.containerView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [UIView animateWithDuration:0.13 animations:^{
        __strong typeof(wself) sself = wself;
        sself.alpha = 1.0f;
        sself.containerView.transform = CGAffineTransformMakeScale(1.03, 1.03);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.07 animations:^{
            __strong typeof(wself) sself = wself;
            sself.containerView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished2) {
            __strong typeof(wself) sself = wself;
            if (sself.didAppearBlock) {
                sself.didAppearBlock();
            }
        }];
    }];
}

- (void)dismissWithAnimation {
    __weak typeof(self) wself = self;
    [UIView animateWithDuration:0.1 animations:^{
        __strong typeof(wself) sself = wself;
        sself.alpha = 0.f;
        sself.containerView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished) {
        __strong typeof(wself) sself = wself;
        [sself removeFromSuperview];
    }];
}

#pragma mark - actions

- (void)closeAction:(id)sender {
    if (self.didCloseBlock) {
        self.didCloseBlock();
    }
}

- (void)submitAction:(id)sender {
    if (self.didSubmitBlock) {
        self.didSubmitBlock();
    }
}

#pragma mark - getter and setter

- (SSThemedView *)containerView {
    if (!_containerView) {
        _containerView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, kTTRedPacketViewWidth, kTTRedPacketViewHeight)];
        _containerView.backgroundColor = [UIColor colorWithHexString:@"E13D35"];
        _containerView.layer.cornerRadius = [TTDeviceUIUtils tt_padding:12.f];
        _containerView.clipsToBounds = YES;
    }

    return _containerView;
}

- (SSThemedButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, kTTCloseButtonSize, kTTCloseButtonSize)];
        _closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(0, -8, -8, 0);
        _closeButton.layer.zPosition = 2;
        [_closeButton addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];

        SSThemedImageView *closeImageView = [[SSThemedImageView alloc] init];
        closeImageView.imageName = @"close_redpacket";
        closeImageView.enableNightCover = NO;
        closeImageView.frame = CGRectMake(0, 0, closeImageView.image.size.width, closeImageView.image.size.height);
        closeImageView.center = CGPointMake(_closeButton.width / 2, _closeButton.height / 2);
        [_closeButton addSubview:closeImageView];
    }

    return _closeButton;
}

- (SSThemedButton *)submitButton {
    if (!_submitButton) {
        _submitButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, kTTSubmitButtonWidth, kTTSubmitButtonHeight)];
        _submitButton.backgroundColor = kTTSubmitButtonBackgroundColor;
        _submitButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16]];
        [_submitButton setTitleColor:kTTSubmitButtonTitleColor forState:UIControlStateNormal];
        _submitButton.layer.cornerRadius = [TTDeviceUIUtils tt_padding:4.f];
        _submitButton.clipsToBounds = YES;
        [_submitButton addTarget:self action:@selector(submitAction:) forControlEvents:UIControlEventTouchUpInside];

        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.locations = @[@0, @0.6];
        gradientLayer.colors = @[
            (__bridge id) [UIColor colorWithHexString:@"F5EFD3"].CGColor, (__bridge id) [UIColor colorWithHexString:@"E7DBA8"].CGColor
        ];
        gradientLayer.startPoint = CGPointMake(0.0, 0.5);
        gradientLayer.endPoint = CGPointMake(0.6, 0.5);
        gradientLayer.frame = _submitButton.bounds;
        gradientLayer.zPosition = -1;
        [_submitButton.layer addSublayer:gradientLayer];
    }

    return _submitButton;
}

@end
