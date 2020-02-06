//
//  FHUGCTopicRefreshHeader.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/8/25.
//

#import "FHUGCTopicRefreshHeader.h"
#import "Masonry.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "TTDeviceHelper.h"
#import "FHCommonDefines.h"
#import "UIView+House.h"

@interface FHUGCTopicRefreshHeader ()

@property(nonatomic, strong) UIImageView *arrowView;
@property(nonatomic, strong) UIImageView *loadingView;
@property(nonatomic, strong) UILabel *textLabel;
@property(nonatomic, assign) BOOL isAnimating;
@property (strong, nonatomic) NSMutableDictionary *stateTitles;
@property(nonatomic,assign) CGFloat lable2LoadingMargin;
@property(nonatomic,assign) CGFloat loadingSize;
@property (nonatomic, assign)   CGFloat       pullingPercent;
@property (nonatomic, assign)   BOOL       isEndRefreshing;
@property (nonatomic, assign)   BOOL       isRefreshing;

@end

@implementation FHUGCTopicRefreshHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (scrollView.contentOffset.y <= 0) {
//        scrollView.contentInset = UIEdgeInsetsZero;
//    }
   
    if (self.isEndRefreshing) {
        return;
    }
    // 当前的contentOffset
    CGFloat offsetY = scrollView.contentOffset.y;
    // 头部控件刚好出现的offsetY
    CGFloat happenOffsetY = 0;
    
    // 如果是向上滚动到看不见头部控件，直接返回
    // >= -> >
    if (offsetY > happenOffsetY) return;
    
    // 普通 和 即将刷新 的临界点
    CGFloat normal2pullingOffsetY = happenOffsetY - self.mj_h;
    CGFloat pullingPercent = (happenOffsetY - offsetY) / self.mj_h;
    
    if (self.scrollView.isDragging) { // 如果正在拖拽
        self.pullingPercent = pullingPercent;
        if (self.state == MJRefreshStateIdle && offsetY < normal2pullingOffsetY) {
            // 转为即将刷新状态
            self.state = MJRefreshStatePulling;
        } else if (self.state == MJRefreshStatePulling && offsetY >= normal2pullingOffsetY) {
            // 转为普通状态
            self.state = MJRefreshStateIdle;
        }
    } else if (self.state == MJRefreshStatePulling) {// 即将刷新 && 手松开
        // 开始刷新
        [self beginRefreshing];
        // 刷新回调
        if (!self.isRefreshing) {
            if (self.refreshingBlk) {
                self.refreshingBlk();
            }
            self.isRefreshing = YES;
        }
    } else if (self.state == MJRefreshStateRefreshing) {// 正在刷新
        if (-offsetY < self.mj_h + 3) {
            self.scrollView.contentInset = UIEdgeInsetsMake(self.mj_h + 1, 0, 0, 0);
        }
        self.pullingPercent = pullingPercent;
    } else if (pullingPercent < 1) {
        self.pullingPercent = pullingPercent;
    }
}

#pragma mark 进入刷新状态
- (void)beginRefreshing
{
    [UIView animateWithDuration:MJRefreshFastAnimationDuration animations:^{
        self.alpha = 1.0;
    }];
    self.pullingPercent = 1.0;
    // 只要正在刷新，就完全显示
    if (self.window) {
        self.state = MJRefreshStateRefreshing;
    } else {
        // 预防正在刷新中时，调用本方法使得header inset回置失败
        if (self.state != MJRefreshStateRefreshing) {
            self.state = MJRefreshStateWillRefresh;
            // 刷新(预防从另一个控制器回到这个控制器的情况，回来要重新刷新一下)
            [self setNeedsDisplay];
        }
    }
}

- (void)endRefreshing {
    self.isEndRefreshing = YES;
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    [UIView animateWithDuration:0.4 animations:^{
        // nothing
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        //UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.scrollView.contentInset = self.beginEdgeInsets;
        self.state = MJRefreshStateIdle;
        self.pullingPercent = 0;
        self.isEndRefreshing = NO;
        self.isRefreshing = NO;
    }];
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    self.isEndRefreshing = NO;
    self.isRefreshing = NO;
    self.stateTitles = [[NSMutableDictionary alloc] init];
    self.loadingSize = 14;
    self.lable2LoadingMargin = 5;
    
    _state = MJRefreshStateIdle;
    [self setTitle:@"下拉刷新" forState:MJRefreshStateIdle];
    [self setTitle:@"松手刷新" forState:MJRefreshStatePulling];
    [self setTitle:@"正在刷新" forState:MJRefreshStateRefreshing];
    [self addSubview:self.arrowView];
    [self addSubview:self.loadingView];
    [self addSubview:self.textLabel];
    self.loadingView.hidden = YES;
    self.state = MJRefreshStateIdle;
}

- (void)setState:(MJRefreshState)state {
    MJRefreshState oldState = self.state;
    if (state == oldState) return;
    _state = state;
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

- (void)layoutSubviews {
    [super layoutSubviews];
    [self placeSubviews];
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

#pragma mark - 公共方法
- (void)setTitle:(NSString *)title forState:(MJRefreshState)state
{
    if (title == nil) return;
    self.stateTitles[@(state)] = title;
    self.textLabel.text = self.stateTitles[@(self.state)];
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

@end
