//
//  NIHRefreshCustomFooter.m
//  Article
//
//  Created by 张静 on 2018/8/30.
//

#import "NIHRefreshCustomFooter.h"
#import "UIView+TTFFrame.h"

@interface NIHRefreshCustomFooter()

@property (weak, nonatomic) UILabel *label;

@property (weak, nonatomic) UIImageView *loadingIndicator;

@end


@implementation NIHRefreshCustomFooter
#pragma mark - 重写方法
#pragma mark 在这里做一些初始化配置（比如添加子控件）
- (void)prepare
{
    [super prepare];
    
    // 设置控件的高度
    self.mj_h = 40;
    self.onlyRefreshPerDrag = YES;

    // 添加label
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor colorWithRed: 34/ 255 green: 34/ 255 blue: 34/ 255 alpha:1];
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    self.label = label;
    
    UIImageView *loadingIndicator = [[UIImageView alloc] init];
    loadingIndicator.image = [UIImage imageNamed: @"loading_icon"];
    [self addSubview:loadingIndicator];
    self.loadingIndicator = loadingIndicator;

}

#pragma mark 在这里设置子控件的位置和尺寸
- (void)placeSubviews
{
    [super placeSubviews];
    
    [self.loadingIndicator sizeToFit];
    [self.label sizeToFit];
    self.loadingIndicator.width = 12;
    self.loadingIndicator.height = 12;
    
    if (self.loadingIndicator.hidden) {
        
        self.label.ttf_centerX = [UIScreen mainScreen].bounds.size.width / 2;

    }else {
        
        self.label.x = ([UIScreen mainScreen].bounds.size.width - self.label.width - self.loadingIndicator.width - 5) / 2;
        self.loadingIndicator.x = self.label.right + 5;
    }

    self.loadingIndicator.ttf_centerY = self.mj_h / 2;
    self.label.ttf_centerY = self.loadingIndicator.ttf_centerY;

}

#pragma mark 监听scrollView的contentOffset改变
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
    
}

#pragma mark 监听scrollView的contentSize改变
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];
    
}

#pragma mark 监听scrollView的拖拽状态改变
- (void)scrollViewPanStateDidChange:(NSDictionary *)change
{
    [super scrollViewPanStateDidChange:change];
    
}

#pragma mark 监听控件的刷新状态
- (void)setState:(MJRefreshState)state {
    MJRefreshCheckState;
    
    switch (state) {
        case MJRefreshStateIdle:
            self.label.text = @"上拉加载更多";
            self.loadingIndicator.hidden = YES;
            [self.loadingIndicator.layer removeAllAnimations];
            break;
            
        case MJRefreshStatePulling:
            self.label.text = @"松手加载更多";
            self.loadingIndicator.hidden = YES;
            [self.loadingIndicator.layer removeAllAnimations];

        case MJRefreshStateRefreshing: {
            
            self.label.text = @"正在努力加载";
            self.loadingIndicator.hidden = NO;
            CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotationAnimation.toValue = @(M_PI * 2.0);
            rotationAnimation.duration = 2;
            rotationAnimation.repeatCount = MAXFLOAT;
            [self.loadingIndicator.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
            break;
        }
            
        case MJRefreshStateNoMoreData:
            self.label.text = @" -- END -- ";
            self.loadingIndicator.hidden = YES;
            [self.loadingIndicator.layer removeAllAnimations];

            break;
        default:
            break;
    }
}

@end
