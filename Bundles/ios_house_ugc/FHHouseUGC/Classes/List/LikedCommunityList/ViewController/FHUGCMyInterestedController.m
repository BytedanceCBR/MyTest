//
//  FHUGCMyInterestedController.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/13.
//

#import "FHUGCMyInterestedController.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "FHUGCMyInterestedViewModel.h"
#import "TTReachability.h"
#import "TTAccount+Multicast.h"
#import "FHEnvContext.h"
#import "UIViewController+Track.h"
#import "FHUserTracker.h"
#import <FHHouseBase/FHBaseTableView.h>
#import "FHUGCSearchView.h"
#import <FHUGCConfig.h>
#import "YYLabel.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "NSAttributedString+YYText.h"

@interface FHUGCMyInterestedController ()<TTRouteInitializeProtocol,UIViewControllerErrorHandler>

@property (nonatomic , strong) FHUGCMyInterestedViewModel *viewModel;
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , assign) NSTimeInterval lastRequestTime;
@property (nonatomic , strong) FHUGCSearchView *searchView;
@property (nonatomic , strong) UILabel *guessYouLikeLabel;
@property (nonatomic , strong) UIView *refreshTipView;
@end

@implementation FHUGCMyInterestedController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.title = @"你可能感兴趣的圈子";
        self.forbidGoToDetail = [paramObj.allParams[@"forbidGoToDetail"] boolValue];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.ttTrackStayEnable = YES;
    if(self.type == FHUGCMyInterestedTypeMore){
        [self initNavbar];
        [self addEnterCategoryLog];
    }
    [self initView];
    [self initConstraints];
    [self initViewModel];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if(self.type == FHUGCMyInterestedTypeMore){
        [self addStayCategoryLog:self.ttTrackStayTime];
        [self tt_resetStayTime];
    }
}

- (void)viewWillAppear {
    [self.viewModel viewWillAppear];
}

- (void)viewWillDisappear {
    [self.viewModel viewWillDisappear];
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = self.title;
}

- (void)initView {
    _tableView = [[FHBaseTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.backgroundColor = [UIColor themeGray7];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    if(self.type == FHUGCMyInterestedTypeEmpty){
        headerView = [self emptyHeaderViewDiscovery];
    }
    _tableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
    _tableView.tableFooterView = footerView;
    
    _tableView.sectionFooterHeight = 0.0;
    
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
        
    [self.view addSubview:_tableView];
    
    [self addDefaultEmptyViewWithEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    if(self.type == FHUGCMyInterestedTypeEmpty){
        
        _tableView.estimatedRowHeight = 192;
        
        [self.emptyView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
    }else{
        _tableView.estimatedRowHeight = 70;
    }
}

- (UIView *)emptyHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 36)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, [UIScreen mainScreen].bounds.size.width, 21)];
    label.font = [UIFont themeFontRegular:15];
    label.textColor = [UIColor themeGray1];
    label.text = @"猜你喜欢";
    [headerView addSubview:label];
    
    return headerView;
}

- (UIView *)emptyHeaderViewDiscovery {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 36 + 49)];
    
    FHUGCSearchView *searchView = [[FHUGCSearchView alloc] initWithFrame:CGRectMake(20, 15, [UIScreen mainScreen].bounds.size.width - 40, 34)];
    
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    [tracerDict addEntriesFromDictionary:self.tracerDict];
    tracerDict[@"page_type"] = @"my_join_feed";
    tracerDict[@"enter_from"] = self.tracerDict[@"enter_from"] ?: @"be_null";
    tracerDict[@"origin_from"] = self.tracerDict[@"origin_from"] ?: @"be_null";
    searchView.tracerDict = tracerDict;
    [headerView addSubview:searchView];
    
    self.guessYouLikeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 15 + 49, [UIScreen mainScreen].bounds.size.width, 21)];
    self.guessYouLikeLabel.font = [UIFont themeFontRegular:15];
    self.guessYouLikeLabel.textColor = [UIColor themeGray1];
    self.guessYouLikeLabel.text = @"猜你喜欢";
    [headerView addSubview:self.guessYouLikeLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFollowStatus) name:kFHUGCUpdateFollowDataAfterAccountStatuschangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRefreshTip) name:kFHUGCLoadFollowDataFinishedNotification object:nil];
    return headerView;
}

-(void)updateFollowStatus {
    [self.viewModel updateDataListFollowStatus];
}

- (void)showRefreshTip {
    BOOL needRefresh = [FHUGCConfig sharedInstance].followList.count > 0;
    if(self.refreshTipView.hidden == !needRefresh) {
        return;
    }
    
    UIView *headerView = self.tableView.tableHeaderView;
    self.tableView.tableHeaderView = nil;
    
    if(needRefresh) {
        CGRect frame = headerView.frame;
        frame.size.height = 120;
        headerView.frame = frame;
        
        frame = self.guessYouLikeLabel.frame;
        frame.origin.y = 99;
        self.guessYouLikeLabel.frame = frame;
        
        self.refreshTipView.hidden = NO;
        [headerView addSubview:self.refreshTipView];
        [self.refreshTipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(headerView).offset(64);
            make.left.equalTo(headerView).offset(15);
            make.right.equalTo(headerView).offset(-15);
            make.height.mas_equalTo(20);
        }];
    }else{
        self.refreshTipView.hidden = YES;
        [self.refreshTipView removeFromSuperview];
        
        CGRect frame = headerView.frame;
        frame.size.height = 85;
        headerView.frame = frame;
        
        frame = self.guessYouLikeLabel.frame;
        frame.origin.y = 64;
        self.guessYouLikeLabel.frame = frame;
        
    }

    self.tableView.tableHeaderView = headerView;
}

-(UIView *)refreshTipView {
    if(!_refreshTipView){
        NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:@"你关注的圈子有内容更新，点击刷新查看"];
        NSDictionary *commonTextStyle = @{ NSFontAttributeName:[UIFont themeFontRegular:14],NSForegroundColorAttributeName:[UIColor themeGray3]};
        [attrText addAttributes:commonTextStyle range:NSMakeRange(0, attrText.length)];
        [attrText yy_setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, attrText.length)];
        NSRange tapRange = [attrText.string rangeOfString:@"点击刷新查看"];
        [attrText yy_setTextHighlightRange:tapRange color:[UIColor themeOrange1] backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kFHMyJoinVCReloadVCNotification object:nil];
        }];
        YYLabel *refreshTipLabel = [[YYLabel alloc] init];
        refreshTipLabel.attributedText = attrText;
        
        UIView *leftLine = [[UIView alloc] init];
        leftLine.backgroundColor = [UIColor themeGray6];
        UIView *rightLine = [[UIView alloc] init];
        rightLine.backgroundColor = [UIColor themeGray6];
        UIView *refreshTipView = [[UIView alloc] init];
        refreshTipView.hidden = YES;
        
        [refreshTipView addSubview:refreshTipLabel];
        [refreshTipView addSubview:leftLine];
        [refreshTipView addSubview:rightLine];
        
        [refreshTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(refreshTipView);
            make.centerX.equalTo(refreshTipView);
            make.width.mas_equalTo(252);
        }];
        [leftLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(refreshTipView);
            make.left.equalTo(refreshTipView);
            make.right.equalTo(refreshTipLabel.mas_left).offset(-20);
            make.height.mas_equalTo(1);
        }];
        [rightLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(refreshTipView);
            make.right.equalTo(refreshTipView);
            make.left.equalTo(refreshTipLabel.mas_right).offset(20);
            make.height.mas_equalTo(1);
        }];
        _refreshTipView = refreshTipView;
    }
    return _refreshTipView;
}

- (void)initConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if(self.type == FHUGCMyInterestedTypeMore){
            if (@available(iOS 11.0, *)) {
                make.top.mas_equalTo(self.mas_topLayoutGuide).offset(44);
            } else {
                make.top.mas_equalTo(64);
            }
        }else{
            make.top.mas_equalTo(self.view);
        }
        make.left.right.bottom.mas_equalTo(self.view);
    }];
}

- (void)initViewModel {
    self.viewModel = [[FHUGCMyInterestedViewModel alloc] initWithTableView:self.tableView controller:self];
    //切换开关
    WeakSelf;
    [[FHEnvContext sharedInstance].configDataReplay subscribeNext:^(id  _Nullable x) {
        StrongSelf;
        [self startLoadData];
    }];
}

- (void)startLoadData {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970] - self.lastRequestTime;
    if ([TTReachability isNetworkConnected]) {
        if(currentTime > 2){
            [_viewModel requestData:YES];
        }
    } else {
        if(!self.hasValidateData){
            [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        }
    }
}

- (void)retryLoadData {
    [self startLoadData];
}

- (void)addEnterCategoryLog {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    
    tracerDict[@"enter_type"] = @"click";
    tracerDict[@"element_from"] = @"like_neighborhood";
    tracerDict[@"category_name"] = [self categoryName];
    TRACK_EVENT(@"enter_category", tracerDict);
}

- (void)addStayCategoryLog:(NSTimeInterval)stayTime {
    NSTimeInterval duration = stayTime * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"enter_type"] = @"click";
    tracerDict[@"element_from"] = @"like_neighborhood";
    tracerDict[@"category_name"] = [self categoryName];
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    TRACK_EVENT(@"stay_category", tracerDict);
}

- (NSString *)categoryName {
    return @"like_neighborhood_list";
}

#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData {
    return _viewModel.dataList.count == 0 ? NO : YES; //默认会显示空
}

#pragma mark - TTAccountMulticaastProtocol
// 帐号切换
- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    [self startLoadData];
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    if(self.type == FHUGCMyInterestedTypeMore){
        [self addStayCategoryLog:self.ttTrackStayTime];
        [self tt_resetStayTime];
    }
}

- (void)trackStartedByAppWillEnterForground {
    if(self.type == FHUGCMyInterestedTypeMore){
        self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
    }
}


@end
