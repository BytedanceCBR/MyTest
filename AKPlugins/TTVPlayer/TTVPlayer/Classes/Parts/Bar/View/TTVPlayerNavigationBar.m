//
//  TTVPlayerNavigationBar.m
//  TTVPlayer
//
//  Created by lisa on 2019/2/7.
//

#import "TTVPlayerNavigationBar.h"
#import "UIImage+TTVHelper.h"

@implementation TTVPlayerNavigationBar

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // 这里是否添加在这里，是有问题的？？
        [self addSubview:self.backgroundImageView];
        [self addSubview:self.defaultTitleLable];
        [self addSubview:self.defaultBackButton];
    }
    return self;
}

#pragma mark - layout
- (void)layoutSubviews {
//    CGFloat leftMargin = 20;
    // 默认顶部
    UIView * leftButton = [self leftButton];
    [leftButton sizeToFit];
//    leftButton.left = leftMargin;


    UIView * titleView = [self titleView];
    titleView.width = self.width - titleView.left * 2 - self.customRightView.width;
    titleView.height = self.height;

    if (self.verticalAlign == TTVPlayerLayoutVerticalAlign_Top) {
        leftButton.top = 0;
        titleView.top = 0;
    }
    else if (self.verticalAlign == TTVPlayerLayoutVerticalAlign_Center) {
        leftButton.center = CGPointMake(self.width/2.0, self.height/2.0);
        titleView.center = CGPointMake(self.width/2.0, self.height/2.0);
    }
    else if (self.verticalAlign == TTVPlayerLayoutVerticalAlign_bottom) {
        leftButton.top = MAX(0, self.height - leftButton.height);
        titleView.top = MAX(0, self.height - titleView.height);
    }
    
    self.backgroundImageView.frame = self.bounds;
}


#pragma mark - action
- (void)defaultBackButtonClicked:(UIButton *)button {
    // 找到自己属于的vc，然后判断 vc
    [TTVPlayerUtility quitCurrentViewController];
}

#pragma mark - getters & setters
- (UILabel *)defaultTitleLable {
    if (!_defaultTitleLable) {
        _defaultTitleLable = [[UILabel alloc] init];
        _defaultTitleLable.backgroundColor = [UIColor clearColor];
        _defaultTitleLable.textColor = [UIColor colorWithWhite:255.0f / 255.0f alpha:1.0f];
        _defaultTitleLable.numberOfLines = 0;
        _defaultTitleLable.textAlignment = NSTextAlignmentLeft;
    }
    return _defaultTitleLable;
}

- (UIButton *)defaultBackButton {
    if (!_defaultBackButton) {
        UIButton *fullbackButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [fullbackButton setImage:[UIImage ttv_ImageNamed:@"player_back"] forState:UIControlStateNormal];
        [fullbackButton sizeToFit];
        fullbackButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
        [fullbackButton addTarget:self action:@selector(defaultBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        _defaultBackButton = fullbackButton;
    }
    
    return _defaultBackButton;
}

- (UIImageView *)backgroundImageView {
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] init];
    }
    return _backgroundImageView;
}

- (void)setCustomTitleView:(UIView *)customTitleView {
    _customTitleView = customTitleView;
    if (_customTitleView && self.customTitleView.superview != self) {
        self.defaultTitleLable.hidden = YES;
        [self addSubview:self.customTitleView];
    }
}

- (void)setCustomLeftButton:(UIButton *)customLeftButton {
    _customLeftButton = customLeftButton;
    if (_customLeftButton && self.customLeftButton.superview != self) {
        self.defaultBackButton.hidden = YES;
        [self addSubview:self.customLeftButton];
    }
}
// 当前起作用的 titleView
- (UIView *)titleView {
    if (self.customTitleView && !self.customTitleView.hidden) {
        return self.customTitleView;
    }
    if (!self.defaultTitleLable.hidden) {
        return self.defaultTitleLable;
    }
    return nil;
}
// 当前起作用的 leftbutton
- (UIView *)leftButton {
    if (self.customLeftButton && !self.customLeftButton.hidden) {
        return self.customLeftButton;
    }
    if (!self.defaultBackButton.hidden) {
        return self.defaultBackButton;
    }
    return nil;
}

- (UIView *)rightView {
    return self.rightView;
}

- (void)setVerticalAlign:(TTVPlayerLayoutVerticalAlign)verticalAlign {
    _verticalAlign = verticalAlign;
    [self setNeedsLayout];
}

@end
