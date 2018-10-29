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

#define kCellId @"singleCellId"

@interface FHMapSearchHouseListViewModel ()

@property(nonatomic , strong) NSMutableArray *houseList;

@end

@implementation FHMapSearchHouseListViewModel

-(instancetype)init
{
    self = [super init];
    if (self) {
        _houseList = [NSMutableArray new];
    }
    return self;
}

-(void)registerCells:(UITableView *)tableView
{
    self.tableView = tableView;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [tableView registerClass:SingleImageInfoCell.class forCellReuseIdentifier:kCellId];
}

-(void)updateWithInitHouseData:(FHSearchHouseDataModel *)data neighbor:(FHMapSearchDataListModel *)neighbor
{
    [_houseList removeAllObjects];
    [_houseList addObjectsFromArray:data.items];
    [self.tableView reloadData];
    [_headerView updateWithMode:neighbor];
    _tableView.tableHeaderView = _headerView;
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
    }else if([self.listController canMoveup]){
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

@end
