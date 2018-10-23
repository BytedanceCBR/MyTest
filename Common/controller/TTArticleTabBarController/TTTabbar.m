//
//  TTTabbar.m
//  Article
//
//  Created by yuxin on 6/9/15.
//
//

#import "TTTabbar.h"
#import "TTThemeManager.h"
#import "UIColor+TTThemeExtension.h"
#import "NSDictionary+TTAdditions.h"
#import "UIImage+TTThemeExtension.h"
#import "UIViewAdditions.h"
#import "TTImageView.h"
#import "TTTabBarManager.h"
#import "TTTabBarCustomMiddleModel.h"


@interface TTTabbar ()

@property (nonatomic, strong) TTImageView *backImageView;
@property (nonatomic, assign) CGFloat tabItemWidth;
@property (nonatomic, assign) NSUInteger selectedIndex;

@end

@implementation TTTabbar

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        UIVisualEffectView *frost = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        CGRect rect = self.bounds;
        frost.frame = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, kTTTabBarHeight);
        frost.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self insertSubview:frost atIndex:0];
        
        if ([TTDeviceHelper isIPhoneXDevice]) {

            UIView *bg = [[UIView alloc]initWithFrame:frost.bounds];
            bg.width = [UIScreen mainScreen].bounds.size.width;
            bg.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
            [self insertSubview:bg atIndex:1];
        }

    }
    return self;
}

#pragma mark - Layout

- (void)setupTabBarItems {
    NSUInteger itemsCount = self.tabItems.count;
    NSInteger middleCustomItemViewIndex = -1;
    if (self.middleCustomItemView) {
        if (itemsCount % 2 == 0) {
            middleCustomItemViewIndex = itemsCount/2;
        }else {
            middleCustomItemViewIndex = (itemsCount + 1)/2;
        }
        itemsCount++;
    }
    self.tabItemWidth = CGRectGetWidth(self.bounds) / itemsCount;
    CGFloat itemHeight = CGRectGetHeight(self.bounds);

//    if ([TTDeviceHelper isIPhoneXDevice]){
//        UIEdgeInsets safaInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets;
//        itemHeight -= safaInset.bottom;
//    }
    for (NSUInteger index = 0; index<itemsCount; index++) {
        if (index == middleCustomItemViewIndex) {
            //Layout middle custom item view

            if ([self.middleCustomItemView isKindOfClass:[LOTAnimationView class]]) {
                self.middleCustomItemView.width = 85;
            } else {
                self.middleCustomItemView.width = self.tabItemWidth;
            }
            
            if (self.middleCustomItemView.height > kTTTabBarHeight) {
                self.middleCustomItemView.bottom = kTTTabBarHeight;
            } else {
                self.middleCustomItemView.centerY = itemHeight/2;
            }
            
            self.middleCustomItemView.centerX = CGRectGetWidth(self.bounds)/2;

            [self bringSubviewToFront:self.middleCustomItemView];
        }else {
            //Layout items
            NSUInteger tabbarItemIndex = index;
            if (tabbarItemIndex > middleCustomItemViewIndex) {
                tabbarItemIndex--;
            }
            if (tabbarItemIndex < self.tabItems.count) {
                TTTabBarItem * item = self.tabItems[tabbarItemIndex];
                CGFloat yOffset = 0.f;
                if (!item.isRegular && [TTTabBarManager sharedTTTabBarManager].middleModel.isExpand) {
                    CGFloat expandHeight = 64.f;
                    yOffset = kTTTabBarHeight - expandHeight;
                    
                    [item setFrame:CGRectMake(index * self.tabItemWidth, yOffset, self.tabItemWidth, expandHeight)];
                } else {
                    [item setFrame:CGRectMake(index * self.tabItemWidth, 0, self.tabItemWidth, itemHeight)];
                }
                [self bringSubviewToFront:item];
            }
        }
    }
}

//这里的重载 纯粹是为了 给badge定位 因为系统汇总layoutsubviews的时候 重载子view
- (void)layoutSubviews {
    [super layoutSubviews];
    [self setupTabBarItems];
}

#pragma mark - Configuration

- (void)setItemWidth:(CGFloat)itemWidth {
    if (itemWidth > 0) {
        _tabItemWidth = itemWidth;
    }
}

- (void)setTabItems:(NSArray<TTTabBarItem *> *)items {
    for (TTTabBarItem *item in self.tabItems) {
        [item removeFromSuperview];
    }
    
    _tabItems = items;
    __weak typeof(self) wself = self;
    for (TTTabBarItem *item in self.tabItems) {
        __weak typeof(item) weakItem = item;
        item.selectedBlock = ^(){
            __strong typeof(wself) self = wself;
            // 修复长按住tabbarItem时push或present操作后select后置响应的问题
            if (self.hidden || nil == self.window) {
                return;
            }
            [self setSelectedIndex:[self.tabItems indexOfObject:weakItem]];
        };
        [self addSubview:item];
    }
    [self setNeedsLayout];
}

- (void)setMiddleCustomItemView:(UIView *)middleCustomItemView {
    [_middleCustomItemView removeFromSuperview];
    _middleCustomItemView = middleCustomItemView;
    [self addSubview:_middleCustomItemView];
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

//无论selectedIndex是否和上次相同都要触发
- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    if (self.itemSelectedBlock) {
        self.itemSelectedBlock(selectedIndex);
    }
}

- (TTImageView *)backImageView {
    if (!_backImageView) {
        _backImageView = [[TTImageView alloc] init];
        _backImageView.frame = self.bounds;
        _backImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//        [self addSubview:_backImageView];
    }
    return _backImageView;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.isUserInteractionEnabled || self.isHidden || self.alpha <= 0.01) {
        return nil;
    }
    /**
     *  此注释掉的方法用来判断点击是否在父View Bounds内，
     *  如果不在父view内，就会直接不会去其子View中寻找HitTestView，return 返回
     */
    for (UIView *subview in [self.subviews reverseObjectEnumerator]) {
        CGPoint convertedPoint = [subview convertPoint:point fromView:self];
        UIView *hitTestView = [subview hitTest:convertedPoint withEvent:event];
        if (hitTestView) {
            return hitTestView;
        }
    }

    return nil;
}

#pragma mark - Public Method

- (void)setItemLoading:(BOOL)loading forIndex:(NSUInteger)index {
    if (index >= self.tabItems.count) {
        return;
    }
    
    TTTabBarItem *item = [self.tabItems objectAtIndex:index];
    
    if (loading) {
        item.state = TTTabBarItemStateLoading;
    }
    else {
        item.state = index == self.selectedIndex ? TTTabBarItemStateHighlighted : TTTabBarItemStateNormal;
    }
}

- (void)setCustomBackgroundImage:(UIImage *)image {
    [self.backImageView setImage:image];
}

@end
