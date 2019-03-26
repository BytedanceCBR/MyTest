//
//  FHHouseFindListViewModel.m
//  FHHouseFind
//
//  Created by 张静 on 2019/1/2.
//

#import "FHHouseFindListViewModel.h"
#import "FHHouseFindListView.h"
#import "TTRoute.h"
#import "FHEnvContext.h"
#import "HMSegmentedControl.h"
#import "FHHouseFindSectionItem.h"
#import "FHHouseFindListViewController.h"
#import "FHErrorView.h"
#import <FHHouseSuggestionDelegate.h>
#import "TTRoute.h"
#import "FHUserTracker.h"
#import "UIViewAdditions.h"

@interface FHHouseFindListViewModel () <UIScrollViewDelegate, FHHouseSuggestionDelegate>

@property(nonatomic,weak)FHHouseFindListViewController *listVC;
@property(nonatomic,weak)UIScrollView *scrollView;
@property (nonatomic , weak) FHErrorView *errorMaskView;
@property(nonatomic,strong)FHTracerModel *tracerModel;
@property (nonatomic , strong) NSDictionary *tracerDict;
@property (nonatomic , copy) NSString *originSearchId;
@property (nonatomic , copy) NSString *originFrom;
@property (nonatomic , strong) FHConfigDataModel *configDataModel;
@property (nonatomic , weak) HMSegmentedControl *segmentView;
@property (nonatomic , strong) NSArray <FHHouseFindSectionItem *> *itemList;
@property (nonatomic , assign) NSInteger currentSelectIndex;
@property (nonatomic , assign) NSInteger lastSelectIndex;
@property (nonatomic , strong) NSMutableDictionary *sugDict;
@property (nonatomic , strong) RACDisposable *configDisposeble;

@end

@implementation FHHouseFindListViewModel

- (instancetype)initWithScrollView:(UIScrollView *)scrollView viewController:(FHHouseFindListViewController *)listVC
{
    self = [super init];
    if (self) {
        _listVC = listVC;
        _scrollView = scrollView;
        _scrollView.delegate = self;
        _sugDict = [NSMutableDictionary dictionary];
        TTRouteUserInfo *userInfo = nil;
        NSMutableDictionary *param = @{}.mutableCopy;
        param[@"enter_from"] = @"findtab";
        param[@"enter_type"] = @"click";
        param[@"element_from"] = @"be_null";
        param[@"origin_from"] = @"findtab_related";
        self.tracerDict = param;
        self.tracerModel = [FHTracerModel makerTracerModelWithDic:self.tracerDict];
        self.originFrom = self.tracerModel.originFrom;
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
    self.configDisposeble = [[FHEnvContext sharedInstance].configDataReplay subscribeNext:^(id  _Nullable x) {
        
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
    __weak typeof(self)wself = self;
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
    
    
    if (self.itemList.count < 1 || ![[[FHEnvContext sharedInstance] getConfigFromCache].cityAvailability.enable boolValue]) {
        // 当前城市未开通
        [self.errorMaskView showEmptyWithTip:@"找房服务即将开通，敬请期待" errorImage:[UIImage imageNamed:kFHErrorMaskNetWorkErrorImageName] showRetry:NO];
        return;
    }
    self.errorMaskView.hidden = YES;
    for (NSInteger index = 0; index < self.itemList.count; index++) {
        
        FHHouseFindSectionItem *item = self.itemList[index];
        FHHouseFindListView *baseView = [[FHHouseFindListView alloc]initWithFrame:CGRectZero];
        baseView.tracerDict = self.tracerDict;
        [baseView updateDataWithItem:item];
        baseView.houseListOpenUrlUpdateBlock = ^(TTRouteParamObj * _Nonnull paramObj) {
            
            [wself handlePlaceholder:paramObj];
        };
        baseView.tag = 10 + index;
        [self.scrollView addSubview:baseView];
        [baseView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.scrollView.bounds.size.width * index);
            make.top.width.height.mas_equalTo(self.scrollView);
        }];
    }
    
    if (self.itemList.count > 0) {
        
        self.segmentView.selectedSegmentIndex = 0;
        [self.scrollView setContentOffset:CGPointZero animated:NO];
        [self selectHouseFindListItem:0];
    }
}

- (void)viewDidLayoutSubviews
{
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * self.itemList.count, self.scrollView.bounds.size.height - self.scrollView.contentInset.bottom);
    if ([self.segmentView totalSegmentedControlWidth] < self.segmentView.width) {
        
        self.segmentView.userDraggable = NO;
        self.segmentView.width = ceil([self.segmentView totalSegmentedControlWidth]);
        self.segmentView.centerX = self.scrollView.width / 2;
    }
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
        NSString *placeholder = [self placeholderByHouseType:FHHouseTypeSecondHandHouse];
        [self.sugDict setValue:placeholder forKey:[self placeholderKeyByHouseType:FHHouseTypeSecondHandHouse]];
    }
    if (self.configDataModel.searchTabRentFilter.count > 0) {
        FHHouseFindSectionItem *item = [[FHHouseFindSectionItem alloc]init];
        item.houseType = FHHouseTypeRentHouse;
        itemTitle = @"租房";
        [itemList addObject:item];
        [titleList addObject:itemTitle];
        NSString *placeholder = [self placeholderByHouseType:FHHouseTypeRentHouse];
        [self.sugDict setValue:placeholder forKey:[self placeholderKeyByHouseType:FHHouseTypeRentHouse]];
    }
    if (self.configDataModel.searchTabCourtFilter.count > 0) {
        FHHouseFindSectionItem *item = [[FHHouseFindSectionItem alloc]init];
        item.houseType = FHHouseTypeNewHouse;
        itemTitle = @"新房";
        [itemList addObject:item];
        [titleList addObject:itemTitle];
        NSString *placeholder = [self placeholderByHouseType:FHHouseTypeNewHouse];
        [self.sugDict setValue:placeholder forKey:[self placeholderKeyByHouseType:FHHouseTypeNewHouse]];
    }
    if (self.configDataModel.searchTabNeighborhoodFilter.count > 0) {
        FHHouseFindSectionItem *item = [[FHHouseFindSectionItem alloc]init];
        item.houseType = FHHouseTypeNeighborhood;
        itemTitle = @"小区";
        [itemList addObject:item];
        [titleList addObject:itemTitle];
        NSString *placeholder = [self placeholderByHouseType:FHHouseTypeNeighborhood];
        [self.sugDict setValue:placeholder forKey:[self placeholderKeyByHouseType:FHHouseTypeNeighborhood]];
    }
    
    self.itemList = itemList;
    [self.segmentView setSectionTitles:titleList];
}

- (void)jump2GuessVC
{
    FHHouseFindListView *baseView = [self.scrollView viewWithTag:10 + self.currentSelectIndex];
    [baseView addClickHouseSearchLog];
    
    NSDictionary *traceParam = [self.tracerModel toDictionary] ? : @{};
    //house_search
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
    
    NSURL *url = [NSURL URLWithString:@"sslocal://house_search"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

#pragma mark - sug delegate
- (void)suggestionSelected:(TTRouteObject *)routeObject
{
    NSString *houseTypeStr = routeObject.paramObj.allParams[@"house_type"];
    FHHouseFindSectionItem *item = self.itemList[self.currentSelectIndex];
    if (item.houseType != houseTypeStr.integerValue) {
        
        for (NSInteger index = 0; index < self.itemList.count; index++) {
            FHHouseFindSectionItem *obj = self.itemList[index];
            if (obj.houseType == houseTypeStr.integerValue) {
                
                self.segmentView.selectedSegmentIndex = index;
                [self.scrollView setContentOffset:CGPointMake(index * self.scrollView.bounds.size.width, 0) animated:NO];
                [self selectHouseFindListItem:index];
                break;
            }
        }
    }
    
    FHHouseFindListView *baseView = [self.scrollView viewWithTag:10 + self.currentSelectIndex];
    baseView.showRedirectTip = YES;
    NSMutableDictionary *allInfo = [routeObject.paramObj.userInfo.allInfo mutableCopy];
    if (allInfo[@"houseSearch"]) {
        [baseView updateHouseSearchDict:allInfo[@"houseSearch"]];
    }
    [baseView handleSugSelection:routeObject.paramObj];
    [self handlePlaceholder:routeObject.paramObj];
}

- (void)handlePlaceholder:(TTRouteParamObj *)paramObj
{
    FHHouseFindSectionItem *obj = self.itemList[self.currentSelectIndex];
    NSString *placeholder = [self.sugDict objectForKey:[self placeholderKeyByHouseType:obj.houseType]];
    NSString *fullText = paramObj.queryParams[@"full_text"];
    NSString *displayText = paramObj.queryParams[@"display_text"];
    
    if (fullText.length > 0) {
        
        placeholder = fullText;
    }else if (displayText.length > 0) {
        
        placeholder = displayText;
    }
    [self.sugDict setValue:placeholder forKey:[self placeholderKeyByHouseType:obj.houseType]];
    if (self.sugSelectBlock) {
        self.sugSelectBlock(placeholder);
    }
}

- (NSString *)placeholderKeyByHouseType:(FHHouseType)houseType
{
    switch (houseType) {
        case FHHouseTypeNewHouse:
            return @"FHHouseTypeNewHouse";
            break;
        case FHHouseTypeSecondHandHouse:
            return @"FHHouseTypeSecondHandHouse";
            break;
        case FHHouseTypeNeighborhood:
            return @"FHHouseTypeNeighborhood";
            break;
        case FHHouseTypeRentHouse:
            return @"FHHouseTypeRentHouse";
            break;
        default:
            return @"";
            break;
    }
}

- (NSString *)placeholderByHouseType:(FHHouseType)houseType
{
    switch (houseType) {
        case FHHouseTypeNewHouse:
            return @"请输入楼盘名/地址";
            break;
        case FHHouseTypeSecondHandHouse:
            return @"请输入小区/商圈/地铁";
            break;
        case FHHouseTypeNeighborhood:
            return @"请输入小区/商圈/地铁";
            break;
        case FHHouseTypeRentHouse:
            return @"请输入小区/商圈/地铁";
            break;
        default:
            return @"";
            break;
    }
}

- (void)setSegmentView:(HMSegmentedControl *)segmentView
{
    _segmentView = segmentView;
    __weak typeof(self)wself = self;
    segmentView.indexChangeBlock = ^(NSInteger index) {
        
        if (index < wself.itemList.count) {
            
            [wself.scrollView setContentOffset:CGPointMake(index * wself.scrollView.bounds.size.width, 0) animated:NO];
            [wself selectHouseFindListItem:index];
            if (wself.lastSelectIndex != wself.currentSelectIndex) {
                
                FHHouseFindListView *lastBaseView = [wself.scrollView viewWithTag:10 + wself.lastSelectIndex];
                [lastBaseView viewWillDisappear:YES];
                
                FHHouseFindListView *currentBaseView = [wself.scrollView viewWithTag:10 + wself.currentSelectIndex];
                [currentBaseView viewWillAppear:YES];
                
                [wself endTrack];
                [wself addStayCategoryLogBy:wself.lastSelectIndex];
                [wself resetStayTime];
                [wself startTrack];
                [wself addEnterCategoryLog];
            }
            
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
        
    }
    [self.scrollView endEditing:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.segmentView.selectedSegmentIndex < self.itemList.count) {
        [self selectHouseFindListItem:self.segmentView.selectedSegmentIndex];
        if (self.lastSelectIndex != self.currentSelectIndex) {
            
            FHHouseFindListView *lastBaseView = [self.scrollView viewWithTag:10 + self.lastSelectIndex];
            [lastBaseView viewWillDisappear:YES];
            
            FHHouseFindListView *currentBaseView = [self.scrollView viewWithTag:10 + self.currentSelectIndex];
            [currentBaseView viewWillAppear:YES];
            
            [self endTrack];
            [self addStayCategoryLogBy:self.lastSelectIndex];
            [self resetStayTime];
            [self startTrack];
            [self addEnterCategoryLog];
        }
    }
}

- (void)selectHouseFindListItem: (NSInteger)index
{
    self.lastSelectIndex = self.currentSelectIndex;
    self.currentSelectIndex = index;
    FHHouseFindSectionItem *item = self.itemList[index];
    FHHouseFindListView *baseView = [self.scrollView viewWithTag:10 + index];
    [baseView refreshData];
    NSString *placeholder = [self.sugDict objectForKey:[self placeholderKeyByHouseType:item.houseType]];
    if (self.sugSelectBlock) {
        self.sugSelectBlock(placeholder);
    }
    
}

- (void)dealloc
{
    [_configDisposeble dispose];
}

#pragma mark - log

- (void)viewWillAppear:(BOOL)animated
{
    [self startTrack];
}
- (void)viewWillDisappear:(BOOL)animated
{
    FHHouseFindListView *currentBaseView = [self.scrollView viewWithTag:10 + self.currentSelectIndex];
    [currentBaseView viewWillDisappear:YES];
    
    [self endTrack];
    [self addStayCategoryLog];
    [self resetStayTime];
}

-(void)addEnterCategoryLog
{
    if (self.currentSelectIndex < self.itemList.count) {
        
        FHHouseFindListView *baseView = [self.scrollView viewWithTag:10 + self.currentSelectIndex];
        FHHouseFindSectionItem *item = self.itemList[self.currentSelectIndex];
        NSMutableDictionary *tracerDict = [baseView categoryLogDict].mutableCopy;
        if (!baseView.isEnterCategory) {
            
            [FHUserTracker writeEvent:@"enter_category" params:tracerDict];
        }
    }
}

- (void)addStayCategoryLog
{
    [self addStayCategoryLogBy:self.currentSelectIndex];
}

- (void)addStayCategoryLogBy:(NSInteger)index
{
    NSTimeInterval duration = self.trackStayTime * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    if (index < self.itemList.count) {
        
        FHHouseFindListView *baseView = [self.scrollView viewWithTag:10 + index];
        FHHouseFindSectionItem *item = self.itemList[index];
        NSMutableDictionary *tracerDict = [baseView categoryLogDict].mutableCopy;
        tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
        [FHUserTracker writeEvent:@"stay_category" params:tracerDict];
    }
}

- (void)resetStayTime
{
    self.trackStayTime = 0;
    
}

- (void)startTrack
{
    self.trackStartTime = [[NSDate date] timeIntervalSince1970];
}

- (void)endTrack
{
    self.trackStayTime += [[NSDate date] timeIntervalSince1970] - self.trackStartTime;
    
}


@end
