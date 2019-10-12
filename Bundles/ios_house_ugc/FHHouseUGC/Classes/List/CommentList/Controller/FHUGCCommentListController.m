//
//  FHUGCCommentListController.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/10/11.
//

#import "FHUGCCommentListController.h"
#import "UIColor+Theme.h"
#import "FHUGCCommentListViewModel.h"
#import "TTReachability.h"
#import <UIViewAdditions.h>
#import "TTDeviceHelper.h"
#import <TTRoute.h>
#import "TTAccountManager.h"
#import "TTAccount+Multicast.h"
#import "FHEnvContext.h"
#import "FHUserTracker.h"
#import <UIScrollView+Refresh.h>
#import "FHFeedOperationView.h"
#import <FHHouseBase/FHBaseTableView.h>

@interface FHUGCCommentListController ()

@property(nonatomic, strong) FHUGCCommentListViewModel *viewModel;
@property(nonatomic, assign) BOOL needReloadData;
@property(nonatomic, copy) void(^notifyCompletionBlock)(void);

@end

@implementation FHUGCCommentListController

-(instancetype)init{
    self = [super init];
    if(self){
        _tableViewNeedPullDown = YES;
        _showErrorView = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initView];
    [self initConstraints];
    [self initViewModel];
    [self startLoadData];
}

- (void)dealloc {
    
}

- (void)viewWillAppear {
    [self.viewModel viewWillAppear];
}

- (void)viewWillDisappear {
    [self.viewModel viewWillDisappear];
    [FHFeedOperationView dismissIfVisible];
}

- (void)initView {
    [self initTableView];
    [self initNotifyBarView];
    
    if(self.showErrorView){
        [self addDefaultEmptyViewFullScreen];
    }
}

- (void)initTableView {
    self.tableView = [[FHBaseTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor themeGray7];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *headerView = self.tableHeaderView ? self.tableHeaderView : [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    _tableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    _tableView.tableFooterView = footerView;
    
    _tableView.sectionFooterHeight = 0.0;
    
    _tableView.estimatedRowHeight = 0;
    
    if (@available(iOS 11.0 , *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    if ([TTDeviceHelper isIPhoneXSeries]) {
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
    
    [self.view addSubview:_tableView];
}

- (void)setTableHeaderView:(UIView *)tableHeaderView {
    _tableHeaderView = tableHeaderView;
    if(self.tableView){
        self.tableView.tableHeaderView = tableHeaderView;
    }
}

- (void)initNotifyBarView {
    self.notifyBarView = [[ArticleListNotifyBarView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:self.notifyBarView];
}

- (void)initConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.notifyBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.tableView);
        make.height.mas_equalTo(32);
    }];
    
    [self.publishBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view).offset(-self.publishBtnBottomHeight);
        make.right.mas_equalTo(self.view).offset(-12);
        make.width.height.mas_equalTo(64);
    }];
}

- (void)initViewModel {
    self.viewModel = [[FHUGCCommentListViewModel alloc] initWithTableView:_tableView controller:self];
    self.needReloadData = YES;
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [_viewModel requestData:YES first:YES];
    } else {
        if(!self.hasValidateData){
            [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        }
    }
}

- (void)startLoadData:(BOOL)isFirst {
    if ([TTReachability isNetworkConnected]) {
        [_viewModel requestData:YES first:isFirst];
    } else {
        if(!self.hasValidateData){
            [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        }
    }
}

//- (void)scrollToTopAndRefreshAllData {
//    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
//    [self startLoadData];
//}
//
//- (void)scrollToTopAndRefresh {
//    if(self.viewModel.isRefreshingTip || self.isLoadingData){
//        return;
//    }
//    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
//    [self.tableView triggerPullDown];
//}

- (void)retryLoadData {
    [self startLoadData];
}

#pragma mark - show notify

- (void)showNotify:(NSString *)message
{
    [self showNotify:message completion:nil];
}

- (void)showNotify:(NSString *)message completion:(void(^)(void))completion{
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.top = self.notifyBarView.height;
    self.tableView.contentInset = inset;
    self.tableView.contentOffset = CGPointMake(0, -inset.top);
    self.notifyCompletionBlock = completion;
    [self.notifyBarView showMessage:message actionButtonTitle:@"" delayHide:YES duration:1 bgButtonClickAction:nil actionButtonClickBlock:nil didHideBlock:nil willHideBlock:^(ArticleListNotifyBarView *barView, BOOL isImmediately) {
        WeakSelf;
        if(!isImmediately) {
            [wself hideIfNeeds];
        } else {
            if(wself.notifyCompletionBlock) {
                wself.notifyCompletionBlock();
            }
        }
    }];
}

- (void)hideIfNeeds {
    [UIView animateWithDuration:0.3 animations:^{
        
        if ([TTDeviceHelper isIPhoneXSeries]) {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
        }else{
            self.tableView.contentInset = UIEdgeInsetsZero;
        }
        self.tableView.originContentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        
    }completion:^(BOOL finished) {
        if (self.notifyCompletionBlock) {
            self.notifyCompletionBlock();
        }
    }];
}

- (void)hideImmediately {
    [self.notifyBarView hideImmediately];
}

@end

