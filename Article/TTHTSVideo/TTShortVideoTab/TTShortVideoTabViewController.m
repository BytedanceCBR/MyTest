//
//  TTShortVideoTabViewController.m
//  Article
//
//  Created by 王双华 on 2017/7/27.
//
//

#import "TTShortVideoTabViewController.h"
#import "UIViewController+NavigationBarStyle.h"
#import "UIViewController+Track.h"
#import "TTShortVideoCollectionViewController.h"
#import "TTFeedCollectionCell.h"
#import "UIColor+TTThemeExtension.h"
#import "TTShortVideoTabHeaderView.h"
#import "TTInteractExitHelper.h"
#import "TTShortVideoStayTrackManager.h"
#import "TTCustomAnimationDelegate.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "TSVTabManager.h"
#import "TSVStartupTabManager.h"

const CGFloat kHeaderViewHeight = 64;

@interface TTShortVideoTabViewController () <TTShortVideoCollectionViewControllerDelegate, TTInteractExitProtocol>

@property (nonatomic, strong) TTShortVideoTabHeaderView *headerView;
@property (nonatomic, strong) TTShortVideoCollectionViewController *collectionVC;

@end

@implementation TTShortVideoTabViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[TTCustomAnimationManager sharedManager] registerFromVCClass:[self class] toVCClass:NSClassFromString(@"AWEVideoDetailViewController") animationClass:[TTUGCVideoEnterDetailAnimation class]];
    
    self.hidesBottomBarWhenPushed = NO;
    self.statusBarStyle = SSViewControllerStatsBarDayWhiteNightBlackStyle;
    self.ttStatusBarStyle = UIStatusBarStyleDefault;
    self.ttNavBarStyle = @"White";
    self.ttHideNavigationBar = YES;
    self.ttTrackStayEnable = YES;
    //必须设置，否则scrollView会异常
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:2];
    [dict setValue:kTTUGCVideoCategoryID forKey:@"category"];
    [dict setValue:@(TTFeedListDataTypeArticle) forKey:@"type"];
    [dict setValue:@(TTShortVideoSubCategoryHTSTabHuoshan) forKey:@"shortVideoSubCategory"];
    TTCategory *huoshanCategory = [TTCategory objectWithDictionary:dict];
    [dict setValue:@(TTShortVideoSubCategoryHTSTabDouyin) forKey:@"shortVideoSubCategory"];
    TTCategory *douyinCategory = [TTCategory objectWithDictionary:dict];
    
    NSArray *pageCategories = @[huoshanCategory,douyinCategory];
    [self.collectionVC setPageCategories:pageCategories];
    [self.collectionVC setCurrentIndex:[TTShortVideoTabHeaderView getCurrentIndexFromNSUserDefaults] scrollToPositionAnimated:NO];
    
    [self addChildViewController:self.collectionVC];
    [self.view addSubview:self.collectionVC.view];
    
    [self.view addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.left.equalTo(self.view);
        make.height.mas_equalTo(kHeaderViewHeight);
    }];
    [self.headerView buildView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(htsTabbarTapped:)
                                                 name:kHTSTabbarClickedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tabbarKeepClick:)
                                                 name:kHTSTabbarKeepClickedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(themeChanged:)
                                                 name:TTThemeManagerThemeModeChangedNotification
                                               object:nil];
    
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kExploreTabBarClickNotification object:nil]
      takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(NSNotification *notification) {
         NSDictionary *userInfo = notification.userInfo;
         [TSVTabManager enterOrLeaveShortVideoTabWithLastViewController:userInfo[@"lastViewController"]
                                                  currentViewController:userInfo[@"currentViewController"]];
     }];
    
    [self themeChanged:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [TSVStartupTabManager sharedManager].shortVideoTabViewControllerVisibility = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [TSVStartupTabManager sharedManager].shortVideoTabViewControllerVisibility = NO;
}

- (TTShortVideoTabHeaderView *)headerView
{
    if (!_headerView) {
        WeakSelf;
        _headerView = [[TTShortVideoTabHeaderView alloc] initWithSelectionBlock:^(NSInteger index) {
            StrongSelf;
            [self.collectionVC setCurrentIndex:index scrollToPositionAnimated:YES];
        }];
    }
    return _headerView;
}

- (TTShortVideoCollectionViewController *)collectionVC
{
    if (!_collectionVC) {
        _collectionVC = [[TTShortVideoCollectionViewController alloc] initWithName:@"shortVideoTab" topInset:kHeaderViewHeight bottomInset:44];
        _collectionVC.delegate = self;
    }
    return _collectionVC;
}

- (void)themeChanged:(NSNotification *)notification
{
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (void)htsTabbarTapped:(NSNotification*)notification
{
    [self.collectionVC trackForTopTabShow:[self.collectionVC currentCategory]];
}

- (void)tabbarKeepClick:(NSNotification*)notification
{
    id<TTFeedCollectionCell> currentCell = self.collectionVC.currentCollectionPageCell;
    
    [currentCell refreshDataWithType:ListDataOperationReloadFromTypeTab];
}

- (void)trackStartedByAppWillEnterForground
{
    [self.collectionVC.currentCollectionPageCell cellWillEnterForground];
}

- (void)trackEndedByAppWillEnterBackground
{
    [self.collectionVC.currentCollectionPageCell cellWillEnterBackground];
}

#pragma mark - TTShortVideoCollectionViewControllerDelegate

- (void)ttShortVideoCollectionViewController:(TTShortVideoCollectionViewController *)vc scrollFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex completePercent:(CGFloat)percent
{
    [self.headerView scrollFromIndex:fromIndex toIndex:toIndex completePercent:percent];
}

- (void)ttShortVideoCollectionViewController:(TTShortVideoCollectionViewController *)vc didScrollToIndex:(NSInteger)toIndex
{
    [self.headerView didScrollToIndex:toIndex];
}

#pragma mark -  InteractExitProtocol

- (UIView *)suitableFinishBackView{
    return _collectionVC.view;
}


@end
