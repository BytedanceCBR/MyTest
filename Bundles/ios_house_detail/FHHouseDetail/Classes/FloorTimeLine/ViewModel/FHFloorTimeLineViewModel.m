//
//  FHFloorTimeLineViewModel.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/17.
//

#import "FHFloorTimeLineViewModel.h"
#import "FHHouseDetailAPI.h"
#import "FHDetailNewTimeLineItemCell.h"
#import "FHDetailNewModel.h"
#import <FHRefreshCustomFooter.h>
#import <FHEnvContext.h>

@interface FHFloorTimeLineViewModel()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , weak) UITableView *timeLineListTable;
@property (nonatomic , strong) NSMutableArray *currentItems;
@property (nonatomic , strong) NSString *courtId;
@property(nonatomic , strong) FHRefreshCustomFooter *refreshFooter;
@property(nonatomic , assign) NSInteger currentPage;

@end
@implementation FHFloorTimeLineViewModel

-(instancetype)initWithController:(FHHouseDetailViewController *)viewController tableView:(UITableView *)tableView courtId:(NSString *)courtId
{
    self = [super init];
    if (self) {
        _timeLineListTable = tableView;
        _courtId = courtId;
        _currentItems = [NSMutableArray new];
        _currentPage = 0;
        [self configTableView];

    
        [self startLoadData];

        WeakSelf;
        self.refreshFooter = [FHRefreshCustomFooter footerWithRefreshingBlock:^{
            StrongSelf;
            if ([FHEnvContext isNetworkConnected]) {
                [self startLoadData];
            }else
            {
                [[ToastManager manager] showToast:@"网络异常"];
            }
        }];
        self.refreshFooter.hidden = YES;
        
        self.timeLineListTable.mj_footer = self.refreshFooter;
    }
    return self;
}

// 注册cell类型
- (void)registerCellClasses {
    [self.timeLineListTable registerClass:[FHDetailNewTimeLineItemCell class] forCellReuseIdentifier:NSStringFromClass([FHDetailNewTimeLineItemCell class])];
}
// cell class
- (Class)cellClassForEntity:(id)model {
    if ([model isKindOfClass:[FHDetailNewTimeLineItemModel class]]) {
        return [FHDetailNewTimeLineItemCell class];
    }
    return [FHDetailBaseCell class];
}
// cell identifier
- (NSString *)cellIdentifierForEntity:(id)model {
    Class cls = [self cellClassForEntity:model];
    return NSStringFromClass(cls);
}

- (void)configTableView
{
    [self registerCellClasses];
    _timeLineListTable.delegate = self;
    _timeLineListTable.dataSource = self;
}

- (void)startLoadData
{
    if (_courtId) {
        
        NSString *stringQuery = [NSString stringWithFormat:@"court_id=%@&count=%@&page=%@",_courtId,@"10",[NSString stringWithFormat:@"%ld",_currentPage]];
        
        __weak typeof(self) wSelf = self;
        [FHHouseDetailAPI requestFloorTimeLineSearch:_courtId query:stringQuery completion:^(FHDetailNewTimeLineResponseModel * _Nullable model, NSError * _Nullable error) {
            if(model.data.list.count != 0)
            {
                self.refreshFooter.hidden = NO;
                wSelf.currentPage ++;
                [wSelf processDetailData:model];
            }
        }];
    }
}

- (void)processDetailData:(FHDetailNewTimeLineResponseModel *)model {
    NSMutableArray *itemsArray = [NSMutableArray new];

    for (NSInteger i = 0; i < model.data.list.count; i++) {
        FHDetailNewDataTimelineListModel *itemModel = model.data.list[i];
        FHDetailNewTimeLineItemModel *item = [[FHDetailNewTimeLineItemModel alloc] init];
        item.desc = itemModel.desc;
        item.title = itemModel.title;
        item.createdTime = itemModel.createdTime;
        item.isFirstCell = (i == 0);
        item.isLastCell = (i == self.currentItems.count - 1);
        item.isExpand = YES;
        [itemsArray addObject:item];
    }
    
    [self updateTableViewWithMoreData:model.data.hasMore];

    [self.currentItems addObjectsFromArray:itemsArray];

    [_timeLineListTable reloadData];
}

- (void)updateTableViewWithMoreData:(BOOL)hasMore {
    self.timeLineListTable.mj_footer.hidden = NO;
    if (hasMore == NO) {
        [self.refreshFooter setUpNoMoreDataText:@" -- 暂无更多数据 -- "];
        [self.timeLineListTable.mj_footer endRefreshingWithNoMoreData];
    }else {
        [self.timeLineListTable.mj_footer endRefreshing];
    }
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
