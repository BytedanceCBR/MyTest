//
//  FHFloorPanListViewController.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/13.
//

#import "FHFloorPanListViewController.h"
#import <HMSegmentedControl.h>
#import <FHEnvContext.h>
#import "FHFloorPanListViewModel.h"

@interface FHFloorPanListViewController ()
@property (nonatomic , strong) HMSegmentedControl *segmentedControl;
@property (nonatomic , strong) UIScrollView *leftFilterView;
@property (nonatomic , strong) UIView *leftView;
@property (nonatomic , strong) UITableView *floorListTable;
@property (nonatomic , strong) FHFloorPanListViewModel *panListModel;
@property (nonatomic , strong) NSMutableArray<FHDetailNewDataFloorpanListListModel *> *floorList;
@end

@implementation FHFloorPanListViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        NSArray *floorList = paramObj.userInfo.allInfo[@"floorlist"];
        
        if (floorList.count > 0 && [floorList.firstObject isKindOfClass:[FHDetailNewDataFloorpanListListModel class]]) {
            _floorList = (NSMutableArray<FHDetailNewDataFloorpanListListModel *> *)floorList;
        }
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置导航条为黑色
    [self refreshContentOffset:CGPointMake(0, 500)];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    
    [self setUpSegmentedControl];
    
    [self setUpLeftView];
    
    [self setUpFloorListTable];
    
    _panListModel = [[FHFloorPanListViewModel alloc] initWithController:self tableView:self.floorListTable houseType:0 andLeftScrollView:self.leftFilterView andItems:_floorList];
    // Do any additional setup after loading the view.
}

- (void)setUpSegmentedControl
{
    _segmentedControl = [HMSegmentedControl new];
    _segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 15, 0, 15);
    _segmentedControl.sectionTitles = @[@"全部(0)",@"3室(0)",@"4室(0)",@"5室(0)"];
    _segmentedControl.selectionIndicatorHeight = 1;
    _segmentedControl.selectionIndicatorColor = [UIColor colorWithHexString:@"#299cff"];
    _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    _segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    _segmentedControl.isNeedNetworkCheck = YES;
    //    _segmentedControl.selec
    NSDictionary *attributeNormal = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont themeFontRegular:16],NSFontAttributeName,
                                     [UIColor colorWithHexString:@"#8a9299"],NSForegroundColorAttributeName,nil];
    
    NSDictionary *attributeSelect = [NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIFont themeFontMedium:16],NSFontAttributeName,
                                     [UIColor colorWithHexString:@"#299cff"],NSForegroundColorAttributeName,nil];
    _segmentedControl.titleTextAttributes = attributeNormal;
    _segmentedControl.selectedTitleTextAttributes = attributeSelect;
    _segmentedControl.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    WeakSelf;
    _segmentedControl.indexChangeBlock = ^(NSInteger index) {
     StrongSelf;
        
    };
    [self.view addSubview:_segmentedControl];
    
    [_segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo([self getNaviBar].mas_bottom);
        make.left.right.equalTo(self.view);
        make.width.mas_equalTo(MAIN_SCREEN_WIDTH);
        make.height.mas_equalTo(40);
    }];
}

- (void)setUpLeftView
{
    _leftView = [UIView new];
    _leftView.backgroundColor = [UIColor colorWithHexString:@"#f4f5f6"];
    [self.view addSubview:_leftView];
    
    [_leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(80);
        make.left.equalTo(self.view);
        make.top.equalTo(self.segmentedControl.mas_bottom);
        make.bottom.equalTo([self getBottomBar].mas_top);
    }];
    
    _leftFilterView = [UIScrollView new];
    _leftFilterView.backgroundColor = [UIColor colorWithHexString:@"#f4f5f6"];
    [_leftView addSubview:_leftFilterView];
    
    [_leftFilterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.leftView);
    }];
}

- (void)setUpFloorListTable
{
    _floorListTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
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
        make.left.equalTo(self.leftView.mas_right);
        make.top.equalTo(self.segmentedControl.mas_bottom);
        make.bottom.equalTo([self getBottomBar].mas_top);
    }];
    
    [_floorListTable setBackgroundColor:[UIColor whiteColor]];
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
