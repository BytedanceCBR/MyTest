//
//  TSVTabViewController.m
//  Article
//
//  Created by 王双华 on 2017/10/26.
//

#import "TSVTabViewController.h"
#import "UIViewController+NavigationBarStyle.h"
#import "UIViewController+Track.h"
#import "TSVCategoryContainerViewController.h"
#import "TTFeedCollectionCell.h"
#import "UIColor+TTThemeExtension.h"
#import "TTInteractExitHelper.h"
#import "TTCustomAnimationDelegate.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TSVTabManager.h"
#import "TSVTabTopBarViewController.h"
#import <TTReachability/TTReachability.h>
#import "TSVTabViewModel.h"
#import "TSVStartupTabManager.h"
#import "TSVTabTipManager.h"
#import "TTUGCPostCenterProtocol.h"
#import "TSVShortVideoPostTaskProtocol.h"
#import <TSVEnterTabAutoRefreshConfig.h>

@interface TSVTabViewController () <TSVCategoryContainerViewControllerDelegate, TTInteractExitProtocol>

@property (nonatomic, strong) TSVTabTopBarViewController *topBarViewController;
@property (nonatomic, strong) TSVCategoryContainerViewController *collectionVC;
@property (nonatomic, strong) TSVTabViewModel *viewModel;

@end

@implementation TSVTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[TTCustomAnimationManager sharedManager] registerFromVCClass:[self class] toVCClass:NSClassFromString(@"AWEVideoDetailViewController") animationClass:[TSVShortVideoEnterDetailAnimation class]];
    
    self.hidesBottomBarWhenPushed = NO;
    self.statusBarStyle = SSViewControllerStatsBarDayWhiteNightBlackStyle;
    self.ttStatusBarStyle = UIStatusBarStyleDefault;
    self.ttNavBarStyle = @"White";
    self.ttHideNavigationBar = YES;
    self.ttTrackStayEnable = YES;
    //必须设置，否则scrollView会异常
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self addChildViewController:self.collectionVC];
    [self.view addSubview:self.collectionVC.view];
    
    [self addChildViewController:self.topBarViewController];
    [self.view addSubview:self.topBarViewController.view];
    
    @weakify(self);
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kTSVTabbarContinuousClickNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        id<TTFeedCollectionCell> currentCell = self.collectionVC.currentCollectionPageCell;
        
        [currentCell refreshDataWithType:ListDataOperationReloadFromTypeTab];
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kHTSTabbarClickedNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        id<TTFeedCollectionCell> currentCell = self.collectionVC.currentCollectionPageCell;
        if ([[TSVTabTipManager sharedManager] isShowingRedDot] && ![currentCell.categoryModel.categoryID isEqualToString:kTTUGCVideoCategoryID]) {
            [self scrollToCategory:kTTUGCVideoCategoryID animated:NO];
        } else if ([TSVEnterTabAutoRefreshConfig shouldAutoRefreshWhenEnterTab]) {
            [currentCell refreshDataWithType:ListDataOperationReloadFromTypeAuto];
        } else {
            [currentCell refreshIfNeeded];
        }
    }];
    
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TTThemeManagerThemeModeChangedNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id x) {
        @strongify(self);
        self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    }];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kExploreTabBarClickNotification object:nil]
      takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(NSNotification *notification) {
         NSDictionary *userInfo = notification.userInfo;
         [[TSVTabManager sharedManager] enterOrLeaveShortVideoTabWithLastViewController:userInfo[@"lastViewController"]
                                                                  currentViewController:userInfo[@"currentViewController"]];
     }];
    
//    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:TTPostTaskBeginNotification object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable notification) {
//        @strongify(self);
//        id<TSVShortVideoPostTaskProtocol> task = notification.object;
//        if ([task isShortVideo] && [task shouldInsertToShortVideoTab]) {
//            [self scrollToCategory:kTTUGCVideoCategoryID animated:NO];
//        }
//    }];
    
    [self.viewModel fetchCategoryData];
    [self bindViewModel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [TSVStartupTabManager sharedManager].shortVideoTabViewControllerVisibility = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [TSVStartupTabManager sharedManager].shortVideoTabViewControllerVisibility = NO;
}

- (void)bindViewModel
{
    @weakify(self);
    [RACObserve(self, viewModel.categoryNames) subscribeNext:^(id x) {
        @strongify(self);
        self.collectionVC.pageCategories = [self.viewModel pageCategories];
        if (self.viewModel.currentIndex < [self.collectionVC.pageCategories count]) {
            [self.collectionVC setCurrentIndex:self.viewModel.currentIndex scrollToPositionAnimated:NO];
        }
    }];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self vclayoutSubviews];
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    [self vclayoutSubviews];
}

- (void)vclayoutSubviews
{
    UIEdgeInsets safeAreaInsets = self.view.tt_safeAreaInsets;
    CGFloat safaAreaInsetsTop = safeAreaInsets.top == 0? 20 : safeAreaInsets.top;
    CGFloat topBarHeight = safaAreaInsetsTop + 44;
    self.topBarViewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, topBarHeight);
    self.collectionVC.view.frame = CGRectMake(0, topBarHeight, self.view.bounds.size.width, self.view.bounds.size.height - topBarHeight);
}

- (TSVTabTopBarViewController *)topBarViewController
{
    if (!_topBarViewController) {
        _topBarViewController = [[TSVTabTopBarViewController alloc] init];
        @weakify(self);
        [_topBarViewController setCategorySelectBlock:^(NSInteger index) {
            @strongify(self);
            if (self.viewModel.currentIndex != index) {
                [self.collectionVC setCurrentIndex:index scrollToPositionAnimated:NO];
            } else {
                [self.collectionVC.currentCollectionPageCell refreshDataWithType:ListDataOperationReloadFromTypeClickCategory];
            }
        }];
        [_topBarViewController setViewModel:self.viewModel];
    }
    return _topBarViewController;
}

- (TSVCategoryContainerViewController *)collectionVC
{
    if (!_collectionVC) {
        _collectionVC = [[TSVCategoryContainerViewController alloc] init];
        _collectionVC.delegate = self;
    }
    return _collectionVC;
}

- (TSVTabViewModel *)viewModel
{
    if (!_viewModel) {
        _viewModel = [[TSVTabViewModel alloc] init];
    }
    return _viewModel;
}

- (void)trackStartedByAppWillEnterForground
{
    [self.collectionVC.currentCollectionPageCell cellWillEnterForground];
}

- (void)trackEndedByAppWillEnterBackground
{
    [self.collectionVC.currentCollectionPageCell cellWillEnterBackground];
}

#pragma mark - TSVCategoryContainerViewControllerDelegate

- (void)tsvCategoryContainerViewController:(TSVCategoryContainerViewController *)vc scrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex completePercent:(CGFloat)percent
{
	[self.topBarViewController scrollFromIndex:fromIndex toIndex:toIndex completePercent:percent];
}

- (void)tsvCategoryContainerViewController:(TSVCategoryContainerViewController *)vc willScrollToIndex:(NSInteger)toIndex
{
    [self.topBarViewController scrollToIndex:toIndex animated:YES];
}

- (void)tsvCategoryContainerViewController:(TSVCategoryContainerViewController *)vc didScrollToIndex:(NSInteger)toIndex
{
    [self.topBarViewController didScrollToIndex:toIndex];
}

#pragma mark -  InteractExitProtocol

- (UIView *)suitableFinishBackView{
    return self.collectionVC.view;
}

#pragma mark -

- (void)scrollToCategory:(NSString *)categoryID animated:(BOOL)animated
{
    NSInteger idx = [self.viewModel indexOfCategory:categoryID];
    
    if (idx == NSNotFound) {
        return;
    }
    
    [self.collectionVC setCurrentIndex:idx scrollToPositionAnimated:animated];
    [self.topBarViewController setCurrentIndex:idx scrollToPositionAnimated:animated];
}

@end
