//
//  FHFloorTimeLineViewController.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/17.
//

#import "FHFloorMoreCoreInfoViewController.h"
#import "FHFloorCoreInfoViewModel.h"
#import "FHDetailHouseNameCell.h"
#import "FHDetailDisclaimerCell.h"
#import "FHFloorCoreInfoViewModel.h"
#import <FHHouseBase/FHBaseTableView.h>
#import "FHLynxView.h"
#import "FHLynxManager.h"

@interface FHFloorMoreCoreInfoViewController () <TTRouteInitializeProtocol>

@property (nonatomic , strong) UITableView *infoListTable;
@property (nonatomic , strong) FHFloorCoreInfoViewModel *coreInfoListViewModel;
@property (nonatomic , strong) NSString *courtId;
@property(nonatomic , strong) FHDetailHouseNameModel *houseNameModel;
@property(nonatomic, strong) FHLynxView *lynxView;

@end

@implementation FHFloorMoreCoreInfoViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _courtId = paramObj.allParams[@"court_id"];
        _houseNameModel = paramObj.userInfo.allInfo[@"courtInfo"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[FHLynxManager sharedInstance] checkChannelTemplateIsAvalable:@"lynx_estate_info" templateKey:@"0"]) {
        [self setUpLynxView];
    }else{
        [self setUpinfoListTable];
    }
    
    [self addDefaultEmptyViewFullScreen];
    
    _coreInfoListViewModel = [[FHFloorCoreInfoViewModel alloc] initWithController:self tableView:_infoListTable courtId:_courtId houseNameModel:_houseNameModel];
    _coreInfoListViewModel.lynxView = self.lynxView;
    _coreInfoListViewModel.navBar = [self getNaviBar];
    self.viewModel = self.coreInfoListViewModel; // IM线索使用，不可以删除
    
    [self setNavBarTitle:@"楼盘信息"];
    [self.view bringSubviewToFront:[self getNaviBar]];
}

- (void)retryLoadData
{
    [self.coreInfoListViewModel startLoadData];
}


- (void)setUpinfoListTable
{
    _infoListTable = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _infoListTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0 , *)) {
        _infoListTable.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _infoListTable.estimatedRowHeight = UITableViewAutomaticDimension;
        _infoListTable.estimatedSectionFooterHeight = 0;
        _infoListTable.estimatedSectionHeaderHeight = 0;
    }
    [_infoListTable setBackgroundColor:[UIColor themeGray7]];
    _infoListTable.contentInset = UIEdgeInsetsMake(15, 0, 0, 0);
    [self.view addSubview:_infoListTable];
    
    [_infoListTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo([self getNaviBar].mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo([self getBottomBar].mas_top);
    }];
    
}

- (void)setUpLynxView{
    _lynxView = [[FHLynxView alloc] initWithFrame:CGRectMake(0, [self getNaviBar].frame.size.height, self.view.frame.size.width,self.view.frame.size.height - 80 - [self getNaviBar].frame.size.height - [self.coreInfoListViewModel getSafeTop]  - [self.coreInfoListViewModel getSafeBottom])];
    [self.view addSubview:_lynxView];
    FHLynxViewBaseParams *baesparmas = [[FHLynxViewBaseParams alloc] init];
    baesparmas.channel = @"lynx_estate_info";
    baesparmas.bridgePrivate = self;
    [_lynxView loadLynxWithParams:baesparmas];
    
    _lynxView.hidden = YES;
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
