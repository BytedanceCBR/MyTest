//
//  FHChildBrowsingHistoryViewController.m
//  FHHouseMine
//
//  Created by xubinbin on 2020/7/13.
//

#import "FHChildBrowsingHistoryViewController.h"
#import "FHBrowsingHistoryEmptyView.h"
#import "Masonry.h"
#import "FHChildBrowsingHistoryViewModel.h"
#import "TTDeviceHelper.h"

@interface FHChildBrowsingHistoryViewController()

@property (nonatomic, strong) FHBrowsingHistoryEmptyView *emptyView;
@property (nonatomic, strong) FHChildBrowsingHistoryViewModel *viewModel;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation FHChildBrowsingHistoryViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    self.viewModel = [[FHChildBrowsingHistoryViewModel alloc] initWithViewController:self tableView:self.tableView emptyView:self.emptyView];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)setHouseType:(FHHouseType)houseType {
    _houseType = houseType;
    self.emptyView.houseType = houseType;
    self.viewModel.houseType = houseType;
    [self.viewModel requestData:YES];
    
}

- (void)setupUI {
    self.emptyView = [[FHBrowsingHistoryEmptyView alloc] init];
    self.emptyView.delegate = self;
    [self.view addSubview:self.emptyView];
    [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    //self.emptyView.hidden = YES;
    
    BOOL isIphoneX = [TTDeviceHelper isIPhoneXDevice];
    self.tableView = [[UITableView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (isIphoneX) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    self.tableView.hidden = YES;
}

- (void)dealloc
{
    
}
@end
