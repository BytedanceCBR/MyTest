//
//  TTDetailContainerViewController.m
//  Article
//
//  Created by Ray on 16/3/31.
//
//

#import "TTDetailContainerViewController.h"
#import "TTDetailModel.h"
#import "TTDetailContainerViewModel.h"
#import "TTDetailContainerViewController.h"
#import "TTVideoTip.h"
#import "TTVVideoDetailViewController.h"

#import "TTVFeedItem+TTVArticleProtocolSupport.h"
#import "TTVFeedItem+TTVConvertToArticle.h"

#import <TTThemed/SSThemed.h>
#import <TTBaseLib/NetworkUtilities.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <TTUIWidget/TTNavigationController.h>
#import <TTUIWidget/UIView+Refresh_ErrorHandler.h>
#import <TTUIWidget/UIViewController+NavigationBarStyle.h>
#import "TTInteractExitHelper.h"
#import <KVOController/KVOController.h>
#import <TTArticleBase/SSCommonLogic.h>
#import <TTMonitor/TTMonitor.h>
#import "TTArticleDetailViewController.h"
#import <FHCHousePush/FHPushAuthorizeManager.h>
#import <FHHouseBase/FHTraceEventUtils.h>
#import "FHUtils.h"
#import "FHErrorView.h"
#import "Masonry.h"
#import "UIView+House.h"

@interface TTDetailContainerViewController ()<TTDetailViewControllerDelegate, TTDetailViewControllerDataSource, UIViewControllerErrorHandler,TTInteractExitProtocol>

@property (nonatomic, strong) FHErrorView *emptyView;

@end

@implementation TTDetailContainerViewController


#pragma mark - TTRouteInitializeProtocol
- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        TTDetailContainerViewModel * viewModel = [[TTDetailContainerViewModel alloc] initWithRouteParamObj:paramObj];
        if([paramObj.allParams[@"report_params"] isKindOfClass:[NSString class]])
        {
            NSMutableDictionary *reportDict = [[FHUtils dictionaryWithJsonString:paramObj.allParams[@"report_params"]] mutableCopy];
            //这里强插入categoryName
            if(reportDict[@"enter_from"]){
                reportDict[@"category_name"] = reportDict[@"enter_from"];
            }
            
            if([reportDict isKindOfClass:[NSDictionary class]])
            {
                viewModel.reportParams = reportDict;
                viewModel.detailModel.reportParams = reportDict;
            }
        }
        
        self.viewModel = viewModel;
    }
    return self;
}

+ (TTRouteUserInfo *)reassginedUserInfoWithParamObj:(TTRouteParamObj *)paramObj {
    
    TTDetailContainerViewModel *viewModel = [[TTDetailContainerViewModel alloc] initWithRouteParamObj:paramObj];
    NSMutableDictionary * pageCondition = [paramObj.userInfo.allInfo mutableCopy]? :[[NSMutableDictionary alloc] init];
    
    if (([viewModel.detailModel.article isImageSubject] || [viewModel isImageDetail]) && ![SSCommonLogic appGalleryTileSwitchOn] && [SSCommonLogic appGallerySlideOutSwitchOn]) {
        
        [pageCondition setValue:@(0) forKey:@"animated"];
    }
    return TTRouteUserInfoWithDict(pageCondition);
}

- (instancetype)initWithArticle:(id<TTVArticleProtocol> )tArticle
               source:(NewsGoDetailFromSource)source
            condition:(NSDictionary *)condition {
    self = [self init];
    if(self){
        self.hidesBottomBarWhenPushed = YES;
        self.statusBarStyle = SSViewControllerStatsBarDayBlackNightWhiteStyle;
        TTDetailContainerViewModel * viewModel = [[TTDetailContainerViewModel alloc] initWithArticle:tArticle source:source condition:condition];
        self.viewModel = viewModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.navigationItem.title = @"";
    self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    NSError *tmpError = nil;
    [self constructDetailViewController:&tmpError isFromNet:NO];
    
    if (tmpError) {
        [[TTMonitor shareManager] trackService:@"detailViewController_construct_error" attributes:tmpError.userInfo];
    }
    [self addDefaultEmptyViewFullScreen];
    [self firstLoadContent];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(statusbarFrameDidChangeNotification)
                                                 name:UIApplicationDidChangeStatusBarFrameNotification
                                               object:nil];
}

- (void)addDefaultEmptyViewFullScreen
{
    _emptyView = [[FHErrorView alloc] init];
    _emptyView.hidden = YES;
    [self.view addSubview:_emptyView];
    [_emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    __weak typeof(self) wself = self;
    _emptyView.retryBlock = ^{
        [wself retryLoadData];
    };
}

- (void)_setupEmptyView {
    _emptyView = [[FHErrorView alloc] init];
    _emptyView.hidden = YES;
    [self.view addSubview:_emptyView];
    [_emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0 , *)) {
            make.left.right.bottom.mas_equalTo(self.view);
            make.top.mas_equalTo(self.view).offset(44.f + self.view.tt_safeAreaInsets.top);
        } else {
            make.left.right.bottom.mas_equalTo(self.view);
            make.top.mas_equalTo(self.view).offset(65);
        }
    }];
    __weak typeof(self) wself = self;
    _emptyView.retryBlock = ^{
        [wself retryLoadData];
    };
}

- (void)retryLoadData {
    // 重新加载数据
    [self firstLoadContent];
}

-(void)firstLoadContent{
    
    BOOL isArticleReliable = self.viewModel.detailModel.isArticleReliable;
    if (!self.detailViewController) {
        [self tt_startUpdate];
    }
    __weak TTDetailContainerViewController * weakSelf = self;
    [self.viewModel fetchContentFromRemoteIfNeededWithComplete:^(ExploreDetailManagerFetchResultType type) {
        __strong __typeof(weakSelf)self = weakSelf;
        if (!self) {
            return;
        }
        if (!weakSelf.detailViewController) {
        //第一次进入时，如果没有detailViewController，无网络时显示错误页，这是为了防止除文章外类型cell，在无网络第一次进入会被当成文章类型，恢复网络刷新以后变成了文章的详情页。 by xsm
            if(type == ExploreDetailManagerFetchResultTypeNoNetworkConnect){
                [weakSelf tt_endUpdataData];
                [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
                return;
            }
            
            if (self.emptyView) {
                [self.emptyView removeFromSuperview];
                self.emptyView = nil;
            }
            
            NSError *error = nil;
            [weakSelf constructDetailViewController:&error isFromNet:YES];
            if (!weakSelf.detailViewController && error) {
                [[TTMonitor shareManager] trackService:@"detail_vcfailure" status:0 extra:error.userInfo];
            }
        }
        if (type == ExploreDetailManagerFetchResultTypeDone) {
            [weakSelf tt_endUpdataData];
            if (!isArticleReliable) {
                weakSelf.viewModel.detailModel.isArticleReliable = [weakSelf.viewModel.detailModel tt_isArticleReliable];
                if (weakSelf.detailViewController && [weakSelf.detailViewController respondsToSelector:@selector(detailContainerViewController:reloadData:)]) {
                    [weakSelf.detailViewController detailContainerViewController:weakSelf reloadData:weakSelf.viewModel.detailModel];
                }
            }
            
            if (weakSelf.detailViewController && [weakSelf.detailViewController respondsToSelector:@selector(detailContainerViewController:reloadDataIfNeeded:)]) {
                [weakSelf.detailViewController detailContainerViewController:weakSelf reloadDataIfNeeded:weakSelf.viewModel.detailModel];
            }
        }
        else if (type == ExploreDetailManagerFetchResultTypeEndLoading) {
            //列表页预加载进入详情页快速返回 or 进入相关阅读等，不需要重复加载浮层并确保要end loading的情况
            [weakSelf tt_endUpdataData];
        }
        else {
            
            //没实现 或者 返回NO retur
            if(![weakSelf.detailViewController respondsToSelector:@selector(shouldShowErrorPageInDetailContaierViewController:)] || ![weakSelf.detailViewController shouldShowErrorPageInDetailContaierViewController:weakSelf]){
                return;
            }
            if (weakSelf.detailViewController && [weakSelf.detailViewController respondsToSelector:@selector(detailContainerViewController:reloadData:)]) {
                [weakSelf.detailViewController detailContainerViewController:weakSelf loadContentFailed:nil];
            }
            if (weakSelf.viewModel.detailModel.isArticleReliable) { //article可用的情况下 不展示error页面
                return;
            }
            NSString * tips = TTNetworkConnected() ? @"加载失败" : @"没有网络连接";
            [weakSelf tt_endUpdataData:NO error:[NSError errorWithDomain:tips code:-3 userInfo:@{@"errmsg":tips}]];
        }
    }];
}

- (BOOL)tt_hasValidateData
{
    return NO;
}

- (void)refreshData{
    [self tt_startUpdate];
    [self firstLoadContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    NSLog(@"TTDetailContainerViewController dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    BOOL result = YES;
    if([TTDeviceHelper isPadDevice]) {
        result = YES;
    } else {
        result = interfaceOrientation == UIInterfaceOrientationPortrait;
    }
    return result;
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    if (self.navigationController){
        [self refreshArticleDetailViewControllerViewFrameIfNeeded];
    }
}

#pragma mark - View
-(void)constructDetailViewController:(NSError **)error isFromNet:(BOOL)isFromNet{
    NSString * className = [self.viewModel classNameForSpecificDetailViewController:error isFromNet:isFromNet];
    if (!className) {
        return;
    }
    
    if ([self.viewModel.detailModel.article isKindOfClass:[TTVFeedItem class]]) {
        if (![className isEqualToString:NSStringFromClass([TTVVideoDetailViewController class])]) {
            TTVFeedItem *videoFeed = (TTVFeedItem *)self.viewModel.detailModel.article;
            self.viewModel.detailModel.article = videoFeed.savedConvertedArticle;
        }else{

        }
    }

    self.detailViewController = [(SSViewControllerBase<TTDetailViewController> *)[NSClassFromString(className) alloc]
                                 initWithDetailViewModel:self.viewModel.detailModel];
    
    if ([self.detailViewController respondsToSelector:@selector(setDelegate:)]) {
        self.detailViewController.delegate = self;
    }
    if ([self.detailViewController respondsToSelector:@selector(setDataSource:)]) {
        self.detailViewController.dataSource = self;
    }
    
    self.ttNavBarStyle = self.detailViewController.ttNavBarStyle;
    if ([SSCommonLogic useNewSearchTransitionAnimation] && [SSCommonLogic isSearchTransitionEnabled]) {
        self.ttNavBarStyle = @"White";
    }
    self.ttHideNavigationBar = self.detailViewController.ttHideNavigationBar;
    self.ttStatusBarStyle = self.detailViewController.ttStatusBarStyle;
    self.ttNeedHideBottomLine = self.detailViewController.ttNeedHideBottomLine;
    
    if (self.ttHideNavigationBar) {
        [self.navigationController setNavigationBarHidden:self.ttHideNavigationBar animated:NO];
    }
    
    [self addDetailVC];
    
    [self.KVOController observe:self.detailViewController keyPaths:@[@"navigationItem.rightBarButtonItem", @"navigationItem.rightBarButtonItems"] options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew action:@selector(detailRightNavBarButtonDidChange:)];
    
    [self.KVOController observe:self.detailViewController keyPaths:@[@"navigationItem.leftBarButtonItem", @"navigationItem.leftBarButtonItems"] options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew action:@selector(detailLeftNavBarButtonDidChange:)];
    
    [self.KVOController observe:self.detailViewController keyPath:@"navigationItem.titleView" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew action:@selector(detailTitleViewDidChange:)];
    if (@available(iOS 11.0, *)) {
        if ([self respondsToSelector:@selector(setNeedsUpdateOfHomeIndicatorAutoHidden)]) {
            [self setNeedsUpdateOfHomeIndicatorAutoHidden];
        }
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([className isEqualToString:NSStringFromClass([TTArticleDetailViewController class])]) {
            NSMutableDictionary *params = @{}.mutableCopy;
            params[@"category_name"] = self.viewModel.detailModel.categoryID ? : @"be_null";
            params[@"enter_from"] = [FHTraceEventUtils generateEnterfrom:self.viewModel.detailModel.categoryID] ? : @"be_null";
            params[@"log_pb"] = self.viewModel.detailModel.logPb ? : @"be_null";
            params[@"group_id"] = self.viewModel.detailModel.originalGroupID;
            [FHPushAuthorizeManager showArticleAlertIfNeeded:params];
        }
    });
}

- (void)detailRightNavBarButtonDidChange:(NSDictionary *)change {
    self.navigationItem.rightBarButtonItem = self.detailViewController.navigationItem.rightBarButtonItem;
    self.navigationItem.rightBarButtonItems = self.detailViewController.navigationItem.rightBarButtonItems;
}

- (void)detailLeftNavBarButtonDidChange:(NSDictionary *)change {
    self.navigationItem.leftBarButtonItem = self.detailViewController.navigationItem.leftBarButtonItem;
    self.navigationItem.leftBarButtonItems = self.detailViewController.navigationItem.leftBarButtonItems;
}

- (void)detailTitleViewDidChange:(NSDictionary *)change {
    self.navigationItem.titleView = self.detailViewController.navigationItem.titleView;
}

- (void)addDetailVC {
    
    [self.detailViewController willMoveToParentViewController:self];
    [self addChildViewController:self.detailViewController];
    [self refreshArticleDetailViewControllerViewFrameIfNeeded];
    [self.view addSubview:self.detailViewController.view];
    [self.detailViewController didMoveToParentViewController:self];
    
}

- (void)themeChanged:(NSNotification *)notification{
    self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
}

-(BOOL)isNewsDetailForImageSubject{
    return [self.viewModel.detailModel.article isImageSubject];
}

//有小窗视频播放时，禁止旋转
- (BOOL)canRotateNewsDetailForImageSubject
{
    UIViewController *vc = [TTUIResponderHelper topmostViewController].presentedViewController;
    if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)vc;
        if (nav.viewControllers.count > 0) {
            TTDetailContainerViewController *detailVC = nav.viewControllers[0];
            if ([detailVC isKindOfClass:[TTDetailContainerViewController class]]) {
                if ([self.viewModel.detailModel.article isVideoSubject]) {
                    return NO;
                }
            }
        }
    }
    return YES;
}

#pragma mark - UIApplicationNotification
- (void)applicationDidEnterBackground:(NSNotification *)notification {
    
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {

}

- (void)applicationDidChangeStatusBarOrientation:(NSNotification *)notification {
}

-(void)goBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- TTDetailViewControllerDataSource implementation
- (CGFloat) stayPageTimeInterValForDetailView:(nullable UIViewController *)controller{
    //@ray 注意这里要返回毫秒值
    return 100;//测试数据
}

#pragma mark -- Rotate Support
- (BOOL)shouldAutorotate
{
    return [self.detailViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([TTDeviceHelper isPadDevice]) {
        return UIInterfaceOrientationMaskAll;
    }

    if (!self.detailViewController) {
        return UIInterfaceOrientationMaskPortrait;
    }
    return [self.detailViewController supportedInterfaceOrientations];
}

#pragma mark -- Notifications

- (void)statusbarFrameDidChangeNotification
{
    [self refreshArticleDetailViewControllerViewFrameIfNeeded];
}

- (void)refreshArticleDetailViewControllerViewFrameIfNeeded
{
    if ([self.detailViewController respondsToSelector:@selector(detailViewFrame)]) {
        self.detailViewController.view.frame = [self.detailViewController detailViewFrame];
    }else {
        self.detailViewController.view.frame = self.view.bounds;
    }
}


- (UIView *)animationToView
{
    if ([self.detailViewController respondsToSelector:@selector(animationToView)]) {
        //强行解除依赖 (NSObject <TTSharedViewTransitionTo> *) => (id)
        return [(id)self.detailViewController animationToView];
    }
    return nil;
}

- (CGRect)animationToFrame
{
    if ([self.detailViewController respondsToSelector:@selector(animationToFrame)]) {
        //同上
        return [(id)self.detailViewController animationToFrame];
    }
    return CGRectZero;
}

#pragma mark - statusbar是否显示
- (BOOL)prefersStatusBarHidden{
    return self.detailViewController.prefersStatusBarHidden;
}

- (void)pushAnimationCompletion
{
    if ([self.detailViewController respondsToSelector:@selector(pushAnimationCompletion)]){
        [self.detailViewController pushAnimationCompletion];
    }
}

#pragma TTInteractExitProtocol

- (UIView *)suitableFinishBackView
{
    if ([self.detailViewController respondsToSelector:@selector(suitableFinishBackView)]){
        return [self.detailViewController performSelector:@selector(suitableFinishBackView)];
    }
    return self.detailViewController.view;
}

- (UIViewController *)childViewControllerForHomeIndicatorAutoHidden
{
    return self.detailViewController;
}

#pragma safeAreaInset

//- (UIEdgeInsets)additionalSafeAreaInsets
//{
//    UIEdgeInsets inset = [super additionalSafeAreaInsets];
//    if (!self.ttHideNavigationBar){
//        inset.top += TTNavigationBarHeight;
//    }
//    return inset;
//}
@end
