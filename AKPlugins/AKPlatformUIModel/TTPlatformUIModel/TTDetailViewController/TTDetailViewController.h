//
//  TTDetailViewController.h
//  Article
//
//  Created by Ray on 16/3/31.
//
//

#ifndef TTDetailViewController_h
#define TTDetailViewController_h
//#import "TTSharedViewTransition.h"
@class TTDetailModel;
@protocol TTDetailViewControllerDelegate;
@protocol TTDetailViewControllerDataSource;

#define kHasTipFavLoginUserDefaultKey @"kHasTipFavLoginUserDefaultKey"
NS_ASSUME_NONNULL_BEGIN
@protocol TTDetailViewController <NSObject>
@optional
/**
 *  告诉container 是否要显示导航栏
 */
@property (nonatomic, assign) BOOL shouldShowNavigationBar;
/**
 *  返回导航栏的左侧按钮  如果没有 则返回nil 或 不实现此协议
 */
@property (nonatomic, strong, nullable)  UIView * leftBarButton;
/**
 *  返回导航栏的右侧按钮  如果没有 则返回nil 或 不实现此协议
 */
@property (nonatomic, strong, nullable)  NSArray * rightBarButtons;

/**
 *  如果需要从container中拿数据，可以实现此协议
 */
@property (nonatomic, weak, nullable)  id<TTDetailViewControllerDataSource> dataSource;

@property (nonatomic, weak, nullable)  id<TTDetailViewControllerDelegate> delegate;

/**
 *  初始化方法
 *
 *  @param model
 *
 *  @return
 */
- (nullable instancetype)initWithDetailViewModel:(nullable TTDetailModel *)model;
/**
 *  container率先得到左侧按钮的点击事件， 在执行之前会询问sub viewcontroller是否要额外执行一些操作
 *
 *  @param container
 *  @param sender    按钮
 */
- (void)detailContainerViewController:(nullable SSViewControllerBase *)container rightBarButtonClicked:(nullable id)sender;
/**
 *  container率先得到右侧按钮的点击事件， 在执行之前会询问sub viewcontroller是否要额外执行一些操作
 *
 *  @param container
 *  @param sender    按钮
 */
- (void)detailContainerViewController:(nullable SSViewControllerBase *)container leftBarButtonClicked:(nullable id)sender;

/**
 *  抓取到content 有数据后，刷新页面
 *
 *  @param container
 *  @param detailModel 数据model
 */
- (void)detailContainerViewController:(nullable SSViewControllerBase *)container reloadData:(nullable TTDetailModel *)detailModel;

/**
 *  没有抓取到内容，需要停掉加载框
 *
 *  @param container
 *  @param error     错误信息
 */
- (void)detailContainerViewController:(nullable SSViewControllerBase *)container loadContentFailed:(nullable NSError *)error;

/**
 *  抓取到content 有数据后，按需刷新页面（适用图集导流页加载超时后加载转码页这种情况）
 *
 *  @param container
 *  @param detailModel 数据model
 */
- (void)detailContainerViewController:(SSViewControllerBase * _Nullable)container reloadDataIfNeeded:(TTDetailModel * _Nullable)detailModel;

@optional
/**
 作为子VC嵌入detailContainer容器时 detailVC.view的frame
 默认为detailContainerVC.view.frame = detailVC.view.frame

 @return detailVC.view.frame
 */
- (CGRect)detailViewFrame;


/**
 是否需要显示 容器的错误页面

 @param container 容器
 @return 是否需要显示
 */
- (BOOL)shouldShowErrorPageInDetailContaierViewController:(SSViewControllerBase *)container;
@end


@protocol TTDetailViewControllerDelegate <NSObject>
@optional

- (void)detailView:(nullable UIViewController *)controller popUpToParentViewController:(BOOL)animated;

- (void)detailView:(nullable UIViewController *)controller rightBarButtonClicked:(BOOL)animated;

@end

@protocol TTDetailViewControllerDataSource <NSObject>
@optional
/**
 *  detailViewCOntroller 想得到其在containerViewController停留的时间
 *
 *  @param controller 不同的detailViewController 计算staypage可能策略不同，所以需要传递此变量（可选）
 *
 *  @return 停留时长
 */
- (CGFloat) stayPageTimeInterValForDetailView:(nullable UIViewController *)controller;

@end
NS_ASSUME_NONNULL_END
#endif /* TTDetailViewController_h */


