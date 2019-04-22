//
//  TTTabbar.h
//  Article
//
//  Created by yuxin on 6/9/15.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "TTTabBarItem.h"
#define kTTTabBarHeight ([TTDeviceHelper isIPhoneXDevice] ? 83.f : 49.f)

typedef void(^TabBarItemSelectedBlock)(NSUInteger index);

@interface TTTabbar : UITabBar

@property (nonatomic, assign, readonly)  NSUInteger selectedIndex;
@property (nonatomic, copy)              NSArray<TTTabBarItem *> *tabItems;
@property (nonatomic, strong)            UIView * middleCustomItemView;
@property (nonatomic, copy)              TabBarItemSelectedBlock itemSelectedBlock;

- (void)setItemLoading:(BOOL)loading forIndex:(NSUInteger)index;
- (void)setCustomBackgroundImage:(UIImage *)image;

@end
