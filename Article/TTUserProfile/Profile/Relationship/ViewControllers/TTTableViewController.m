//
//  TTTableViewController.m
//  Article
//
//  Created by liuzuopeng on 9/9/16.
//
//

#import "TTTableViewController.h"
#import <TTAccountBusiness.h>



typedef NS_ENUM(NSUInteger, TTNetworkRequestType) {
    kTTNetworkRequestTypeNone = 0, // 没有进行网络操作
    kTTNetworkRequestTypeRefresh,  // 默认刷新和下拉刷新
    kTTNetworkRequestTypeLoadMore, // 上拉加载更多
};

@interface TTTableViewController ()
@property (nonatomic, assign) BOOL isFirstAppear;       // 首次进入
@property (nonatomic, assign) TTNetworkRequestType requestType; // default is kTTNetworkRequestTypeNone
@end

@implementation TTTableViewController
- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if ((self = [super initWithRouteParamObj:paramObj])) {
        _reloadWhenAppear = NO;
        _reloadEnabled = YES;
        _loadMoreEnabled = YES;
        
        _requestType = kTTNetworkRequestTypeNone;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isFirstAppear = YES;
    self.ttViewType = TTFullScreenErrorViewTypeEmpty;
    
    __weak typeof (self) wself = self;
    [self.tableView tt_addDefaultPullDownRefreshWithHandler:^{
        [wself triggerReload];
    }];
    [self.tableView tt_addDefaultPullUpLoadMoreWithHandler:^{
        [wself triggerLoadMore];
    }];
    
    [self triggerReload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self reloadWhenAppear]) {
        [self triggerReload];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _isFirstAppear = NO;
}

#pragma mark - UIViewControllerErrorHandler delegate

- (void)refreshData {
    [self triggerReload];
}

- (BOOL)tt_hasValidateData {
    return NO; //默认会显示空
}

- (void)sessionExpiredAction {
    [self goToAuthorityView];
}

- (void)goToAuthorityView {
    [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeDefault source:nil completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeCancel) {
            
        } else if (type == TTAccountAlertCompletionEventTypeTip) {
            [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:nil completion:^(TTAccountLoginState state) {
                if (state == TTAccountLoginStateCancelled) {
                    
                };
            }];
        }
    }];
}

#pragma mark - public API

- (BOOL)hasMoreData {
    return NO;
}

- (void)rebuildIndexes {
}

- (void)loadRequest {
    [self tt_startUpdate];
    
    if (_requestType == kTTNetworkRequestTypeNone) _requestType = kTTNetworkRequestTypeRefresh;
    
    if (!self.isFirstAppear) {
        NSString *labelString = [self isRefreshing] ? @"refresh" : ([self isLoadingMore] ? @"load_more" : nil);
        if (!isEmptyString([self eventPageKey]) && !isEmptyString(labelString)) {
            wrapperTrackEvent([self eventPageKey], labelString);
        }
    }
}

- (BOOL)isRefreshing {
    return (_requestType == kTTNetworkRequestTypeRefresh);
}

- (BOOL)isLoadingMore {
    return (_requestType == kTTNetworkRequestTypeLoadMore);
}

- (void)pullDownToReload {
    [self.tableView triggerPullDown];
}

- (void)pullUpToLoadMore {
    [self.tableView triggerPullUp];
}

- (void)triggerReload {
    if (_reloadEnabled) {
        _requestType = kTTNetworkRequestTypeRefresh;
        [self loadRequest];
    } else {
        [self.tableView finishPullDownWithSuccess:YES];
    }
}

- (void)triggerLoadMore {
    if (_loadMoreEnabled && [self hasMoreData]) {
        _requestType = kTTNetworkRequestTypeLoadMore;
        [self loadRequest];
    } else {
        [self.tableView finishPullUpWithSuccess:YES];
    }
}

- (void)finishNetworkResponseWithError:(NSError *)error {
    if ([self isRefreshing]) {
        [self.tableView finishPullDownWithSuccess:!error];
    } else if ([self isLoadingMore]) {
        [self.tableView finishPullUpWithSuccess:!error];
    }
    [self tt_endUpdataData:NO error:error];
    
    _requestType = kTTNetworkRequestTypeNone;
}

- (void)reload {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self rebuildIndexes];
        
        if ([self.tableView respondsToSelector:@selector(hasMore)]) {
            [self.tableView setValue:@([self hasMoreData]) forKey:@"hasMore"];
        }
        [self.tableView reloadData];
    });
}

- (void)reloadWithError:(NSError *)error {
    //        http://www.phonesdevelopers.com/1708468/
    //        Always change the dataSource and reloadData in the mainThread. What's more, reloadData should be called immediately after the dataSource change.
    //        If dataSource is changed but tableView's reloadData method is not called immediately, the tableView may crash if it's in scrolling.
    //        Crash Reason: There is still a time gap between the dataSource change and reloadData. If the table is scrolling during the time gap, the app may Crash!!!!
    dispatch_async(dispatch_get_main_queue(), ^{
        [self rebuildIndexes];
        
        [self finishNetworkResponseWithError:error];
        if ([self.tableView respondsToSelector:@selector(hasMore)]) {
            [self.tableView setValue:@([self hasMoreData]) forKey:@"hasMore"];
        }
        [self.tableView reloadData];
    });
}

#pragma mark - TTTableRefreshEventPageProtocol

- (NSString *)eventPageKey {
    return nil;
}

#pragma mark - properties

- (void)setReloadEnabled:(BOOL)reloadEnabled {
    _reloadEnabled = reloadEnabled;
    
    if (reloadEnabled) {
        [self.tableView.pullDownView startObserve];
    } else {
        [self.tableView.pullDownView removeObserve:self.tableView];
    }
}

- (BOOL)reloadWhenAppear {
    return !_isFirstAppear && _reloadWhenAppear;
}
@end
