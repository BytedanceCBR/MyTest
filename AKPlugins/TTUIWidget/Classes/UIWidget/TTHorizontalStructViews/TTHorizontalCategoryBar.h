//
//  TTHorizontalTabbar.h
//  HorizontalTabbar
//
//  Created by 刘廷勇 on 15/8/25.
//  Copyright (c) 2015年 liuty. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SSThemed.h"

typedef void(^TTCategoryItemSelectedHandler)(NSUInteger index);
typedef void(^TTCategoryItemTappedHandler)(NSUInteger indexOfTappedItem, NSUInteger currentIndex);

typedef NS_ENUM(NSUInteger, TTCategoryItemBadgeStyle) {
    TTCategoryItemBadgeStyleNone,
    TTCategoryItemBadgeStylePoint,
    TTCategoryItemBadgeStyleNumber
};

#pragma mark - TTCategoryItem
/** 频道项 */
@interface TTCategoryItem : NSObject

/** 红点数量 */
@property (nonatomic, assign) NSInteger badgeNum;
/** 红点类型 */
@property (nonatomic, assign) TTCategoryItemBadgeStyle badgeStyle;
/** 频道名称 */
@property (nonatomic, copy) NSString * _Nonnull title;

@end


#pragma mark - TTHorizontalCategoryBarDelegate
/** 水平频道栏协议 */
@protocol TTHorizontalCategoryBarDelegate<NSObject>

/** 每个项的大小 */
- (CGSize)sizeForEachItem:(nonnull TTCategoryItem *)item;
/** 单项内部偏移 */
- (UIEdgeInsets)insetForSection;
/** 红点对于标题的偏移量 */
- (UIOffset)offsetOfBadgeViewToTitleView;

@end


@interface TTHorizontalCategoryBar : SSThemedView
/** 频道项 */
@property (nonatomic, strong) NSArray<TTCategoryItem *> * _Nonnull categories;
/** 频道被选中响应 */
@property (nonatomic, copy) TTCategoryItemSelectedHandler _Nullable didSelectCategory;
/** 频道项被点击响应 */
@property (nonatomic, copy) TTCategoryItemTappedHandler _Nullable didTapCategoryItem;

@property (nonatomic) CGFloat interitemSpacing;//Default 30pt
@property (nonatomic) CGFloat itemExpandSpacing;
@property (nonatomic) CGFloat leftAlignmentPadding;

@property (nonatomic) NSUInteger selectedIndex;                 //Initial 0

@property (nonatomic, strong) UIColor * _Nonnull bottomIndicatorColor;    //Default redColor
@property (nonatomic, copy) NSString * _Nullable bottomIndicatorColorThemeKey;
@property (nonatomic) BOOL bottomIndicatorEnabled;              //Default YES
@property (nonatomic) BOOL leftAlignmentEnabled;
@property (nonatomic) BOOL enableSelectedHighlight;//Default YES;
@property (nonatomic) BOOL enableAnimatedHighlighted;//控制移动滚动条的时候，渐变的效果是否开启，默认为YES
@property (nonatomic) BOOL bottomIndicatorFitTitle;

@property (nonatomic) CGFloat itemInsetSpacing;
@property (nonatomic) CGFloat bottomIndeicatorBottomSpacing;

@property (nonatomic) NSUInteger bottomIndicatorMinLength;

@property (nonatomic, weak) id<TTHorizontalCategoryBarDelegate> _Nullable delegate;

- (nonnull instancetype)initWithFrame:(CGRect)frame;

- (nonnull instancetype)initWithFrame:(CGRect)frame delegate:(id<TTHorizontalCategoryBarDelegate> _Nonnull)delegate;

- (void)updateInteractiveTransition:(CGFloat)percentComplete fromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex;

- (void)scrollToIndex:(NSUInteger)index;

- (void)showVerticalLine:(BOOL)show;

- (void)setTabBarAnimateToBigger:(BOOL)animate;

- (void)setTabBarTextColor:(nonnull UIColor *)textColor maskColor:(nonnull UIColor *)maskColor lineColor:(nonnull UIColor *)lineColor;

/// set colorThemeKey
- (void)setTabBarTextColorThemeKey:(nonnull NSString *)textColorKey maskColorThemeKey:(nonnull NSString *)maskColorKey lineColorThemeKey:(nonnull NSString *)lineColorKey;

- (void)setTabBarTextFont:(nonnull UIFont *)font;
- (void)setTabBarTextFont:(nonnull UIFont *)textFont maskTextFont:(nonnull UIFont *)maskFont;

- (void)setBottomSeperatorHidden:(BOOL)hidden;

- (void)setBadgeNumber:(NSUInteger)badgeNumber AtIndex:(NSUInteger)index;

- (void)reloadItemAtIndex:(NSUInteger)index;

- (void)didSelectItemAtIndex:(NSUInteger)index;

- (void)updateAppearanceColor;

@end
