//
//  TTVPlayerErrorView.m
//  Article
//
//  Created by panxiang on 2018/10/12.
//

#import "TTVPlayerErrorView.h"
#import "UIImage+TTVHelper.h"

#define kTipLoadingViewH 32
#define kHorizontalGap [TTVPlayerUtility tt_padding:12]

@interface TTVPlayerErrorView ()

@property (nonatomic, strong) UILabel *retryLabel;
@property (nonatomic, assign) BOOL showRetry;

@property (nonatomic, strong) UIButton *retryButton;
//重试View上的返回按钮
@property (nonatomic, strong) UIButton *retryBackBtn;

@end

@implementation TTVPlayerErrorView
@synthesize didClickBack = _didClickBack;
@synthesize didClickRetry = _didClickRetry;

//@synthesize errorText = _errorText;
- (instancetype)init {
    self = [super init];
    if (self) {
        self.showRetry = YES;
        self.hidden = YES;
        _retryLabel = [[UILabel alloc] init];
        _retryLabel.textColor = [UIColor colorWithRed:244.0f / 255.0f green:245.0f / 255.0f blue:246.0f / 255.0f alpha:1.0f];
        _retryLabel.font = [UIFont systemFontOfSize:[TTVPlayerUtility tt_fontSize:15]];
        [self addSubview:_retryLabel];
        
        _retryButton = [[UIButton alloc] init];
        _retryButton.hitTestEdgeInsets = UIEdgeInsetsMake([TTVPlayerUtility tt_padding:-80], [TTVPlayerUtility tt_padding:-60], [TTVPlayerUtility tt_padding:-48], [TTVPlayerUtility tt_padding:-60]); // 扩大加载失败页面的点击区域
        _retryButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_retryButton setTitle:@"点击重试" forState:UIControlStateNormal];
        _retryButton.titleLabel.font = [UIFont systemFontOfSize:[TTVPlayerUtility tt_padding:13]];
        [_retryButton setTitleColor:[UIColor colorWithRed:244.0f / 255.0f green:245.0f / 255.0f blue:246.0f / 255.0f alpha:1.0f] forState:UIControlStateNormal];
        _retryButton.layer.cornerRadius = 4;
        _retryButton.layer.borderWidth = 1;
        _retryButton.layer.borderColor = [UIColor colorWithRed:244.0f / 255.0f green:245.0f / 255.0f blue:246.0f / 255.0f alpha:1.0f].CGColor;
        [_retryButton addTarget:self action:@selector(retryClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_retryButton];
        
        _retryBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _retryBackBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
        [_retryBackBtn setImage:[UIImage ttv_ImageNamed:@"player_back"] forState:UIControlStateNormal];
        [_retryBackBtn addTarget:self action:@selector(retryBackBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_retryBackBtn];
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

#pragma mark -
#pragma mark public methods

- (void)retryClicked:(id)sender {
    if (self.didClickRetry) {
        self.hidden = YES;
        self.didClickRetry();
    }
}

- (void)retryBackBtnClicked:(id)sender {
    if (self.didClickBack) {
        self.didClickBack();
    }
}

#pragma mark -
#pragma mark UI

- (void)ttvl_buildConstraints {
    
    [self.retryButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_centerY).offset(8);
        make.centerX.equalTo(self);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(32);
    }];
    
    BOOL isIPhoneXDevice = [TTDeviceHelper isIPhoneXSeries];
    CGFloat statusBarHeight = 44.0f; // iPhoneX刘海高度
    [self.retryBackBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        CGFloat leftMargin = kHorizontalGap;
        if (isIPhoneXDevice) {
            leftMargin += statusBarHeight; // 返回按钮左边需要留出刘海空间
        }
        make.top.equalTo(self).offset(28);
        make.left.equalTo(self.mas_left).offset(leftMargin);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.frame = self.superview.bounds;
}

- (void)updateRetryBackBtn {
    BOOL isIPhoneXDevice = [TTDeviceHelper isIPhoneXSeries];
    CGFloat statusBarHeight = 44.0f; // iPhoneX刘海高度
//    if (self.supportsPortaitFullScreen) {
//        [self.retryBackBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//            CGFloat topMargin = 28;
//            CGFloat leftMargin = kHorizontalGap;
//            if (isIPhoneXDevice) {
//                topMargin += statusBarHeight; // 返回按钮上边需要留出刘海空间
//            }
//            make.top.equalTo(self).offset(topMargin);
//            make.left.equalTo(self.mas_left).offset(leftMargin);
//        }];
//    } else {
        [self.retryBackBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            CGFloat leftMargin = kHorizontalGap;
            if (isIPhoneXDevice) {
                leftMargin += statusBarHeight; // 返回按钮左边需要留出刘海空间
            }
            make.top.equalTo(self).offset(28);
            make.left.equalTo(self.mas_left).offset(leftMargin);
        }];
//    }
}

//- (void)ttvl_buildBindings {
//    RAC(self.retryBackBtn, hidden) = RACObserve(self, isFullScreen).not;
//    WeakSelf;
//    [[RACObserve(self.retryBackBtn, hidden) distinctUntilChanged] subscribeNext:^(id x) {
//        StrongSelf;
//        [self updateRetryBackBtn];
//    }];
//}

- (void)show {
    self.userInteractionEnabled = YES;
    self.hidden = NO;
//    if (!isEmptyString(self.errorText)) {
//        self.retryLabel.text = self.errorText;
//    }
    [self.retryLabel sizeToFit];
    self.retryButton.hidden = !self.showRetry;
    [self ttvl_buildConstraints];
    if (self.retryButton.hidden) {
        [self.retryLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_centerY);
            make.centerX.equalTo(self);
        }];
    }else{
        [self.retryLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mas_centerY).offset(-8);
            make.centerX.equalTo(self);
        }];
    }
    [self layoutIfNeeded];
}

- (void)dismiss {
    self.hidden = YES;
    [self removeFromSuperview];
}

- (BOOL)isShowed {
    if (self.hidden) {
        return NO;
    }
    if (!self.hidden && !self.superview) {
        return NO;
    }
    return YES;
}

- (void)showRetry:(BOOL)show {
    self.showRetry = show;
    [self setNeedsLayout];
}

- (void)setErrorText:(NSString *)errorText {
    self.retryLabel.text = errorText;
}

@end
