//
//  WDDetailContainerViewController.m
//  Article
//
//  Created by 延晋 张 on 16/6/12.
//
//

#import "WDDetailContainerViewController.h"
#import "WDMonitorManager.h"
#import "WDDetailModel.h"
#import "WDDetailContainerViewModel.h"
#import "WDAnswerEntity.h"

#import "TTDetailViewController.h"
#import "UIViewController+NavigationBarStyle.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "NetworkUtilities.h"
#import "SSThemed.h"
#import "TTDeviceHelper.h"
#import <TTInteractExitHelper.h>
#import <KVOController/NSObject+FBKVOController.h>

@interface WDDetailContainerViewController ()<TTDetailViewControllerDelegate, TTDetailViewControllerDataSource, UIViewControllerErrorHandler,TTInteractExitProtocol, WDDetailModelDataSource>
@property (nonatomic, assign) BOOL hasDidAppeared;

@property (nonatomic, strong, nullable) WDDetailContainerViewModel * viewModel;
@property (nonatomic, strong, nullable) SSViewControllerBase<TTDetailViewController> * detailViewController;

@property (nonatomic, strong) TTRouteParamObj *paramObj;

@end

@implementation WDDetailContainerViewController

+ (void)load
{
    RegisterRouteObjWithEntryName(@"wenda_detail");
}

#pragma mark - Life cycle

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {

    self = [super init];
    if (self) {
        self.paramObj = paramObj;
        self.hidesBottomBarWhenPushed = YES;
        WDDetailContainerViewModel *viewModel = [[WDDetailContainerViewModel alloc] initWithRouteParamObj:paramObj];
        self.viewModel = viewModel;
        if (self.viewModel.isNewVersion) {
            self.ttHideNavigationBar = YES;
            [self.navigationController setNavigationBarHidden:self.ttHideNavigationBar animated:NO];
        }
        else {
            self.viewModel.detailModel.dataSource = self;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    if (self.viewModel.isNewVersion) {
        [self constructDetailViewController];
    }
    else {
        self.navigationItem.title = @"";
        [self firstLoadContent];
    }
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
    if (_hasDidAppeared) {
        [self startStayPageTrackerIfNeeded];
    } else {
        [self cleanNavigationWDPages];
    }
    _hasDidAppeared = YES;
    if (self.viewModel.isNewVersion) {
        self.ttStatusBarStyle = self.detailViewController.ttStatusBarStyle;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self endStayPageTrackerIfNeed];
}

#pragma mark - View

- (void)firstLoadContent{
    BOOL isArticleReliable = self.viewModel.detailModel.isArticleReliable;

    [self tt_startUpdate];

    WeakSelf;
    [self.viewModel fetchContentFromRemoteIfNeededWithComplete:^(WDFetchResultType type) {
        StrongSelf;
        if (!self.detailViewController) {
            [self constructDetailViewController];
        }
        if (type == WDFetchResultTypeDone) {
            [self tt_endUpdataData];
            if (!isArticleReliable) {
                self.viewModel.detailModel.isArticleReliable = !isEmptyString(self.viewModel.detailModel.answerEntity.questionTitle);
                if (self.detailViewController && [self.detailViewController respondsToSelector:@selector(detailContainerViewController:reloadData:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
                    [self.detailViewController detailContainerViewController:self reloadData:self.viewModel.detailModel];
#pragma clang diagnostic pop
                }
            }

        }
        else if (type == WDFetchResultTypeEndLoading) {
            //列表页预加载进入详情页快速返回 or 进入相关阅读等，不需要重复加载浮层并确保要end loading的情况
            [self tt_endUpdataData];
        }else{
            if (self.detailViewController && [self.detailViewController respondsToSelector:@selector(detailContainerViewController:loadContentFailed:)]) {
                [self.detailViewController detailContainerViewController:self loadContentFailed:nil];
            }
            NSString * tips = TTNetworkConnected() ? @"加载失败" : @"没有网络连接";
            [self tt_endUpdataData:NO error:[NSError errorWithDomain:tips code:-3 userInfo:@{@"errmsg":tips}]];
        }
    }];
}

- (void)constructDetailViewController{
    NSString * className = [self.viewModel classNameForSpecificDetailViewController];
    if (!className) {
        return;
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    if (self.viewModel.isNewVersion) {
        self.detailViewController = [(SSViewControllerBase<TTDetailViewController> *)[NSClassFromString(className) alloc]
                                     initWithRouteParamObj:self.paramObj];
    }
    else {
        self.detailViewController = [(SSViewControllerBase<TTDetailViewController> *)[NSClassFromString(className) alloc]
                                     initWithDetailViewModel:self.viewModel.detailModel];
    }
#pragma clang diagnostic pop
    if ([self.detailViewController respondsToSelector:@selector(setDelegate:)]) {
        self.detailViewController.delegate = self;
    }
    if ([self.detailViewController respondsToSelector:@selector(setDataSource:)]) {
        self.detailViewController.dataSource = self;
    }
    if (!self.viewModel.isNewVersion) {
        self.ttNavBarStyle = self.detailViewController.ttNavBarStyle;
        self.ttStatusBarStyle = self.detailViewController.ttStatusBarStyle;
        self.ttHideNavigationBar = self.detailViewController.ttHideNavigationBar;
        self.ttNeedHideBottomLine = self.detailViewController.ttNeedHideBottomLine;
        
        if (self.ttHideNavigationBar) {
            [self.navigationController setNavigationBarHidden:self.ttHideNavigationBar animated:NO];
        }
    }
    [self addDetailVC];
    
    [self.KVOController observe:self.detailViewController keyPaths:@[@"navigationItem.rightBarButtonItem", @"navigationItem.rightBarButtonItems"] options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew action:@selector(detailRightNavBarButtonDidChange:)];
    
    [self.KVOController observe:self.detailViewController keyPaths:@[@"navigationItem.leftBarButtonItem", @"navigationItem.leftBarButtonItems"] options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew action:@selector(detailLeftNavBarButtonDidChange:)];
    
    [self.KVOController observe:self.detailViewController keyPath:@"navigationItem.titleView" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew action:@selector(detailTitleViewDidChange:)];
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
    self.detailViewController.view.frame = self.view.bounds;
    [self addChildViewController:self.detailViewController];
    [self.view addSubview:self.detailViewController.view];
    [self.detailViewController didMoveToParentViewController:self];
}

- (void)backViewItemPressed:(id)sender {
    if ([self.detailViewController respondsToSelector:@selector(detailContainerViewController:leftBarButtonClicked:)]) {
        [self.detailViewController detailContainerViewController:self leftBarButtonClicked:sender];
    }else{
        [self goBack:sender];
    }
}

- (void)moreButtonPressed {
    if ([self.detailViewController respondsToSelector:@selector(detailContainerViewController:rightBarButtonClicked:)]) {
        [self.detailViewController detailContainerViewController:self rightBarButtonClicked:nil];
    }
}

- (void)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cleanNavigationWDPages
{
    NSArray *reverseViewControllers = [[[self.navigationController viewControllers] reverseObjectEnumerator] allObjects];
    NSMutableArray *mutableReverse = reverseViewControllers.mutableCopy;
    for (SSViewControllerBase *viewController in reverseViewControllers) {
        if (![viewController isEqual:self]) {
            if ([viewController isKindOfClass:[WDDetailContainerViewController class]]) {
                [mutableReverse removeObject:viewController];
            } else {
                break;
            }
        }
    }
    
    NSArray *normalViewControllers = [[mutableReverse reverseObjectEnumerator] allObjects];
    [self.navigationController setViewControllers:normalViewControllers animated:YES];
}

#pragma mark - WDDetailModelDataSource

- (BOOL)needReturn
{
    BOOL needReturn = NO;
    NSArray *reverseViewControllers = [[[self.navigationController viewControllers] reverseObjectEnumerator] allObjects];
    for (SSViewControllerBase *viewController in reverseViewControllers) {
        if ([viewController isKindOfClass:[WDDetailContainerViewController class]]) {
            continue;
        } else {
            if ([viewController isKindOfClass:NSClassFromString(@"WDWendaListViewController")] || [viewController isKindOfClass:NSClassFromString(@"WDWendaMoreListViewController")]) {
                if ([viewController respondsToSelector:@selector(viewModel)]) {
                    id viewModel = [viewController valueForKey:@"viewModel"];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                    if ([viewModel respondsToSelector:@selector(qID)]) {
                        NSString *qid = [viewModel valueForKey:@"qID"];
                        if ([qid isEqualToString:self.viewModel.detailModel.answerEntity.qid]) {
                            needReturn = YES;
                        }
                    }
#pragma clang diagnostic pop
                }
            }
            break;
        }
    }
    return needReturn;
}

#pragma mark - Notification

- (void)themeChanged:(NSNotification *)notification{
    self.view.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
}

#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData
{
    return NO;
}

- (void)refreshData{
    [self tt_startUpdate];
    [self firstLoadContent];
}

#pragma mark - StayPage tracker
- (void)startStayPageTrackerIfNeeded{
    if ([self.detailViewController isKindOfClass:[SSViewControllerBase class]]) {
        return;
    }
}

- (void)endStayPageTrackerIfNeed{
    if ([self.detailViewController isKindOfClass:[SSViewControllerBase class]]) {
        return;
    }
}

#pragma mark - UIApplicationNotification
- (void)applicationDidEnterBackground:(NSNotification *)notification {
    // 如果加载期间切换到后台，则放弃这一次统计
    [self endStayPageTrackerIfNeed];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [self startStayPageTrackerIfNeeded];
}

- (void)applicationDidChangeStatusBarOrientation:(NSNotification *)notification {
}

#pragma mark -- TTDetailViewControllerDataSource implementation
- (CGFloat) stayPageTimeInterValForDetailView:(nullable UIViewController *)controller{
    //@ray 注意这里要返回毫秒值
    return 100;//测试数据
}

#pragma mark -- TTDetailViewControllerDelegate implementation
- (void)detailContainerViewController:(nullable SSViewControllerBase *)container rightBarButtonClicked:(nullable id)sender{
    [self moreButtonPressed];
}

- (void)detailContainerViewController:(nullable SSViewControllerBase *)container leftBarButtonClicked:(nullable id)sender{
    [self goBack:nil];
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

#pragma mark -  InteractExitProtocol
- (UIView *)suitableFinishBackView
{
    if ([_detailViewController respondsToSelector:@selector(suitableFinishBackView)]){
        return [_detailViewController performSelector:@selector(suitableFinishBackView)];
    }
    return _detailViewController.view;
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

@end
