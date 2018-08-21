//
//  TTCancelFollowButton.m
//  Article
//
//  Created by ranny_90 on 2017/8/8.
//
//

#import "TTCancelFollowButton.h"

@interface TTFollowLoadingAnimateView :SSThemedView

@property (nonatomic, strong)SSThemedView *loadingBackView;

@property (nonatomic, strong)SSThemedImageView *loadingAnimateView;

@end

@implementation TTFollowLoadingAnimateView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.loadingBackView = [[SSThemedView alloc] initWithFrame:self.bounds];
        [self addSubview:self.loadingBackView];
        self.loadingAnimateView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        self.loadingAnimateView.center = CGPointMake(CGRectGetWidth(frame)/2, CGRectGetHeight(frame)/2);
        [self addSubview:self.loadingAnimateView];
        self.loadingAnimateView.imageName = @"toast_keywords_refresh_gray";
        self.backgroundColorThemeKey = kColorBackground4;
    }
    return self;
}

- (void)startLoading{
    self.loadingAnimateView.imageName = @"toast_keywords_refresh_gray";
    
    CGFloat duration = 0.4f;
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI * 2.0];
    rotationAnimation.duration = duration;
    rotationAnimation.repeatCount = NSUIntegerMax;
    
    [self.loadingAnimateView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopLoading{
    [self.loadingAnimateView.layer removeAllAnimations];
}


@end

@interface TTCancelFollowButton ()

@property (nonatomic, strong) TTFollowLoadingAnimateView *loadingView;

@property (nonatomic, assign) BOOL isLoading;

@end

@implementation TTCancelFollowButton

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.isLoading = NO;
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1.f;
        self.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:14]];
        self.titleColorThemeKey = kColorText6;
        self.disabledTitleColorThemeKey = kColorText3;
        
        self.borderColorThemeKey = kColorLine3;
        self.disabledBorderColorThemeKey = kColorLine1;
        
        self.backgroundColorThemeKey = kColorBackground4;
        self.disabledBackgroundColorThemeKey = kColorBackground4;
    
        [self refreshUI];
    }
    return self;
}

- (TTFollowLoadingAnimateView *)loadingView {
    if (_loadingView == nil) {
        _loadingView = [[TTFollowLoadingAnimateView alloc] initWithFrame:self.bounds];
        _loadingView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_loadingView];
        _loadingView.center = CGPointMake(self.width / 2, self.height / 2);
    }
    return _loadingView;
}



- (void)startLoading{
    self.isLoading = YES;
    [self refreshUI];
}

- (void)stopLoading{
    self.isLoading = NO;
    
    [self refreshUI];
}

-(BOOL)isLoading{
    return _isLoading;
}

- (void)setFollowState:(TTFolloweState)followState{
    
    if ([self isLoading]) {
        [self stopLoading];
    }
    
    if (followState == _followState) {
        return;
    }
    _followState = followState;
    
    [self refreshUI];
    
}

- (void)refreshUI{

    if (self.isLoading) {
        self.loadingView.hidden = NO;
        [self.loadingView startLoading];
        
    }
    
    else {
        [self.loadingView stopLoading];
        
        if (self.followState == TTFolloweStateFollow) {
            [self setTitle:@"取消关注" forState:UIControlStateNormal];
            self.enabled = YES;
        }
        else if (self.followState == TTFolloweStateCancel){
            [self setTitle:@"已取消" forState:UIControlStateNormal];
            self.enabled = NO;
        }
        
        self.loadingView.hidden = YES;
    }
}




@end
