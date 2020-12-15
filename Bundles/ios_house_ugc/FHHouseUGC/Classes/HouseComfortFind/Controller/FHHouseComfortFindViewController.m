//
//  FHHouseComfortFindViewController.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/11/22.
//

#import "FHHouseComfortFindViewController.h"
#import "UIViewAdditions.h"
#import "FHCommonDefines.h"
#import "FHEnvContext.h"
#import "FHUserTracker.h"

@interface FHHouseComfortFindViewController ()
@property(nonatomic,strong) FHHouseComfortFindHeaderView *headerView;
@property(nonatomic,assign) NSTimeInterval lastRequestTime;
@property(nonatomic,assign) BOOL isOpenByPush;
@end

@implementation FHHouseComfortFindViewController

-(instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if(self = [super initWithRouteParamObj:paramObj]) {
        NSDictionary *params = paramObj.allParams;
        if(params[@"origin_from"]){
            self.tracerDict[@"origin_from"] = params[@"origin_from"];
        }
        if(params[@"element_from"]){
            self.tracerDict[@"element_from"] = params[@"element_from"];
        }
        _isOpenByPush = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initView];
    self.lastRequestTime = [[NSDate date] timeIntervalSince1970];
}

- (void)viewWillAppear {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970] - self.lastRequestTime;
    
    //间隔6小时再次进入页面会主动刷新
    if(currentTime > 21600){
        [self.feedVC startLoadData];
        self.lastRequestTime = [[NSDate date] timeIntervalSince1970];
    }
    
    [self.feedVC viewWillAppear];
}

- (void)viewWillDisappear {
    [self.feedVC viewWillDisappear];
}

- (void)initView {
    self.view.backgroundColor = [UIColor whiteColor];
    self.feedVC =[[FHCommunityFeedListController alloc] init];
    self.feedVC.listType = FHCommunityFeedListTypeCustom;
    self.feedVC.category = @"f_house_finder";
    self.feedVC.needReportEnterCategory = YES;
    
    self.headerView = [[FHHouseComfortFindHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, comfortFindHeaderViewHeight)];
    WeakSelf;
    self.feedVC.requestSuccess = ^(BOOL hasFeedData) {
        StrongSelf;
        [self updateHeaderView];
    };
    
    self.feedVC.tracerDict = [self.tracerDict mutableCopy];
    self.headerView.tracerDict = [self.tracerDict mutableCopy];
    
    if(self.isOpenByPush) {
        [self setupDefaultNavBar:NO];
        self.customNavBarView.title.text = @"好房推荐";
        self.feedVC.tableViewNeedPullDown = NO;

        CGFloat navBarHeight = [self navBarHeight];
        CGRect frame = self.view.bounds;
        frame.size.height = frame.size.height - navBarHeight;
        frame.origin.y = navBarHeight;
        self.feedVC.view.frame = frame;
    } else {
        self.feedVC.view.frame = self.view.bounds;
    }
    
    [self addChildViewController:self.feedVC];
    [self.view addSubview:self.feedVC.view];
    [self.feedVC viewWillAppear];
}

-(void)updateHeaderView {
    [self.headerView loadItemViews];
    if(self.headerView.itemsCount) {
        if(self.feedVC.tableHeaderView != self.headerView) {
            self.feedVC.tableHeaderView = self.headerView;
        }
    } else {
        self.feedVC.tableHeaderView = nil;
    }
}

-(CGFloat)navBarHeight {
    if (@available(iOS 13.0 , *)) {
        CGFloat topInset = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
        return 44.f + topInset;
    } else if (@available(iOS 11.0 , *)) {
        return 44.f + self.view.tt_safeAreaInsets.top;
    } else {
        return 65.f;
    }
}

- (void)setTracerDict:(NSMutableDictionary *)tracerDict {
    [super setTracerDict:tracerDict];
    _feedVC.tracerDict = [tracerDict mutableCopy];
    _headerView.tracerDict = [tracerDict mutableCopy];
}


@end
