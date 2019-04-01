//
//  FHHouseFindMainViewController.m
//  FHHouseFind
//
//  Created by 张静 on 2019/4/1.
//

#import "FHHouseFindMainViewController.h"
#import "FHHouseFindHelpMainViewModel.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import "FHHouseFindRecommendModel.h"
#import "FHHouseFindHelpViewController.h"
#import "FHHouseFindResultViewController.h"
#import <TTReachability/TTReachability.h>

@interface FHHouseFindMainViewController ()

@property (nonatomic , strong) FHErrorView *errorMaskView;
@property (nonatomic , strong) FHHouseFindHelpMainViewModel *viewModel;
@property (nonatomic , strong) TTRouteParamObj *paramObj;
@property (nonatomic , strong) FHHouseFindRecommendDataModel *recommendModel;
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
        NSDictionary *recommendDict = [paramObj.allParams tt_dictionaryValueForKey:@"recommend_house"];
        if (recommendDict.count > 0) {
            self.recommendModel = [[FHHouseFindRecommendDataModel alloc]initWithDictionary:recommendDict error:nil];
        }
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

- (void)loadData
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // add by zjing for test
        if (self.recommendModel.used) {
            _resultVC = [[FHHouseFindResultViewController alloc]initWithRouteParamObj:self.paramObj];
            [self addChildViewController:_resultVC];
            [self.view addSubview:_resultVC.view];
        }else {
            _helpVC = [[FHHouseFindHelpViewController alloc]initWithRouteParamObj:self.paramObj];
            [self addChildViewController:_helpVC];
            [self.view addSubview:_helpVC.view];
        }
        self.isLoadingData = NO;
        self.hasValidateData = YES;

    });
}
- (void)startLoadData
{
    if ([TTReachability isNetworkConnected]) {
        [self startLoading];
        self.isLoadingData = YES;
        [self loadData];
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
