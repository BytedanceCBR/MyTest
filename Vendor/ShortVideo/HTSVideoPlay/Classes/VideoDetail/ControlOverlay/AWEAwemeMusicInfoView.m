//
//  AWEAwemeMusicInfoView.m
//  Aweme
//
//  Created by willorfang on 16/10/9.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import "AWEAwemeMusicInfoView.h"
#import <Masonry/Masonry.h>
#import "UIColor+TTThemeExtension.h"

@interface AWEAwemeMusicInfoView ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIView *loopContainerView;
@property (nonatomic, strong) UIImageView *musicLogoView;
@property (nonatomic, assign) CGFloat containerViewWidth;
@property (nonatomic, assign) CGFloat containerViewHeight;
@property (nonatomic, assign) CGFloat subviewWidth;
@property (nonatomic, assign) NSInteger subviewCount;

@end

@implementation AWEAwemeMusicInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        
        _containerView = [UIView new];
        _containerView.clipsToBounds = YES;
        [self addSubview:_containerView];
        
        _loopContainerView = [UIView new];
        [_containerView addSubview:_loopContainerView];
        // icon
        _musicLogoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tsv_music_icon"]];
        _musicLogoView.contentMode = UIViewContentModeScaleAspectFit;
        _musicLogoView.frame = CGRectMake(0, 0, 16, 16);
        [self addSubview:_musicLogoView];
    }
    
    return self;
}

- (void)configRollingAnimationWithLabelString:(NSString *)musicLabelString;
{
    // 清除旧有的subview
    [self.loopContainerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    // 计算蒙版的宽度
    self.containerViewWidth = [UIScreen mainScreen].bounds.size.width;
    self.containerViewHeight = 16;
    
    // 计算subview的宽度
    self.subviewWidth = [self widthWithLabelString:musicLabelString];
    
    // 填充subview
    self.subviewCount = ceil(self.containerViewWidth / self.subviewWidth) + 1;
    self.musicLogoView.hidden = self.hideLogo;
    CGFloat x = self.hideLogo ? 0 : 18;
    self.containerView.frame = CGRectMake(x,
                                      0,
                                      self.subviewWidth * self.subviewCount,
                                      self.containerViewHeight);

    self.loopContainerView.frame = CGRectMake(0,
                                          0,
                                          self.subviewWidth * self.subviewCount,
                                          self.containerViewHeight);
    //
    for (int i = 0; i < self.subviewCount; ++i) {
        UIView *extrasubview = [self subviewItemWithLabelString:musicLabelString];
        [self.loopContainerView addSubview:extrasubview];
        extrasubview.frame = CGRectMake(i * self.subviewWidth,
                                        0,
                                        self.subviewWidth,
                                        self.containerViewHeight);
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)startAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    animation.duration = 20 * self.subviewWidth / self.containerViewWidth;
    animation.fromValue = @(0);
    animation.toValue = @(-self.subviewWidth);
    animation.removedOnCompletion = NO;
    animation.repeatCount = HUGE_VALF;
    [self.loopContainerView.layer addAnimation:animation forKey:nil];
}

- (void)stopAnimation
{
    [self.loopContainerView.layer removeAllAnimations];
}

- (UIView *)subviewItemWithLabelString:(NSString *)musicLabelString
{
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.subviewWidth, 16)];
    // label
    UILabel *musicLabel = [UILabel new];
    musicLabel.textColor = [UIColor colorWithHexString:@"ffffffe6"];
    musicLabel.font = [UIFont systemFontOfSize:14];
    musicLabel.lineBreakMode = NSLineBreakByWordWrapping;
    musicLabel.numberOfLines = 0;
    if (!self.shadowDisabled) {
        musicLabel.layer.shadowOffset = CGSizeZero;
        musicLabel.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.6].CGColor;
        musicLabel.layer.shadowRadius = 1.0;
        musicLabel.layer.shadowOpacity = 1.0;
    }
    musicLabel.text = musicLabelString;
    musicLabel.frame = CGRectMake(0, 0, self.subviewWidth - 15, 16);
    [containerView addSubview:musicLabel];
    
    return containerView;
}

- (CGFloat)widthWithLabelString:(NSString *)musicLabelString
{
    UILabel *musicLabel = [UILabel new];
    musicLabel.font = [UIFont systemFontOfSize:14];
    musicLabel.text = musicLabelString;
    //
    CGFloat width = 15 + [self widthWithText:musicLabel.text font:musicLabel.font height:14];
    return width;
}

- (CGFloat)widthWithText:(NSString *)text font:(UIFont *)font height:(CGFloat)height
{
    CGRect rect = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
                                     options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                  attributes:@{ NSFontAttributeName : font }
                                     context:nil];
    CGFloat width = ceil(rect.size.width);
    return width;
}

@end
