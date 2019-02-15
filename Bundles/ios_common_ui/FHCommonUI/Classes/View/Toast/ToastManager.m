//
//  ToastManager.m
//  Pods
//
//  Created by 张元科 on 2018/12/20.
//

#import "ToastManager.h"
#import "UIView+Toast.h"
#import <Masonry.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import "MBProgressHUD.h"

@interface ToastManager ()

@property (nonatomic, strong)   FHToastView       *toastView;
@property (nonatomic, strong)   CSToastStyle      *toastStyle;

@property (nonatomic, strong)   UIView       *loadingView;

@end

@implementation ToastManager

+ (instancetype)manager {
    static ToastManager *_sharedInstance = nil;
    if (!_sharedInstance){
        _sharedInstance = [[ToastManager alloc] init];
    }
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self createDefaultStyle];
    }
    return self;
}

- (void)createDefaultStyle {
    _toastStyle = [[CSToastStyle alloc] initWithDefaultStyle];
    _toastStyle.backgroundColor = RGBA(0x08, 0x1f, 0x33,0.96);
    _toastStyle.cornerRadius = 4.0;
    _toastStyle.messageFont = [UIFont systemFontOfSize:14.0];
    _toastStyle.messageAlignment = NSTextAlignmentCenter;
    _toastStyle.verticalPadding = 15.0;
    _toastStyle.horizontalPadding = 20;
    _toastStyle.messageColor = UIColor.whiteColor;
}

- (void)showToast:(NSString *)message {
    [self showToast:message duration:1.0 isUserInteraction:NO];
}

- (void)showToast:(NSString *)message duration:(NSTimeInterval)duration isUserInteraction:(BOOL)isUserInteraction {
    [self dismissToast];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    _toastView = [[FHToastView alloc] initWithFrame:window.bounds];
    _toastView.userInteractionEnabled = isUserInteraction;
    [window addSubview:_toastView];
    __weak typeof(self) wSelf = self;
    __weak FHToastView * wToast = _toastView;
    [_toastView makeToast:message duration:duration position:CSToastPositionCenter title:NULL image:NULL style:self.toastStyle completion:^(BOOL didTap) {
        if (wToast) {
            [wToast removeFromSuperview];
        }
    }];
}

- (void)dismissToast {
    [_toastView removeFromSuperview];
    _toastView = NULL;
}

// loading
- (void)showCustomLoading:(NSString *)message {
    [self showCustomLoading:message isUserInteraction:YES];
}

- (void)showCustomLoading:(NSString *)message isUserInteraction:(BOOL)isUserInteraction {
    [self dismissToast];
    [self dismissCustomLoading];
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window) {
        UIView *loadingParentView = [[UIView alloc] initWithFrame:window.bounds];
        loadingParentView.userInteractionEnabled = isUserInteraction;
        self.loadingView = loadingParentView;
        FHLoadingView *loadV = [[FHLoadingView alloc] initWithFrame:CGRectZero];
        [window addSubview:loadingParentView];
        [loadingParentView addSubview:loadV];
        [loadV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(loadingParentView);
        }];
        loadV.message.text = message;
    }
}

- (void)dismissCustomLoading {
    [self.loadingView removeFromSuperview];
    self.loadingView = NULL;
}

@end

#pragma mark - FHToastView

@implementation FHToastView

@end


#pragma mark - FHCycleIndicatorView

@interface FHCycleIndicatorView ()

@property (nonatomic, strong)   UIImageView       *loadingIndicator;
@property (nonatomic, assign)   BOOL       isAnimating;

@end

@implementation FHCycleIndicatorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isAnimating = NO;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _loadingIndicator = [[UIImageView alloc] init];
    _loadingIndicator.image = [UIImage imageNamed:@"loading_icon"];
    [self addSubview:_loadingIndicator];
    [_loadingIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(20);
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.bottom.mas_equalTo(self).offset(-4);
    }];
}

- (void)startAnimating {
    self.isAnimating = YES;
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = @(M_PI * 2);
    rotationAnimation.duration = 2.0;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = MAXFLOAT;
    [self.loadingIndicator.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopAnimating {
    self.isAnimating = NO;
    [self.loadingIndicator.layer removeAllAnimations];
}

@end

#pragma mark - FHLoadingView

@interface FHLoadingView ()

@property (nonatomic, strong)   FHCycleIndicatorView       *cycleIndicatorView;

@end

@implementation FHLoadingView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 4.0;
        self.backgroundColor = RGBA(8, 31, 51, 0.96);
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _cycleIndicatorView = [[FHCycleIndicatorView alloc] init];
    [self addSubview:_cycleIndicatorView];
    [self.cycleIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(15);
        make.bottom.mas_equalTo(-15);
        make.width.height.mas_equalTo(24);
    }];
    [_cycleIndicatorView startAnimating];
    
    _message = [[UILabel alloc] init];
    _message.font = [UIFont themeFontRegular:14];
    _message.textColor = [UIColor whiteColor];
    [self addSubview:_message];
    [_message mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.cycleIndicatorView.mas_right).offset(4);
        make.centerY.mas_equalTo(self.cycleIndicatorView.mas_centerY);
        make.height.mas_equalTo(20);
        make.right.mas_equalTo(-20);
    }];
}

@end
