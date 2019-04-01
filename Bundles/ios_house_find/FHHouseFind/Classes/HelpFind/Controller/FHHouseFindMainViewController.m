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
#import <TTBaseLib/NSDictionary+TTAdditions.h>

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
        NSDictionary *recommendDict = [paramObj.allParams tt_dictionaryValueForKey:@"recommend_house"];
        if (recommendDict.count > 0) {
            _viewModel.recommendModel = [[FHHouseFindRecommendDataModel alloc]initWithDictionary:recommendDict error:nil];
        }
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    if (_viewModel.recommendModel.used) {
        [self addHouseFindResultVC];
    }else {
        [self startLoadData];
    }
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
    NSDictionary *recommendDict = [_viewModel.recommendModel toDictionary];
    TTRouteParamObj *paramObj = self.paramObj;
    NSMutableDictionary *infoDict = @{}.mutableCopy;
    if (paramObj.userInfo.allInfo) {
        [infoDict addEntriesFromDictionary:paramObj.userInfo.allInfo];
    }
    infoDict[@"recommend_house"] = recommendDict;
    paramObj.userInfo = [[TTRouteUserInfo alloc]initWithInfo:infoDict];
    _helpVC = [[FHHouseFindHelpViewController alloc]initWithRouteParamObj:paramObj];
    [self addChildViewController:_helpVC];
    [self.view addSubview:_helpVC.view];
    [self.view bringSubviewToFront:self.emptyView];
}

- (void)addHouseFindResultVC
{
    NSDictionary *recommendDict = [_viewModel.recommendModel toDictionary];
    TTRouteParamObj *paramObj = self.paramObj;
    NSMutableDictionary *infoDict = @{}.mutableCopy;
    if (paramObj.userInfo.allInfo) {
        [infoDict addEntriesFromDictionary:paramObj.userInfo.allInfo];
    }
    infoDict[@"recommend_house"] = recommendDict;
    paramObj.userInfo = [[TTRouteUserInfo alloc]initWithInfo:infoDict];
    _resultVC = [[FHHouseFindResultViewController alloc]initWithRouteParamObj:paramObj];
    [self addChildViewController:_resultVC];
    [self.view addSubview:_resultVC.view];
    [self.view bringSubviewToFront:self.emptyView];
}

- (void)startLoadData
{
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
