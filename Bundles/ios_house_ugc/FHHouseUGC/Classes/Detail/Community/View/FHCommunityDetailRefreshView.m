//
//  FHCommunityDetailRefreshView.m
//  TTUGCBusiness
//
//  Created by  wanghanfeng on 2019/1/24.
//

#import <FHCommonUI/UIView+House.h>
#import "FHCommunityDetailRefreshView.h"

static const CGFloat kPadding = 7.f;

@interface FHCommunityDetailRefreshView ()

@property(nonatomic, strong) UIImageView *arrowView;
@property(nonatomic, strong) UIImageView *loadingView;
@property(nonatomic, strong) UILabel *textLabel;

@property(strong, nonatomic) NSMutableDictionary *stateTitles;
@property(nonatomic, assign) FHCommunityDetailRefreshViewType state;
@property(nonatomic, assign) BOOL isAnimating;

@end

@implementation FHCommunityDetailRefreshView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.state = FHCommunityDetailRefreshViewIdle;
        self.toShowMinDistance = 25;
        self.toRefreshMinDistance = 35;
        self.colorThemeKey = [UIColor whiteColor];
        [self setTitle:@"下拉刷新" forState:FHCommunityDetailRefreshViewIdle];
        [self setTitle:@"下拉刷新" forState:FHCommunityDetailRefreshViewPull];
        [self setTitle:@"正在刷新" forState:FHCommunityDetailRefreshViewLoading];
        [self setTitle:@"松手刷新" forState:FHCommunityDetailRefreshViewWillRefresh];
        [self addSubview:self.arrowView];
        [self addSubview:self.loadingView];
        [self addSubview:self.textLabel];
        self.loadingView.hidden = YES;
        [self refreshUI];
        self.arrowView.centerY = self.textLabel.centerY;
        self.arrowView.centerX = self.loadingView.centerX;
    }
    return self;
}

- (void)setLoadingImageName:(NSString *)loadingImageName {
    _loadingImageName = loadingImageName;
    self.loadingView.image = [UIImage imageNamed:loadingImageName];
}

- (void)setColorThemeKey:(UIColor *)color{
    _color = color;
    self.textLabel.textColor = color;
    self.arrowView.tintColor = color;
    self.loadingView.tintColor = color;
}

- (void)setState:(FHCommunityDetailRefreshViewType)state {
    // 当前正在刷新，则只有idle更新才有效
    if (_state == FHCommunityDetailRefreshViewLoading && state != FHCommunityDetailRefreshViewIdle) return;

    self.textLabel.text = self.stateTitles[@(state)];
    switch (state) {
        case FHCommunityDetailRefreshViewPull:
        case FHCommunityDetailRefreshViewWillRefresh: {
            self.arrowView.hidden = NO;
            self.loadingView.hidden = YES;
            if (_state != state) {
                [UIView animateWithDuration:0.25 animations:^{
                    if (state == FHCommunityDetailRefreshViewPull) {
                        self.arrowView.transform = CGAffineTransformIdentity;
                    } else if (state == FHCommunityDetailRefreshViewWillRefresh) {
                        self.arrowView.transform = CGAffineTransformMakeRotation(M_PI);
                    }
                }];
            }
        }
            break;
        case FHCommunityDetailRefreshViewLoading:
            self.arrowView.hidden = YES;
            self.loadingView.hidden = NO;
            [self startAnimating];
            self.arrowView.transform = CGAffineTransformIdentity;
            break;
        case FHCommunityDetailRefreshViewIdle:
            self.arrowView.hidden = NO;
            self.arrowView.transform = CGAffineTransformIdentity;
            self.loadingView.hidden = YES;
            [self stopAnimating];
            break;
    }
    _state = state;
    [self refreshUI];
}

- (void)refreshUI {
    self.textLabel.text = self.stateTitles[@(self.state)];
    [self.textLabel sizeToFit];
    self.textLabel.left = self.loadingView.right + kPadding;

    self.width = self.textLabel.right;
    self.height = self.textLabel.height;
    self.centerX = [self.superview centerX];

    self.loadingView.centerY = self.textLabel.centerY;
}

- (void)startAnimating {
    if (!self.isAnimating) {
        self.isAnimating = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotateAnimation.duration = 1.0f;
            rotateAnimation.repeatCount = HUGE_VAL;
            rotateAnimation.toValue = @(M_PI * 2);
            [self.loadingView.layer addAnimation:rotateAnimation forKey:@"rotateAnimation"];
        });
    }
}

- (void)stopAnimating {
    if (self.isAnimating) {
        self.isAnimating = NO;
        [self.loadingView.layer removeAllAnimations];
    }
}

#pragma mark - Public

- (void)setTitle:(NSString *)title forState:(FHCommunityDetailRefreshViewType)state {
    if (isEmptyString(title)) return;
    self.stateTitles[@(state)] = title;
    self.textLabel.text = self.stateTitles[@(self.state)];
}

- (void)updateWithContentOffsetY:(CGFloat)offsetY {
    if (self.state != FHCommunityDetailRefreshViewLoading) {
        if (offsetY < self.toShowMinDistance) {
            self.state = FHCommunityDetailRefreshViewIdle;
        } else if (offsetY > self.toRefreshMinDistance) {
            self.state = FHCommunityDetailRefreshViewWillRefresh;
        } else if (offsetY > self.toShowMinDistance) {
            self.state = FHCommunityDetailRefreshViewPull;
        }
    }
}

- (void)beginRefresh {
    self.state = FHCommunityDetailRefreshViewLoading;
}

- (void)endRefresh {
    self.state = FHCommunityDetailRefreshViewIdle;
}

#pragma mark - Getter

- (SSThemedImageView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        _arrowView.image = [UIImage imageNamed:@"fh_ugc_pull_arrow_down"];
    }

    return _arrowView;
}

- (SSThemedImageView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
        _loadingView.image = [UIImage imageNamed:@"fh_ugc_pull_arrow_loading"];
    }

    return _loadingView;
}

- (SSThemedLabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[SSThemedLabel alloc] init];
        _textLabel.font = [UIFont systemFontOfSize:14];
        _textLabel.textColor = [UIColor whiteColor];
    }

    return _textLabel;
}

- (NSMutableDictionary *)stateTitles {
    if (!_stateTitles) {
        _stateTitles = [[NSMutableDictionary alloc] initWithCapacity:4];
    }
    return _stateTitles;
}

@end
