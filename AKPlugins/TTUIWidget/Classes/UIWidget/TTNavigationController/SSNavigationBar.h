//
//  SSNavigationBar.h
//  Article
//
//  Created by SunJiangting on 14-9-17.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"

typedef NS_ENUM(NSInteger, SSNavigationButtonOrientation) {
    SSNavigationButtonOrientationOfNormal = 0,
    SSNavigationButtonOrientationOfLeft,
    SSNavigationButtonOrientationOfRight
};

@interface TTNavigationBarItemContainerView : SSThemedView

@property (nonatomic, strong, readonly) SSThemedButton *button;
@property (nonatomic, assign, readonly) SSNavigationButtonOrientation orientation;

- (instancetype)initWithOrientation:(SSNavigationButtonOrientation)orientation;

@end

@interface SSNavigationBar : SSViewBase

@property(nonatomic, strong) UIView *backgroundView;

@property(nonatomic, copy)   NSString *title;
@property(nonatomic, strong) SSThemedLabel *titleLabel;

@property(nonatomic, strong) UIView *leftBarView;
@property(nonatomic, strong) UIView *titleView;
@property(nonatomic, strong) UIView *rightBarView;

@property(nonatomic, strong) SSThemedView *separatorView;

@property(nonatomic, assign) CGFloat preferredItemWidth;

@property(nonatomic, assign) BOOL shouldTitleViewSizeToFit;

- (void)relayoutNavigationSubviews;

- (void)setTitleText:(NSString *)title;
+ (CGFloat)navigationBarHeight;

+ (UIButton *)navigationBackButtonWithTarget:(id)target action:(SEL)action;
+ (UIButton *)navigationButtonOfOrientation:(SSNavigationButtonOrientation)orientation withTitle:(NSString *)title target:(id)target action:(SEL)action;

+ (UIView *)navigationTitleViewWithTitle:(NSString *)title;

@end
