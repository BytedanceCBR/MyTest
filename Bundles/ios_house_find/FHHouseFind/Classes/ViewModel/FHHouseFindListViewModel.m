//
//  FHHouseFindListViewModel.m
//  FHHouseFind
//
//  Created by 张静 on 2019/1/2.
//

#import "FHHouseFindListViewModel.h"
#import "FHHouseFindBaseView.h"
#import "TTRoute.h"
#import "FHEnvContext.h"
#import "FHHomeConfigManager.h"
#import "HMSegmentedControl.h"
#import "FHHouseFindSectionItem.h"
#import "FHHouseFindListViewController.h"
#import "FHErrorView.h"

@interface FHHouseFindListViewModel () <UIScrollViewDelegate>

@property(nonatomic,weak)FHHouseFindListViewController *listVC;
@property(nonatomic,weak)UIScrollView *scrollView;
@property (nonatomic , weak) FHErrorView *errorMaskView;
@property(nonatomic,strong)FHTracerModel *tracerModel;
@property (nonatomic , copy) NSString *originSearchId;
@property (nonatomic , copy) NSString *originFrom;
@property (nonatomic , strong) FHConfigDataModel *configDataModel;
@property (nonatomic , weak) HMSegmentedControl *segmentView;
@property (nonatomic , strong) NSArray <FHHouseFindSectionItem *> *itemList;
@property (nonatomic , assign) NSInteger currentSelectIndex;

@end

@implementation FHHouseFindListViewModel

- (instancetype)initWithScrollView:(UIScrollView *)scrollView viewController:(FHHouseFindListViewController *)listVC
{
    self = [super init];
    if (self) {
        _listVC = listVC;
        _scrollView = scrollView;
        _scrollView.delegate = self;
    }
    return self;
}

- (void)setErrorMaskView:(FHErrorView *)errorMaskView
{
    _errorMaskView = errorMaskView;
}

- (void)addConfigObserver
{
    __weak typeof(self)wself = self;
    self.configDataModel = [[FHEnvContext sharedInstance]getConfigFromCache];
    [self refreshDataWithConfigDataModel];
    //订阅config变化
    __block BOOL isFirstChange = YES;
    [[FHEnvContext sharedInstance].configDataReplay subscribeNext:^(id  _Nullable x) {
        
        //过滤多余刷新
        if (wself.configDataModel == [[FHEnvContext sharedInstance]getConfigFromCache] && !isFirstChange) {
            
            return;
        }
        wself.configDataModel = [[FHEnvContext sharedInstance]getConfigFromCache];
        [wself refreshDataWithConfigDataModel];
        isFirstChange = NO;

    }];
    
}

- (void)refreshDataWithConfigDataModel
{
    [self.listVC endLoading];
    
    if (self.configDataModel == nil) {
        // 网络失败页
        [self.errorMaskView showEmptyWithType:FHEmptyMaskViewTypeNetWorkError];
        return;
    }
    
    for (UIView *subview in self.scrollView.subviews) {
        [subview removeFromSuperview];
    }
    [self refreshHouseItemList];
    
    if (self.itemList.count < 1) {
        // 当前城市未开通
        [self.errorMaskView showEmptyWithTip:@"找房服务即将开通，敬请期待" errorImage:[UIImage imageNamed:kFHErrorMaskNetWorkErrorImageName] showRetry:NO];
        return;
    }
    self.errorMaskView.hidden = YES;
    for (NSInteger index = 0; index < self.itemList.count; index++) {
        
        FHHouseFindSectionItem *item = self.itemList[index];
        FHHouseFindBaseView *baseView = [[FHHouseFindBaseView alloc]initWithFrame:CGRectMake(self.scrollView.bounds.size.width * index, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
        baseView.tag = 10 + index;
        [self.scrollView addSubview:baseView];
    }
    
    if (self.itemList.count > 0) {
        
        self.currentSelectIndex = 0;
        [self.scrollView setContentOffset:CGPointZero animated:NO];
        FHHouseFindSectionItem *item = self.itemList[0];
        FHHouseFindBaseView *baseView = [self.scrollView viewWithTag:10];
        [baseView updateDataWithItem:item needRefresh:YES];
    }
}

- (void)viewDidLayoutSubviews
{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * self.itemList.count, self.scrollView.bounds.size.height - self.scrollView.contentInset.bottom);
}

- (void)refreshHouseItemList
{
    NSMutableArray *itemList = @[].mutableCopy;
    NSMutableArray *titleList = @[].mutableCopy;
    FHHouseFindSectionItem *item = [[FHHouseFindSectionItem alloc]init];
    NSString *itemTitle = @"";
    if (self.configDataModel.searchTabFilter.count > 0) {
        item.houseType = FHHouseTypeSecondHandHouse;
        itemTitle = @"二手房";
        [itemList addObject:item];
        [titleList addObject:itemTitle];
    }
    if (self.configDataModel.searchTabCourtFilter.count > 0) {
        FHHouseFindSectionItem *item = [[FHHouseFindSectionItem alloc]init];
        item.houseType = FHHouseTypeNewHouse;
        itemTitle = @"新房";
        [itemList addObject:item];
        [titleList addObject:itemTitle];
    }
    if (self.configDataModel.searchTabRentFilter.count > 0) {
        FHHouseFindSectionItem *item = [[FHHouseFindSectionItem alloc]init];
        item.houseType = FHHouseTypeRentHouse;
        itemTitle = @"租房";
        [itemList addObject:item];
        [titleList addObject:itemTitle];
    }
    if (self.configDataModel.searchTabNeighborhoodFilter.count > 0) {
        FHHouseFindSectionItem *item = [[FHHouseFindSectionItem alloc]init];
        item.houseType = FHHouseTypeNeighborhood;
        itemTitle = @"小区";
        [itemList addObject:item];
        [titleList addObject:itemTitle];
    }

    self.itemList = itemList;
    [self.segmentView setSectionTitles:titleList];
    self.segmentView.selectedSegmentIndex = 0;
    if (self.itemList.count > 0) {
        self.currentSelectIndex = 0;
    }
    
}

- (void)jump2GuessVC
{
    NSDictionary *traceParam = [self.tracerModel toDictionary] ? : @{};
    //sug_list
    NSHashTable *sugDelegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [sugDelegateTable addObject:self];
    FHHouseType houseType = FHHouseTypeSecondHandHouse;
    if (self.currentSelectIndex < self.itemList.count) {
        FHHouseFindSectionItem *item = self.itemList[self.currentSelectIndex];
        houseType = item.houseType;
    }
    NSDictionary *dict = @{@"house_type":@(houseType),
                           @"tracer": traceParam,
                           @"from_home":@(3), // list
                           @"sug_delegate":sugDelegateTable
                           };
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL *url = [NSURL URLWithString:@"sslocal://sug_list"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

- (void)setTracerModel:(FHTracerModel *)tracerModel
{
    _tracerModel = tracerModel;
    self.originFrom = tracerModel.originFrom;
}

- (void)setSegmentView:(HMSegmentedControl *)segmentView
{
    _segmentView = segmentView;
    __weak typeof(self)wself = self;
    segmentView.indexChangeBlock = ^(NSInteger index) {
        
        if (index < wself.itemList.count) {
            
            wself.currentSelectIndex = index;
            [wself.scrollView setContentOffset:CGPointMake(index * wself.scrollView.bounds.size.width, 0) animated:NO];
            FHHouseFindSectionItem *item = wself.itemList[index];
            FHHouseFindBaseView *baseView = [wself.scrollView viewWithTag:10 + index];
            [baseView updateDataWithItem:item needRefresh:YES];
        }
    };
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != self.scrollView) {
        return;
    }
    NSInteger index = self.scrollView.contentOffset.x / [UIScreen mainScreen].bounds.size.width;
    if ((self.scrollView.contentOffset.x - index * [UIScreen mainScreen].bounds.size.width) > ([UIScreen mainScreen].bounds.size.width / 2)) {
        index += 1;
    }
    if (index >= 0 && index < self.itemList.count) {
        self.segmentView.selectedSegmentIndex = index;
        self.currentSelectIndex = index;

    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.segmentView.selectedSegmentIndex < self.itemList.count) {
        
        NSInteger index = self.segmentView.selectedSegmentIndex;
        FHHouseFindSectionItem *item = self.itemList[index];
        FHHouseFindBaseView *baseView = [self.scrollView viewWithTag:10 + index];
        [baseView updateDataWithItem:item needRefresh:YES];
    }
}

@end
