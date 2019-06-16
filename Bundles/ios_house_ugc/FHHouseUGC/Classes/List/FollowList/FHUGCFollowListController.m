//
//  FHUGCFollowListController.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/16.
//

#import "FHUGCFollowListController.h"
#import "TTReachability.h"
#import "UIViewAdditions.h"
#import "FHRefreshCustomFooter.h"
#import "FHUserTracker.h"
#import "FHFakeInputNavbar.h"
#import "FHConditionFilterFactory.h"
#import "SSNavigationBar.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "UIViewController+NavbarItem.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTDeviceHelper.h"
#import "FHUGCFollowManager.h"

@interface FHUGCFollowListController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign)   FHUGCFollowVCType       vcType;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation FHUGCFollowListController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        // 我关注的小区列表 默认
        self.vcType = FHUGCFollowVCTypeList;
        // 根据host区分页面
        if ([paramObj.host isEqualToString:@"ugc_follow_list"]) {
            self.vcType = FHUGCFollowVCTypeList;
        } else if ([paramObj.host isEqualToString:@"ugc_follow_select_list"]) {
            self.vcType = FHUGCFollowVCTypeSelectList;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupUI];
    [self setupData];
    [self startLoadData];
}

- (void)setupData {
    // title
    if (self.vcType == FHUGCFollowVCTypeList) {
        self.title = @"我关注的小区";
    } else if (self.vcType == FHUGCFollowVCTypeSelectList)  {
        self.title = @"选择小区";
    }
    // 是否有数据
    if ([FHUGCFollowManager sharedInstance].followData && [FHUGCFollowManager sharedInstance].followData.data.userFollowSocialGroups.count > 0) {
        // 有数据
        [self.emptyView hideEmptyView];
        [self.tableView reloadData];
    } else {
        // 暂时没有数据
        if (self.vcType == FHUGCFollowVCTypeList) {
            [self.emptyView showEmptyWithTip:@"你还没有关注任何小区" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:NO];
        } else if (self.vcType == FHUGCFollowVCTypeSelectList)  {
            [self.emptyView showEmptyWithTip:@"你还没有关注任何小区" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:YES];
            [self.emptyView.retryButton setTitle:@"关注小区" forState:UIControlStateNormal];
        }
    }
}

- (void)setupUI {
    [self setupDefaultNavBar:YES];
    
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    
    [self configTableView];
    [self.view addSubview:_tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(height);
        make.bottom.mas_equalTo(self.view);
    }];
    [self addDefaultEmptyViewFullScreen];
}

- (void)configTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        // 重新加载数据
        
        // 有数据 隐藏 空页面
    }
}

- (void)retryLoadData {
    // 关注小区 按钮点击
    if (self.vcType == FHUGCFollowVCTypeSelectList) {
        
    }
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 105;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
