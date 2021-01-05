//
//  FHFloorPanListViewModel.m
//  FHHouseDetail
//
//  Created by bytedance on 2021/1/4.
//

#import "FHFloorPanListViewModel.h"
#import "FHHouseDetailSubPageViewController.h"
#import "FHCommonDefines.h"
#import "FHHouseDetailAPI.h"
#import "FHFloorPanListCollectionCell.h"

@interface FHFloorPanListViewModel () <UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate>
@property (nonatomic,weak) UICollectionView *collectionView;
@property (nonatomic,weak) FHHouseDetailSubPageViewController *viewController;
@property (nonatomic,strong) NSArray<NSArray *> *dataList;
@property (nonatomic,weak) HMSegmentedControl *segmentedControl;
@property (nonatomic,copy) NSString  *currentCourtId;
@property(nonatomic,strong) NSDictionary *subPageParams;
@property(nonatomic,assign) CGFloat beginOffset;
@property(nonatomic,assign) CGFloat lastOffset;
@property(nonatomic,assign) NSInteger currentIndex;
@end

@implementation FHFloorPanListViewModel

-(instancetype)initWithController:(FHHouseDetailSubPageViewController *)viewController collectionView:(UICollectionView *)collectionView SegementView:(UIView *)segmentView courtId:(NSString *)courtId {
    if(self = [super init]) {
        self.collectionView = collectionView;
        self.viewController = viewController;
        self.segmentedControl = (HMSegmentedControl *)segmentView;
        self.bottomBar = (FHDetailBottomBar *)[viewController getBottomBar];
        self.contactViewModel = [viewController getContactViewModel];
        self.bottomBar.hidden = YES;
        self.currentCourtId = courtId;
        [self startLoadData];
    }
    return self;
}

- (void)startLoadData {
    if (![TTReachability isNetworkConnected]) {
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkNotRefresh];
        return;
    }
    
    if (self.currentCourtId) {
        [self.detailController startLoading];
        WeakSelf;
        [FHHouseDetailAPI requestFloorPanListSearch:self.currentCourtId completion:^(FHDetailFloorPanListResponseModel * _Nullable model, NSError * _Nullable error) {
            StrongSelf;
            if(model.data && !error) {
                self.segmentedControl.hidden = NO;
                [self.navBar showMessageNumber];
                [self.viewController.emptyView hideEmptyView];
                self.viewController.hasValidateData = YES;
                [self processDataWithModel:model];
            } else {
                self.viewController.hasValidateData = NO;
                [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoData];
            }
        }];
    }
}


- (void)processDataWithModel:(FHDetailFloorPanListResponseModel *)model {
    self.detailData = model;
    self.subPageParams = [self.viewController subPageParams];
    [self updateContactModel:model];
    [self generateDataListAndTitleArrayWithArray:model.data.list];
    
    WeakSelf;
    self.segmentedControl.indexChangeBlock = ^(NSInteger index) {
        StrongSelf;
        [self updateSelectCell:index];
    };
    
    self.bottomBar.hidden = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    for (NSInteger i = 0;i < self.dataList.count; i++) {
        NSString *identifier = [NSString stringWithFormat:@"%@_%zd",NSStringFromClass([FHFloorPanListCollectionCell class]),i];
        [self.collectionView registerClass:[FHFloorPanListCollectionCell class] forCellWithReuseIdentifier:identifier];
    }
    [self.collectionView reloadData];
}

- (void)updateContactModel:(FHDetailFloorPanListResponseModel *)model {
    FHDetailContactModel *contactPhone = nil;
    if (model.data.highlightedRealtor) {
        contactPhone = model.data.highlightedRealtor;
    }else {
        contactPhone = model.data.contact;
        contactPhone.unregistered = YES;
    }
    contactPhone.isFormReport = !contactPhone.enablePhone;
    self.contactViewModel.contactPhone = contactPhone;
    self.contactViewModel.followStatus = model.data.userStatus.courtSubStatus;
    self.contactViewModel.chooseAgencyList = model.data.chooseAgencyList;
    self.contactViewModel.highlightedRealtorAssociateInfo = model.data.highlightedRealtorAssociateInfo;
}


- (void)generateDataListAndTitleArrayWithArray:(NSArray<FHDetailNewDataFloorpanListListModel *> *)items{
    NSMutableSet *roomCountSet = [NSMutableSet setWithObject:@"0"];
    for(FHDetailNewDataFloorpanListListModel *model in items) {
        [roomCountSet addObject:model.roomCount];
    }
    NSMutableArray *roomCountArray = [NSMutableArray array];
    for(NSString *roomCount in roomCountSet) {
        [roomCountArray addObject:roomCount];
    }
    [roomCountArray sortUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2){
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return NSOrderedAscending;
        }else{
            return NSOrderedDescending;
        }
    }];
    NSMutableDictionary *roomCountDictionary = [NSMutableDictionary dictionary];
    for(NSInteger i = 0;i < roomCountArray.count; i++) {
        NSString *roomCount = [roomCountArray objectAtIndex:i];
        roomCountDictionary[roomCount] = @(i);
    }

    NSMutableArray *dataList = [NSMutableArray array];
    for(NSInteger i = 0;i < roomCountSet.count; i++) {
        NSMutableArray *itemArray = [NSMutableArray array];
        if(i == 0) {
            [itemArray addObjectsFromArray:items];
        }
        [dataList addObject:itemArray];
    }
    
    for(FHDetailNewDataFloorpanListListModel *model in items) {
        NSInteger index = [roomCountDictionary[model.roomCount] integerValue];
        if(index >= 1 && index < dataList.count) {
            NSMutableArray *itemArray = [dataList objectAtIndex:index];
            [itemArray addObject:model];
        }
    }
    
    NSMutableArray *titleArray = [NSMutableArray array];
    for(NSInteger i = 0; i < dataList.count; i++) {
        NSMutableArray *itemArray = [dataList objectAtIndex:i];
        NSString *roomCount = [roomCountArray objectAtIndex:i];
        if(i == 0) {
            [titleArray addObject:[NSString stringWithFormat:@"全部(%zd)",itemArray.count]];
        } else {
            [titleArray addObject:[NSString stringWithFormat:@"%@室(%zd)",roomCount,itemArray.count]];
        }
    }
    self.dataList = dataList;
    self.segmentedControl.sectionTitles = titleArray;
}

- (void)updateSelectCell:(NSInteger)index {
    if(index >= 0 && index < self.dataList.count) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    NSString *identifier = [NSString stringWithFormat:@"%@_%zd",NSStringFromClass([FHFloorPanListCollectionCell class]),index];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if([cell isKindOfClass:[FHFloorPanListCollectionCell class]]) {
        FHFloorPanListCollectionCell *detailCell = (FHFloorPanListCollectionCell *)cell;
        if(index >= 0 && index < self.dataList.count) {
            [detailCell refreshDataWithItemArray:[self.dataList objectAtIndex:index] subPageParams:self.subPageParams];
        }
    }
    return cell;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize cellSize = self.collectionView.bounds.size;
    return cellSize;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.beginOffset = self.currentIndex * SCREEN_WIDTH;
    self.lastOffset = scrollView.contentOffset.x;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollDistance = scrollView.contentOffset.x - self.lastOffset;
    CGFloat diff = scrollView.contentOffset.x - self.beginOffset;

    CGFloat tabIndex = scrollView.contentOffset.x / SCREEN_WIDTH;
    if(diff >= 0){
        tabIndex = floorf(tabIndex);
    }else if (diff < 0){
        tabIndex = ceilf(tabIndex);
    }

    if(tabIndex != self.segmentedControl.selectedSegmentIndex){
        self.currentIndex = tabIndex;
        self.segmentedControl.selectedSegmentIndex = self.currentIndex;
    } else {
        if(scrollView.contentOffset.x < 0 || scrollView.contentOffset.x > [UIScreen mainScreen].bounds.size.width * (CGFloat)(self.segmentedControl.sectionTitles.count - 1)){
            self.segmentedControl.selectedSegmentIndex = self.currentIndex;
            if (scrollView.contentOffset.x < 0) {
                self.lastOffset = 0;
            } else {
                self.lastOffset = [UIScreen mainScreen].bounds.size.width * (CGFloat)(self.segmentedControl.sectionTitles.count - 1);
            }
            return;
        }
        CGFloat value = scrollDistance / SCREEN_WIDTH;
        [self.segmentedControl setScrollValue:value isDirectionLeft:diff < 0];
    }

    self.lastOffset = scrollView.contentOffset.x;
}

@end
