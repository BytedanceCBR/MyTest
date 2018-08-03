//
//  TTFavoriteHistoryViewController.m
//  Article
//
//  Created by fengyadong on 16/11/22.
//
//

#import "TTFavoriteHistoryViewController.h"
#import "TTSwipePageViewController.h"
#import "TTHorizontalCategoryBar.h"
#import "SSNavigationBar.h"
#import "TTFavoriteViewController.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTFeedFavoriteHistoryHeader.h"
#import "TTHistoryViewController.h"
#import "NSObject+FBKVOController.h"
#import "UIViewController+Refresh_ErrorHandler.h"
#import <SDWebImage/SDWebImageCompat.h>
#import "ExploreSearchViewController.h"
#import "TTNavigationController.h"
#import "TTFavoriteSearchViewController.h"
#import <TTInteractExitHelper.h>
//#import "ExploreSearchViewController.h"
//#import "TTFavoriteSearchHotView.h"
#import "TTRoute.h"
#import <TTAlphaThemedButton.h>
#import "TTCustomAnimationDelegate.h"


#define kFavoriteHistoryTopBarHeight [TTDeviceUIUtils tt_padding:36.f]

#ifndef dispatch_main_sync_safe
#define dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}
#endif

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}
#endif

@interface TTFavoriteHistoryViewController () <TTSwipePageViewControllerDelegate, TTHorizontalCategoryBarDelegate, TTAccountMulticastProtocol, TTInteractExitProtocol>

@property (nonatomic, strong) TTSwipePageViewController *pageController;
@property (nonatomic, strong) NSArray *tabControllers;
@property (nonatomic, assign) NSUInteger initialIndex;//初始停留在哪个tab
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) TTNavigationBarItemContainerView *rightView;

@property (nonatomic, strong) TTAlphaThemedButton *searchButton;

@end

@implementation TTFavoriteHistoryViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    NSDictionary *params = paramObj.allParams;
    if (self = [super initWithRouteParamObj:paramObj]) {
        if ([params valueForKey:@"stay_id"]) {
            NSString *stayID = [params tt_stringValueForKey:@"stay_id"];
            if ([[[self class] stayIDArray] containsObject:stayID]) {
                _initialIndex = [[[self class] stayIDArray] indexOfObject:stayID];
            } else {
                _initialIndex = 0;
            }
        }
    }
    return self;
}

#pragma mark -- LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupComponents];
    [self setupSwipeViewController];
    [self registerNotification];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
    
    [[TTCustomAnimationManager sharedManager] registerFromVCClass:[self class] toVCClass:NSClassFromString(@"AWEVideoDetailViewController") animationClass:[TSVShortVideoEnterDetailAnimation class]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.ttStatusBarStyle = [[TTThemeManager sharedInstance_tt] statusBarStyle];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    if (![UIApplication sharedApplication].isStatusBarHidden){
        CGFloat topInset = TTNavigationBarHeight + self.view.tt_safeAreaInsets.top;
        self.pageController.view.frame = CGRectMake(CGRectGetMinX(self.view.bounds), CGRectGetMinY(self.view.bounds) + topInset, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - topInset);
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [TTAccount removeMulticastDelegate:self];
}

#pragma mark -- setup

- (void)setupComponents {
    SSThemedView * themeView = [[SSThemedView alloc] initWithFrame:self.view.bounds];
    themeView.backgroundColorThemeKey = kColorBackground4;
    self.view = themeView;
    [self setupNavigationBar];
}

- (void)setupNavigationBar {
    self.ttHideNavigationBar = NO;
    self.titleLabel = (SSThemedLabel *)[SSNavigationBar navigationTitleViewWithTitle:NSLocalizedString(@"收藏", nil)];
    self.navigationItem.titleView = self.titleLabel;
    
    // 搜索页面开关
    [self initRightBarButtonsWithSearchButtonEnable:[SSCommonLogic mineTabSearchEnabled]];
}

- (void)initRightBarButtonsWithSearchButtonEnable:(BOOL)enable {
    self.rightView = (TTNavigationBarItemContainerView *)[SSNavigationBar navigationButtonOfOrientation:SSNavigationButtonOrientationOfRight withTitle:@"编辑" target:self action:@selector(_editActionFired:)];
    if (!enable) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightView];
        return;
    }
    NSMutableArray *buttons = [NSMutableArray array];
    [buttons addObject:[[UIBarButtonItem alloc] initWithCustomView:self.rightView]];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace   target:nil action:nil];
    
    /**
     width为负数时，相当于btn向右移动width数值个像素，由于按钮本身和  边界间距为5pix，所以width设为-5时，间距正好调整为0；width为正数 时，正好相反，相当于往左移动width数值个像素
     */
    negativeSpacer.width = 12.5;
    [buttons addObject:negativeSpacer];
    
    _searchButton = [self p_generateBarButtonWithImageName:@"search_topic" selector:@selector(showSearchPageViewController)];
    _searchButton.hidden = YES;
    _searchButton.enableHighlightAnim = NO; // TTAlphaThemedButton会在Hightlight改变时候提交动画，BarButton自带处理的动画冲突，需要关闭
    [buttons addObject:[[UIBarButtonItem alloc] initWithCustomView:_searchButton]];
    
    self.navigationItem.rightBarButtonItems = buttons;
}

- (void)showSearchPageViewController {
    UIViewController *currentViewController = self.pageController.currentPageViewController;
    NSString *from = nil;
    if ([currentViewController isKindOfClass:[TTFavoriteViewController class]]) {
        from = @"favorite";
    } else if ([currentViewController isKindOfClass:[TTHistoryViewController class]]) {
        TTHistoryViewController *historyViewController = (TTHistoryViewController *)(currentViewController);
        if (historyViewController.historyType == TTHistoryTypeRead) {
            from = @"read_history";
        } else if (historyViewController.historyType == TTHistoryTypeReadPush) {
            from = @"push_history";
        } else {
            from = @"refresh_history";
        }
    }
    // 点击搜索按钮埋点，对应来源
    wrapperTrackEvent(from, @"search");
    
    NSMutableDictionary *condition = [NSMutableDictionary dictionaryWithCapacity:1];
    condition[@"from"] = from;
    
    TTFavoriteSearchViewController *vc = [[TTFavoriteSearchViewController alloc] initWithRouteParamObj:TTRouteParamObjWithDict(condition)];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)_showSearchViewController {
    
}

- (TTAlphaThemedButton *)p_generateBarButtonWithImageName:(NSString *)imageName selector:(SEL)selector {
    TTAlphaThemedButton *barButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    barButton.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
    barButton.imageName = imageName;
    [barButton addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [barButton sizeToFit];
    
    if ([TTDeviceHelper isScreenWidthLarge320]) {
        [barButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -2)];
    }
    else {
        [barButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -4)];
    }
    return barButton;
}

- (void)setupSwipeViewController {
    [self setupViewControllers];
    [self addChildViewController:self.pageController];
    [self.view addSubview:self.pageController.view];
    [self.pageController didMoveToParentViewController:self];
}

- (void)setupViewControllers {
    TTSwipePageViewController *pageController = [[TTSwipePageViewController alloc] init];
    pageController.view.frame = CGRectMake(CGRectGetMinX(self.view.bounds), CGRectGetMinY(self.view.bounds) + 64.f + kFavoriteHistoryTopBarHeight, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 64.f - kFavoriteHistoryTopBarHeight);
    self.pageController = pageController;
    TTFavoriteViewController *favoriteViewController = [[TTFavoriteViewController alloc] init];
    pageController.pages = @[favoriteViewController];
    pageController.delegate = self;
    self.tabControllers = pageController.pages;
    [self.pageController setSelectedIndex:self.initialIndex animated:NO];
    
    [pageController.pages enumerateObjectsUsingBlock:^(__kindof UIResponder * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WeakSelf;
        [self.KVOController observe:obj keyPath:@"viewModel.allItems" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            StrongSelf;
            NSArray *dataSource = (NSArray *)[change valueForKey:NSKeyValueChangeNewKey];
            dispatch_main_sync_safe(^{
                self.rightView.button.enabled = dataSource.count > 0;
                self.searchButton.enabled = YES;
            });
        }];
        
        [self.KVOController observe:obj keyPath:@"tableView.editing" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            StrongSelf;
            dispatch_main_sync_safe(^{
                [self changeRightButtonTextIfNeededAtIndex:idx];
            });
        }];
    }];
}

- (void)_editActionFired:(id)sender {
    if ([self.pageController.currentPageViewController respondsToSelector:@selector(didEditButtonPressed:)]) {
        [((id<TTFeedFavoriteHistoryProtocol>)self.pageController.currentPageViewController) didEditButtonPressed:sender];
    }
    
    [self changeRightButtonTextIfNeededAtIndex:0];
    
    if ([self.pageController.currentPageViewController respondsToSelector:@selector(isCurrentVCEditing)]) {
        if([((id<TTFeedFavoriteHistoryProtocol>)self.pageController.currentPageViewController) isCurrentVCEditing]) {
           wrapperTrackEvent([[[self class] stayIDArray] objectAtIndex:0], @"edit");
        }
    }
}

+ (NSArray <NSString *> *)titleStringArray {
    return @[NSLocalizedString(@"我的收藏", nil)];
}

+ (NSArray <NSString *> *)edittingTitleStringArray {
    return @[NSLocalizedString(@"编辑收藏", nil)];
}

+ (NSArray <NSString *> *)stayIDArray {
    return @[@"favorite"];
}

#pragma mark TTSwipePageViewControllerDelegate method
- (void)pageViewController:(TTSwipePageViewController *)pageViewController
           pagingFromIndex:(NSInteger)fromIndex
                   toIndex:(NSInteger)toIndex
           completePercent:(CGFloat)percent {
}

- (void)pageViewController:(TTSwipePageViewController *)pageViewController
         willPagingToIndex:(NSInteger)toIndex {
}

- (void)pageViewController:(TTSwipePageViewController *)pageViewController
          didPagingToIndex:(NSInteger)toIndex {
    [self disableEditButtonIfNeededForViewController:self.pageController.currentPageViewController];
    [self changeRightButtonTextIfNeededAtIndex:toIndex];
    if (toIndex >=0 && toIndex < [[self class] stayIDArray].count) {
        wrapperTrackEvent([[[self class] stayIDArray] objectAtIndex:toIndex], @"tab_swipe");
    }
}

- (void)pageViewControllerWillBeginDragging:(UIScrollView *)scrollView {
}

#pragma mark -- TTHorizontalCategoryBarDelegate Method
- (CGSize)sizeForEachItem:(TTCategoryItem *)item {
    CGSize size = [item.title sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:15]]}];
    return CGSizeMake([TTDeviceUIUtils tt_padding:ceil(size.width)], kFavoriteHistoryTopBarHeight);
}

- (UIEdgeInsets)insetForSection {
    return UIEdgeInsetsZero;
}

- (UIOffset)offsetOfBadgeViewToTitleView {
    return UIOffsetMake(2.f, -7.f);
}

#pragma mark -- Notification

- (void)registerNotification {
    [TTAccount addMulticastDelegate:self];
}

#pragma mark - TTAccountMulticastProtocol

- (void)onAccountStatusChanged:(TTAccountStatusChangedReasonType)reasonType platform:(NSString *)platformName
{
    [self.pageController.pages enumerateObjectsUsingBlock:^(__kindof UIResponder * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(cleanupDataSource)] && [obj respondsToSelector:@selector(refreshData)]) {
            [((id<TTFeedFavoriteHistoryProtocol>)obj) cleanupDataSource];
            [((id<UIViewControllerErrorHandler>)obj) refreshData];
        }
    }];
}

#pragma mark -- Helper

- (void)disableEditButtonIfNeededForViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[TTFavoriteViewController class]] ||
        [viewController isKindOfClass:[TTHistoryViewController class]]) {
        NSArray *dataSource = [viewController valueForKeyPath:@"viewModel.allItems"];
        
        self.rightView.button.enabled = dataSource.count > 0;
        self.searchButton.enabled = YES;
    }
}

- (void)changeRightButtonTextIfNeededAtIndex:(NSUInteger)index {
    if ([self.pageController.currentPageViewController respondsToSelector:@selector(isCurrentVCEditing)]) {
        if([((id<TTFeedFavoriteHistoryProtocol>)self.pageController.currentPageViewController) isCurrentVCEditing]) {
            [self.rightView.button setTitle:NSLocalizedString(@"取消", nil) forState:UIControlStateNormal];
            [self.titleLabel setText:[[[self class] edittingTitleStringArray] objectAtIndex:index]];
            [self.titleLabel sizeToFit];
        }
        else {
            [self.rightView.button setTitle:NSLocalizedString(@"编辑", nil) forState:UIControlStateNormal];
            [self.titleLabel setText:NSLocalizedString(@"收藏", nil)];
            [self.titleLabel sizeToFit];
        }
    }
}

#pragma mark - TTInteractExitProtocol

- (UIView *)suitableFinishBackView
{
    return self.pageController.view;
}

#pragma mark -- ThemedChange

- (void)themeChanged:(NSNotification *)notification
{
    
}

@end
