//
//  FHHomeViewController.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/20.
//

#import "FHHomeViewController.h"
#import "FHHomeListViewModel.h"
#import "ArticleListNotifyBarView.h"
#import "FHEnvContext.h"
#import "FHHomeCellHelper.h"
#import "FHHomeConfigManager.h"
#import "TTBaseMacro.h"
#import "TTURLUtils.h"
#import "ToastManager.h"
#import "FHTracerModel.h"
#import "TTCategoryStayTrackManager.h"
#import "FHLocManager.h"

static CGFloat const kShowTipViewHeight = 32;

static CGFloat const kSectionHeaderHeight = 38;

@interface FHHomeViewController ()

@property (nonatomic, strong) FHHomeListViewModel *homeListViewModel;
@property (nonatomic, assign) BOOL isClickTab;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) BOOL isShowToasting;
@property (nonatomic, assign) ArticleListNotifyBarView * notifyBar;

@end

@implementation FHHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isRefreshing = NO;
    
    self.mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    if (@available(iOS 7.0, *)) {
        self.mainTableView.estimatedSectionFooterHeight = 0;
        self.mainTableView.estimatedSectionHeaderHeight = 0;
        self.mainTableView.estimatedRowHeight = 0;
    } else {
        // Fallback on earlier versions
    }
        
    self.mainTableView.sectionFooterHeight = 0;
    self.mainTableView.sectionHeaderHeight = 0;
    self.mainTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, MAIN_SCREEN_WIDTH, 0.1)]; //to do:设置header0.1，防止系统自动设置高度
    self.mainTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, MAIN_SCREEN_WIDTH, 0.1)]; //to do:设置header0.1，防止系统自动设置高度

    [self.view addSubview:self.mainTableView];

    self.mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [FHHomeCellHelper registerCells:self.mainTableView];
    
    self.homeListViewModel = [[FHHomeListViewModel alloc] initWithViewController:self.mainTableView andViewController:self];
        // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.mainTableView.backgroundColor = [UIColor whiteColor];
    
    FHConfigDataModel *configModel = [[FHEnvContext sharedInstance] readConfigFromLocal];
    if (!configModel) {
        self.mainTableView.hidden = YES;
        [self tt_startUpdate];
    }

    [self addDefaultEmptyViewFullScreen];

    self.notifyBar = [[ArticleListNotifyBarView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:self.notifyBar];
    
    [self.notifyBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.mainTableView);
        make.height.mas_equalTo(32);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}


- (void)applicationDidEnterBackground:(NSNotification *)notification {
    self.homeListViewModel.stayTime = 0;
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    self.homeListViewModel.stayTime = [[NSDate date] timeIntervalSince1970];
}

-(void)showNotify:(NSString *)message
{
    UIEdgeInsets inset = self.mainTableView.contentInset;
    inset.top = 32;
    self.mainTableView.contentInset = inset;
    
    [self.notifyBar showMessage:message actionButtonTitle:@"" delayHide:YES duration:1 bgButtonClickAction:nil actionButtonClickBlock:nil didHideBlock:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            UIEdgeInsets inset = self.mainTableView.contentInset;
            inset.top = 0;
            self.mainTableView.contentInset = inset;
            [FHEnvContext sharedInstance].isRefreshFromCitySwitch = NO;
     
//    [self.mainTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }];
//        [UIView animateWithDuration:0.3 animations:^{
//
//        } completion:^(BOOL finished) {
//        }];
        
    });
    
}
         
- (void)retryLoadData
{
    if (![FHEnvContext isNetworkConnected]) {
        
        if (self.isShowToasting) {
            return;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isShowToasting = NO;
            });
        });
        
        if (!self.isShowToasting) {
            [[ToastManager manager] showToast:@"网络异常"];
            self.isShowToasting = YES;
        }
        
        return;
    }
    
    if (self.isRefreshing) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isRefreshing = NO;
            });
        });
        return;
    }
    
    self.isRefreshing = YES;
    //无网点击重试逻辑
    FHConfigDataModel *configDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    if (configDataModel) {
        [self.homeListViewModel updateCategoryViewSegmented:NO];
        [self.homeListViewModel requestOriginData:YES];
    }
    [[FHLocManager sharedInstance] requestCurrentLocation:NO andShowSwitch:NO];
}

- (void)willAppear
{    
    if (![FHEnvContext isNetworkConnected]) {
        if (self.homeListViewModel.hasShowedData) {
            [[ToastManager manager] showToast:@"网络异常"];
        }else
        {
            [self.emptyView showEmptyWithTip:@"网络异常，请检查网络连接" errorImage:[UIImage imageNamed:@"group-4"] showRetry:YES];
        }
    }
    self.homeListViewModel.enterType = [TTCategoryStayTrackManager shareManager].enterType != nil ? [TTCategoryStayTrackManager shareManager].enterType : @"default";
    if (self.mainTableView.contentOffset.y > MAIN_SCREENH_HEIGHT) {
        [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance isShowTabbarScrollToTop:YES];
    }
    //
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self scrollToTopEnable:YES];
}

- (void)pullAndRefresh
{
    self.homeListViewModel.reloadType = _reloadFromType;
    [self.mainTableView triggerPullDown];
}

- (void)scrollToTopEnable:(BOOL)enable
{
    self.mainTableView.scrollsToTop = enable;
}

- (void)scrollToTopAnimated:(BOOL)animated
{
    self.mainTableView.contentOffset = CGPointMake(0, 0);
}

- (void)didAppear
{
    self.homeListViewModel.stayTime = [[NSDate date] timeIntervalSince1970];
}

- (void)willDisappear
{
    
}


- (void)didDisappear
{
    [self.homeListViewModel sendTraceEvent:FHHomeCategoryTraceTypeStay];
    self.homeListViewModel.stayTime = 0;
    [FHEnvContext sharedInstance].isRefreshFromCitySwitch = NO;
}

- (void)setTopEdgesTop:(CGFloat)top andBottom:(CGFloat)bottom
{
    self.mainTableView.ttContentInset = UIEdgeInsetsMake(top, 0, bottom, 0);
//    self.mainTableView.scrollIndicatorInsets = UIEdgeInsetsMake(top, 0, bottom, 0);
}

- (BOOL)tt_hasValidateData
{
    FHConfigDataModel *configModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    return configModel != nil;
}

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self tt_resetStayTime];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
