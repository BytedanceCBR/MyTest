//
//  FHUGCVideoListController.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/8/9.
//

#import "FHUGCVideoListController.h"
#import "UIColor+Theme.h"
#import "FHUGCVideoListViewModel.h"
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"
#import "TTRoute.h"
#import "FHEnvContext.h"
#import "FHUserTracker.h"
#import <FHHouseBase/FHBaseTableView.h>
#import "ToastManager.h"
#import "FHUGCCellHelper.h"

@interface FHUGCVideoListController ()<SSImpressionProtocol>

@property(nonatomic, strong) FHUGCVideoListViewModel *viewModel;
@property(nonatomic, assign) NSTimeInterval enterTabTimestamp;
@property(nonatomic, assign) BOOL noNeedAddEnterCategorylog;

@end

@implementation FHUGCVideoListController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if(self){
        self.currentVideo = [FHFeedUGCCellModel modelFromFeed:paramObj.allParams[@"currentVideo"]];
        self.currentVideo.cellSubType = FHUGCFeedListCellSubTypeFullVideo;
        self.currentVideo.isVideoJumpDetail = YES;
        self.currentVideo.numberOfLines = 2;
        [FHUGCCellHelper setRichContentWithModel:self.currentVideo width:([UIScreen mainScreen].bounds.size.width - 40) numberOfLines:self.currentVideo.numberOfLines];
        
        self.category = @"f_house_video_flow";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self initNavbar];
    [self initView];
    [self initViewModel];
    
    [[SSImpressionManager shareInstance] addRegist:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)initNavbar {
    [self setupDefaultNavBar:NO];
    self.customNavBarView.seperatorLine.hidden = YES;
}

- (void)setTracerDict:(NSMutableDictionary *)tracerDict {
    [super setTracerDict:tracerDict];
    if(self.dataList.count > 0){
        for (FHFeedUGCCellModel *cellModel in self.dataList) {
            NSMutableDictionary *tracerDic = [cellModel.tracerDic mutableCopy];
            if(tracerDict[@"origin_from"]){
                tracerDic[@"origin_from"] = tracerDict[@"origin_from"];
            }
            cellModel.tracerDic = tracerDic;
        }
    }
}

- (void)dealloc {
    [[SSImpressionManager shareInstance] removeRegist:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.viewModel viewWillAppear];

    if ([[NSDate date]timeIntervalSince1970] - _enterTabTimestamp > 24*60*60) {
        //超过一天
        _enterTabTimestamp = [[NSDate date]timeIntervalSince1970];
    }

//    if(!self.noNeedAddEnterCategorylog){
//        if(self.needReportEnterCategory){
//            [self addEnterCategoryLog];
//        }
//    }else{
//        self.noNeedAddEnterCategorylog = NO;
//    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [self.viewModel autoPlayCurrentVideo];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.viewModel viewWillDisappear];
    if(self.needReportEnterCategory){
        [self addStayCategoryLog];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [self.viewModel stopCurrentVideo];
}

- (void)initView {
    [self.view layoutIfNeeded];
    [self initTableView];
}

- (void)initTableView {
    if(!_tableView){
        self.tableView = [[FHBaseTableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.customNavBarView.frame), [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - CGRectGetMaxY(self.customNavBarView.frame)) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
        _tableView.tableHeaderView = headerView;
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
        _tableView.tableFooterView = footerView;
        
        _tableView.sectionFooterHeight = 0.0;
        
        _tableView.estimatedRowHeight = 0;
        
        if (@available(iOS 11.0 , *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            _tableView.estimatedRowHeight = 0;
            _tableView.estimatedSectionFooterHeight = 0;
            _tableView.estimatedSectionHeaderHeight = 0;
        }
        
        if ([TTDeviceHelper isIPhoneXSeries]) {
            _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
        }
        
        [self.view addSubview:_tableView];
    }
}

- (void)setErrorViewTopOffset:(CGFloat)errorViewTopOffset {
    _errorViewTopOffset = errorViewTopOffset;
    
    [self.emptyView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(errorViewTopOffset);
    }];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.customNavBarView.frame), [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - CGRectGetMaxY(self.customNavBarView.frame));
}

- (void)initViewModel {
    FHUGCVideoListViewModel *viewModel = [[FHUGCVideoListViewModel alloc] initWithTableView:_tableView controller:self];
    viewModel.categoryId = self.category;
    self.viewModel = viewModel;
    
    if(self.currentVideo){
        [self.viewModel.dataList addObject:self.currentVideo];
        [self.tableView reloadData];
        [self.viewModel readyCurrentVideo];
        self.tableView.mj_footer.hidden = NO;
        self.tableView.mj_footer.state = MJRefreshStateRefreshing;
    }
        
//    [self startLoadData];
}

- (void)startLoadData {
    [_viewModel requestData:YES first:YES];
}

- (void)retryLoadData {
    [self startLoadData];
}

- (NSArray *)dataList {
    return self.viewModel.dataList;
}

- (void)applicationDidEnterBackground {
    if(self.needReportEnterCategory){
        [self addStayCategoryLog];
    }
}

- (void)applicationDidBecomeActive {
    self.enterTabTimestamp = [[NSDate date]timeIntervalSince1970];
}

#pragma mark - SSImpressionProtocol

- (void)needRerecordImpressions {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.viewModel.dataList.count == 0) {
            return;
        }
        
        SSImpressionParams *params = [[SSImpressionParams alloc] init];
        params.refer = self.viewModel.refer;
        
        for (FHUGCBaseCell *cell in [self.tableView visibleCells]) {
            if ([cell isKindOfClass:[FHUGCBaseCell class]]) {
                id data = cell.currentData;
                if ([data isKindOfClass:[FHFeedUGCCellModel class]]) {
                    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
                    if (self.viewModel.isShowing) {
                        [self.viewModel recordGroupWithCellModel:cellModel status:SSImpressionStatusRecording];
                    }
                    else {
                        [self.viewModel recordGroupWithCellModel:cellModel status:SSImpressionStatusSuspend];
                    }
                }
            }
        }
    });
    
}

#pragma mark - 埋点

- (void)addEnterCategoryLog {
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"category_name"] = self.category;
    TRACK_EVENT(@"enter_category", tracerDict);
    
    self.enterTabTimestamp = [[NSDate date] timeIntervalSince1970];
}

- (void)addStayCategoryLog {
    NSTimeInterval duration = [[NSDate date] timeIntervalSince1970] - _enterTabTimestamp;
    if (duration <= 0 || duration >= 24*60*60) {
        return;
    }
    NSMutableDictionary *tracerDict = self.tracerDict.mutableCopy;
    tracerDict[@"category_name"] = self.category;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:(duration * 1000)];
    TRACK_EVENT(@"stay_category", tracerDict);
    
    self.enterTabTimestamp = [[NSDate date]timeIntervalSince1970];
}

@end
