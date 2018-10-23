//
//  TTAccountAlertView.m
//  TTAccountLogin
//
//  Created by yuxin on 3/15/16.
//
//

#import "TTAccountAlertView.h"
#import "TTAccountLoginPCHHeader.h"
#import <TTKeyboardListener.h>
#import <NSStringAdditions.h>
#import <UIViewAdditions.h>
#import <TTNavigationController.h>
#import <TTAlphaThemedButton.h>
#import <TTDeviceHelper.h>
#import "TTAccountNavigationController.h"
#import "TTAccountLoginManager.h"



@interface TTAccountAlertView ()

@end

@implementation TTAccountAlertView

- (instancetype)init
{
    if ((self = [self initWithFrame:[UIScreen mainScreen].bounds])) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        _touchDismissEnabled = NO;
        
        [self setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.75f]];
        [self setTintColor:[UIColor clearColor]];
        
        [self centerView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardDidShow:)
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
               cancelBtnTitle:(NSString *)cancelTitle
              confirmBtnTitle:(NSString *)confirmBtnTitle
                     animated:(BOOL)animated
                tapCompletion:(TTAccountAlertCompletionBlock)tapCompletedHandler
{
    if ((self = [self init])) {
        _centerView.frame = CGRectMake(0.0f, 0.0f, 270.f, 128.0f);
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            // iPad下用一个 固定宽度
            _centerView.frame = CGRectMake(0.0f, 0.0f, 380, 128.0f);
        }
        
        if (!isEmptyString(title)) {
            [self.titleLabel setAttributedText:[self.class attributedStringWithString:title fontSize:self.titleLabel.font.pointSize lineSpacing:self.titleLabel.font.pointSize * 0.4 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter]];
        }
        
        CGRect titleLabelSize = [self.titleLabel.attributedText boundingRectWithSize:CGSizeMake(_centerView.frame.size.width-kTTAccountAlertLeading * 2, 300) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        // 计算实际frame大小，并将label的frame变成实际大小
        if ((84.f - titleLabelSize.size.height) / 2 < 21.f) {
            _centerView.height = 42.f + titleLabelSize.size.height + kTTAccountAlertButtonHeight;
        }
        _titleLabel.frame = CGRectMake(kTTAccountAlertLeading, 0, _centerView.frame.size.width - kTTAccountAlertLeading * 2, titleLabelSize.size.height);
        
        if ((84.f - titleLabelSize.size.height)/2 > 21.f) {
            _titleLabel.top = (84.f - titleLabelSize.size.height)/2;
        } else {
            _titleLabel.top = 21.f;
        }
        
        if (!isEmptyString(message)) {
            self.titleLabel.top = 21.f;
            
            [self.messageLabel setAttributedText:[self.class attributedStringWithString:message fontSize:self.messageLabel.font.pointSize lineSpacing:self.messageLabel.font.pointSize*0.4 lineBreakMode:NSLineBreakByWordWrapping textAlignment:NSTextAlignmentCenter]];
            CGRect rect = [self.messageLabel.attributedText boundingRectWithSize:CGSizeMake(_centerView.frame.size.width-kTTAccountAlertLeading * 2, 300) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
            self.messageLabel.frame = CGRectMake(self.messageLabel.frame.origin.x, self.titleLabel.bottom + 10.f, self.messageLabel.frame.size.width, rect.size.height);
            
            _centerView.frame = CGRectMake(0.0f, 0.0f, 270.f, titleLabelSize.size.height + kTTAccountAlertButtonHeight + 52 + rect.size.height);
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                // iPad下用一个 固定宽度
                _centerView.frame = CGRectMake(0.0f, 0.0f, 380.f, titleLabelSize.size.height + kTTAccountAlertButtonHeight + 52 + rect.size.height);
            }
        }
        
        if (!cancelTitle && !confirmBtnTitle) {
            confirmBtnTitle = @"确定";
        }
        if (cancelTitle) {
            [self.cancelBtn setTitle:cancelTitle forState:UIControlStateNormal];
        } else {
            self.cancelBtn.hidden = YES;
            self.doneBtn.frame = CGRectMake(0, self.doneBtn.frame.origin.y, _centerView.frame.size.width, self.doneBtn.frame.size.height);
        }
        
        if (confirmBtnTitle) {
            [self.doneBtn setTitle:confirmBtnTitle forState:UIControlStateNormal];
        } else {
            self.doneBtn.hidden = YES;
            self.cancelBtn.frame = CGRectMake(0, self.cancelBtn.frame.origin.y, _centerView.frame.size.width, self.doneBtn.frame.size.height);
        }
        
        self.tapCompletedHandler = tapCompletedHandler;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - show/hidden

- (void)show
{
    [self showInView:nil];
}

- (void)showInView:(UIView *)superView
{
    UIView *selfSuperView = superView;
    
    if (!selfSuperView) {
        UIWindow *window = nil;
        if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
            window = [UIApplication sharedApplication].delegate.window;
        }
        if (!window) {
            window = [UIApplication sharedApplication].keyWindow;
        }
        
        UIViewController *vc = window.rootViewController;
        while (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController *)vc).topViewController;
        }
        selfSuperView = vc.view;;
    }
    
    // ajust layout before any animations
    self.alpha = 0.0f;
    self.frame = selfSuperView.bounds;
    if ([[TTKeyboardListener sharedInstance] isVisible]) {
        CGFloat keyboardTop = self.frame.size.height - [TTKeyboardListener sharedInstance].keyboardHeight;
        CGPoint center = CGPointMake(self.centerX,  keyboardTop/2 - self.superview.frame.origin.y);
        _centerView.center = center;
    } else {
        self.centerView.center = self.center;
    }
    
    // add self to window hierarchy
    [selfSuperView addSubview:self];
    
    self.centerView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    [UIView animateWithDuration:0.13 animations:^{
        self.alpha = 1.0f;
        self.centerView.transform = CGAffineTransformMakeScale(1.03, 1.03);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.07 animations:^{
            self.centerView.transform = CGAffineTransformIdentity;
        } completion:nil];
    }];
    
    UINavigationController *topNaviVC = self.window.navigationController;
    
    if ([topNaviVC isKindOfClass:[TTAccountNavigationController class]]) {
        if (![TTNavigationController refactorNaviEnabled]) {
            topNaviVC.navigationBar.userInteractionEnabled = NO;
        } else {
            topNaviVC.topViewController.ttNavigationBar.userInteractionEnabled = NO;
        }
    }
}

- (void)hideWithEventType:(TTAccountAlertCompletionEventType)eventType
{
    [TTAccountLoginManager hideLoginAlert];
    
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0.0f;
        self.centerView.transform = CGAffineTransformMakeScale(0.9, 0.9);
    } completion:^(BOOL finished) {
        
        if (self.didDismissCompletedHandler) {
            self.didDismissCompletedHandler(eventType);
        }
        
        [self removeFromSuperview];
    }];
    
    UINavigationController *topNaviVC = self.window.navigationController;
    
    if ([topNaviVC isKindOfClass:[TTAccountNavigationController class]]) {
        if (![TTNavigationController refactorNaviEnabled]) {
            topNaviVC.navigationBar.userInteractionEnabled = YES;
        } else {
            topNaviVC.topViewController.ttNavigationBar.userInteractionEnabled = YES;
        }
    }
}

- (void)hide
{
    [self hideWithEventType:TTAccountAlertCompletionEventTypeCancel];
}

#pragma mark - layout

- (void)doLayoutSubviews
{
    if ([TTDeviceHelper isPadDevice]) {
        // 很trick的方案，否则在iPad上按钮文案会有平移动画
        [CATransaction begin];
        [CATransaction setDisableActions:NO];
        CGFloat keyboardTop = self.frame.size.height - [TTKeyboardListener sharedInstance].keyboardHeight;
        CGPoint center = CGPointMake(self.frame.size.width / 2.0f,  keyboardTop / 2 - self.superview.frame.origin.y);
        _centerView.center = center;
        [CATransaction commit];
        [CATransaction setDisableActions:YES];
    } else {
        CGFloat keyboardTop = self.frame.size.height - [TTKeyboardListener sharedInstance].keyboardHeight;
        CGPoint center = CGPointMake(self.frame.size.width / 2.0f,  keyboardTop / 2 - self.superview.frame.origin.y);
        _centerView.center = center;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.frame = self.superview.bounds;
    [self doLayoutSubviews];
}

#pragma mark - Getters/Setters

- (SSThemedView *)centerView
{
    if (!_centerView) {
        _centerView = [[SSThemedView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width - 35, 210.0f)];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            //iPad下用一个 固定宽度
            _centerView.frame = CGRectMake(0.0f, 0.0f, 380, 210.0f);
        }
        
        _centerView.layer.cornerRadius = 12.0f;
        _centerView.backgroundColorThemeKey = kColorBackground20;
        _centerView.clipsToBounds = YES;
        
        [self addSubview:_centerView];
    }
    return _centerView;
}

- (SSThemedLabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(kTTAccountAlertLeading, 0.0f, _centerView.frame.size.width - kTTAccountAlertLeading * 2, kTTAccountAlertTitleHeight)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 0;
        
        [self.centerView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (SSThemedLabel *)messageLabel
{
    if (!_messageLabel) {
        _messageLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(kTTAccountAlertLeading, kTTAccountAlertTitleHeight + 5, _centerView.frame.size.width - kTTAccountAlertLeading * 2, kTTAccountAlertTitleHeight)];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.font = [UIFont systemFontOfSize:13];
        _messageLabel.textColorThemeKey = kColorText1;
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.numberOfLines = 0;
        
        [self.centerView addSubview:_messageLabel];
    }
    return _messageLabel;
}

- (TTAlphaThemedButton *)cancelBtn
{
    if (!_cancelBtn) {
        _cancelBtn = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0.0f, _centerView.frame.size.height - kTTAccountAlertButtonHeight, _centerView.frame.size.width / 2, kTTAccountAlertButtonHeight)];
        [_cancelBtn addTarget:self action:@selector(cancelBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn.titleColorThemeKey = kColorText6;
        _cancelBtn.borderColorThemeKey = kColorLine7;
        _cancelBtn.layer.borderWidth = 0.5f;
        _cancelBtn.backgroundColorThemeKey = kColorBackground20;
        [_cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        
        [self.centerView addSubview:_cancelBtn];
    }
    return _cancelBtn;
}

- (SSThemedButton *)doneBtn
{
    if (!_doneBtn) {
        _doneBtn = [[SSThemedButton alloc] initWithFrame:CGRectMake(_centerView.frame.size.width / 2, _centerView.frame.size.height - kTTAccountAlertButtonHeight, _centerView.frame.size.width / 2, kTTAccountAlertButtonHeight)];
        [_doneBtn addTarget:self action:@selector(doneBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        _doneBtn.borderColorThemeKey = kColorLine7;
        _doneBtn.layer.borderWidth = 0.5f;
        _doneBtn.backgroundColorThemeKey = kColorBackground20;
        [_doneBtn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        
        _doneBtn.enabled = YES;
        _doneBtn.titleColorThemeKey = kColorText6;
        
        [self.centerView addSubview:_doneBtn];
    }
    return _doneBtn;
}

- (TTAlphaThemedButton *)tipBtn
{
    if (!_tipBtn) {
        _tipBtn = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, _centerView.frame.size.height - 105, _centerView.frame.size.width, 62.0f)];
        [_tipBtn addTarget:self action:@selector(tipBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        _tipBtn.titleColorThemeKey = kColorText2;
        [_tipBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        
        
        [self.centerView addSubview:_tipBtn];
    }
    return _tipBtn;
}


#pragma mark - Button Actions

- (void)tipBtnTouched:(id)sender
{
    if (self.tapCompletedHandler) {
        self.tapCompletedHandler(TTAccountAlertCompletionEventTypeTip);
    }
}

- (void)cancelBtnTouched:(id)sender
{
    [self hideWithEventType:TTAccountAlertCompletionEventTypeCancel];
    if (self.tapCompletedHandler) {
        self.tapCompletedHandler(TTAccountAlertCompletionEventTypeCancel);
    }
}

- (void)doneBtnTouched:(id)sender
{
    [self hideWithEventType:TTAccountAlertCompletionEventTypeDone];
    if (self.tapCompletedHandler) {
        self.tapCompletedHandler(TTAccountAlertCompletionEventTypeDone);
    }
}


#pragma mark - keyboard notifications

- (void)keyboardDidShow:(NSNotification *)notification
{
    if (!self.superview) return;
    CGFloat keyboardTop = self.frame.size.height - [TTKeyboardListener sharedInstance].keyboardHeight;
    CGFloat centerX = _centerView.superview ? _centerView.superview.width/2.f : self.frame.size.width/2.0f;
    CGFloat centerY = keyboardTop/2 - self.superview.frame.origin.y;
    
    if (!CGPointEqualToPoint(_centerView.center, CGPointMake(centerX, centerY))) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25f];
        _centerView.center = CGPointMake(centerX, centerY);
        [UIView commitAnimations];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (!self.superview) return;
    if (!CGPointEqualToPoint(_centerView.center, self.center)) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25f];
        _centerView.center = self.center;
        [UIView commitAnimations];
    }
}

#pragma mark - NSMutableAttributedString Helper

+ (NSMutableAttributedString *)attributedStringWithString:(NSString *)string
                                                 fontSize:(CGFloat)fontSize
                                              lineSpacing:(CGFloat)lineSpace
                                            lineBreakMode:(NSLineBreakMode)lineBreakMode
                                            textAlignment:(NSTextAlignment)alignment
{
    if (isEmptyString(string)) {
        return [[NSMutableAttributedString alloc] initWithString:@""];
    }
    
    NSDictionary *attributes = [self _attributesWithFontSize:fontSize
                                                 lineSpacing:lineSpace
                                               lineBreakMode:lineBreakMode
                                               textAlignment:alignment];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString setAttributes:attributes range:NSMakeRange(0, attributedString.length)];
    return attributedString;
}


+ (NSDictionary *)_attributesWithFontSize:(CGFloat)fontSize
                              lineSpacing:(CGFloat)lineSpace
                            lineBreakMode:(NSLineBreakMode)lineBreakMode
                            textAlignment:(NSTextAlignment)alignment
{
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = lineBreakMode;
    style.lineSpacing = lineSpace;
    style.alignment = alignment;
    NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style};
    
    return attributes;
}
@end
