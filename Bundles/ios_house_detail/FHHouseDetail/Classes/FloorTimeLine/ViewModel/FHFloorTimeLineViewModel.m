//
//  FHFloorTimeLineViewModel.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/17.
//

#import "FHFloorTimeLineViewModel.h"
#import "FHHouseDetailAPI.h"
#import "FHDetailNewTimeLineItemCell.h"
#import "FHRefreshCustomFooter.h"
#import "FHEnvContext.h"

@interface FHFloorTimeLineViewModel()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , weak) UITableView *timeLineListTable;
@property (nonatomic , strong) NSMutableArray *currentItems;
@property (nonatomic , strong) NSString *courtId;
@property(nonatomic , strong) FHRefreshCustomFooter *refreshFooter;
@property(nonatomic , assign) NSInteger currentPage;

@end
@implementation FHFloorTimeLineViewModel

-(instancetype)initWithController:(FHHouseDetailSubPageViewController *)viewController tableView:(UITableView *)tableView courtId:(NSString *)courtId
{
    self = [super init];
    if (self) {
        self.detailController = viewController;
        _timeLineListTable = tableView;
        _courtId = courtId;
        _currentItems = [NSMutableArray new];
        _currentPage = 0;
        [self configTableView];
        self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
            
        }];
        self.timeLineListTable.mj_footer = self.refreshFooter;
        [self.refreshFooter setUpNoMoreDataText:@"无更多动态"];
        [self.timeLineListTable.mj_footer endRefreshingWithNoMoreData];
    }
    return self;
}

// 注册cell类型
- (void)registerCellClasses {
    [self.timeLineListTable registerClass:[FHDetailNewTimeLineItemCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNewTimeLineItemCell class])];
}

- (void)configTableView
{
    [self registerCellClasses];
    _timeLineListTable.delegate = self;
    _timeLineListTable.dataSource = self;
}


- (void)scrollToItemAtRow:(NSInteger)index {
    if (index < [self.currentItems count]) {
        [self.timeLineListTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (void)processDetailData:(FHDetailNewDataTimelineModel *)model {
    NSMutableArray *itemsArray = [NSMutableArray new];

    for (NSInteger i = 0; i < model.list.count; i++) {
        FHDetailNewDataTimelineListModel *itemModel = model.list[i];
        FHDetailNewTimeLineItemModel *item = [[FHDetailNewTimeLineItemModel alloc] init];
        item.desc = itemModel.desc;
        item.title = itemModel.title;
        item.createdTime = itemModel.createdTime;
        item.isFirstCell = (i == 0);
        item.isLastCell = (i == model.list.count - 1);
        item.isExpand = YES;
        [itemsArray addObject:item];
    }
    [self.currentItems addObjectsFromArray:itemsArray];
    
    UIView *bottomBar = [self.detailController getBottomBar];
    bottomBar.hidden = YES;

    [_timeLineListTable reloadData];
    [_timeLineListTable layoutIfNeeded];
}


#pragma UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.currentItems count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHDetailNewTimeLineItemCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FHDetailNewTimeLineItemCell class])];
    if (!cell) {
        cell = [[FHDetailNewTimeLineItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass([FHDetailNewTimeLineItemCell class])];
    }
    if ([cell isKindOfClass:[FHDetailNewTimeLineItemCell class]] && _currentItems.count > indexPath.row) {
        [cell refreshWithData:_currentItems[indexPath.row]];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

@end
