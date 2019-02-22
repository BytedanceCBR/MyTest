//
//  FHFloorPanDetailViewController.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/13.
//

#import "FHFloorPanDetailViewController.h"
#import "FHHouseDetailBaseViewModel.h"
#import "TTReachability.h"
#import "FHDetailBottomBarView.h"
#import "FHDetailNavBar.h"
#import "TTDeviceHelper.h"
#import "UIFont+House.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHFloorPanDetailViewModel.h"

@interface FHFloorPanDetailViewController ()

@property (nonatomic, copy)   NSString* floorPanId; // 房源id
@property (nonatomic , strong) UITableView *infoListTable;
@property (nonatomic , strong) FHFloorPanDetailViewModel *coreInfoListViewModel;

@end

@implementation FHFloorPanDetailViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _floorPanId = paramObj.allParams[@"floorpanid"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置导航条为黑色
//    [self refreshContentOffset:CGPointMake(0, 500)];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    // Do any additional setup after loading the view.
    
    [self setUpinfoListTable];
    
    [self addDefaultEmptyViewFullScreen];

    _coreInfoListViewModel = [[FHFloorPanDetailViewModel alloc] initWithController:self tableView:_infoListTable floorPanId:_floorPanId];
    
    // Do any additional setup after loading the view.
}

- (void)retryLoadData
{
    [self.coreInfoListViewModel startLoadData];
}

- (void)setUpinfoListTable
{
    _infoListTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _infoListTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0 , *)) {
        _infoListTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _infoListTable.estimatedRowHeight = UITableViewAutomaticDimension;
        _infoListTable.estimatedSectionFooterHeight = 0;
        _infoListTable.estimatedSectionHeaderHeight = 0;
    }
    [_infoListTable setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_infoListTable];
    
    [_infoListTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo([self getNaviBar].mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo([self getBottomBar].mas_top);
    }];
    
    [_infoListTable setBackgroundColor:[UIColor whiteColor]];
    
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
