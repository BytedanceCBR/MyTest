//
//  ExploreVideoTopView.m
//  Article
//
//  Created by 冯靖君 on 15/8/28.
//
//

#import "ExploreVideoTopView.h"

#import "UIButton+TTAdditions.h"
#import "ExploreVideoDetailHelper.h"
#import "TTDeviceHelper.h"

#define kLeftMargin     10.f

@interface ExploreVideoTopView ()
@property(nonatomic, strong) TTAlphaThemedButton *backButton;
@end

@implementation ExploreVideoTopView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self buildBackButton];
        [self reloadThemeUI];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (void)buildBackButton
{
    _backButton = [[TTAlphaThemedButton alloc] init];
    _backButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -12, -15, -36);
    
    [self addSubview:_backButton];
    
    [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([TTDeviceHelper isPadDevice]) {
            make.top.equalTo(self).offset(kLeftMargin);
        } else {
            make.centerY.equalTo(self);
        }
        make.left.equalTo(self).offset(kLeftMargin);
    }];
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    self.backgroundColor = [UIColor clearColor];
    NSString *imgName = [TTDeviceHelper isPadDevice] ? @"leftbackbutton_video_detais" : @"shadow_lefterback_titlebar";
    [_backButton setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
    [_backButton setImage:[UIImage imageNamed:@"shadow_lefterback_titlebar_press"] forState:UIControlStateHighlighted];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect rect = UIEdgeInsetsInsetRect(self.backButton.frame, self.backButton.hitTestEdgeInsets);
    return CGRectContainsPoint(rect, point);
}

@end
