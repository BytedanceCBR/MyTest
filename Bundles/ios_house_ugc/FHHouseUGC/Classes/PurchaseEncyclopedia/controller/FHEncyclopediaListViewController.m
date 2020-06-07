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
@property (weak, nonatomic) FHEncyclopediaHeader *encyclopediaHeader;
@property (strong, nonatomic) FHEncyclopediaListViewModel *viewModel;
@property (weak, nonatomic) UITableView *mainTable;
@property(nonatomic, copy) void(^notifyCompletionBlock)(void);
@property(nonatomic, strong) ArticleListNotifyBarView *notifyBarView;
@property(nonatomic, strong) NSDictionary *buryingPointDic;

@end

@implementation FHEncyclopediaListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initViewModel];
//    [self startLoadData];
//    [self setupDefaultNavBar:NO];
    self.automaticallyAdjustsScrollViewInsets = NO;
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
        if(!self.hasValidateData){
            [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        }
    }
}

- (void)initViewModel {
    _viewModel = [[FHEncyclopediaListViewModel alloc] initWithWithController:self tableView:self.mainTable headerView:self.encyclopediaHeader userInfo:nil];;
}

- (void)initNav {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"购房百科";
}

- (void)initUI {
    [self.mainTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-30);
        make.top.equalTo(self.view).offset(30);
    }];
    [self initNotifyBarView];
    [self.notifyBarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.mainTable);
        make.height.mas_offset(32);
    }];
    [self.mainTable triggerPullDown];
}

- (FHEncyclopediaHeader *)encyclopediaHeader {
    if (!_encyclopediaHeader) {
        FHEncyclopediaHeader *encyclopediaHeader = [[FHEncyclopediaHeader alloc]init];
        [self.view addSubview:encyclopediaHeader];
        _encyclopediaHeader = encyclopediaHeader;
    }
    return _encyclopediaHeader;
}

- (UITableView *)mainTable {
    if (!_mainTable) {
        UITableView * mainTable = [[FHBaseTableView alloc]init];
        mainTable.showsVerticalScrollIndicator = NO;
        mainTable.estimatedRowHeight = 0;
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
        if ([UIDevice btd_isIPhoneXSeries]) {
            mainTable.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
        }
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
        mainTable.tableFooterView = footerView;
        [self.view addSubview:mainTable];
        _mainTable = mainTable;
    }
    return _mainTable;
}

#pragma mark - show notify

- (void)showNotify:(NSString *)message {
    [self showNotify:message completion:nil];
}

- (void)showNotify:(NSString *)message completion:(void(^)())completion {
    UIEdgeInsets inset = self.mainTable.contentInset;
    inset.top = self.notifyBarView.height;
    self.mainTable.contentInset = inset;
    self.mainTable.contentOffset = CGPointMake(0, -inset.top);
    self.notifyCompletionBlock = completion;
    WeakSelf;
    [self.notifyBarView showMessage:message actionButtonTitle:@"" delayHide:YES duration:1 bgButtonClickAction:nil actionButtonClickBlock:nil didHideBlock:nil willHideBlock:^(ArticleListNotifyBarView *barView, BOOL isImmediately) {
        if(!isImmediately) {
            [wself hideIfNeeds];
        } else {
            if(wself.notifyCompletionBlock) {
                wself.notifyCompletionBlock();
            }
        }
    }];
}

- (void)hideImmediately {
    [self.notifyBarView hideImmediately];
}

- (void)initNotifyBarView {
    self.notifyBarView = [[ArticleListNotifyBarView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:self.notifyBarView];
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
