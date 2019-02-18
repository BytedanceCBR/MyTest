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

@interface FHFloorTimeLineViewModel()
@property (nonatomic , weak) UITableView *timeLineListTable;
@property (nonatomic , strong) NSMutableArray *currentItems;
@property (nonatomic , strong) NSString *courtId;
@end
@implementation FHFloorTimeLineViewModel

-(instancetype)initWithController:(FHHouseDetailViewController *)viewController tableView:(UITableView *)tableView courtId:(NSString *)courtId
{
    _timeLineListTable = tableView;
    _courtId = courtId;
    [self configTableView];
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
    _timeLineListTable.delegate = self;
    _timeLineListTable.dataSource = self;
    [self registerCellClasses];
}

- (void)startLoadData
{
    if (_courtId) {
        NSString *stringCourtId = [NSString stringWithFormat:@"court_id=%@&count=%@&page=%@",_courtId,@"10",@"1"];
        
        __weak typeof(self) wSelf = self;
        [FHHouseDetailAPI requestFloorTimeLineSearch:_courtId query:stringCourtId completion:^(FHDetailNewTimeLineResponseModel * _Nullable model, NSError * _Nullable error) {
            
        }];
    }
}

#pragma UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _currentItems.count;
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NSStringFromClass([FHDetailNewTimeLineItemCell class])];
    }
    if ([cell isKindOfClass:[FHDetailNewTimeLineItemCell class]] && _currentItems.count > indexPath.row) {
        [cell refreshWithData:_currentItems[indexPath.row]];
    }
    cell.backgroundColor = [UIColor whiteColor];
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
