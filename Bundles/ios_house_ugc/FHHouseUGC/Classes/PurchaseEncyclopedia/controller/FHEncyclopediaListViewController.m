//
//  FHEncyclopediaListViewController.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/5/13.
//

#import "FHEncyclopediaListViewController.h"
#import "FHEncyclopediaHeader.h"
#import "Masonry.h"
#import "UIDevice+BTDAdditions.h"
#import "FHEncyclopediaListViewModel.h"
#import "FHBaseTableView.h"
#import "UIScrollView+Refresh.h"
#import "TTReachability.h""
#import "UIDevice+BTDAdditions.h"
#import <TTUIWidget/ArticleListNotifyBarView.h>
#import "UIViewAdditions.h"
@interface FHEncyclopediaListViewController ()
@property (strong, nonatomic) FHEncyclopediaListViewModel *viewModel;
@property (weak, nonatomic) UITableView *mainTable;
@property(nonatomic, copy) void(^notifyCompletionBlock)(void);
@property(nonatomic, strong) NSDictionary *buryingPointDic;

@end

@implementation FHEncyclopediaListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initViewModel];
    [self addDefaultEmptyViewFullScreen];
//    [self startLoadData];
//    [self setupDefaultNavBar:NO];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)retryLoadData {
     _viewModel.channel_id = self.channel_id;
    [_viewModel requestData:YES first:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        _viewModel.channel_id = self.channel_id;
        [_viewModel requestData:YES first:YES];
    }else {
         [self.emptyView showEmptyWithTip:@"网络异常，请检查网络连接" errorImageName:kFHErrorMaskNoNetWorkImageName showRetry:YES];
    }
}

- (void)initViewModel {
    _viewModel = [[FHEncyclopediaListViewModel alloc] initWithWithController:self tableView:self.mainTable userInfo:[NSDictionary dictionary]];;
}

- (void)initUI {
    [self.mainTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(10);
    }];
    [self.mainTable triggerPullDown];
}

- (UITableView *)mainTable {
    if (!_mainTable) {
        UITableView * mainTable = [[FHBaseTableView alloc]init];
        mainTable.showsVerticalScrollIndicator = NO;
        mainTable.estimatedRowHeight = 0;
        mainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        if (@available(iOS 11.0 , *)) {
            mainTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }else{
            
        }
        if (@available(iOS 11.0 , *)) {
            mainTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            mainTable.estimatedRowHeight = 0;
            mainTable.estimatedSectionFooterHeight = 0;
            mainTable.estimatedSectionHeaderHeight = 0;
        }else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 50)];
        mainTable.tableFooterView = footerView;
        mainTable.tableHeaderView = [[UIView alloc]initWithFrame:CGRectZero];
        [self.view addSubview:mainTable];
        _mainTable = mainTable;
    }
    return _mainTable;
}



- (void)hideIfNeeds {
    [UIView animateWithDuration:0.3 animations:^{
        if ([UIDevice btd_isIPhoneXSeries]) {
            self.mainTable.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
        }else{
            self.mainTable.contentInset = UIEdgeInsetsZero;
        }
        self.mainTable.originContentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        
    }completion:^(BOOL finished) {
        if (self.notifyCompletionBlock) {
            self.notifyCompletionBlock();
        }
    }];
}

- (void)setTracerModel:(FHTracerModel *)tracerModel {
    self.viewModel.tracerModel = tracerModel;
}
@end
