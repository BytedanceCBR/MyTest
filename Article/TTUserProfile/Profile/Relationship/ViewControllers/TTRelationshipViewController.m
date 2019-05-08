
//  TTRelationshipViewController.m
//  Article
//
//  Created by liuzuopeng on 8/9/16.
//
//

#import "TTRelationshipViewController.h"
#import "TTSwipePageViewController.h"
#import "TTHorizontalCategoryBar.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTAlphaThemedButton.h"
#import "UIButton+TTAdditions.h"
#import "ArticleAppPageHelper.h"
#import "SSNavigationBar.h"

#import "TTFollowingViewController.h"
#import "TTFollowedViewController.h"
#import "TTVisitorViewController.h"
#import "TTRoute.h"
//#import "TTAddFriendViewController.h"

@interface TTRelationshipViewController ()
<
TTSwipePageViewControllerDelegate,
TTHorizontalCategoryBarDelegate
>
@property (nonatomic, strong) NSArray<NSString *> *titles;
@property (nonatomic, strong) NSArray<TTSocialBaseViewController *> *viewControllers;
@property (nonatomic, strong) TTSwipePageViewController *containerViewController;
@property (nonatomic, strong) TTHorizontalCategoryBar   *navCategoryBar;
@property (nonatomic, strong) SSThemedView              *navigationView;
@property (nonatomic, strong) TTAlphaThemedButton       *backButton;     /*返回按钮*/

// model
@property (nonatomic, strong) ArticleFriend             *friendModel;
@end

@implementation TTRelationshipViewController
+ (void)load {
    RegisterRouteObjWithEntryName(@"relation");
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    NSNumber *index;
    NSArray<NSString *> *titles;
    ArticleFriend *tFriend = [[ArticleAppPageHelper sharedHelper] newArticleFriendForRouteParamObj:paramObj index:&index titles:&titles];
    return [self initWithAppearType:index.unsignedIntegerValue currentUser:tFriend titles:titles];
}

- (instancetype)initWithAppearType:(NSUInteger)type currentUser:(ArticleFriend *)aFriend {
    return [self initWithAppearType:type currentUser:aFriend titles:nil];
}

- (instancetype)initWithAppearType:(NSUInteger)type currentUser:(ArticleFriend *)aFriend titles:(NSArray<NSString *> *)titles {
    if (!aFriend) return nil;
    
    NSUInteger selectedIdx = 0;
    if (type == 2) {
        selectedIdx = 1;
    } else if (type == 3) {
        selectedIdx = 2;
    }
    
    // default viewcontrollers
    TTFollowingViewController *followingVC;
    NSArray *titleArray;
    NSArray *vcArray;
    
    // check titles
    if (!SSIsEmptyArray(titles)) {
        NSMutableArray *mutableTitleArray = [NSMutableArray arrayWithCapacity:3];
        NSMutableArray *mutableVCArray = [NSMutableArray arrayWithCapacity:3];
        for (NSString *title in titles) {
            if ([title isEqualToString:@"subscribe"]) {
                if (followingVC) continue;
                
                followingVC = [[TTFollowingViewController alloc] initWithArticleFriend:aFriend];
                [mutableTitleArray addObject:[aFriend isAccountUser] ? @"关注" : @"TA的关注"];
                [mutableVCArray addObject:followingVC];
            }
        }
        titleArray = [mutableTitleArray copy];
        vcArray = [mutableVCArray copy];
    } else {
        followingVC = [[TTFollowingViewController alloc] initWithArticleFriend:aFriend];
        titleArray = [aFriend isAccountUser] ? @[@"关注"] : @[@"TA的关注"];
        vcArray    = [aFriend isAccountUser] ? @[followingVC] : @[followingVC];
    }
    
    return [self initWithSelectedIndex:selectedIdx titles:titleArray viewControllers:vcArray friendModel:aFriend];
}

- (instancetype)init {
    if ((self = [super init])) {
        _selectedIndex = 0;
        _reloadSelectedEnabled = NO;
        _friendModel = nil;
        _titles = nil;
        _viewControllers = nil;
    }
    return self;
}

- (instancetype)initWithTitles:(NSArray<NSString *> *)titles viewControllers:(NSArray<TTSocialBaseViewController *> *)viewControllers {
    return [self initWithTitles:titles viewControllers:viewControllers friendModel:nil];
}

- (instancetype)initWithTitles:(NSArray<NSString *> *)titles viewControllers:(NSArray<TTSocialBaseViewController *> *)viewControllers friendModel:(ArticleFriend *)aFriend {
    return [self initWithSelectedIndex:0 titles:titles viewControllers:viewControllers friendModel:aFriend];
}

- (instancetype)initWithSelectedIndex:(NSUInteger)idx titles:(NSArray<NSString *> *)titles viewControllers:(NSArray<TTSocialBaseViewController *> *)viewControllers friendModel:(ArticleFriend *)aFriend {
    if ([titles count] != [viewControllers count] ||
        !titles || !viewControllers) {
        NSAssert(NO, @"数据不一致，请确保数据一致");
        return nil;
    }
    
    if ((self = [self init])) {
        _selectedIndex = idx;
        _friendModel = aFriend;
        _titles = titles;
        _viewControllers = viewControllers;
    }
    return self;
}

- (instancetype)initWithTitles:(NSArray<NSString *> *)titles classNames:(NSArray<NSString *> *)classNames friendModel:(ArticleFriend *)aFriend {
    NSMutableArray *vcArray = [NSMutableArray array];
    [classNames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Class aClass = NSClassFromString(obj);
        id inst = nil;
        if ([aClass instancesRespondToSelector:@selector(initWithArticleFriend:)]) {
            inst = [[aClass alloc] initWithArticleFriend:aFriend];
        } else {
            inst = [aClass new];
        }
        [vcArray addObject:inst];
    }];
    return [self initWithTitles:titles viewControllers:vcArray friendModel:aFriend];
}

- (void)dealloc {
    [_containerViewController removeFromParentViewController];
    _containerViewController.delegate = nil;
    _navCategoryBar.delegate = nil;
    _friendModel = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupNavigationView];
    [self setupContainerViewController];
    
    [self refreshScrollToTopViewController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    wrapperTrackEvent(@"friends", @"enter");
}

- (void)willMoveToParentViewController:(UIViewController *)parent {
    [super willMoveToParentViewController:parent];
    self.containerViewController.view.frame = CGRectMake(CGRectGetMinX(self.view.frame), CGRectGetMaxY(self.navigationView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.navigationView.frame));
}

- (void)viewSafeAreaInsetsDidChange {
    [super viewSafeAreaInsetsDidChange];

    self.navigationView.height = 44.f + self.view.tt_safeAreaInsets.top;
    self.navCategoryBar.bottom = self.navigationView.height;
    self.containerViewController.view.frame = CGRectMake(CGRectGetMinX(self.view.frame), CGRectGetMaxY(self.navigationView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetMaxY(self.navigationView.frame));
}

- (void)setupNavigationView {
    if ([_titles count] > 1) {
        self.ttHideNavigationBar = YES;
        [self.view addSubview:self.navigationView];
        [self.navigationView addSubview:self.navCategoryBar];
        
//        [self.navCategoryBar addSubview:self.addFriendButton];
        [self.navCategoryBar addSubview:self.backButton];
        [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(24));
            make.width.equalTo(@(24));
            make.centerY.equalTo(self.navCategoryBar);
            make.left.equalTo(self.navCategoryBar).with.offset([TTDeviceUIUtils tt_padding:9]);
        }];
//        [self.addFriendButton mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.height.equalTo(@(24));
//            make.width.equalTo(@(24));
//            make.centerY.equalTo(self.navCategoryBar);
//            make.right.equalTo(self.navCategoryBar.mas_right).with.offset(-[TTDeviceUIUtils tt_padding:13.f]);
//        }];
        [self buildCategoriesIfNeeded];
    } else {
        self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle: NSLocalizedString([_titles firstObject], nil)];
    }
}

- (void)setupContainerViewController {
    [_viewControllers enumerateObjectsUsingBlock:^(TTSocialBaseViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.currentFriend) {
            obj.currentFriend = _friendModel;
        }
    }];
    
    self.containerViewController = [[TTSwipePageViewController alloc] initWithDefaultSelectedIndex:_selectedIndex];
    self.containerViewController.view.frame = CGRectMake(CGRectGetMinX(self.view.frame), CGRectGetMaxY(self.navigationView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.navigationView.frame));
    self.containerViewController.pages = _viewControllers;
    self.containerViewController.delegate = self;
    self.containerViewController.internalScrollView.scrollsToTop = NO;
    [self.view addSubview:self.containerViewController.view];
    [self addChildViewController:self.containerViewController];
    [self.containerViewController didMoveToParentViewController:self];
    
}

- (void)buildCategoriesIfNeeded {
    NSMutableArray<TTCategoryItem *> *catogories = [NSMutableArray array];
    for (NSUInteger index = 0; index < [_titles count]; index++) {
        TTCategoryItem *item = [[TTCategoryItem alloc] init];
        item.title = _titles[index];
        [catogories addObject:item];
    }
    _navCategoryBar.interitemSpacing = [catogories count] > 2 ? [TTDeviceUIUtils tt_padding:30.f] : [TTDeviceUIUtils tt_padding:45.f];
    _navCategoryBar.categories = catogories;
    [_navCategoryBar layoutIfNeeded]; // 强制刷新布局
    _navCategoryBar.selectedIndex = _selectedIndex;
}

- (TTSocialBaseViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (index >= [_viewControllers count]) {
        return nil;
    }
    return _viewControllers[index];
}

#pragma mark - TTSwipePageViewControllerDelegate

- (void)pageViewController:(TTSwipePageViewController *)pageViewController
           pagingFromIndex:(NSInteger)fromIndex
                   toIndex:(NSInteger)toIndex
           completePercent:(CGFloat)percent {
    if (fromIndex < [_viewControllers count] && toIndex < [_viewControllers count] && [_titles count] > 1) {
        [self.navCategoryBar updateInteractiveTransition:percent fromIndex:fromIndex toIndex:toIndex];
    }
}

- (void)pageViewController:(TTSwipePageViewController *)pageViewController
         willPagingToIndex:(NSInteger)toIndex {
}

- (void)pageViewController:(TTSwipePageViewController *)pageViewController
          didPagingToIndex:(NSInteger)toIndex {
    [self setSelectedIndex:toIndex animated:YES];
}

- (void)pageViewControllerWillBeginDragging:(UIScrollView *)scrollView {
}


#pragma mark - TTHorizontalCategoryBarDelegate

- (CGSize)sizeForEachItem:(TTCategoryItem *)item
{
    return CGSizeMake([TTDeviceUIUtils tt_padding:67.f], 44.f);
}

- (UIOffset)offsetOfBadgeViewToTitleView {
    return UIOffsetMake(2.f, -7.f);
}

- (UIEdgeInsets)insetForSection {
    return UIEdgeInsetsZero;
}


#pragma mark - events

- (void)didTapBackButton:(id)sender {
    [self dismissSelf];
}

#pragma mark - refresh scrollToTop of viewcontrollers

- (void)refreshScrollToTopViewController {
    [self.viewControllers enumerateObjectsUsingBlock:^(TTSocialBaseViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == _selectedIndex) {
            obj.tableView.scrollsToTop = YES;
        } else {
            obj.tableView.scrollsToTop = NO;
        }
    }];
}

#pragma mark - properties

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    if (selectedIndex != _selectedIndex) {
        [self setSelectedIndex:selectedIndex animated:NO];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
    if (selectedIndex >= [_viewControllers count]) {
        selectedIndex = 0;
    }
    
    if (selectedIndex != _selectedIndex) {
        _selectedIndex = selectedIndex;
        //        [_navCategoryBar setSelectedIndex:_selectedIndex animated:animated];
        [_navCategoryBar setSelectedIndex:_selectedIndex];
        [_containerViewController setSelectedIndex:_selectedIndex animated:animated];
    } else {
        if (_reloadSelectedEnabled) {
            [[self viewControllerAtIndex:_selectedIndex] pullDownToReload];
        }
    }
    
    [self refreshScrollToTopViewController];
}

/**
 *  NavigationBar's views level is : navigationView -> navTintView -> navCategoryBar
 */
- (SSThemedView *)navigationView {
    if (!_navigationView) {
        _navigationView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, SSWidth(self.view), [SSNavigationBar navigationBarHeight])];
        _navigationView.backgroundColor = [UIColor colorWithRed:0.97 green:0.97 blue:0.97 alpha:0.5];
        _navigationView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        SSThemedView *navTintView = [SSThemedView new];
        navTintView.backgroundColorThemeKey = kColorBackground4;
        navTintView.alpha = 0.85;
        [_navigationView addSubview:navTintView];
        [navTintView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_navigationView);
        }];
    }
    return _navigationView;
}

- (TTHorizontalCategoryBar *)navCategoryBar {
    if (!_navCategoryBar) {
        _navCategoryBar = [[TTHorizontalCategoryBar alloc] initWithFrame:CGRectMake(0, 20.f, SSWidth(self.view), 44.f) delegate:self];
        _navCategoryBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _navCategoryBar.interitemSpacing = 13.f;
        _navCategoryBar.backgroundColor = [UIColor clearColor];
        _navCategoryBar.bottomIndicatorEnabled = YES;
        [_navCategoryBar setTabBarAnimateToBigger:NO];
        [_navCategoryBar showVerticalLine:NO];
        [_navCategoryBar setTabBarTextFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:17.f]]];
        
        [_navCategoryBar setTabBarTextColor:[UIColor tt_themedColorForKey:kColorText1] maskColor:[UIColor tt_themedColorForKey:kAKMainColorHex] lineColor:[UIColor tt_themedColorForKey:kColorLine1]];
        _navCategoryBar.bottomIndicatorColor = [UIColor tt_themedColorForKey:kAKMainColorHex];
        
        __weak typeof (self) wself = self;
        _navCategoryBar.didTapCategoryItem = ^(NSUInteger indexOfTappedItem, NSUInteger currentIndex) {
            __weak typeof (wself) sself = wself;
            [sself setSelectedIndex:indexOfTappedItem animated:YES];
            
            NSArray *logs = @[@"followings_enter", @"followers_enter", @"enter_mine_visitor"];
            if (indexOfTappedItem < [logs count]) {
                wrapperTrackEvent(@"friends", logs[indexOfTappedItem]);
            }
        };
    }
    return _navCategoryBar;
}

- (TTAlphaThemedButton *)backButton {
    if (!_backButton) {
        _backButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _backButton.contentVerticalAlignment   = UIControlContentHorizontalAlignmentCenter;
        _backButton.enableHighlightAnim = YES;
        _backButton.imageName = @"lefterbackicon_titlebar";
        _backButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        [_backButton addTarget:self action:@selector(didTapBackButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

#pragma mark -- TTThemedChangeNotification
- (void)themeChanged:(NSNotification *)notification
{
    [_navCategoryBar setTabBarTextColor:[UIColor tt_themedColorForKey:kColorText1] maskColor:[UIColor tt_themedColorForKey:kColorText4] lineColor:[UIColor tt_themedColorForKey:kColorLine1]];
    _navCategoryBar.bottomIndicatorColor = [UIColor tt_themedColorForKey:kColorText4];
    [_navCategoryBar updateAppearanceColor];
}
@end
