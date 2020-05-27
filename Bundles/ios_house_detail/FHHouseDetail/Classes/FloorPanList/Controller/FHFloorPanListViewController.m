//
//  FHFloorPanListViewController.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/13.
//

#import "FHFloorPanListViewController.h"
#import "HMSegmentedControl.h"
#import "FHEnvContext.h"
#import "FHFloorPanListViewModel.h"
#import <FHHouseBase/FHBaseTableView.h>

@interface FHFloorPanListViewController ()
@property (nonatomic , strong) HMSegmentedControl *segmentedControl;
@property (nonatomic , strong) UIView *segementBottomLine;
@property (nonatomic , strong) UITableView *floorListTable;
@property (nonatomic , strong) FHFloorPanListViewModel *panListModel;
@property (nonatomic , strong) NSMutableArray<FHDetailNewDataFloorpanListListModel *> *floorList;
@property (nonatomic , strong) NSString *courtId;
@end

@implementation FHFloorPanListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSArray *floorList = paramObj.userInfo.allInfo[@"floorlist"];
        
        if (floorList.count > 0 && [floorList.firstObject isKindOfClass:[FHDetailNewDataFloorpanListListModel class]]) {
            _floorList = (NSMutableArray<FHDetailNewDataFloorpanListListModel *> *)floorList;
        }
        
        if (paramObj.userInfo.allInfo[@"court_id"]) {
            _courtId = paramObj.userInfo.allInfo[@"court_id"];
        }
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUpSegmentedControl];
    
    [self setUpFloorListTable];

    _panListModel = [[FHFloorPanListViewModel alloc] initWithController:self tableView:self.floorListTable houseType:0 andSegementView:self.segmentedControl andItems:_floorList andCourtId:_courtId];
    
    self.viewModel = self.panListModel; // IM线索使用，不可以删除
    
    [self setNavBarTitle:@"户型列表"];
    
    [(FHDetailNavBar *)[self getNaviBar] removeBottomLine];

    
    [self addDefaultEmptyViewFullScreen];

    if (![TTReachability isNetworkConnected]) {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkNotRefresh];
        [self.view bringSubviewToFront:[self getNaviBar]];
        return;
    }
    
    [self.view bringSubviewToFront:[self getNaviBar]];
    // Do any additional setup after loading the view.
}

- (void)setUpSegmentedControl
{
    _segmentedControl = [HMSegmentedControl new];
    _segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 15, 0, 13);
    _segmentedControl.selectionIndicatorHeight = 4;
    _segmentedControl.selectionIndicatorCornerRadius = 2;
    _segmentedControl.selectionIndicatorWidth = 20;
    _segmentedControl.selectionIndicatorColor = [UIColor themeOrange4];
    _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    _segmentedControl.isNeedNetworkCheck = YES;
    //    _segmentedControl.selec
    NSDictionary *attributeNormal = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont themeFontRegular:16],NSFontAttributeName,
                                     [UIColor blackColor],NSForegroundColorAttributeName,nil];
    
    NSDictionary *attributeSelect = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont themeFontSemibold:18],NSFontAttributeName,
                                     [UIColor blackColor],NSForegroundColorAttributeName,nil];
    _segmentedControl.titleTextAttributes = attributeNormal;
    _segmentedControl.selectedTitleTextAttributes = attributeSelect;
    //_segmentedControl.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(-3, 0, -3, 0);
    _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    WeakSelf;

    [self.view addSubview:_segmentedControl];
    
    [_segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo([self getNaviBar].mas_bottom);
        make.left.right.equalTo(self.view);
        make.width.mas_equalTo(MAIN_SCREEN_WIDTH);
        make.height.mas_equalTo(44);
    }];
    
    _segementBottomLine = [UIView new];
    _segementBottomLine.backgroundColor = [UIColor themeGray6];
    [_segmentedControl addSubview:_segementBottomLine];
    [_segementBottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_segmentedControl);
        make.left.right.equalTo(_segmentedControl);
        make.width.mas_equalTo(MAIN_SCREEN_WIDTH);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)setUpFloorListTable
{
    _floorListTable = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _floorListTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0 , *)) {
        _floorListTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _floorListTable.estimatedRowHeight = UITableViewAutomaticDimension;
        _floorListTable.estimatedSectionFooterHeight = 0;
        _floorListTable.estimatedSectionHeaderHeight = 0;
    }
    
    [self.view addSubview:_floorListTable];
    
    [_floorListTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        make.left.equalTo(0);
        make.top.equalTo(self.segmentedControl.mas_bottom);
        make.bottom.equalTo([self getBottomBar].mas_top);
    }];
    self.floorListTable.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    [_floorListTable setBackgroundColor:[UIColor themeGray7]];
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
