//
//  WDDetailSlideNavigationView.h
//  Article
//
//  Created by wangqi.kaisa on 2017/6/22.
//
//

#import "SSThemed.h"

/*
 * 6.22 横向滑动切换回答的回答详情页自定义的导航栏view，之所有不用系统的1是担心不兼容现有代码，2是夜间模式不一定OK，3是时间成本不可控
 *      稍后有时间可能会修改成系统的
 *      状态栏：日间模式根据位置两种颜色切换，夜间模式只有一种颜色
 * 8.2  新添加一种旧的白色样式，除非日夜间，无需做颜色切换，bottomLine显示与否切换，也无需做状态栏颜色切换
 */

@class WDDetailModel;

@protocol WDDetailSlideNavigationViewDelegate <NSObject>

- (void)wdDetailSlideNaviViewTitleButtonTapped;
- (void)wdDetailSlideNaviViewBackButtonTapped;
- (void)wdDetailSlideNaviViewMoreButtonTapped;

@end

@interface WDDetailSlideNavigationView : SSThemedView

@property (nonatomic, assign) NSInteger showSlideType;

@property (nonatomic, weak) id<WDDetailSlideNavigationViewDelegate> delegate;

- (void)addExtraViewWithDetailModel:(WDDetailModel *)detailModel;

- (void)setTitleShow:(BOOL)show;

- (BOOL)isTitleShow;

- (void)reLayoutSubviews;

- (void)statusBarHeightChanged;

@end
