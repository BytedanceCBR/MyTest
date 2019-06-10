//
//  TTIndicatorView.m
//  test
//
//  Created by lisa on 2018/12/14.
//  Copyright © 2018 lina. All rights reserved.
//

#import "TTVIndicatorView.h"

static NSTimeInterval defaultAudoStayInterval = 3; // 单位秒

@interface TTVIndicatorView ()

@property (nonatomic, strong) NSTimer * hideDelayTimer; // 设置 stayDuration 会启动
@property (nonatomic, strong) UILabel * tipLabel;       // 提示文字，最多支持两行
@property (nonatomic, strong) UIImageView * icon;       // 提示图片，加在文字的上面
@property (nonatomic, strong) UIView  * backgroundView; // 黑色背景
@property (nonatomic, weak)   UIView  * parentView;     // 主要用来处理旋转，同步 bounds 的变化

@end

@implementation TTVIndicatorView

#pragma mark - class methods
+ (instancetype)showIndicatorAudoHideWithText:(NSString * _Nonnull)text image:(UIImage * _Nullable)image {
    
    // 默认加到 keywindow 上 ？？ 不知道是否有问题
    TTVIndicatorView * indicator = [[self class] showIndicatorAddedToView:[UIApplication sharedApplication].keyWindow text:text image:image];
    indicator.stayDuration = defaultAudoStayInterval;
    return indicator;
}

+ (instancetype)showIndicatorAddedToView:(UIView * _Nonnull)view
                                    text:(NSString * _Nonnull)text
                                   image:(UIImage * _Nullable)image {
    
    TTVIndicatorView * indicator = [[TTVIndicatorView alloc] initWithView:view];
    [view addSubview:indicator];
    indicator.tipLabel.text = text;
    indicator.icon.image = image;
    [indicator show];
    return indicator;
}

+ (void)hideForView:(UIView * _Nonnull)view animated:(BOOL)animated {
    TTVIndicatorView * indicator = [[self class] indicatorForView:view];
    [indicator hideAnimated:animated];
}

+ (TTVIndicatorView * _Nullable)indicatorForView:(UIView * _Nonnull)view {
    NSEnumerator * enums = [view.subviews reverseObjectEnumerator];
    for (UIView * possibleIndicator in enums) {
        if ([possibleIndicator isKindOfClass:[self class]]) {
            return (TTVIndicatorView*)possibleIndicator;
        }
    }
    return nil;
}

#pragma mark -
- (instancetype)initWithView:(UIView *)view {
    NSAssert(view, @"提示不能添加到空视图上哈！");
    self = [super initWithFrame:view.bounds];
    if (self) {
        [self addSubview:self.backgroundView];
        self.parentView = view;
        [self.backgroundView addSubview:self.tipLabel];
        [self.backgroundView addSubview:self.icon];
        
        // 添加转屏通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleStatusBarOrientationDidChange:) name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
        
    }
    return self;
}

- (void)show {
    // 含有动画
    self.alpha = 0;
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        self.alpha = 1;
    }];
}

- (void)hideAnimated:(BOOL)animated {
    [self stopHideDelayTimer];
    if (animated) {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            self.alpha = 0;
            [self removeFromSuperview];
            if (self.hideCompletionBlock) {
                self.hideCompletionBlock();
            }
        }];
    }
    else {
        [self removeFromSuperview];
        if (self.hideCompletionBlock) {
            self.hideCompletionBlock();
        }
    }
}


#pragma mark - layout

- (void)layoutSubviews {
    
    // 提示框最大宽度是，宽度的0.5, 如果文字小于这个宽度，则按照文字宽度来
    CGFloat max_width = MIN(self.bounds.size.width, self.bounds.size.height) / 2.0;
    CGFloat min_padding = 20;
    CGFloat max_icon_height = 20;
    
    CGSize max_lableSize = CGSizeMake(max_width-min_padding*2, max_width-min_padding*2);
    
    // 计算 label 的尺寸
    CGSize tipLabelSize = [self.tipLabel sizeThatFits:max_lableSize];
    self.tipLabel.frame = CGRectMake(0, 0, tipLabelSize.width, tipLabelSize.height);
    
    CGFloat bottom = min_padding;
    // icon
    if (_icon.image) {
        _icon.hidden = NO;
        self.icon.frame = CGRectMake(0, min_padding, max_lableSize.width, max_icon_height);
        bottom += self.icon.frame.size.height+min_padding/2.0;
    }
    
    // 计算 background
    CGFloat background_width = tipLabelSize.width+min_padding*2;
    CGFloat background_height = tipLabelSize.height + min_padding*2 + self.icon.frame.size.height+(self.icon.hidden?0:min_padding/2.0);
    self.backgroundView.frame = CGRectMake(0, 0, background_width, background_height);
    
    // pos
    self.backgroundView.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
    self.tipLabel.frame = CGRectMake(0, bottom, self.tipLabel.frame.size.width, self.tipLabel.frame.size.height);
    self.tipLabel.center = CGPointMake(self.backgroundView.bounds.size.width/2.0, self.tipLabel.center.y);
    self.icon.center = CGPointMake(self.backgroundView.bounds.size.width/2.0, self.icon.center.y);
    
}

- (void)handleStatusBarOrientationDidChange:(NSNotification *)note {
    self.frame = self.parentView.bounds;
    //    [self setNeedsLayout];
}


#pragma mark - hittest 需要让事件透传,不然会在出现 indicator 时无法点击
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView * hitTestView = [super hitTest:point withEvent:event];
    if (hitTestView == self) {
        return nil;
    }
    return hitTestView;
}

#pragma mark - timer
- (void)startHideDelayTimer {
    NSTimer * timer = [NSTimer timerWithTimeInterval:self.stayDuration target:self selector:@selector(handleHideDelayTimer:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.hideDelayTimer = timer;
}

- (void)stopHideDelayTimer {
    [self.hideDelayTimer invalidate];
}

- (void)handleHideDelayTimer:(NSTimer *)timer {
    [self hideAnimated:YES];// TODO
}

#pragma mark - getters & setters
- (void)setStayDuration:(NSTimeInterval)stayDuration {
    if (_stayDuration != stayDuration) {
        _stayDuration = stayDuration;
        [self stopHideDelayTimer];
        if (_stayDuration > 0) {
            [self startHideDelayTimer];
        }
    }
}

- (UILabel *)tipLabel {
    if (_tipLabel == nil) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.textColor = [UIColor whiteColor];
        _tipLabel.textAlignment = NSTextAlignmentCenter;
        _tipLabel.numberOfLines = 2;
        _tipLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _tipLabel.font = [UIFont systemFontOfSize:17];
    }
    return _tipLabel;
}

- (UIView *)backgroundView {
    if (_backgroundView == nil) {
        _backgroundView = [[UIView alloc] init];
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        _backgroundView.layer.masksToBounds = YES;
        _backgroundView.layer.cornerRadius = 5.f;
    }
    return _backgroundView;
}

- (UIImageView *)icon {
    if (!_icon) {
        _icon = [[UIImageView alloc] init];
        _icon.contentMode = UIViewContentModeScaleAspectFit;
        _icon.hidden = YES;
    }
    return _icon;
}

@end

