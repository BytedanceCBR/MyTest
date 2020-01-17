//
//  TTModalWrapController.h
//  Article
//
//  Created by muhuai on 2017/4/5.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TTModalControllerTitleView.h"
#import <TTUIWidget/SSViewControllerBase.h>
#import <TTUIWidget/TTNavigationController.h>

/** Container提供给nestedVC调用的方法 */
@protocol TTModalWrapNestedViewProtocol <NSObject>
/** 刷新返回和关闭按钮样式 */
- (void)refreshModalContainerTitleView;
@end


/** nestedVC需要提供的方法 */
@class TTModalWrapController;
@protocol TTModalWrapControllerProtocol <NSObject>

@optional
@property (nonatomic, assign) BOOL hasNestedInModalContainer; //让业务层知道 自己是否处在Modal容器里..
@property (nonatomic, assign) BOOL disableRoundCorner;

- (void)setModalWrapContainer:(id<TTModalWrapNestedViewProtocol>)modalContainer;// 让nestedVC获取当前container

/**
 会对ScrollView做一些特殊的手势处理, 如果需要联动,实现该协议

 @return 需要联动的ScrollView
 */
- (UIScrollView *)tt_scrollView;

/**
 下拉手势经常会与其他手势冲突, 如果需要同时响应, 实现该协议

 @return 需要和下拉手势一同响应的手势
 */
- (NSArray<UIView *> *)simultaneouslyPullGestureViews;


/**
 是否禁用右滑退出

 @return 是/否
 */

- (BOOL)shouldDisableRightSwipeGesture;
/**
 控制左上角返回按钮的样式

 @return 样式
 */
- (TTModalControllerTitleType)leftBarItemStyle;

/**
 隐藏标题栏下面的分割线

 @return 是/否
 */
- (BOOL)hiddenTitleViewBottomLineInModalContainer;


/**
 是否需要拦截back按钮

 @return 是/否
 */
- (BOOL)shouldInterceptBackBarItemInModalContainer;

@end

@protocol TTModalWrapControllerDelegate <NSObject>

@required
- (void)modalWrapController:(TTModalWrapController *)controller closeButtonOnClick:(id)sender;

- (void)modalWrapController:(TTModalWrapController *)controller backButtonOnClick:(id)sender;

- (void)modalWrapController:(TTModalWrapController *)controller panAtPercent:(CGFloat)percent;
@end

@interface TTModalWrapController : SSViewControllerBase <TTModalWrapNestedViewProtocol>
@property (nonatomic, strong, readonly) UIView<TTModalWrapControllerTitleViewProtocol> *titleView;
@property (nonatomic, assign) BOOL titleViewHidden; // 是否隐藏titleView, default is NO
@property (nonatomic, weak) id<TTModalWrapControllerDelegate> delegate;
@property (nonatomic, strong, readonly) UIViewController<TTModalWrapControllerProtocol> *nestedController;

/**
 浮层VC

 @param controller 要嵌入浮层的VC, 这个是最终展现的业务VC
 @return 浮层VC,
 */
- (instancetype)initWithController:(UIViewController<TTModalWrapControllerProtocol> *)controller;

- (instancetype)initWithController:(UIViewController<TTModalWrapControllerProtocol> *)controller disabledGesture:(UIGestureRecognizer *)disabledGesture;
@end


@interface UIViewController (ModelControllerWrapper)


/**
 是否隐藏ModalWapperTitleView
 */
@property (nonatomic, assign) BOOL tt_modalWrapperTitleViewHidden;

@property (nonatomic, strong) UIView<TTModalWrapControllerTitleViewProtocol> *tt_modalWrapTitleView;

@property (nonatomic, assign) CGFloat tt_modalWrapTitleViewHeight;

@end
