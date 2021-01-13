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
#import "FHHouseUGCHeader.h"
#import "UIScrollView+Refresh.h"
#import "FHUGCCellManager.h"
#import <ByteDanceKit/ByteDanceKit.h>

@interface FHUGCVideoListController ()<SSImpressionProtocol>

@property(nonatomic, strong) FHUGCVideoListViewModel *viewModel;
@property(nonatomic, assign) NSTimeInterval enterTabTimestamp;

@end

@implementation FHUGCVideoListController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if(self){
        self.currentVideo = [FHFeedUGCCellModel modelFromFeed:paramObj.allParams[@"currentVideo"]];
        self.currentVideo.cellSubType = FHUGCFeedListCellSubTypeFullVideo;
        self.currentVideo.isVideoJumpDetail = YES;
        self.currentVideo.numberOfLines = 2;
        //计算layout
        Class layout = [FHUGCCellManager cellLayoutClassFromCellViewType:self.currentVideo.cellSubType cellModel:self.currentVideo];
        if(layout){
            self.currentVideo.layout = [[layout alloc] init];
            [self.currentVideo.layout updateLayoutWithData:self.currentVideo];
        }
        
        FHFeedUGCCellModel *cellModel = paramObj.allParams[@"cellModel"];
        if(cellModel){
            self.currentVideo.diggCount = cellModel.diggCount;
            self.currentVideo.userDigg = cellModel.userDigg;
            self.currentVideo.commentCount = cellModel.commentCount;
            self.currentVideo.videoItem.article.diggCount = cellModel.videoItem.article.diggCount;
            self.currentVideo.videoItem.article.userDigg = cellModel.videoItem.article.userDigg;
            self.currentVideo.videoItem.article.commentCount = cellModel.videoItem.article.commentCount;
            self.currentVideo.videoItem.article.userRepin = cellModel.videoItem.article.userRepin;
        }
        
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

    [self addEnterCategoryLog];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.viewModel viewWillDisappear];
    [self addStayCategoryLog];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)initView {
    [self.view layoutIfNeeded];
    [self initTableView];
}

- (void)initTableView {
    if(!_tableView){
        self.tableView = [[FHBaseTableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.customNavBarView.frame), screenWidth, screenHeight - CGRectGetMaxY(self.customNavBarView.frame)) style:UITableViewStylePlain];
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
        
        if ([UIDevice btd_isIPhoneXSeries]) {
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
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.customNavBarView.frame), screenWidth, screenHeight - CGRectGetMaxY(self.customNavBarView.frame));
}

- (void)initViewModel {
    FHUGCVideoListViewModel *viewModel = [[FHUGCVideoListViewModel alloc] initWithTableView:_tableView controller:self];
    viewModel.categoryId = self.category;
    self.viewModel = viewModel;
    
    if(self.currentVideo){
        [self.viewModel.dataList addObject:self.currentVideo];
        [self.tableView reloadData];
        self.tableView.mj_footer.hidden = NO;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.tableView.mj_footer.state = MJRefreshStateRefreshing;
        });
    }
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
    [self addStayCategoryLog];
}

- (void)applicationDidBecomeActive {
    self.enterTabTimestamp = [[NSDate date]timeIntervalSince1970];
    [self.tableView setContentOffset:self.tableView.contentOffset animated:NO];
    [self.viewModel startVideoPlay];
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
    tracerDict[@"page_type"] = self.category;
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
    tracerDict[@"page_type"] = self.category;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:(duration * 1000)];
    TRACK_EVENT(@"stay_category", tracerDict);
    
    self.enterTabTimestamp = [[NSDate date]timeIntervalSince1970];
}

@end
