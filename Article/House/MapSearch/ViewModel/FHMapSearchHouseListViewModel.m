//
//  FHMapSearchHouseListViewModel.m
//  Article
//
//  Created by 谷春晖 on 2018/10/25.
//

#import "FHMapSearchHouseListViewModel.h"
#import "Bubble-Swift.h"
#import "FHSearchHouseModel.h"
#import "FHHouseAreaHeaderView.h"
#import "FHMapSearchHouseListViewController.h"
#import "FHMapSearchModel.h"
#import "FHHouseSearcher.h"
#import "FHMapSearchConfigModel.h"

#define kCellId @"singleCellId"

@interface FHMapSearchHouseListViewModel ()

@property(nonatomic , strong) NSMutableArray *houseList;
@property(nonatomic , strong) FHMapSearchDataListModel *neighbor;
@property(nonatomic , strong) NSString *searchId;
@property(nonatomic , assign) NSInteger offset;
@property(nonatomic , strong) NIHRefreshCustomFooter *refreshFooter;

@end

@implementation FHMapSearchHouseListViewModel

-(instancetype)init
{
    self = [super init];
    if (self) {
        _houseList = [NSMutableArray new];
        _offset = 1;
    }
    return self;
}

-(void)registerCells:(UITableView *)tableView
{
    self.tableView = tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    __weak typeof(self) wself = self;
    self.refreshFooter = [NIHRefreshCustomFooter footerWithRefreshingBlock:^{
        [wself loadMoreData];
    }];
    self.tableView.mj_footer = _refreshFooter;
    [tableView registerClass:SingleImageInfoCell.class forCellReuseIdentifier:kCellId];
}

-(void)setHeaderView:(FHHouseAreaHeaderView *)headerView
{
    _headerView = headerView;
    [headerView addTarget:self action:@selector(showNeighborDetail) forControlEvents:UIControlEventTouchUpInside];
}

-(void)updateWithHouseData:(FHSearchHouseDataModel *)data neighbor:(FHMapSearchDataListModel *)neighbor
{
    [_houseList removeAllObjects];
    [_houseList addObjectsFromArray:data.items];
    [self.tableView reloadData];
    self.tableView.contentOffset = CGPointZero;
    [_headerView updateWithMode:neighbor];
    _tableView.tableHeaderView = _headerView;
    self.searchId = data.searchId;
    self.neighbor = neighbor;
    if (data.hasMore) {
        [self.tableView.mj_footer resetNoMoreData];
    }else{
        [self.tableView.mj_footer endRefreshingWithNoMoreData];
    }
    
}

-(void)showNeighborDetail
{
    if (self.listController.showNeighborhoodDetailBlock) {
        self.listController.showNeighborhoodDetailBlock(self.neighbor);
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _houseList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SingleImageInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    
    FHSearchHouseDataItemsModel *item = _houseList[indexPath.row];
    [cell updateWithModel:item isLastCell:(indexPath.row == _houseList.count - 1)];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == _houseList.count - 1) {
        return 125;
//    }
//    return 105;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHSearchHouseDataItemsModel *model = _houseList[indexPath.row];
    if (self.listController.showHouseDetailBlock) {
        self.listController.showHouseDetailBlock(model);
    }
}

-(void)dismiss
{
    [self handleDismiss:0.3];
}

-(void)handleDismiss:(CGFloat)duration
{
    self.tableView.userInteractionEnabled = false;
    if (self.listController.willSwipeDownDismiss) {
        self.listController.willSwipeDownDismiss(duration);
    }
    [UIView animateWithDuration:duration animations:^{
        self.listController.view.top = self.listController.parentViewController.view.height;
    } completion:^(BOOL finished) {
        if (self.listController.didSwipeDownDismiss) {
            self.listController.didSwipeDownDismiss();
        }
        self.tableView.userInteractionEnabled = true;
    }];
    [self.tableView.mj_footer resetNoMoreData];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat minTop =  [self.listController minTop];
    if ([self.listController canMoveup]) {
        [self.listController moveTop:(self.tableView.superview.top - scrollView.contentOffset.y)];
        scrollView.contentOffset = CGPointZero;
        
    }else if (scrollView.contentOffset.y < 0){
        [self.listController moveTop:(self.tableView.superview.top - scrollView.contentOffset.y)];
        scrollView.contentOffset = CGPointZero;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (self.listController.view.top > self.listController.view.height*0.6) {
        [self handleDismiss:0.3];
    }else if(self.listController.view.top - [self.listController minTop] < 50){
        //吸附都顶部
        [self.listController moveTop:0];
    }
    else if([self.listController canMoveup]){
        //当前停留在中间
        self.listController.moveDock();
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (velocity.y < -2.5) {
        //quickly swipe done
        [self handleDismiss:0.1];
    }
}

-(void)loadMoreData
{
    /*
     "exclude_id[]=\(self.houseId ?? "")&exclude_id[]=\(self.neighborhoodId)&neighborhood_id=\(self.neighborhoodId)&house_type=\(self.theHouseType.value.rawValue)&neighborhood_id=\(self.neighborhoodId)" +
     */
    
    //TODO: add loading ...
    
    NSString *query = [NSString stringWithFormat:@""];
    NSMutableDictionary *param = [NSMutableDictionary new];
    
    if (self.neighbor.nid) {
        param[NEIGHBORHOOD_ID_KEY] = self.neighbor.nid;
    }
    param[HOUSE_TYPE_KEY] = @(self.configModel.houseType);
    if (self.searchId) {
        param[@"search_id"] = self.searchId;
    }

    self.offset = self.houseList.count;
    
    __weak typeof(self) wself = self;
    [FHHouseSearcher houseSearchWithQuery:query param:param offset:self.offset needCommonParams:YES callback:^(NSError * _Nullable error, FHSearchHouseDataModel * _Nullable houseModel) {
        if (!wself) {
            return ;
        }
        
        if (!error && houseModel) {
            [wself.houseList addObjectsFromArray:houseModel.items];
            [wself.tableView reloadData];
            if (houseModel.hasMore) {
                [wself.tableView.mj_footer endRefreshing];
            }else{
                [wself.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }else{
            //TODO: show error toast
        }
        
    }];
    
}

@end
