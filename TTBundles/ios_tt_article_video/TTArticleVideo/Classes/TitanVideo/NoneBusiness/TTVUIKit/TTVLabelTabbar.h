//
//  TTVLabelTabbar.h
//  Article
//
//  Created by pei yun on 2017/3/23.
//
//

#import <UIKit/UIKit.h>

@class TTVLabelTabbar;
@protocol TTVLabelTabbarDelegate <NSObject>
@required
- (void)tabbar:(TTVLabelTabbar *)tabbar didSelectedIndex:(NSInteger)index;

@end

@interface TTVLabelTabbar : UIScrollView

@property (nonatomic, weak) id<TTVLabelTabbarDelegate> delegateCustom;
@property (nonatomic)NSInteger selectedIndex;
@property (nonatomic, assign) NSTimeInterval animateDuration; // defaults to .5s
@property (nonatomic, strong) UIColor *unhighlightColor;
@property (nonatomic, strong) UIColor *highlightColor;
@property (nonatomic, readonly) NSArray *tabs;
@property (nonatomic, assign) BOOL forceLeftAlignment; // default to NO.forceLeftAlignment为YES时，tabs之间等间距排列，如果所有tabs所需要的总宽度小于屏幕宽度，则居左展示。如果forceLeftAlignment为NO时，每个tab的宽度相等，平分总宽度，居中展示。
@property (nonatomic, assign) BOOL indicatorMovingWhenPageDragged; // default to YES.indicatorMovingWhenPageDragged为YES时，意味着在向左或右拖动页面时，指示标会随着页面位置滑动而移动。indicatorMovingWhenPageDragged为NO时，意味着在向左或右拖动页面时，指示标不会随着页面移动，当确认选中某个页面后，指示标才会滑动到相应的tab下边。

- (void)setTabs:(NSArray *)tabs;
- (void)setIndicator:(UIView *)indicator;
- (instancetype)initWithTabs:(NSArray *)tabs;
- (void)layoutTabs;
- (void)setTabNormalizedOffset:(CGFloat)offset;

@end
