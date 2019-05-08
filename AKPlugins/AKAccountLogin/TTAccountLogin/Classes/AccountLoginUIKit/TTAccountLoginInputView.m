//
//  TTAccountLoginInputView.m
//  TTAccountLogin
//
//  Created by huic on 16/3/14.
//
//

#import "TTAccountLoginInputView.h"
#import <UIViewAdditions.h>
#import <TTDeviceHelper.h>
#import <TTDeviceUIUtils.h>



#define kTTAccountLoginInputFieldHeight     (45)
#define kTTAccountLoginAgreeBottomMargin    (20)
#define kTTAccountLoginAgreeHorizonMargin   (10)



@implementation TTAccountLoginInputView

- (instancetype)initWithFrame:(CGRect)frame rightText:(NSString *)text
{
    if ((self = [super initWithFrame:frame])) {
        [self addSubview:self.field];
        [self addSubview:self.errorLabel];
        [self addSubview:self.bottomSeparatorView];
        [self updateRightText:text];
    }
    return self;
}

/**
 *  恢复初始设置，将错误提示隐藏
 */
- (void)recover
{
    if (_errorLabel.hidden) return;
    
    _errorLabel.hidden = YES;
}

#pragma mark - layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self doLayoutSubviews];
}

- (void)doLayoutSubviews
{
    if (_field.rightView) {
        [self layoutResendView];
    }
    CGRect frame = self.frame;
    frame.origin = CGPointMake(0, 0);
    _field.frame = frame;
    
    _errorLabel.top = _field.bottom + 5;
    _errorLabel.left = _field.left;
}

- (void)updateRightText:(NSString *)text
{
    if (text && ![text  isEqual: @""]) {
        [self.resendButton setTitle:text forState:UIControlStateNormal];
        [self.resendButton setTitle:text forState:UIControlStateDisabled];
        
        if (!_field.rightView) {
            self.field.rightView = self.resendView;
            self.field.rightViewMode = UITextFieldViewModeAlways;
        }
        [self layoutResendView];
    } else {
        self.field.rightView = nil;
        self.field.rightViewMode = UITextFieldViewModeNever;
    }
}

- (void)layoutResendView
{
    [self.resendButton sizeToFit];
    CGFloat resendViewWidth =
    self.resendSeparatorView.width + 15 + self.resendButton.width + 15;
    CGFloat resendViewHeight = MAX(15, self.resendButton.height);
    self.resendView.size = CGSizeMake(resendViewWidth, resendViewHeight);
    
    self.resendSeparatorView.centerY = self.resendView.height / 2;
    self.resendButton.centerY = self.resendView.height / 2;
    self.resendButton.centerX = self.resendView.width / 2;
}

- (void)showError
{
    [_errorLabel sizeToFit];
    _errorLabel.hidden = NO;
    
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    moveAnimation.fromValue = [NSValue valueWithCGPoint:_errorLabel.layer.position];
    moveAnimation.toValue   = [NSValue valueWithCGPoint:CGPointMake(_errorLabel.layer.position.x + 10,
                                                                    _errorLabel.layer.position.y)];
    moveAnimation.autoreverses = YES;
    moveAnimation.fillMode = kCAFillModeForwards;
    moveAnimation.repeatCount = 3;
    moveAnimation.duration = 0.1;
    
    [_errorLabel.layer addAnimation:moveAnimation forKey:@"moveAnimation"];
}

#pragma mark - Getter/Setter

/**
 *  默认左对齐，缩进40px
 */
- (SSThemedTextField *)field
{
    if (!_field) {
        _field = [[SSThemedTextField alloc] init];
        _field.keyboardType = UIKeyboardTypeNumberPad;
        _field.returnKeyType = UIReturnKeyDone;
        _field.clearButtonMode = UITextFieldViewModeWhileEditing;
        _field.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:16]];
        _field.textColorThemeKey = kColorText1;
        _field.textAlignment = NSTextAlignmentLeft;
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
        [dict setValue:[UIColor colorWithHexString:@"999999"] forKey:NSForegroundColorAttributeName];
        [dict setValue:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16.f]] forKey:NSFontAttributeName];
        _field.placeholderAttributedDict = dict;
    }
    return _field;
}


- (SSThemedLabel *)errorLabel
{
    if (!_errorLabel) {
        _errorLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _errorLabel.backgroundColor = [UIColor clearColor];
        _errorLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:11]];
        _errorLabel.textAlignment = NSTextAlignmentLeft;
        _errorLabel.textColorThemeKey = kColorText4;
        _errorLabel.hidden = YES;
    }
    return _errorLabel;
}

- (SSThemedView *)resendSeparatorView
{
    if (!_resendSeparatorView) {
        _resendSeparatorView = [[SSThemedView alloc]
                                initWithFrame:CGRectMake(0, 0, [TTDeviceHelper ssOnePixel], 16)];
        _resendSeparatorView.backgroundColorThemeKey = kColorLine9;
    }
    return _resendSeparatorView;
}

- (SSThemedButton *)resendButton
{
    if (!_resendButton) {
        _resendButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _resendButton.titleLabel.font =
        [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:15]];
        _resendButton.enabled = YES;
        _resendButton.disabledTitleColorThemeKey = kColorText3;
        [_resendButton setTitleColor:[UIColor colorWithHexString:@"FF0031"] forState:UIControlStateNormal];
        _resendButton.adjustsImageWhenHighlighted = YES;
        [_resendButton sizeToFit];
    }
    return _resendButton;
}

- (SSThemedView *)resendView
{
    if (!_resendView) {
        _resendView = [[SSThemedView alloc] init];
        _resendView.backgroundColor = [UIColor clearColor];
//        [_resendView addSubview:self.resendSeparatorView];
        [_resendView addSubview:self.resendButton];
    }
    return _resendView;
}

- (SSThemedView *)bottomSeparatorView
{
    if (!_bottomSeparatorView) {
        _bottomSeparatorView = [[SSThemedView alloc]
                                initWithFrame:CGRectMake(0, self.height - [TTDeviceHelper ssOnePixel], self.width, [TTDeviceHelper ssOnePixel])];
        _bottomSeparatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _bottomSeparatorView.backgroundColor = [UIColor colorWithHexString:@"ECECEC"];
    }
    return _bottomSeparatorView;
}

@end



@interface TTAccountLoginUserAgreement ()

@end

@implementation TTAccountLoginUserAgreement
/**
 *  左右居中，下对齐
 */
- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self addSubview:self.radioButton];
        [self addSubview:self.leftLabel];
        [self addSubview:self.termButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat agreeGroupWidth = _radioButton.width + kTTAccountLoginAgreeHorizonMargin + _leftLabel.width + _termButton.width;
    CGFloat agreeLeft = (self.width - agreeGroupWidth) / 2.0;
    CGFloat agreeGroupHeight = MIN(MIN(_leftLabel.height, _radioButton.height), _termButton.height);
    
    _radioButton.centerY = self.height - agreeGroupHeight / 2;
    _radioButton.left  = agreeLeft;
    _leftLabel.centerY = self.height - agreeGroupHeight / 2;
    _leftLabel.left = _radioButton.right + kTTAccountLoginAgreeHorizonMargin;
    
    _termButton.centerY = self.height - agreeGroupHeight / 2;
    _termButton.left = _leftLabel.right;
}

#pragma mark - Getter/Setter

- (SSThemedButton *)radioButton
{
    if (!_radioButton) {
        _radioButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _radioButton.imageName = @"hookicon_press_sdk_login";
        _radioButton.selectedImageName = @"hookicon_sdk_login";
        _radioButton.selected = YES;
        [_radioButton sizeToFit];
    }
    return _radioButton;
}

- (SSThemedLabel *)leftLabel
{
    if (!_leftLabel) {
        _leftLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _leftLabel.text = NSLocalizedString(@"同意", nil);
        _leftLabel.backgroundColor = [UIColor clearColor];
        _leftLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
        _leftLabel.textColorThemeKey = kColorText2;
        [_leftLabel sizeToFit];
    }
    return _leftLabel;
}

- (SSThemedButton *)termButton
{
    if (!_termButton) {
        _termButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _termButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        _termButton.contentHorizontalAlignment =
        UIControlContentHorizontalAlignmentLeft;
        [_termButton setTitle:NSLocalizedString(@"幸福里用户协议", nil)
                     forState:UIControlStateNormal];
        _termButton.titleLabel.font =
        [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:12]];
        _termButton.titleColorThemeKey = kColorText5;
        _termButton.highlightedTitleColorThemeKey = kColorText5Highlighted;
        [_termButton sizeToFit];
    }
    return _termButton;
}
@end

