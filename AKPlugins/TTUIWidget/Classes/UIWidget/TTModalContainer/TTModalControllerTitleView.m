//
//  TTMomentTitleView.m
//  Article
//
//  Created by zhaoqin on 10/01/2017.
//
//

#import "TTModalControllerTitleView.h"
#import "SSThemed.h"
#import "TTAlphaThemedButton.h"
#import <TTBaseLib/UIViewAdditions.h>
#import <TTThemed/UIImage+TTThemeExtension.h>
#import <TTBaseLib/TTDeviceUIUtils.h>

#define TITLEVIEWHEIGHT [TTDeviceUIUtils tt_newPadding:49]

@interface TTModalControllerTitleView ()
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) TTAlphaThemedButton *closeButton;
@property (nonatomic, strong) TTAlphaThemedButton *backButton;
@property (nonatomic, strong) SSThemedView *bottomLine;
@end

@implementation TTModalControllerTitleView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, TITLEVIEWHEIGHT);
        self.backgroundColorThemeName = kColorBackground4;
        
        [self addSubview:self.backButton];
        [self addSubview:self.titleLabel];
        [self addSubview:self.closeButton];
        [self addSubview:self.bottomLine];
    }
    return self;
}

- (void)layoutSubviews {
    self.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, TITLEVIEWHEIGHT);
    UIBezierPath *maskPath = [UIBezierPath
                              bezierPathWithRoundedRect:self.bounds
                              byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                              cornerRadii:CGSizeMake(6, 6)
                              ];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
    
    self.titleLabel.centerX = self.width / 2;
    self.titleLabel.centerY = self.height / 2;
    self.titleLabel.left = nearbyintf(self.titleLabel.left);
    self.titleLabel.top = nearbyintf(self.titleLabel.top);
    
    self.backButton.centerY = self.height / 2;
    self.backButton.left = [TTDeviceUIUtils tt_newPadding:12];
    
    self.closeButton.centerY = self.height / 2;
    if (self.backButton.hidden) {
        self.closeButton.left = [TTDeviceUIUtils tt_newPadding:12];
    } else {
        self.closeButton.left = self.backButton.right + [TTDeviceUIUtils tt_newPadding:12];
    }
    
}

#pragma mark - public
- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
    [self.titleLabel sizeToFit];
}

#pragma mark - action
- (void)closeButtonClicked:(id)sender {
    if (self.closeComplete) {
        self.closeComplete(sender);
    }
}

- (void)backButtonClicked {
    if (self.backComplete) {
        self.backComplete();
    }
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    _closeButton.tintColor = [UIColor tt_themedColorForKey:kColorText1];
    _backButton.tintColor = [UIColor tt_themedColorForKey:kColorText1];
}

#pragma mark - get/set Method
- (void)setType:(TTModalControllerTitleType)type {
    if (_type == type) {
        return;
    }
    _type = type;
    switch (type) {
        case TTModalControllerTitleTypeBoth:
            self.backButton.hidden = NO;
            self.closeButton.hidden = NO;
            break;
        case TTModalControllerTitleTypeOnlyBack:
            self.backButton.hidden = NO;
            self.closeButton.hidden = YES;
            break;
        case TTModalControllerTitleTypeOnlyClose:
            self.backButton.hidden = YES;
            self.closeButton.hidden = NO;
        default:
            break;
    }
}

- (void)setHiddenBottomLine:(BOOL)hiddenBottomLine {
    _hiddenBottomLine = hiddenBottomLine;
    self.bottomLine.hidden = hiddenBottomLine;
}

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.textColorThemeKey = kColorText1;
    }
    return _titleLabel;
}

- (TTAlphaThemedButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
        [_closeButton setImage:[UIImage themedImageNamed:@"close_comment"] forState:UIControlStateNormal];
        _closeButton.tintColor = [UIColor tt_themedColorForKey:kColorText1];
        [_closeButton sizeToFit];
        if ([TTDeviceHelper isScreenWidthLarge320]) {
            [_closeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -2)];
        }
        else {
            [_closeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -4)];
        }
        [_closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (TTAlphaThemedButton *)backButton {
    if (!_backButton) {
        _backButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _backButton.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
        [_backButton setImage:[UIImage themedImageNamed:@"lefterbackicon_titlebar"] forState:UIControlStateNormal];
        [_backButton sizeToFit];
        if ([TTDeviceHelper isScreenWidthLarge320]) {
            [_backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -2)];
        }
        else {
            [_backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -4)];
        }
        [_backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (SSThemedView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[SSThemedView alloc] init];
        _bottomLine.backgroundColorThemeKey = kColorLine1;
        _bottomLine.frame = CGRectMake(0, self.height - [TTDeviceHelper ssOnePixel], self.width, [TTDeviceHelper ssOnePixel]);
    }
    return _bottomLine;
}

@end
