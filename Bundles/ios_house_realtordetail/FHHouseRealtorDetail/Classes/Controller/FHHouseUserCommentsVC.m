//
//  FHHouseUserCommentsVC.m
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/17.
//

#import "FHHouseUserCommentsVC.h"
#import "FHHouseUserCommentsVM.h"
#import "FHBaseTableView.h"
#import "UIDevice+BTDAdditions.h"
#import "FHCommonDefines.h"
#import "FHUserTracker.h"
#import "UIViewController+NavigationBarStyle.h"
#import "Masonry.h"
@interface FHHouseUserCommentsVC ()
@property (strong, nonatomic)UITableView *tableView;
@property (strong, nonatomic) FHHouseUserCommentsVM *viewModel;
@end

@implementation FHHouseUserCommentsVC
- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        [self createTracerDic:paramObj.allParams];
//        self.realtorInfoDic = paramObj.allParams.mutableCopy;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    [self createModel];
    [self addDefaultEmptyViewFullScreen];
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"用户评价";
    [self initFrame];
}

- (void)initFrame {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.customNavBarView.mas_bottom);
        make.left.bottom.right.mas_equalTo(self.view);
    }];
    
}

- (void)initTableView {
    _tableView = [[FHBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor = [UIColor colorWithHexStr:@"#f8f8f8"];
    _tableView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0);
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    [self.view addSubview:_tableView];
}

- (void)createModel {
    _viewModel = [[FHHouseUserCommentsVM alloc]initWithController:self tableView:self.tableView];
}

- (void)createTracerDic:(NSDictionary *)dic {
    
}
@end
