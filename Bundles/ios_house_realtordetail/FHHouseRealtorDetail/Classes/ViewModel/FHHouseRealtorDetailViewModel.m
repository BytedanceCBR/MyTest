//
//  FHHouseRealtorDetailViewModel.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/12.
//

#import "FHHouseRealtorDetailViewModel.h"
#import "FHHouseRealtorDetailRGCCell.h"
#import "FHHouseRealtorDetailInfoModel.h"
#import "FHHouseRealtorDetailBaseCell.h"
#import "FHMainApi.h"
#import "UIScrollView+Refresh.h"
#import "FHRefreshCustomFooter.h"
#import "FHHouseRealtorDetailInfoModel.h"
#import "FHHouseRealtorDetailStatusModel.h"
@interface FHHouseRealtorDetailViewModel()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic , weak) UITableView *tableView;
@property(nonatomic , weak) FHHouseRealtorDetailController *detailController;
@property(nonatomic, strong) FHHouseRealtorDetailRgcTabView *rgcTab;
@property(nonatomic, strong) NSMutableArray *dataArr;
@property(nonatomic, assign) CGFloat currentCelleHeight;
@property(nonatomic, assign) NSInteger currentIndex;
@property(nonatomic, strong)FHRefreshCustomFooter *refreshFooter;
@end
@implementation FHHouseRealtorDetailViewModel
- (instancetype)initWithController:(FHHouseRealtorDetailController *)viewController tableView:(UITableView *)tableView {
    self = [super init];
    if (self) {
        //        _detailTracerDic = [NSMutableDictionary new];
        //        _items = [NSMutableArray new];
        //        _cellHeightCaches = [NSMutableDictionary new];
        //        _elementShowCaches = [NSMutableDictionary new];
        //        _elementShdowGroup = [NSMutableDictionary new];
        //        _lastPointOffset = CGPointZero;
        //        _weakedCellTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        //        _weakedVCLifeCycleCellTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        //        self.houseType = houseType;
        self.detailController = viewController;
        self.tableView = tableView;
        //        self.tableView.backgroundColor = [UIColor themeGray7];
        [self configTableView];
        [self requestData];
    }
    return self;
}


- (void)requestData {
    NSMutableDictionary *parmas= [NSMutableDictionary new];
    [parmas setValue:@"3021100461591229" forKey:@"realtor_id"];
    // 详情页数据-Main
    __weak typeof(self) wSelf = self;
    [FHMainApi requestRealtorHomePage:parmas completion:^(FHHouseRealtorDetailModel * _Nonnull model, NSError * _Nonnull error) {
        if (model && error == NULL) {
            if (model.data) {
                [wSelf processDetailData:model];
            }
        }
    }];
}

- (void)processDetailData:(FHHouseRealtorDetailModel *)model {
    NSMutableArray *rgcTabList = model.data.ugcTabList.mutableCopy;
    FHHouseRealtorDetailRgcTabModel *models =  [[FHHouseRealtorDetailRgcTabModel alloc]init];
    models.showName = @"房源";
    models.tabName = @"house";
    [rgcTabList insertObject:models atIndex:0];
    [self createListStatuaModel:rgcTabList];
    if (rgcTabList.count > 0) {
        FHHouseRealtorDetailRGCCellModel *rgcModel = [[FHHouseRealtorDetailRGCCellModel alloc]init];
        rgcModel.tabDataArray = [rgcTabList copy];
        [self.dataArr addObject:rgcModel];
    };
    self.rgcTab.tabInfoArr = rgcTabList;
    [self.tableView reloadData];
}

- (void)createListStatuaModel:(NSArray *)array {
    NSMutableArray *statusArr = @[].mutableCopy;
    for (int m = 0; m <array.count; m++) {
        FHHouseRealtorDetailStatus *statusIndex =  [[FHHouseRealtorDetailStatus alloc]init];
        statusIndex.cellHeight = 1;
        statusIndex.hasMore = YES;
        [statusArr addObject:statusIndex];
    }
    [FHHouseRealtorDetailStatusModel sharedInstance].statusArray = [statusArr copy];
}

- (void)configTableView
{
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //    _tableView.backgroundColor = [UIColor colorWithRed:252 green:252 blue:252 alpha:1];
    //    self.detailController.view.backgroundColor = [UIColor redColor];
    [self registerCellClasses];
    __weak typeof(self) wself = self;
    
    self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
        NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
        FHHouseRealtorDetailBaseCell*cell = [wself.tableView cellForRowAtIndexPath:index];
        [cell requestData:NO first:NO];
    }];
    self.tableView.mj_footer = self.refreshFooter;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
        if (scrollView.contentOffset.y>425) {
    
        }
    self.tableView.scrollEnabled = NO;
}
- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    
    
    
    self.tableView.mj_footer.hidden = NO;
    if (hasMore) {
        [self.tableView.mj_footer endRefreshing];
    }else {
        [self.refreshFooter setUpNoMoreDataText:@"我是有底线的" offsetY:-3];
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
}

- (void)registerCellClasses {
    [self.tableView registerClass:[FHHouseRealtorDetailRGCCell class] forCellReuseIdentifier:@"FHHouseRealtorDetailRGCCellModel"];
}

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        NSMutableArray *dataArr = [[NSMutableArray alloc]init];
        _dataArr = dataArr;
    }
    return _dataArr;
}


#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if (row >= 0 && row < self.dataArr.count) {
        FHHouseRealtorDetailBaseCellModel *dataModel = self.dataArr[row];
        NSString *identifier = NSStringFromClass([dataModel class]);//[self cellIdentifierForEntity:data];
        if (identifier.length > 0) {
            FHHouseRealtorDetailBaseCell*cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            __weak typeof(self)Ws = self;
            cell.cellRefreshComplete = ^() {
                [Ws reloadRowHeight];
            };
            
            if (cell) {
                [cell refreshWithData:dataModel];
                return cell;
            }else{
                NSLog(@"nil cell for data: %@",dataModel);
            }
        }
    }
    return [[FHHouseRealtorDetailBaseCell alloc] init];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!_rgcTab) {
        __weak typeof(self)WS = self;
        FHHouseRealtorDetailRgcTabView *rgcTab = [[FHHouseRealtorDetailRgcTabView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
        
        rgcTab.headerItemSelectAction = ^(NSInteger index) {
             [WS selectSectionHeader:index];
        };
        _rgcTab = rgcTab;
    }
    return _rgcTab;
}

- (void)selectSectionHeader:(NSInteger )index {
    [FHHouseRealtorDetailStatusModel sharedInstance].currentIndex = index;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    FHHouseRealtorDetailRGCCell *rgcCell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (rgcCell) {
        NSIndexPath *collectionIndex = [NSIndexPath indexPathForItem:index inSection:0];
        [rgcCell.collection.collectionContainer scrollToItemAtIndexPath:collectionIndex atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
        [self reloadRowHeight];
    }
}
- (void)reloadRowHeight {
    // 获取主队列
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(mainQueue, ^{
        [self.tableView reloadData];
        self.refreshFooter.hidden = [FHHouseRealtorDetailStatusModel sharedInstance].currentRealtorDetailStatus.isHiddenFooterRefish;
        [self updateTableViewWithMoreData:[FHHouseRealtorDetailStatusModel sharedInstance].currentRealtorDetailStatus.hasMore];
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [FHHouseRealtorDetailStatusModel sharedInstance].currentCellHeight;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FHHouseRealtorDetailBaseCell*cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.didClickCellBlk) {
        cell.didClickCellBlk();
    }
}


@end
