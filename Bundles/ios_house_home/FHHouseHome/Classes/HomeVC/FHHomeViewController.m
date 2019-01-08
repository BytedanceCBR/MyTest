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
@property (nonatomic, assign) ArticleListNotifyBarView * notifyBar;

@end

@implementation FHHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
        }];
    });
    
}

- (void)retryLoadData
{
    FHConfigDataModel *configDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    //to do request config xiefei.xf
    [[FHLocManager sharedInstance] requestCurrentLocation:NO];
}

- (void)willAppear
{
    if (![FHEnvContext isNetworkConnected]) {
        if (self.homeListViewModel.hasShowedData) {
            [[ToastManager manager] showToast:@"网络异常"];
        }else
        {
            [self.emptyView showEmptyWithTip:@"网络不给力,点击重试" errorImage:[UIImage imageNamed:@"group-4"] showRetry:YES];
        }
    }
    self.homeListViewModel.enterType = [TTCategoryStayTrackManager shareManager].enterType != nil ? [TTCategoryStayTrackManager shareManager].enterType : @"default";
    if (self.mainTableView.contentOffset.y > MAIN_SCREENH_HEIGHT) {
        [[FHHomeConfigManager sharedInstance].fhHomeBridgeInstance isShowTabbarScrollToTop:YES];
    }
    
//    [[FHLocManager sharedInstance] showCitySwitchAlert:@"北京"];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self scrollToTopEnable:YES];
}

- (void)pullAndRefresh
{
    self.homeListViewModel.reloadType = _reloadFromType;
    if ([FHHomeConfigManager sharedInstance].isNeedTriggerPullDownUpdateFowFindHouse) {
        [FHHomeConfigManager sharedInstance].isNeedTriggerPullDownUpdateFowFindHouse = NO;
    }else
    {
        [self.mainTableView triggerPullDown];
    }
    
//    detailPageViewModel?.reloadFromType = self._reloadFromType
//    tableView.triggerPullDown()
}

- (void)scrollToTopEnable:(BOOL)enable
{
    self.mainTableView.scrollsToTop = enable;
}

- (void)scrollToTopAnimated:(BOOL)animated
{
//    [self.tableView setContentOffset:CGPointMake(0, self.mainTableView.customTopOffset - self.mainTableView.contentInset.top) animated:animated];
}

//- (void)scroll

//@objc func pullAndRefresh() {
//
//    detailPageViewModel?.reloadFromType = reloadFromType
//    tableView.triggerPullDown()
//}
//
//@objc func scrollToTopEnable(_ enable: Bool) {
//
//    tableView.scrollsToTop = enable
//}
//
//@objc func scrollToTopAnimated(_ animated: Bool) {
//    tableView.setContentOffset(CGPoint.zero, animated: animated)
//}

- (void)didAppear
{
    
}

- (void)willDisappear
{
    
}

- (void)didDisappear
{
    [self.homeListViewModel sendTraceEvent:FHHomeCategoryTraceTypeStay];
}

- (void)setTopEdgesTop:(CGFloat)top andBottom:(CGFloat)bottom
{
//    self.ttContentInset = UIEdgeInsets(top: topInset, left: 0, bottom: BottomInset, right: 0)
//    tableView.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: BottomInset, right: 0)
//    tableView.scrollIndicatorInsets = UIEdgeInsets(top: topInset, left: 0, bottom: BottomInset, right: 0)
}

//- (void)pullAndRefresh
//{
//
//}


- (BOOL)tt_hasValidateData
{
    FHConfigDataModel *configModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    return configModel != nil;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - TTUIViewControllerTrackProtocol

- (void)trackEndedByAppWillEnterBackground {
    [self tt_resetStayTime];
}

- (void)trackStartedByAppWillEnterForground {
    [self tt_resetStayTime];
    self.ttTrackStartTime = [[NSDate date] timeIntervalSince1970];
}

@end
