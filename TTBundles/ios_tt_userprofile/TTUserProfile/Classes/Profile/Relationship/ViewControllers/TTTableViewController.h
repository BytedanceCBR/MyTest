//
//  TTTableViewController.h
//  Article
//
//  Created by liuzuopeng on 9/9/16.
//
//

#import "TTBaseTableViewController.h"
#import "UIScrollView+Refresh.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "UIView+Refresh_ErrorHandler.h"


@protocol TTTableRefreshEventPageProtocol <NSObject>
@required
/**
 *  page name that flags view controller
 *
 *  @return page name
 */
- (NSString *)eventPageKey;
@end

@interface TTTableViewController : TTBaseTableViewController
<
UITableViewDelegate,
UITableViewDataSource,
UIViewControllerErrorHandler,
TTTableRefreshEventPageProtocol
>
// if reload when view has appeared
@property (nonatomic, assign) BOOL reloadWhenAppear; // default is NO

// if supports reload when pull down
@property (nonatomic, assign) BOOL reloadEnabled; // default is YES

// if supports load more when pull up
@property (nonatomic, assign) BOOL loadMoreEnabled; // default is YES


/**
 * 在tableView reloadData之前，会调用rebuildIndexes来建立结构化的数据
 * 重载该方法，计算和结构化网络返回的数据
 */
- (void)rebuildIndexes;

/**
 *  overrid to send network request, must call super to tt_startUpdate
 */
- (void)loadRequest;

/**
 *  手动触发下拉并且执行triggerReload
 */
- (void)pullDownToReload;

/**
 *  手动触发上拉加载并且执行triggerLoadMore
 */
- (void)pullUpToLoadMore;

/**
 *  发送网络请求，获取新的数据
 */
- (void)triggerReload;

/**
 *  发送网络请求，在此当前数据基础上获取更多数据
 */
- (void)triggerLoadMore;

/**
 *  重新刷新tableview，一般在初始化和网络返回后调用
 */
- (void)reload;

- (void)reloadWithError:(NSError *)error;

/**
 *  重载，返回当前是否有更多的数据去加载，默认返回NO
 *
 *  @return 是否有更多的数据
 */
- (BOOL)hasMoreData;

/**
 *  网络请求完成后调用，判断是否有错误并根据错误类型来显示相应的错误提示信息
 *
 *  @param error 错误描述
 */
- (void)finishNetworkResponseWithError:(NSError *)error;

/**
 * return YES, when pulling down to refresh; or return NO
 */
- (BOOL)isRefreshing;

/**
 * return YES, when pulling up to load more; or return NO
 */
- (BOOL)isLoadingMore;

@end
