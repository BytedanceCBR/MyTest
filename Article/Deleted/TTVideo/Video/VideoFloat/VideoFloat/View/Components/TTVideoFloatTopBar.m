//
//  TTVideoFloatTopBar.m
//  Article
//
//  Created by panxiang on 16/7/6.
//
//

#import "TTVideoFloatTopBar.h"

@interface TTVideoFloatTopBar ()
@property(nonatomic, strong ,readwrite) UIButton *backButton;
@property(nonatomic, strong ,readwrite) SSThemedLabel *titleLabel;
@property(nonatomic, strong) UIImageView *backgroundView;
@end

@implementation TTVideoFloatTopBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        UIImage *bg = [UIImage imageNamed:@"titlebar_shadow.png"];
        _backgroundView = [[UIImageView alloc] init];
        _backgroundView.userInteractionEnabled = YES;
        _backgroundView.image = [bg stretchableImageWithLeftCapWidth:bg.size.width/2.0 topCapHeight:bg.size.height/2.0];
        _backgroundView.userInteractionEnabled = YES;
        [self addSubview:_backgroundView];
        
        self.backgroundColor = [UIColor clearColor];
        [self buildBackButton];
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.text = @"更多视频";
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.textColor = [UIColor tt_defaultColorForKey:kColorText10];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [_titleLabel sizeToFit];
        [self addSubview:_titleLabel];
        _titleLabel.alpha = 0;
        _hiddenTitle = YES;
    }
    return self;
}

- (void)hidden:(BOOL)hidden animated:(BOOL)animated
{
    CGFloat alpha = 0.2;
    if (animated) {
        [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
        
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = hidden ? alpha : 1;
        } completion:^(BOOL finished) {
            if (!self.hiddenTitle) {
                self.titleLabel.alpha = hidden ? 0 : 1;
            }
        }];
    }
    else
    {
        [[UIApplication sharedApplication] setStatusBarHidden:hidden];
        self.alpha = hidden ? alpha : 1;
    }
}


- (void)layoutSubviews
{
    _backButton.frame = CGRectMake([TTDeviceUIUtils tt_newPaddingSpecialElement:13], ((self.height - 20) - _backButton.height) / 2.0 + 20, _backButton.width, _backButton.height);
    _backgroundView.frame = self.bounds;
    _titleLabel.center = CGPointMake(self.width/2.0, (self.height - 20)/2.0 + 20);
    [super layoutSubviews];
}

- (void)setHiddenTitle:(BOOL)hiddenTitle
{
    _hiddenTitle = hiddenTitle;
    [UIView animateWithDuration:0.25 animations:^{
        if (self.hiddenTitle) {
            _titleLabel.alpha = 0;
        }
        else
        {
            _titleLabel.alpha = 1;
        }
    }];
}

- (void)buildBackButton
{
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backButton setBackgroundImage:[UIImage imageNamed:@"titlebar_close_white.png"] forState:UIControlStateNormal];
    [_backButton sizeToFit];
    _backButton.hitTestEdgeInsets = UIEdgeInsetsMake(-15, -15, -15, -15);
    [self addSubview:_backButton];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return CGRectContainsPoint(self.frame, point);
}

@end
