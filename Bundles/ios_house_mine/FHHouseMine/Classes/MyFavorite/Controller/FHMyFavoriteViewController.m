//
//  FHMyFavoriteViewController.m
//  AFgzipRequestSerializer
//
//  Created by 谢思铭 on 2019/2/14.
//

#import "FHMyFavoriteViewController.h"
#import "FHMyFavoriteViewModel.h"
#import <Masonry.h>
#import "UIViewController+NavbarItem.h"
#import "UIColor+Theme.h"
#import "TTReachability.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import "UIViewController+Track.h"
#import "FHTracerModel.h"
#import "FHUserTracker.h"
#import "FHHouseType.h"

extern NSString *const kFHDetailFollowUpNotification;

@interface FHMyFavoriteViewController ()<UIViewControllerErrorHandler,TTRouteInitializeProtocol>

@property(nonatomic, strong) FHMyFavoriteViewModel *viewModel;
@property(nonatomic, assign) FHHouseType type;

@end

@implementation FHMyFavoriteViewController

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.type = [paramObj.allParams[@"type"] integerValue];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.showenRetryButton = YES;
    self.ttTrackStayEnable = YES;
    
    [self initNavbar];
    [self initView];
    [self initConstraints];
    [self initViewModel];
    [self initNotification];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.tableView setEditing:NO animated:YES];
//    [self addStayCategoryLog:self.ttTrackStayTime];
//    [self tt_resetStayTime];
    
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = [self titleText];
}

- (NSString *)titleText {
    NSString *text = @"我关注的";
    switch (self.type) {
        case FHHouseTypeSecondHandHouse:
            text = [text stringByAppendingString:@"二手房"];
            break;
        case FHHouseTypeRentHouse:
            text = [text stringByAppendingString:@"租房"];
            break;
        case FHHouseTypeNewHouse:
            text = [text stringByAppendingString:@"新房"];
            break;
        case FHHouseTypeNeighborhood:
            text = [text stringByAppendingString:@"小区"];
            break;
            
        default:
            break;
    }
    
    return text;
}

- (void)initView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    if (@available(iOS 11.0, *)) {
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:_tableView];
    [self addDefaultEmptyViewFullScreen];
}

- (void)initConstraints {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        if (@available(iOS 11.0, *)) {
//            make.top.mas_equalTo(self.mas_topLayoutGuide).offset(44);
//        } else {
            make.top.mas_equalTo(self.customNavBarView.mas_bottom);
//        }
        make.left.right.bottom.mas_equalTo(self.view);
    }];
}

- (void)initViewModel {
    _viewModel = [[FHMyFavoriteViewModel alloc] initWithTableView:_tableView controller:self type:self.type];
    [self startLoadData];
}

- (void)initNotification {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshData:) name:kFHDetailFollowUpNotification object:nil];
}

- (void)refreshData:(NSNotification *)notification {
    [self startLoadData];
}

- (void)startLoadData {
    if ([TTReachability isNetworkConnected]) {
        [_viewModel requestData:YES];
    } else {
        if(!self.hasValidateData){
            [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        }
    }
}

- (void)retryLoadData {
    [self startLoadData];
}

-(NSDictionary *)categoryLogDict {
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    tracerDict[@"enter_type"] = @"click_tab";
    tracerDict[@"tab_name"] = @"message";
    tracerDict[@"with_tips"] = @"0";
    
    return tracerDict;
}

-(void)addStayCategoryLog:(NSTimeInterval)stayTime {
    
    NSTimeInterval duration = stayTime * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    TRACK_EVENT(@"stay_tab", tracerDict);
}

#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData {
    return _viewModel.dataList.count == 0 ? NO : YES; //默认会显示空
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self addStayCategoryLog:self.ttTrackStayTime];
    [self tt_resetStayTime];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

@end
