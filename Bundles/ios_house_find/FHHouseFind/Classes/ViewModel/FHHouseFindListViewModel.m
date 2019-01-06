//
//  FHHouseFindListViewModel.m
//  FHHouseFind
//
//  Created by 张静 on 2019/1/2.
//

#import "FHHouseFindListViewModel.h"
#import "FHHouseFindCollectionCell.h"
#import "TTRoute.h"
#import "FHEnvContext.h"
#import "FHHomeConfigManager.h"
#import "HMSegmentedControl.h"
#import "FHHouseFindSectionItem.h"

#define kFHHouseFindCollectionViewCell @"kFHHouseFindCollectionViewCell"


@interface FHHouseFindListViewModel () <UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic,weak)UICollectionView *collectionView;
@property(nonatomic,strong)FHTracerModel *tracerModel;
@property (nonatomic , copy) NSString *originSearchId;
@property (nonatomic , copy) NSString *originFrom;
@property (nonatomic , strong) FHConfigDataModel *configDataModel;
@property (nonatomic , weak) HMSegmentedControl *segmentView;
@property (nonatomic , strong) NSArray <FHHouseFindSectionItem *> *itemList;
@property (nonatomic , assign) FHHouseType currentHouseType;

@end

@implementation FHHouseFindListViewModel

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
{
    self = [super init];
    if (self) {
        
        self.collectionView = collectionView;
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        
        [self.collectionView registerClass:[FHHouseFindCollectionCell class] forCellWithReuseIdentifier:kFHHouseFindCollectionViewCell];
    }
    
    return self;
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
    [self refreshHouseItemList];
    [self.collectionView reloadData];
    if (self.itemList.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        self.currentHouseType = self.itemList[0].houseType;
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

- (void)refreshHouseItemList
{
    NSMutableArray *itemList = @[].mutableCopy;
    NSMutableArray *titleList = @[].mutableCopy;
    if (self.configDataModel.searchTabFilter.count > 0) {
        FHHouseFindSectionItem *item = [[FHHouseFindSectionItem alloc]init];
        item.houseType = FHHouseTypeSecondHandHouse;
        item.title = @"二手房";
        [itemList addObject:item];
        [titleList addObject:@"二手房"];
    }
    if (self.configDataModel.searchTabCourtFilter.count > 0) {
        FHHouseFindSectionItem *item = [[FHHouseFindSectionItem alloc]init];
        item.houseType = FHHouseTypeNewHouse;
        item.title = @"新房";
        [itemList addObject:item];
        [titleList addObject:@"新房"];
    }
    if (self.configDataModel.searchTabRentFilter.count > 0) {
        FHHouseFindSectionItem *item = [[FHHouseFindSectionItem alloc]init];
        item.houseType = FHHouseTypeRentHouse;
        item.title = @"租房";
        [itemList addObject:item];
        [titleList addObject:@"租房"];
    }
    if (self.configDataModel.searchTabNeighborhoodFilter.count > 0) {
        FHHouseFindSectionItem *item = [[FHHouseFindSectionItem alloc]init];
        item.houseType = FHHouseTypeNeighborhood;
        item.title = @"小区";
        [itemList addObject:item];
        [titleList addObject:@"小区"];
    }
    self.itemList = itemList;
    [self.segmentView setSectionTitles:titleList];
    self.segmentView.selectedSegmentIndex = 0;
    if (self.itemList.count > 0) {
        self.currentHouseType = self.itemList[0].houseType;
    }
    
}

- (void)jump2GuessVC
{
    NSDictionary *traceParam = [self.tracerModel toDictionary] ? : @{};
    //sug_list
    NSHashTable *sugDelegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
    [sugDelegateTable addObject:self];
    NSDictionary *dict = @{@"house_type":@(self.currentHouseType) ,
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
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
            self.currentHouseType = self.itemList[index].houseType;
            [wself.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
    };
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.itemList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FHHouseFindCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kFHHouseFindCollectionViewCell forIndexPath:indexPath];
    NSString *openUrl;
    FHHouseType houseType;
    if (indexPath.item < self.itemList.count) {
        
        FHHouseFindSectionItem *item = self.itemList[indexPath.item];
        houseType = item.houseType;
        openUrl = [NSString stringWithFormat:@"fschema://house_list?house_type=%ld",houseType];
        [cell updateDataWithHouseType:houseType openUrl:openUrl];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{

    //    if ((_userDrag && ![self.lastCategoryID isEqualToString:self.currentCategory.categoryID]) || _userClick) {
//        if ([[cell class] conformsToProtocol:@protocol(TTFeedCollectionCell)]) {
//            id<TTFeedCollectionCell> collectionCell = (id<TTFeedCollectionCell>)cell;
//
//            if ([collectionCell respondsToSelect or:@selector(willDisappear)]) {
//                [collectionCell willDisappear];
//            }
//
//            TTCategory *category = [self categoryAtIndex:indexPath.item];
//            [self leaveCategory:category];
//
//            if ([collectionCell respondsToSelector:@selector(didDisappear)]) {
//                [collectionCell didDisappear];
//            }
//        }
//    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView != self.collectionView) {
        return;
    }
    NSInteger index = self.collectionView.contentOffset.x / [UIScreen mainScreen].bounds.size.width;
    if ((self.collectionView.contentOffset.x - index * [UIScreen mainScreen].bounds.size.width) > ([UIScreen mainScreen].bounds.size.width / 2)) {
        index += 1;
    }
    if (index >= 0 && index < self.itemList.count) {
        self.segmentView.selectedSegmentIndex = index;
        self.currentHouseType = self.itemList[index].houseType;

    }
}


@end
