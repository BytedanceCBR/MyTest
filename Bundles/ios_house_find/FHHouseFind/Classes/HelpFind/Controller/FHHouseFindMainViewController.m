//
//  FHHouseFindMainViewController.m
//  FHHouseFind
//
//  Created by 张静 on 2019/4/1.
//

#import "FHHouseFindMainViewController.h"
#import "FHHouseFindHelpMainViewModel.h"
#import "FHHouseFindHelpViewController.h"
#import "FHHouseFindResultViewController.h"
#import <TTReachability/TTReachability.h>

@interface FHHouseFindMainViewController ()

@property (nonatomic , strong) FHErrorView *errorMaskView;
@property (nonatomic , strong) FHHouseFindHelpMainViewModel *viewModel;
@property (nonatomic , strong) TTRouteParamObj *paramObj;
@property (nonatomic , strong) FHHouseFindHelpViewController *helpVC;
@property (nonatomic , strong) FHHouseFindResultViewController *resultVC;

@end

@implementation FHHouseFindMainViewController

-(instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        
        //init coordinate viewmodel according to viewmodel
        self.paramObj = paramObj;
        self.hidesBottomBarWhenPushed = YES;
        _viewModel = [[FHHouseFindHelpMainViewModel alloc]initWithViewController:self paramObj:paramObj];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    [self startLoadData];
}

- (void)setupUI
{
    [self addDefaultEmptyViewFullScreen];
    [self.emptyView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.mas_equalTo(self.customNavBarView.mas_bottom);
    }];
}

- (void)addHouseFindHelpVC
{
    _helpVC = [[FHHouseFindHelpViewController alloc]initWithRouteParamObj:self.paramObj];
    [self addChildViewController:_helpVC];
    [self.view addSubview:_helpVC.view];
}

- (void)addHouseFindResultVC
{
    _resultVC = [[FHHouseFindResultViewController alloc]initWithRouteParamObj:self.paramObj];
    [self addChildViewController:_resultVC];
    [self.view addSubview:_resultVC.view];
}

- (void)startLoadData
{
    [self.viewModel startLoadData];
    if ([TTReachability isNetworkConnected]) {
        [self startLoading];
        self.isLoadingData = YES;
        [self.viewModel startLoadData];
    } else {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
    }
}

// 重新加载
- (void)retryLoadData
{
    if (!self.isLoadingData) {
        [self startLoadData];
    }
}

@end
