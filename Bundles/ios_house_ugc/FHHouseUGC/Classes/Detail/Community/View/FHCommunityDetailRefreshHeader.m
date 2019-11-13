//
//  FHCommunityDetailRefreshHeader.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/11/12.
//

#import "FHCommunityDetailRefreshHeader.h"
#import <FHCommonUI/UIView+House.h>
#import <Masonry.h>

@interface FHCommunityDetailRefreshHeader ()

@property (nonatomic, strong) UIImageView *arrowView;
@property (nonatomic, strong) UIImageView *loadingView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, strong) NSMutableDictionary *stateTitles;
@property (nonatomic, assign) CGFloat startRefreshingTime;

@end

@implementation FHCommunityDetailRefreshHeader

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initVars];
        [self initViews];
    }
    return self;
}

- (void)initVars {
    self.state = MJRefreshStateIdle;
    self.loadingSize = 14;
    self.lable2LoadingMargin = 5;
    [self setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
    [self setTitle:@"松手刷新" forState:MJRefreshStatePulling];
    [self setTitle:@"正在刷新" forState:MJRefreshStateRefreshing];
    self.loadingView.hidden = YES;
}

- (void)initViews {
    [self addSubview:self.arrowView];
    [self addSubview:self.loadingView];
    [self addSubview:self.textLabel];
    [self placeSubviews];
}

- (void)setState:(MJRefreshState)state {
    self.textLabel.text = self.stateTitles[@(state)];
    
    switch (state) {
        case MJRefreshStatePulling:
            self.arrowView.hidden = NO;
            self.loadingView.hidden = YES;
            if (_state != state) {
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
            self.startRefreshingTime = [[NSDate date] timeIntervalSinceReferenceDate];
            if(self.refreshingBlock){
                self.refreshingBlock();
            }
            break;
        case MJRefreshStateIdle:
            self.arrowView.hidden = NO;
            self.arrowView.transform = CGAffineTransformIdentity;
            self.loadingView.hidden = YES;
            [self stopAnimating];
            break;
        case MJRefreshStateWillRefresh:
            break;
        case MJRefreshStateNoMoreData:
            break;
    }
    _state = state;
}

- (void)placeSubviews {
    CGFloat mj_width = [self.textLabel mj_textWith];
    CGFloat totalWidth = mj_width + self.lable2LoadingMargin + self.loadingSize;
    CGFloat left = (self.frame.size.width - totalWidth) * 0.5;
    
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(left + self.lable2LoadingMargin + self.loadingSize);
        make.width.mas_equalTo(mj_width + 5);
        make.height.mas_equalTo(self.loadingSize);
    }];
    
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(left);
        make.width.height.mas_equalTo(self.loadingSize);
    }];
    
    [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(left);
        make.width.height.mas_equalTo(self.loadingSize);
    }];
}

#pragma mark - 公共方法
- (void)setTitle:(NSString *)title forState:(MJRefreshState)state {
    if (title == nil) return;
    self.stateTitles[@(state)] = title;
    self.textLabel.text = self.stateTitles[@(self.state)];
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

- (void)beginRefreshing {
//    if(self.state == MJRefreshStatePulling){
        self.state = MJRefreshStateRefreshing;
//    }
}

- (void)endRefreshing {
    NSTimeInterval endRefreshingTime = [[NSDate date] timeIntervalSinceReferenceDate];
    NSTimeInterval interval = 0;
    if(endRefreshingTime - self.startRefreshingTime < 1.0f){
        interval = 1.0f - (endRefreshingTime - self.startRefreshingTime);
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.state = MJRefreshStateIdle;
        [UIView animateWithDuration:0.3 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            if(self.endRefreshingCompletionBlock){
                self.endRefreshingCompletionBlock();
            }
        }];
    });
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

- (NSMutableDictionary *)stateTitles {
    if (!_stateTitles) {
        self.stateTitles = [NSMutableDictionary dictionary];
    }
    return _stateTitles;
}

@end
