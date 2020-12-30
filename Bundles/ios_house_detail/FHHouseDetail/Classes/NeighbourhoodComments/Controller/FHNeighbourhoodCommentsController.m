//
//  FHNeighbourhoodCommentsController.m
//  FHHouseDetail
//
//  Created by 王志舟 on 2020/2/23.
//

#import "FHNeighbourhoodCommentsController.h"
#import "UIColor+Theme.h"
#import "FHCommunityFeedListBaseViewModel.h"
#import "FHNeighbourhoodCommentsViewModel.h"
#import "TTReachability.h"
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"
#import "TTRoute.h"
#import "TTAccountManager.h"
#import "TTAccount+Multicast.h"
#import "FHEnvContext.h"
#import "FHUserTracker.h"
#import "UIScrollView+Refresh.h"
#import "FHFeedOperationView.h"
#import <FHHouseBase/FHBaseTableView.h>
#import "FHUGCConfig.h"
#import "ToastManager.h"
#import "FHUGCPostMenuView.h"
#import "FHCommonDefines.h"
#import "FHUserTracker.h"
#import "UIViewController+Track.h"

@interface FHNeighbourhoodCommentsController ()<SSImpressionProtocol, FHUGCPostMenuViewDelegate>

@property(nonatomic, strong) FHCommunityFeedListBaseViewModel *viewModel;
@property(nonatomic, copy) void(^notifyCompletionBlock)(void);
@property(nonatomic, assign) NSInteger currentCityId;
@property(nonatomic, strong) FHUGCPostMenuView *publishMenuView;
@property(nonatomic, strong) UIView *bottomView;
@property(nonatomic, strong) UIButton *bottomBtn;

@end

@implementation FHNeighbourhoodCommentsController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        
        _tableViewNeedPullDown = NO;
        _showErrorView = YES;
        
        NSDictionary *params = paramObj.allParams;
        self.title = [params objectForKey:@"title"];
        
        // 埋点
        self.tracerDict[@"page_type"] = @"neighborhood_comment_list";
        // 取链接中的埋点数据
        NSString *enterFrom = params[@"tracer"][@"enter_from"];
        if (enterFrom.length > 0) {
            self.tracerDict[@"enter_from"] = enterFrom;
        }
        NSString *elementFrom = params[@"tracer"][@"element_from"];
        if (elementFrom.length > 0) {
            self.tracerDict[@"element_from"] = elementFrom;
        }
        NSString *originFrom = params[@"tracer"][@"origin_from"];
        if (originFrom.length > 0) {
            self.tracerDict[@"origin_from"] = originFrom;
        }
        
        NSDictionary *logPb = params[@"tracer"][@"log_pb"];
        if (logPb) {
            self.tracerDict[@"log_pb"] = logPb;
        }
        
        self.neighborhoodId = params[@"neighborhood_id"];
        
        self.ttTrackStayEnable = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initNavbar];
    [self initView];
    [self initConstraints];
    [self initViewModel];
    [self startLoadData];
    [self addGoDetailLog];
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = self.title ?: @"小区点评";
}

- (void)initView {
    [self initTableView];
    [self initBottomView];
    [self addDefaultEmptyViewFullScreen];
}

- (void)initTableView {
    self.tableView = [[FHBaseTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor themeGray7];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CGFLOAT_MIN)];
    _tableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CGFLOAT_MIN)];
    _tableView.tableFooterView = footerView;
    
    _tableView.sectionFooterHeight = 0.0;
    
    _tableView.estimatedRowHeight = 0;
    
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
    }
    
    [self.view addSubview:_tableView];
}

- (void)setTableHeaderView:(UIView *)tableHeaderView {
    _tableHeaderView = tableHeaderView;
    if(self.tableView){
        self.tableView.tableHeaderView = tableHeaderView;
    }
}


- (void)initBottomView {
    self.bottomView = [[UIView alloc] init];
    _bottomView.backgroundColor = [UIColor themeGray7];
    [self.view addSubview:_bottomView];
    
    self.bottomBtn = [[UIButton alloc] init];
    _bottomBtn.backgroundColor = [UIColor themeOrange4];
    [_bottomBtn setTitle:@"写点评" forState:UIControlStateNormal];
    [_bottomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _bottomBtn.titleLabel.font = [UIFont themeFontSemibold:16];
    _bottomBtn.layer.cornerRadius = 22; //4;
    [_bottomBtn addTarget:self action:@selector(gotoCommentPublish) forControlEvents:UIControlEventTouchUpInside];
//    house_detail_write_comment
    _bottomBtn.layer.shadowColor = [UIColor colorWithHexStr:@"#ff9629"].CGColor;
    _bottomBtn.layer.shadowOffset = CGSizeMake(0, 8);
    _bottomBtn.layer.shadowOpacity = .2 ;
    _bottomBtn.layer.shadowRadius = 6;
    _bottomBtn.imageView.contentMode = UIViewContentModeCenter;
    [_bottomBtn setImage:[UIImage imageNamed:@"house_detail_write_comment"] forState:UIControlStateNormal];
    [_bottomBtn setImage:[UIImage imageNamed:@"house_detail_write_comment"] forState:UIControlStateHighlighted];
    [_bottomBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
    [_bottomBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
    [self.bottomView addSubview:_bottomBtn];
}

- (void)initConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.mas_equalTo(self.mas_topLayoutGuide).offset(44);
        } else {
            make.top.mas_equalTo(64);
        }
        make.left.right.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.bottomView.mas_top);
    }];
    
    CGFloat bottom = 64;
    if (@available(iOS 11.0 , *)) {
        bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
    }
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.height.mas_equalTo(bottom);
    }];
    
    [self.bottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomView).offset(10);
        make.left.mas_equalTo(self).offset(20);
        make.right.mas_equalTo(self).offset(-20);
        make.height.mas_equalTo(44);
    }];
}

- (void)initViewModel {
    self.viewModel = [[FHNeighbourhoodCommentsViewModel alloc] initWithTableView:_tableView controller:self];
    self.needReloadData = YES;
    _viewModel.categoryId = @"f_neigh_review";
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [_viewModel requestData:YES first:YES];
    } else {
        if(!self.hasValidateData){
            [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        }
    }
}

- (void)startLoadData:(BOOL)isFirst {
    if ([TTReachability isNetworkConnected]) {
        [_viewModel requestData:YES first:isFirst];
    } else {
        if(!self.hasValidateData){
            [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        }
    }
}

- (void)retryLoadData {
    [self startLoadData];
}

- (void)hideIfNeeds {
    [UIView animateWithDuration:0.3 animations:^{
        
        if ([TTDeviceHelper isIPhoneXSeries]) {
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
        }else{
            self.tableView.contentInset = UIEdgeInsetsZero;
        }
        self.tableView.originContentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
        
    }completion:^(BOOL finished) {
        if (self.notifyCompletionBlock) {
            
            
            
            
            self.notifyCompletionBlock();
        }
    }];
}

- (void)gotoCommentPublish {

    if ([TTAccountManager isLogin]) {
        [self gotoCommentVC];
    } else {
        [self gotoLogin];
    }
}

- (void)gotoCommentVC {
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:@"sslocal://ugc_post"];
    NSMutableDictionary *dict = @{}.mutableCopy;
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[UT_ENTER_FROM] = self.tracerDict[@"page_type"];
    tracerDict[UT_LOG_PB] = self.tracerDict[@"log_pb"] ?: @"be_null";
    dict[TRACER_KEY] = tracerDict;
    dict[@"neighborhood_id"] = self.neighborhoodId;
    dict[@"post_content_hint"] = @"说说你对该小区的评价，小区物业、配套、停车、周边学校、邻居关系等方面都可以~最少要写10个字以上哦";
    dict[@"title"] = @"发布点评";
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByPresentViewController:components.URL userInfo:userInfo];
}

- (void)gotoLogin {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *page_type = self.tracerDict[@"page_type"] ?: @"be_null";
    [params setObject:page_type forKey:@"enter_from"];
    [params setObject:@"click_publisher" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];
    params[@"from_ugc"] = @(YES);
    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [wSelf gotoCommentVC];
                });
            }
        }
    }];
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self addStayPageLog];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

#pragma mark - Tracer

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self addStayPageLog];
}

#pragma mark - 埋点

- (void)addGoDetailLog {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"group_id"] = self.neighborhoodId;
    TRACK_EVENT(@"go_detail", tracerDict);
}

- (void)addStayPageLog {
    NSTimeInterval duration = self.ttTrackStayTime * 1000.0;
    if (duration == 0) {
        return;
    }
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"group_id"] = self.neighborhoodId;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    TRACK_EVENT(@"stay_page", tracerDict);
    
    [self tt_resetStayTime];
}

@end
