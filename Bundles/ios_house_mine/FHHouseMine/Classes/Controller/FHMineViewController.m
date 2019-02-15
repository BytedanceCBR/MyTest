//
//  FHMineViewController.m
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/2/12.
//

#import "FHMineViewController.h"
#import <Masonry/Masonry.h>
#import "TTNavigationController.h"
#import "TTRoute.h"
#import "FHMineViewModel.h"
#import "FHEnvContext.h"
#import "TTAccountManager.h"

@interface FHMineViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) FHMineViewModel *viewModel;
@property (nonatomic , strong) NSDate *enterDate;

@end

@implementation FHMineViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        self.tracerModel = [[FHTracerModel alloc] init];
//        self.tracerModel.originFrom = UT_OF_MINE;
//        self.tracerModel.enterFrom = UT_OF_MINE;
//        self.tracerModel.categoryName = [self categoryName];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNavbar];
    [self initView];
    [self initConstraints];
    [self initViewModel];
    [self setupHeaderView];
}

//- (NSString *)categoryName {
//    return UT_OF_MINE;//@"user_profile";
//}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.viewModel requestData];
    [self.viewModel updateHeaderView];
}

- (void)initNavbar
{
    self.ttHideNavigationBar = YES;
}

- (void)initView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    if (@available(iOS 11.0, *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
}

- (void)initConstraints
{
    CGFloat bottom = 49;
    CGFloat top = 20;
    if (@available(iOS 11.0 , *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
        top = [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].top;
    }
    
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(top);
        make.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-bottom);
    }];
}

- (void)initViewModel
{
    self.viewModel = [[FHMineViewModel alloc] initWithTableView:_tableView controller:self];
}

- (void)setupHeaderView
{
    FHMineHeaderView *headerView = [[FHMineHeaderView alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 136)];
    headerView.userInteractionEnabled = YES;
    _tableView.tableHeaderView = headerView;
    self.headerView = headerView;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInfo)];
    [headerView addGestureRecognizer:gesture];
}

-(void)showInfo
{
    [self.viewModel showInfo];
}

//-(void)enterTab:(FHTabEnterType)tab
//{
    /*
     "1. event_type：house_app2b
     2. tab_name：tab名称：{客户：customer，消息：message，我的：mine，房源：house}
     3. enter_type：进入tab方式：{点击tab：'click_tab，默认：default
     4. with_tips：(是否有红点：是，否)[1，0]"
     */
//    NSString *enterType = tab == FHTabEnterTypeClick?@"click_tab":@"default";
//    self.tracerModel.enterType = enterType;
//    NSMutableDictionary *dict = [NSMutableDictionary new];//[self.tracerModel logDict];
//    dict[@"with_tips"] = @"0";
//    dict[@"tab_name"] = @"mine";
//    dict[UT_ENTER_TYPE] = enterType;
//    TRACK_EVENT(@"enter_tab", dict);
//
//    self.enterDate = [NSDate date];
//}

//-(void)leaveTab
//{
//    NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:self.enterDate];
//    if (duration <= 0 || duration >= 24*60*60) {
//        return;
//    }
//
//    NSMutableDictionary *dict = [NSMutableDictionary new];//[self.tracerModel logDict];
//    dict[@"stay_time"] = [NSString stringWithFormat:@"%.0f",(duration*1000)];
//    dict[UT_ENTER_TYPE]  = self.tracerModel.enterType;
//    dict[@"with_tips"] = @"0";
//    dict[@"tab_name"] = @"mine";
//    TRACK_EVENT(@"stay_tab", dict);
//}

@end
