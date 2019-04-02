//
//  FHHouseFindMainViewController.m
//  FHHouseFind
//
//  Created by 张静 on 2019/4/1.
//

#import "FHHouseFindMainViewController.h"
#import "FHHouseFindHelpMainViewModel.h"
#import "FHHouseFindHelpBaseViewController.h"
#import "FHHouseFindResultViewController.h"
#import <TTReachability/TTReachability.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>
#import "FHHouseFindHelpViewController.h"

@interface FHHouseFindMainViewController ()

@property (nonatomic , strong) FHErrorView *errorMaskView;
@property (nonatomic , strong) FHHouseFindHelpMainViewModel *viewModel;
@property (nonatomic , strong) TTRouteParamObj *paramObj;
@property (nonatomic , strong) FHHouseFindHelpBaseViewController *childVC;

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
        NSHashTable<FHHouseSuggestionDelegate> *help_delegate = paramObj.allParams[@"help_delegate"];
        self.helpDelegate = help_delegate.anyObject;
        NSHashTable *back_vc = paramObj.allParams[@"need_back_vc"]; // pop方式返回某个页面
        self.backListVC = back_vc.anyObject;  // 需要返回到的某个列表页面
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    if (_viewModel.recommendModel != nil) {
        
        if (_viewModel.recommendModel.used) {
            [self addHouseFindResultVC];
        }else {
            [self addHouseFindHelpVC];
        }
        return;
    }
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
    NSDictionary *recommendDict = [_viewModel.recommendModel toDictionary];
    TTRouteParamObj *paramObj = self.paramObj;
    NSMutableDictionary *infoDict = @{}.mutableCopy;
    if (paramObj.userInfo.allInfo) {
        [infoDict addEntriesFromDictionary:paramObj.userInfo.allInfo];
    }
    infoDict[@"recommend_house"] = recommendDict;
    paramObj.userInfo = [[TTRouteUserInfo alloc]initWithInfo:infoDict];
    _childVC = [[FHHouseFindHelpViewController alloc]initWithRouteParamObj:paramObj];
    [self addChildViewController:_childVC];
    [self.view addSubview:_childVC.view];
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
    _childVC = [[FHHouseFindResultViewController alloc]initWithRouteParamObj:paramObj];
    [self addChildViewController:_childVC];
    [self.view addSubview:_childVC.view];
    [self.view bringSubviewToFront:self.emptyView];
}

- (void)jump2HouseFindHelpVC
{
    NSDictionary *recommendDict = nil;
    NSMutableDictionary *infoDict = @{}.mutableCopy;
    FHHouseFindRecommendDataModel *recommendModel = [self.childVC getRecommendModel];
    if (recommendModel) {
        recommendModel.used = NO;
        recommendDict = [recommendModel toDictionary];
    }
    infoDict[@"recommend_house"] = recommendDict;
    [self jump2ChildVC:infoDict];
}
- (void)jump2HouseFindResultVC
{
    NSString *openUrl = [NSString stringWithFormat:@"sslocal://house_find"];
    NSMutableDictionary *infoDict = @{}.mutableCopy;
    NSDictionary *recommendDict = nil;
    FHHouseFindRecommendDataModel *recommendModel = [self.childVC getRecommendModel];
    if (recommendModel) {
        recommendModel.used = YES;
        recommendDict = [recommendModel toDictionary];
    }
    infoDict[@"recommend_house"] = recommendDict;
    [self jump2ChildVC:infoDict];
}

- (void)jump2ChildVC:(NSDictionary *)dict
{
    NSString *openUrl = [NSString stringWithFormat:@"sslocal://house_find"];
    NSMutableDictionary *infoDict = @{}.mutableCopy;
    if (dict.count > 0) {
        [infoDict addEntriesFromDictionary:dict];
    }
    if (self.helpDelegate != nil) {
        
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
        // 回传数据，外部pop 页面
        TTRouteObject *obj = [[TTRoute sharedRoute] routeObjWithOpenURL:[NSURL URLWithString:openUrl] userInfo:userInfo];
        if ([self.helpDelegate respondsToSelector:@selector(suggestionSelected:)]) {
            [self.helpDelegate suggestionSelected:obj];// 部分-内部有页面跳转逻辑
        }
        if (self.backListVC) {
            [self.navigationController popToViewController:self.backListVC animated:YES];
        }
    } else {
        
        NSHashTable *helpDelegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        [helpDelegateTable addObject:self];
        infoDict[@"help_delegate"] = helpDelegateTable;
        NSHashTable *tempTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        [tempTable addObject:self];
        infoDict[@"need_back_vc"] = tempTable;
        
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:infoDict];
        NSURL *url = [NSURL URLWithString:openUrl];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

#pragma mark - help delegate
-(void)suggestionSelected:(TTRouteObject *)routeObject
{
    NSMutableDictionary *allInfo = [routeObject.paramObj.userInfo.allInfo mutableCopy];
    NSDictionary *recommendDict = [routeObject.paramObj.allParams tt_dictionaryValueForKey:@"recommend_house"];
    if (recommendDict.count > 0) {
        _viewModel.recommendModel = [[FHHouseFindRecommendDataModel alloc]initWithDictionary:recommendDict error:nil];
    }
    [_childVC refreshRecommendModel:_viewModel.recommendModel];
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
