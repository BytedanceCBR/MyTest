//
//  FHLoadingButton.m
//  FHHouseDetail
//
//  Created by 张静 on 2019/2/12.
//

#import "FHLoadingButton.h"
#import "UIView+House.h"

@interface FHLoadingButton ()

@property(nonatomic , assign) BOOL isLoading;
@property(nonatomic , strong) UIImageView *loadingAnimateView;
@end

@implementation FHLoadingButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self addSubview:self.loadingAnimateView];
    self.loadingAnimateView.size = CGSizeMake(16, 16);
    self.loadingAnimateView.hidden = YES;
}

- (void)startLoading
{
    self.isLoading = YES;
    self.enabled = NO;
    self.loadingAnimateView.hidden = NO;
    CFTimeInterval duration = 0.4;
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = @(M_PI * 2);
    rotationAnimation.duration = duration;
    rotationAnimation.repeatCount = CGFLOAT_MAX;
    [self.loadingAnimateView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void)stopLoading
{
    self.isLoading = NO;
    self.enabled = YES;
    self.loadingAnimateView.hidden = YES;
    [self.loadingAnimateView.layer removeAllAnimations];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.isLoading) {
        [self.titleLabel sizeToFit];
        self.loadingAnimateView.centerY = self.height / 2;
        self.loadingAnimateView.left = (self.width - self.loadingAnimateView.width - self.titleLabel.width - 4) / 2;
        self.titleLabel.left = self.loadingAnimateView.right + 4;
    }else {
        self.titleLabel.centerY = self.height / 2;
        self.titleLabel.centerX = self.width / 2;
    }
}

- (UIImageView *)loadingAnimateView
{
    if (!_loadingAnimateView) {
        _loadingAnimateView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"detail_loading"]];
    }
    return _loadingAnimateView;
}

@end
