//
//  TTUserPrivacyView.m
//  Pods
//
//  Created by liuzuopeng on 24/06/2017.
//
//

#import "TTUserPrivacyView.h"
#import <TTDeviceUIUtils.h>
#import <UIButton+TTAdditions.h>
#import <UIViewAdditions.h>



#define kTTInsetTop ([TTDeviceUIUtils tt_padding:8.f])

#define kTTSpacingFromCheckButton ([TTDeviceUIUtils tt_padding:4.f])


@interface TTUserPrivacyView ()

@property (nonatomic, strong) SSThemedButton *checkButton;

@property (nonatomic, strong) SSThemedLabel  *agreementTextLabel;

@property (nonatomic, strong) SSThemedButton *userProtocolButton; // 用户协议

@property (nonatomic, strong) SSThemedLabel  *andTextLabel;

@property (nonatomic, strong) SSThemedButton *privacyTextButton; // 隐私政策


@end

@implementation TTUserPrivacyView

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setupCustomViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupCustomViews];
    }
    return self;
}

- (void)setupCustomViews
{
    [self addSubview:self.agreementTextLabel];
    [self addSubview:self.userProtocolButton];
    [self addSubview:self.andTextLabel];
    [self addSubview:self.privacyTextButton];
//    [self addSubview:self.checkButton];
    
    _agreementTextLabel.textColorThemeKey = _checkButton.selected ? kColorText1 : kColorText3;
    _andTextLabel.textColorThemeKey = _checkButton.selected ? kColorText1 : kColorText3;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat totalWidth =self.agreementTextLabel.width + self.privacyTextButton.width + self.andTextLabel.width + self.userProtocolButton.width ;
    CGFloat totalHeight = kTTInsetTop * 2 + self.privacyTextButton.height;
    
//    self.checkButton.frame = CGRectIntegral(CGRectMake(marginExtraSpacing, (totalHeight - self.checkButton.height) / 2, self.checkButton.width, self.checkButton.height));
    
    self.agreementTextLabel.frame = CGRectIntegral(CGRectMake(0, (totalHeight - self.agreementTextLabel.height) / 2, self.agreementTextLabel.width, self.agreementTextLabel.height));
    
    self.userProtocolButton.frame = CGRectIntegral(CGRectMake(self.agreementTextLabel.right, (totalHeight - self.userProtocolButton.height) / 2, self.userProtocolButton.width, self.userProtocolButton.height));
    
    self.andTextLabel.frame = CGRectIntegral(CGRectMake(self.userProtocolButton.right, (totalHeight - self.andTextLabel.height) / 2, self.andTextLabel.width, self.andTextLabel.height));
    
    self.privacyTextButton.frame = CGRectIntegral(CGRectMake(self.andTextLabel.right, (totalHeight - self.privacyTextButton.height) / 2, self.privacyTextButton.width, self.privacyTextButton.height));
    
    self.size = CGSizeMake(totalWidth, totalHeight);
}

#pragma mark - public methods

- (BOOL)isChecked
{
    return _checkButton.selected;
}

#pragma mark - actions

- (void)actionForDidCheckButton:(id)sender
{
    _checkButton.selected = !_checkButton.selected;
    _agreementTextLabel.textColorThemeKey = _checkButton.selected ? kColorText1 : kColorText3;
    _andTextLabel.textColorThemeKey = _checkButton.selected ? kColorText1 : kColorText3;
    
    if (_viewCheckActionHandler) {
        _viewCheckActionHandler();
    }
}

- (void)actionForDidPrivacyTextButton:(id)sender
{
    if (_viewPrivacyHandler) {
        _viewPrivacyHandler();
    }
}

- (void)actionForDidUserProtocolButton:(id)sender
{
    if (_viewUserAgreementHandler) {
        _viewUserAgreementHandler();
    }
}

#pragma mark - Setter/Getter

- (SSThemedButton *)checkButton
{
    if (!_checkButton) {
        _checkButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _checkButton.selected = YES;
        _checkButton.imageName = @"details_choose_icon";
        _checkButton.selectedImageName = @"details_choose_ok_icon";
        _checkButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -15, -10, -15);
        _checkButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12.f]];
        _checkButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _checkButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _checkButton.titleColorThemeKey = kColorText1;
        [_checkButton sizeToFit];
        [_checkButton addTarget:self
                         action:@selector(actionForDidCheckButton:)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkButton;
}

- (SSThemedLabel *)agreementTextLabel
{
    if (!_agreementTextLabel) {
        _agreementTextLabel = [SSThemedLabel new];
        _agreementTextLabel.textColorThemeKey = kColorText1;
        _agreementTextLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12.f]];
        _agreementTextLabel.text = @"注册即代表同意「爱看」";
        [_agreementTextLabel sizeToFit];
    }
    return _agreementTextLabel;
}

- (SSThemedLabel *)andTextLabel
{
    if (!_andTextLabel) {
        _andTextLabel = [SSThemedLabel new];
        _andTextLabel.userInteractionEnabled = NO;
        _andTextLabel.textColorThemeKey = kColorText1;
        _andTextLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12.f]];
        _andTextLabel.text = @"和";
        [_andTextLabel sizeToFit];
    }
    return _andTextLabel;
}

- (SSThemedButton *)userProtocolButton
{
    if (!_userProtocolButton) {
        _userProtocolButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _userProtocolButton.hitTestEdgeInsets = UIEdgeInsetsMake(-(kTTInsetTop - 2),
                                                                 0,
                                                                 -(kTTInsetTop - 2),
                                                                 0);
        _userProtocolButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12.f]];
        [_userProtocolButton setTitle:@"服务条款" forState:UIControlStateNormal];
        [_userProtocolButton setTitleColor:[UIColor colorWithHexString:@"999999"] forState:UIControlStateNormal];
        [_userProtocolButton addTarget:self
                                action:@selector(actionForDidUserProtocolButton:)
                      forControlEvents:UIControlEventTouchUpInside];
        [_userProtocolButton sizeToFit];
    }
    return _userProtocolButton;
}

- (SSThemedButton *)privacyTextButton
{
    if (!_privacyTextButton) {
        _privacyTextButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _privacyTextButton.hitTestEdgeInsets = UIEdgeInsetsMake(-(kTTInsetTop - 2),
                                                                0,
                                                                -(kTTInsetTop - 2),
                                                                0);
        _privacyTextButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12.f]];
        [_privacyTextButton setTitle:@"隐私条款" forState:UIControlStateNormal];
        [_privacyTextButton setTitleColor:[UIColor colorWithHexString:@"999999"] forState:UIControlStateNormal];
        [_privacyTextButton addTarget:self
                               action:@selector(actionForDidPrivacyTextButton:)
                     forControlEvents:UIControlEventTouchUpInside];
        [_privacyTextButton sizeToFit];
    }
    return _privacyTextButton;
}

+ (CGFloat)topBottomMargin
{
    return kTTInsetTop;
}

@end
