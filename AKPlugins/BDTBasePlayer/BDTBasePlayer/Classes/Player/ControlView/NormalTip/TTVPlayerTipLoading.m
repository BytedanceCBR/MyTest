//
//  TTVPlayerTipLoading.m
//  Article
//
//  Created by panxiang on 2017/5/17.
//
//

#import "TTVPlayerTipLoading.h"
#import "TTVPlayerIdleController.h"
#import "UIColor+TTThemeExtension.h"
#import "UIViewAdditions.h"
#import "TTBaseMacro.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"

@interface TTVPlayerTipLoading ()<CAAnimationDelegate>
{
    CABasicAnimation *rotateAnimation;
    BOOL _finishedFlag;
    BOOL _isFinished;
    CALayer *presentationLayer;
}
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIImageView *loadingImageView;
@property(nonatomic, strong)UILabel *tipLabel;
@end

@implementation TTVPlayerTipLoading
- (void)dealloc
{
    
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _loadingImageView = [[UIImageView alloc] init];
        _loadingImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_loadingImageView];
        [self addSubview:self.tipLabel];
        self.isFullScreen = NO;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.tipLabel.hidden) {
        _loadingImageView.center = self.center;//CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0);
    } else {
        
        CGFloat totoalHeight = self.loadingImageView.height + self.tipLabel.height + 4.f;
        self.loadingImageView.top = (self.height - totoalHeight) / 2;
        self.loadingImageView.centerX = self.centerX;
        
        self.tipLabel.bottom = self.height - self.loadingImageView.top;
        self.tipLabel.centerX = self.centerX;
    }
}

- (void)setIsFullScreen:(BOOL)isFullScreen
{
    _isFullScreen = isFullScreen;
    if (isFullScreen) {
        _loadingImageView.image = [UIImage imageNamed:@"video_fullLoading"];
        [_loadingImageView sizeToFit];
    }
    else
    {
        _loadingImageView.image = [UIImage imageNamed:@"video_loading"];
        [_loadingImageView sizeToFit];
    }
}

- (void)stopLoading
{
    _isFinished = NO;
    _finishedFlag = YES;
    [_timer invalidate];
    _timer = nil;
    self.hidden = YES;
    self.tipLabel.hidden = YES;
    rotateAnimation.delegate = nil;
    [_loadingImageView.layer removeAllAnimations];
}

- (void)startLoading:(NSString *)tipText
{
    _isFinished = NO;
    _finishedFlag = YES;
    [_timer invalidate];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(ttv_timerAction) userInfo:nil repeats:YES];
    
    self.tipLabel.text = tipText;
    [self.tipLabel sizeToFit];
    self.tipLabel.hidden = (isEmptyString(tipText));
    
    self.hidden = NO;
    
    [self layoutSubviews];
    [[TTVPlayerIdleController sharedInstance] lockScreen:NO later:NO];
    [self ttv_loading];
}

- (void)ttv_timerAction
{
    if (_isFinished && !_finishedFlag && !self.hidden && [UIApplication sharedApplication].applicationState == UIApplicationStateActive && _loadingImageView.layer.animationKeys.count <= 0) {
        [self ttv_loading];
    }
}

- (void)ttv_loading
{
    rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    if (presentationLayer) {//动画中断后,继续从上一次中断点开始动画
        rotateAnimation.duration = 1.0f;
        rotateAnimation.repeatCount = HUGE_VAL;
        rotateAnimation.fromValue = [NSNumber numberWithDouble:presentationLayer.transform.m43];
        rotateAnimation.toValue = @(M_PI * 2);
    }
    else
    {
        rotateAnimation.duration = 1.0f;
        rotateAnimation.repeatCount = 1000000;
        rotateAnimation.toValue = @(M_PI * 2);
    }
    rotateAnimation.delegate = self;
    [_loadingImageView.layer addAnimation:rotateAnimation forKey:@"rotateAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    presentationLayer = (CALayer *)_loadingImageView.layer.presentationLayer;
    [_loadingImageView.layer removeAllAnimations];
    _isFinished = YES;
    _finishedFlag = flag;
}

#pragma mark - Getter

- (UILabel *)tipLabel {
    
    if (!_tipLabel) {
        
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.textColor = [UIColor tt_defaultColorForKey:kColorText12];
        _tipLabel.font = [UIFont systemFontOfSize:12.f];
        [_tipLabel sizeToFit];
        _tipLabel.hidden = YES;
    }
    
    return _tipLabel;
}
@end
