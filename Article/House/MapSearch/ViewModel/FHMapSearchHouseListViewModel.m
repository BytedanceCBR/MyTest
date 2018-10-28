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

-(void)dismiss
{
    [self handleDismiss];
}

-(void)handleDismiss
{
    self.tableView.userInteractionEnabled = false;
    CGFloat duration = 0.1;
    if (self.listController.willSwipDownDismiss) {
        self.listController.willSwipDownDismiss(duration);
    }
    [UIView animateWithDuration:duration animations:^{
        self.listController.view.top = self.listController.parentViewController.view.height;
    } completion:^(BOOL finished) {
        if (self.listController.didSwipDownDismiss) {
            self.listController.didSwipDownDismiss();
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
        [self handleDismiss];
    }else if([self.listController canMoveup]){
        //当前停留在中间
        self.listController.moveDock();
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
}

@end
