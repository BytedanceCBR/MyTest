//
//  TTTabBarItem.h
//  Pods
//
//  Created by fengyadong on 16/7/12.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "TTBadgeNumberView.h"
#import <Lottie/Lottie.h>

typedef void(^SelectedBlock)();

typedef NS_ENUM(NSUInteger, TTTabBarItemState) {
    TTTabBarItemStateNone,//初始状态
    TTTabBarItemStateNormal,//未被选中
    TTTabBarItemStateHighlighted,//被选中
    TTTabBarItemStateLoading//加载中
};

@interface TTTabBarItem : SSThemedView

@property (nonatomic, strong)           UIFont *titleFont;
@property (nonatomic, strong)           UIColor *normalTitleColor;
@property (nonatomic, strong)           UIColor *highlightedTitleColor;
@property (nonatomic, copy)             SelectedBlock selectedBlock;

@property (nonatomic, assign, readonly) TTTabBarItemState state;
@property (nonatomic, strong, readonly) SSThemedImageView *imageView;

@property (nonatomic, strong, readonly) TTBadgeNumberView * ttBadgeView;
@property (nonatomic, assign)           CGFloat ttBadgeOffsetV;/*距离TabItem imageView右上角的纵向偏移量*/
@property (nonatomic, assign, readonly) NSUInteger index;
@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, strong, readonly) UIViewController *viewController;
@property (nonatomic, assign, readonly) BOOL isRegular;
@property (nonatomic, strong, readwrite) LOTAnimationView *animationView;
// 表示当前tabItem是否隐藏。用于不改变tabItems数据源，可随时隐藏/显示的case
@property (nonatomic, assign, readwrite) BOOL freezed;

- (void)setTitle:(NSString *)title;
- (void)setNormalImage:(UIImage *)normalImage
      highlightedImage:(UIImage *)highlightedImage
            loadingImage:(UIImage *)loadingImage;
- (void)setState:(TTTabBarItemState)state;

- (instancetype)initWithIdentifier:(NSString *)identifier viewController:(UIViewController *)viewController index:(NSUInteger)index isRegular:(BOOL)isRegular;

//批量缓存所有tabBar label的size
+ (void)syncAllCachedBounds;

@end
