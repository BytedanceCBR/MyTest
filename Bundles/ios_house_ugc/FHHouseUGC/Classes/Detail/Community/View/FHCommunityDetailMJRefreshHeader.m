//
//  FHCommunityDetailRefreshView.m
//  TTUGCBusiness
//
//  Created by  wanghanfeng on 2019/1/24.
//

#import <FHCommonUI/UIView+House.h>
#import "FHCommunityDetailMJRefreshHeader.h"

static const CGFloat kPadding = 7.f;

@interface FHCommunityDetailMJRefreshHeader ()

@property(nonatomic, strong) UIImageView *arrowView;
@property(nonatomic, strong) UIImageView *loadingView;
@property(nonatomic, strong) UILabel *textLabel;
@property(nonatomic, assign) BOOL isAnimating;
@property (strong, nonatomic) NSMutableDictionary *stateTitles;
@end

@implementation FHCommunityDetailMJRefreshHeader

#pragma mark - 公共方法
- (void)setTitle:(NSString *)title forState:(MJRefreshState)state
{
    if (title == nil) return;
    self.stateTitles[@(state)] = title;
    self.textLabel.text = self.stateTitles[@(self.state)];
}

-(void)prepare{
    [super prepare];
    self.loadingSize = 14;
    self.lable2LoadingMargin = 5;
    
    self.state = MJRefreshStateIdle;
    [self setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
    [self setTitle:@"松手刷新" forState:MJRefreshStatePulling];
    [self setTitle:@"正在刷新" forState:MJRefreshStateRefreshing];
    [self addSubview:self.arrowView];
    [self addSubview:self.loadingView];
    [self addSubview:self.textLabel];
    self.loadingView.hidden = YES;
}

- (void)setState:(MJRefreshState)state{
    MJRefreshCheckState
    self.textLabel.text = self.stateTitles[@(state)];
    
    switch (state) {
        case MJRefreshStatePulling:
            self.arrowView.hidden = NO;
            self.loadingView.hidden = YES;
            if (oldState != state) {
                [UIView animateWithDuration:0.25 animations:^{
                    self.arrowView.transform = CGAffineTransformMakeRotation(M_PI);
                }];
            }
            break;
        case MJRefreshStateRefreshing:
            self.arrowView.hidden = YES;
            self.loadingView.hidden = NO;
            [self startAnimating];
            self.arrowView.transform = CGAffineTransformIdentity;
            break;
        case MJRefreshStateIdle:
            self.arrowView.hidden = NO;
            self.arrowView.transform = CGAffineTransformIdentity;
            self.loadingView.hidden = YES;
            [self stopAnimating];
            break;
    }
    
}

- (void)placeSubviews{
    CGFloat mj_width = [self.textLabel mj_textWith];
    CGFloat totalWidth = mj_width + self.lable2LoadingMargin + self.loadingSize;
    CGFloat left = (self.mj_w - totalWidth) * 0.5;
    
    self.textLabel.mj_w = mj_width;
    self.textLabel.mj_h = self.loadingSize;
    self.textLabel.mj_x = left + self.lable2LoadingMargin + self.loadingSize;
    self.textLabel.centerY = self.mj_h * 0.5;
    
    self.loadingView.mj_x = left;
    self.loadingView.centerY = self.textLabel.centerY;
    self.loadingView.size = CGSizeMake(self.loadingSize, self.loadingSize);
    
    self.arrowView.mj_x = left;
    self.arrowView.centerY = self.textLabel.centerY;
    self.arrowView.size = CGSizeMake(self.loadingSize, self.loadingSize);
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
#pragma mark - Getter

- (UIImageView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _arrowView.contentMode = UIViewContentModeCenter;
        _arrowView.image = [UIImage imageNamed:@"fh_ugc_pull_arrow_down"];
        _arrowView.tintColor = [UIColor whiteColor];
    }
    return _arrowView;
}

- (UIImageView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _loadingView.image = [UIImage imageNamed:@"fh_ugc_pull_arrow_loading"];
        _loadingView.tintColor = [UIColor whiteColor];
    }
    return _loadingView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [UILabel mj_label];
        _textLabel.font = [UIFont systemFontOfSize:14];
        _textLabel.textColor = [UIColor whiteColor];
    }
    return _textLabel;
}

- (NSMutableDictionary *)stateTitles{
    if (!_stateTitles) {
        self.stateTitles = [NSMutableDictionary dictionary];
    }
    return _stateTitles;
}
@end
