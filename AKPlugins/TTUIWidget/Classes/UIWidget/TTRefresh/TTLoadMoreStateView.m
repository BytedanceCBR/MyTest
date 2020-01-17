//
//  TTLoadMoreStateView.m
//  TTUIWidget
//
//  Created by carl on 2018/3/1.
//

#import "TTLoadMoreStateView.h"
#import <Masonry/Masonry.h>
#import "UIImage+TTThemeExtension.h"
#import <TTThemeManager.h>

@implementation TTLoadMoreStateView

- (void)reduxState:(PullDirectionState)state {
    self.state = state;
}

@end


@interface TTLoadMoreStateNomoreView ()

@property (nonatomic, strong) SSThemedButton *titleButton;
@property (nonatomic, strong) SSThemedLabel *subtitleLabel;

@end

@implementation TTLoadMoreStateNomoreView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildupView];
    }
    return self;
}

- (void)buildupView {
    
    self.backgroundColorThemeKey = kColorBackground3;
    self.titleButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    [self.titleButton setImage:[UIImage themedImageNamed:@"loadmore_arrow_up"] forState:UIControlStateNormal];
    self.titleButton.titleColorThemeKey = kColorText2;
    self.titleButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
   
    [self.titleButton setTitle:@" 继 续 上 滑" forState:UIControlStateNormal];
    [self.titleButton setTitle:@" 松 手 释 放" forState:UIControlStateSelected];
    [self addSubview:self.titleButton];

    self.subtitleLabel = [[SSThemedLabel alloc] init];
    self.subtitleLabel.attributedText = [self subtitleAttributeText];
    self.subtitleLabel.font = [UIFont systemFontOfSize:12.0f];
    [self addSubview:self.subtitleLabel];
    
    [self.titleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(@18);
        make.centerX.mas_equalTo(@0);
    }];
    
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleButton.mas_bottom).offset(4);
        make.centerX.mas_equalTo(@0);
        make.left.mas_greaterThanOrEqualTo(@15);
        make.right.mas_lessThanOrEqualTo(@-15);
    }];
    self.clipsToBounds = YES;
    
}

- (NSAttributedString *)subtitleAttributeText {
   TTThemeMode themeModel = [[TTThemeManager sharedInstance_tt] currentThemeMode];
    NSMutableDictionary *subAttribute = @{}.mutableCopy;
    subAttribute[NSKernAttributeName] = @1.5;
    subAttribute[NSForegroundColorAttributeName] = [UIColor tt_themedColorForKey:kColorText3];
    subAttribute[NSFontAttributeName] = [UIFont systemFontOfSize:12.0f];
    NSAttributedString *subText = [[NSAttributedString alloc] initWithString:@"为你推荐更多精彩内容" attributes:subAttribute];
    return subText;
}

- (void)themeChanged:(NSNotification *)notification {
    self.subtitleLabel.attributedText = [self subtitleAttributeText];
}

- (void)updateScrollPercent:(CGFloat)percent {
    if (self.state == PULL_REFRESH_STATE_INIT) {
        return;
    }
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(1 + percent, 1 + percent);
    self.transform = scaleTransform;
}

- (void)reduxState:(PullDirectionState)state {
    if (state == PULL_REFRESH_STATE_PULL_OVER) {
         self.titleButton.selected = YES;
    } else {
        self.titleButton.selected = NO;
    }
    
    if (self.state != PULL_REFRESH_STATE_INIT && state == PULL_REFRESH_STATE_INIT) {
        [UIView animateWithDuration:0.23 animations:^{
            self.transform = CGAffineTransformIdentity;
        }];
    }
    self.state = state;
}

@end
