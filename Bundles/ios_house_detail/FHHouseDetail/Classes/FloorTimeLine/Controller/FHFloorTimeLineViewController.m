//
//  FHFloorTimeLineViewController.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/17.
//

#import "FHFloorTimeLineViewController.h"
#import "FHFloorTimeLineViewModel.h"
#import "FHDetailNavBar.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHDetailBottomBarView.h"
#import <FHHouseBase/FHBaseTableView.h>

@interface FHFloorTimeLineViewController () <TTRouteInitializeProtocol>

@property (nonatomic , strong) UITableView *timeLineListTable;
@property (nonatomic , strong) FHFloorTimeLineViewModel *timeLineListViewModel;
@property (nonatomic , strong) NSString *courtId;
@property (nonatomic , strong) FHHouseDetailContactViewModel *contactViewModel;

@end

@implementation FHFloorTimeLineViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _courtId = paramObj.allParams[@"court_id"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUpTimeLineListTable];

    [self addDefaultEmptyViewFullScreen];

    _timeLineListViewModel = [[FHFloorTimeLineViewModel alloc] initWithController:self tableView:_timeLineListTable courtId:_courtId];
    [self setNavBarTitle:@"楼盘动态"];
    [self.view bringSubviewToFront:[self getNaviBar]];

}

- (void)setUpTimeLineListTable
{
    _timeLineListTable = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _timeLineListTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0 , *)) {
        _timeLineListTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _timeLineListTable.estimatedRowHeight = UITableViewAutomaticDimension;
        _timeLineListTable.estimatedSectionFooterHeight = 0;
        _timeLineListTable.estimatedSectionHeaderHeight = 0;
    }
    [_timeLineListTable setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_timeLineListTable];
    
    [_timeLineListTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo([self getNaviBar].mas_bottom);
        make.left.right.bottom.equalTo(self.view);
//        make.bottom.equalTo([self getBottomBar].mas_top);
    }];
    
    [_timeLineListTable setBackgroundColor:[UIColor whiteColor]];
   
}

- (void)retryLoadData
{
    [self.timeLineListViewModel startLoadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
