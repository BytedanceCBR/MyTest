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
#import "FHUGCConfig.h"
#import "FHUGCFollowListCell.h"

@interface FHUGCFollowListController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, assign)   FHUGCFollowVCType       vcType;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong)   NSMutableArray       *items;
@property (nonatomic, weak)     id<FHUGCFollowListDelegate>   ugc_delegate;

@end

@implementation FHUGCFollowListController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        // 我关注的小区列表 默认
        self.vcType = FHUGCFollowVCTypeList;
        // 根据action_type区分页面
        if (paramObj.allParams[@"action_type"]) {
            NSInteger action_type = [[paramObj.allParams objectForKey:@"action_type"] integerValue];
            self.vcType = (FHUGCFollowVCType)action_type;
        }
        NSHashTable<FHUGCFollowListDelegate> *ugc_delegate = paramObj.allParams[@"ugc_delegate"];
        self.ugc_delegate = ugc_delegate.anyObject;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.items = [NSMutableArray new];
    [self setupUI];
    [self setupData];
    [self startLoadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadFollowDataFinished:) name:kFHUGCLoadFollowDataFinishedNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.items.count > 0) {
        [self.tableView reloadData];
    }
}

- (void)loadFollowDataFinished:(NSNotification *)noti {
    [self setupData];
}

- (void)setupData {
    // title
    if (self.vcType == FHUGCFollowVCTypeList) {
        // self.title = @"我关注的小区";
    } else if (self.vcType == FHUGCFollowVCTypeSelectList)  {
        // self.title = @"选择小区";
    }
    [self.items removeAllObjects];
    // 是否有数据
    if ([FHUGCConfig sharedInstance].followData && [FHUGCConfig sharedInstance].followData.data.userFollowSocialGroups.count > 0) {
        // 有数据
        [self.items addObjectsFromArray:[FHUGCConfig sharedInstance].followData.data.userFollowSocialGroups];
        [self.emptyView hideEmptyView];
        [self.tableView reloadData];
    } else {
        // 暂时没有数据
        [self.emptyView showEmptyWithTip:@"你还没有关注任何小区" errorImageName:kFHErrorMaskNetWorkErrorImageName showRetry:YES];
        [self.emptyView.retryButton setTitle:@"关注小区" forState:UIControlStateNormal];
    }
}

- (void)setupUI {
    [self setupDefaultNavBar:YES];
    
    CGFloat height = [FHFakeInputNavbar perferredHeight];
    
    [self configTableView];
    [self.view addSubview:_tableView];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [_tableView registerClass:[FHUGCFollowListCell class] forCellReuseIdentifier:@"FHUGCFollowListCell"];
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
    _tableView.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _tableView.estimatedRowHeight = 70;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    if ([TTDeviceHelper isIPhoneXDevice]) {
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    }
}

- (void)startLoadData {
    
}

- (void)retryLoadData {
    // 关注小区 按钮点击
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_my_interest"];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FHUGCFollowListCell *cell = (FHUGCFollowListCell *)[tableView dequeueReusableCellWithIdentifier:@"FHUGCFollowListCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger row = indexPath.row;
    if (row >= 0 && row < self.items.count) {
        id data = self.items[row];
        [cell refreshWithData:data];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
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
    NSInteger row = indexPath.row;
    if (row >= 0 && row < self.items.count) {
        FHUGCScialGroupDataModel* data = self.items[row];
        if (self.vcType == FHUGCFollowVCTypeList) {
            // 我关注的小区
            FHUGCScialGroupDataModel *data = self.items[row];
            NSMutableDictionary *dict = @{}.mutableCopy;
            dict[@"community_id"] = data.socialGroupId;
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
            // 跳转到圈子详情页
            NSURL *openUrl = [NSURL URLWithString:@"sslocal://ugc_community_detail"];
            [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
        } else if (self.vcType == FHUGCFollowVCTypeSelectList)  {
            // 选择小区
            if (self.ugc_delegate) {
                [self.ugc_delegate selectedItem:data];
                [self dismissSelf];
            }
        }
    }
}

// pop
- (void)dismissSelf
{
    if (self.navigationController.viewControllers.count>1) {
        NSArray *viewControllers = self.navigationController.viewControllers;
        if (viewControllers && viewControllers.count > 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

@end
