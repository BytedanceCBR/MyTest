//
//  ArticleMobileCaptchaAlertView.m
//  Article
//
//  Created by SunJiangting on 14-7-7.
//
//

#import "ArticleMobileCaptchaAlertView.h"
#import <SSThemed.h>
#import <TTDeviceHelper.h>
#import <TTAccountBusiness.h>



@interface ArticleMobileCaptchaAlertView ()

@property(nonatomic, strong) UIView         *backgroundView;
@property(nonatomic, strong) UIView         *contentView;
@property(nonatomic, strong) UILabel        *titleLabel;
@property(nonatomic, strong) UIImageView    *captchaImageView;
@property(nonatomic, strong) UITextField    *captchaField;
@property(nonatomic, strong) UIButton       *resendButton;
@property(nonatomic, strong) UIButton       *cancelButton;
@property(nonatomic, strong) UIButton       *submitButton;

@property(nonatomic, strong) UIImage        *captchaImage;
@property(nonatomic, copy)   NSString       *captchaValue;
@property(nonatomic, strong) UIActivityIndicatorView   *indicatorView;
@property(nonatomic, strong) ArticleMobileCaptchaBlock dismissBlock;

@end

@implementation ArticleMobileCaptchaAlertView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithCaptchaImage:(UIImage *)captchaImage {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.contentOffset = 64;
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView.backgroundColor = [UIColor colorWithWhite:0x0 alpha:0.3];
        [self addSubview:self.backgroundView];
        
        UIButton *button = [[UIButton alloc] initWithFrame:self.backgroundView.frame];
        button.autoresizingMask = self.backgroundView.autoresizingMask;
        [self addSubview:button];
        
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 270) / 2, 64, 271, 158)];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.cornerRadius = 7.5;
        self.contentView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        self.contentView.layer.borderColor = [UIColor colorWithHexString:@"#afafbc"].CGColor;
        self.contentView.layer.masksToBounds = YES;
        self.contentView.layer.shadowOffset = CGSizeMake(-1, 1);
        self.contentView.layer.shadowColor = [UIColor whiteColor].CGColor;
        [self addSubview:self.contentView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 230, 35)];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:16.];
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.text = NSLocalizedString(@"请输入验证码", nil);
        [self.contentView addSubview:self.titleLabel];
        
        self.captchaImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 35, 210, 33)];
        self.captchaImageView.layer.borderColor = [UIColor colorWithHexString:@"#afafbc"].CGColor;
        self.captchaImageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        self.captchaImageView.image = captchaImage;
        self.captchaImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.captchaImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.captchaImageView];
        
        self.captchaField = [[UITextField alloc] initWithFrame:CGRectMake(30, 74, 121, 33)];
        self.captchaField.layer.borderColor = [UIColor colorWithHexString:@"#afafbc"].CGColor;
        self.captchaField.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        self.captchaField.layer.masksToBounds = YES;
        [self.contentView addSubview:self.captchaField];
        
        UIColor *buttonTintColor = [UIColor colorWithHexString:@"#cc3131"];
        self.resendButton = [[UIButton alloc] initWithFrame:CGRectMake(156, 74, 84, 33)];
        self.resendButton.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        self.resendButton.layer.cornerRadius = 3;
        self.resendButton.layer.borderColor = buttonTintColor.CGColor;
        self.resendButton.layer.masksToBounds = YES;
        [self.resendButton setTitle:NSLocalizedString(@"换一张", nil) forState:UIControlStateNormal];
        [self.resendButton setTitleColor:buttonTintColor forState:UIControlStateNormal];
        [self.resendButton addTarget:self action:@selector(resendCaptchaActionFired:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.resendButton];
        
        self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.indicatorView.center = self.resendButton.center;
        self.indicatorView.hidesWhenStopped = YES;
        [self.contentView addSubview:self.indicatorView];
        
        UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 115, 271, [TTDeviceHelper ssOnePixel])];
        separatorView.backgroundColor = [UIColor colorWithHexString:@"#afafbc"];
        [self.contentView addSubview:separatorView];
        
        UIColor *optionColor = [UIColor colorWithHexString:@"#247deb"];
        UIFont *operationFont = [UIFont boldSystemFontOfSize:16.];
        
        self.cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 116, 130, 42)];
        [self.cancelButton setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:optionColor forState:UIControlStateNormal];
        self.cancelButton.titleLabel.font = operationFont;
        [self.cancelButton addTarget:self action:@selector(cancelActionFired:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.cancelButton];
        
        UIView *horSeparatorView = [[UIView alloc] initWithFrame:CGRectMake(130, 116, [TTDeviceHelper ssOnePixel], 42)];
        horSeparatorView.backgroundColor = [UIColor colorWithHexString:@"#afafbc"];
        [self.contentView addSubview:horSeparatorView];
        
        self.submitButton = [[UIButton alloc] initWithFrame:CGRectMake(131, 116, 130, 42)];
        [self.submitButton setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
        [self.submitButton setTitleColor:optionColor forState:UIControlStateNormal];
        self.submitButton.titleLabel.font = operationFont;
        [self.submitButton addTarget:self action:@selector(submitActionFired:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.submitButton];
        
        self.error = nil;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithCaptchaImage:nil];
}

- (void)setError:(NSError *)error {
    if (error.code == kPRWrongCaptchaErrorCode) {
        self.titleLabel.font = [UIFont boldSystemFontOfSize:14.];
        self.titleLabel.text = NSLocalizedString(@"验证码输入错误，请重新输入", nil);
        self.titleLabel.textColor = [UIColor colorWithHexString:@"#cc3131"];
    } else {
        self.titleLabel.font = [UIFont boldSystemFontOfSize:16.];
        self.titleLabel.text = NSLocalizedString(@"请输入验证码", nil);
        self.titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    }
    
    _error = error;
}

- (void)showWithDismissBlock:(ArticleMobileCaptchaBlock)block {
    self.dismissBlock = block;
    if (self.visible) {
        return;
    }
    UIView *superview = SSGetMainWindow();
    [superview addSubview:self];
    self.visible = YES;
    
    CGRect frame = self.contentView.frame;
    frame.origin.y = ([UIScreen mainScreen].bounds.size.height - self.contentOffset - 240) / 2;
    self.contentView.frame = frame;
    
    [self.captchaField becomeFirstResponder];
    void (^animations)(void) = ^{
        self.backgroundView.alpha = 0.5;
        self.contentView.frame = frame;
    };
    void (^completion)(BOOL) = ^(BOOL finished) {
        
    };
    
    if ([TTDeviceHelper OSVersionNumber] > 7.0) {
        [UIView animateWithDuration:0.3
                              delay:0.0
             usingSpringWithDamping:0.75
              initialSpringVelocity:0.8
                            options:0
                         animations:animations
                         completion:completion];
    } else {
        [UIView animateWithDuration:0.1 animations:animations completion:completion];
    }
}

- (void)dismissAnimated:(BOOL)animated {
    [self _dismissAnimated:animated completion:NULL];
}

- (void)_dismissAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    [self removeFromSuperview];
    if (completion) {
        completion(YES);
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    /// keyboard相对于屏幕的坐标
    CGRect keyboardScreenFrame = [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    
    UIViewAnimationOptions options = UIViewAnimationCurveEaseIn | UIViewAnimationCurveEaseOut | UIViewAnimationCurveLinear;
    switch (animationCurve) {
        case UIViewAnimationCurveEaseInOut:
            options = UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            options = UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            options = UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            options = UIViewAnimationOptionCurveLinear;
            break;
        default:
            options = animationCurve << 16;
            break;
    }
    
    CGFloat duration = [[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect frame = self.contentView.frame;
    CGFloat offset = (CGRectGetMinY(keyboardScreenFrame) - self.contentOffset - CGRectGetHeight(frame)) / 2;
    frame.origin.y = self.contentOffset + offset;
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:options
                     animations:^{ self.contentView.frame = frame; }
                     completion:^(BOOL finished) { self.contentView.frame = frame; }];
}

#pragma mark - UIControlEvent

- (void)resendCaptchaActionFired:(id)sender {
    __weak ArticleMobileCaptchaAlertView *weakSelf = self;
    [self.indicatorView startAnimating];
    self.resendButton.enabled = NO;
    
    [TTAccountManager startRefreshCaptchaWithScenarioType:self.scenario completion:^(UIImage *captchaImage, NSError *error) {
        [weakSelf.indicatorView stopAnimating];
        weakSelf.resendButton.enabled = YES;
        if (captchaImage) {
            weakSelf.captchaImageView.image = captchaImage;
        }
    }];
}

- (void)cancelActionFired:(id)sender {
    self.captchaImage = self.captchaImageView.image;
    self.captchaValue = nil;
    [self _dismissAnimated:YES
                completion:^(BOOL finished) {
                    if (self.dismissBlock) {
                        self.dismissBlock(self, 0);
                    }
                }];
}

- (void)submitActionFired:(id)sender {
    self.captchaImage = self.captchaImageView.image;
    self.captchaValue = self.captchaField.text;
    [self _dismissAnimated:YES  completion:^(BOOL finished) {
        if (self.dismissBlock) {
            self.dismissBlock(self, 1);
        }
    }];
}

@end
