//
//  ArticleMessageContainerViewController.m
//  Article
//
//  Created by fengyadong on 16/6/5.
//
//

#import "ArticleMessageContainerViewController.h"
#import "TTHorizontalCategoryBar.h"
#import "TTSwipePageViewController.h"
#import "UIViewController+TTCustomLayout.h"
#import "ArticleMessageViewController.h"
#import "ArticleNoticeViewController.h"
#import "ArticleMessageManager.h"
#import "ArticleNotificationManager.h"
#import "ArticleBadgeManager.h"
#import "UIButton+TTAdditions.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTAlphaThemedButton.h"
#import <TTAccountBusiness.h>
#import "ArticleMessageDefinitions.h"
#import "TTDeviceUIUtils.h"
#import "NSObject+TTAdditions.h"
#import "WDInviteOpenService.h"
#import "TTAdapterManager.h"
#import "TTRoute.h"


@interface ArticleMessageContainerViewController () <TTSwipePageViewControllerDelegate, TTHorizontalCategoryBarDelegate>

@property (nonatomic, strong) TTAlphaThemedButton *backButton;/*返回按钮*/
@property (nonatomic, strong) SSThemedView *titleView;
@property (nonatomic, strong) TTHorizontalCategoryBar *topTabView;
@property (nonatomic, strong) TTSwipePageViewController *pageController;
@property (nonatomic, strong) NSArray *tabControllers;
@property (nonatomic, assign) NSUInteger initialIndex;//初始停留在哪个tab

@end

@implementation ArticleMessageContainerViewController

#pragma mark -- Register

+ (void)load
{
    if (![SSCommonLogic isNewMessageNotificationEnabled]) {
        RegisterRouteObjWithEntryName(@"message");
        RegisterRouteObjWithEntryName(@"notification");
        RegisterRouteObjWithEntryName(@"msg");
    }
}

#pragma mark -- Initilization

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if (self = [super initWithRouteParamObj:paramObj]) {
        NSString *schema = paramObj.host;
        if ([schema isEqualToString:@"notification"]) {
            _initialIndex = [[[self class ] titleStringArray] indexOfObject:NSLocalizedString(@"系统通知", nil)];;
        }
        else if([schema isEqualToString:@"msg"]) {
            _initialIndex = [[[self class ] titleStringArray] indexOfObject:NSLocalizedString(@"评论", nil)];
        }
        else if([schema isEqualToString:@"message"]) {
            [self automaticallyChooseChannel];
        }
        else {
            _initialIndex = 0;
        }
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self automaticallyChooseChannel];
    }
    return self;
}

- (void)automaticallyChooseChannel {
    __block NSUInteger index = 0;
    NSArray <NSNumber *> *badgeNumbersArray = [[self class] badgeNumbersArray];
    [badgeNumbersArray enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.integerValue > 0) {
            index = idx;
            *stop = YES;
        }
    }];
    _initialIndex = index;
}

#pragma mark -- Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.ttHideNavigationBar = YES;
    [self setupComponents];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self tt_performSelector:@selector(refreshData) onlyOnceInSelector:_cmd];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self tt_performSelector:@selector(calloutLoginIfNeed) onlyOnceInSelector:_cmd];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.topTabView.width = self.view.width;
    self.pageController.view.frame = CGRectMake(CGRectGetMinX(self.view.bounds), CGRectGetMinY(self.view.bounds) + CGRectGetHeight(self.titleView.bounds), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetHeight(self.titleView.bounds));
}

- (void)dealloc {
}

//- (void)themeChanged:(NSNotification *)notification {
//    [super themeChanged:notification];
//    [self.topTabView setTabBarTextColor:[UIColor tt_themedColorForKey:kColorText1]
//                              maskColor:[UIColor tt_themedColorForKey:kColorText1]
//                              lineColor:[UIColor tt_themedColorForKey:kColorLine1]];
//    for (NSUInteger index = 0; index < self.topTabView.categories.count; index++) {
//        [self.topTabView reloadItemAtIndex:index];
//    }
//}

#pragma mark --Setup Components

- (SSThemedView *)titleView {
    if (!_titleView) {
        _titleView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 64.f)];
        _titleView.backgroundColorThemeKey = kColorBackground4;
    }
    return _titleView;
}

- (TTHorizontalCategoryBar *)topTabView {
    if (!_topTabView) {
        // 频道切换
        _topTabView = [[TTHorizontalCategoryBar alloc] initWithFrame:CGRectMake(0, 20, self.view.width, 44.f) delegate:self];
        _topTabView.bottomIndicatorEnabled = YES;
        [_topTabView setTabBarAnimateToBigger:NO];
        [_topTabView showVerticalLine:NO];
        //        [_topTabView setTabBarTextColor:[UIColor tt_themedColorForKey:kColorText1]
        //                              maskColor:[UIColor tt_themedColorForKey:kColorText1]
        //                              lineColor:[UIColor tt_themedColorForKey:kColorLine1]];
        [_topTabView setTabBarTextColorThemeKey:kColorText1 maskColorThemeKey:kColorText4 lineColorThemeKey:kColorLine1];
        _topTabView.bottomIndicatorColorThemeKey = kColorText4;
        [_topTabView setTabBarTextFont:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:17]]];
        
        _topTabView.interitemSpacing = [TTDeviceUIUtils tt_padding:40.0f];
        _topTabView.backgroundColorThemeKey = kColorBackground4;
        __weak typeof(self) wself = self;
        _topTabView.didSelectCategory = ^(NSUInteger index) { // , BOOL animated
            __strong typeof(wself) self = wself;
            [self.pageController setSelectedIndex:index animated:YES];
            if (index == 1) {
                if(self.topTabView.categories[index].badgeNum > 0){
                    wrapperTrackEvent(@"message_list", @"display_digg_with_badge");
                }
                else {
                    wrapperTrackEvent(@"message_list", @"display_digg_without_badge");
                }
            }
            else if(index == 2) {
                if(self.topTabView.categories[index].badgeNum > 0){
                    wrapperTrackEvent(@"message_list", @"display_notification_with_badge");
                }
                else {
                    wrapperTrackEvent(@"message_list", @"display_notification_without_badge");
                }
            }
        };
        NSArray *titleArray = [[self class] titleStringArray];
        NSArray <NSNumber *> *badgeNumbersArray = [[self class] badgeNumbersArray];
        NSMutableArray *categoryItems = [[NSMutableArray alloc] init];
        for (NSUInteger index = 0; index < [[self class] categoryItemCount]; index++) {
            TTCategoryItem *item = [[TTCategoryItem alloc] init];
            item.title = titleArray[index];
            item.badgeStyle = TTCategoryItemBadgeStyleNumber;
            item.badgeNum = badgeNumbersArray[index].integerValue;
            [categoryItems addObject:item];
        }
        _topTabView.categories = categoryItems;
        [_topTabView layoutIfNeeded];
        _topTabView.selectedIndex = self.initialIndex;
    }
    return _topTabView;
}

- (void)setupComponents {
    [self.titleView addSubview:self.topTabView];
    [self setupBackButton];
    [self.view addSubview:self.titleView];
}

- (void)setupViewControllers {
    __weak typeof(self) wself = self;
    TTSwipePageViewController *pageController = [[TTSwipePageViewController alloc] init];
    self.pageController = pageController;
    ArticleMessageViewController *commentViewController = [[ArticleMessageViewController alloc] initWithType:TTArticleMessageComment clearBlock:^(NSUInteger index) {
        __strong typeof(wself) self = wself;
        if ([self shouldClearBadgeAtIndex:index]) {
            [self clearBadgeAtIndex:index];
        }
    }];
    ArticleMessageViewController *diggViewController = [[ArticleMessageViewController alloc] initWithType:TTArticleMessageDigg clearBlock:^(NSUInteger index) {
        __strong typeof(wself) self = wself;
        if ([self shouldClearBadgeAtIndex:index]) {
            [self clearBadgeAtIndex:index];
        }
    }];
    NSUInteger noticeIndex = [ArticleMessageManager sharedManager].hasInvitation ? 3 : 2;
    ArticleNoticeViewController *noticeViewController = [[ArticleNoticeViewController alloc] initWithClearBlock:^{
        __strong typeof(wself) self = wself;
        if ([self shouldClearBadgeAtIndex:noticeIndex]) {
            [self clearBadgeAtIndex:noticeIndex];
        }
    }];
    if ([ArticleMessageManager sharedManager].hasInvitation) {
        WDInMessageInviteListViewController *questionController = [[WDInviteOpenService sharedInstance_tt] listViewControllerWithBlock:^(NSUInteger index) {
            StrongSelf;
            if ([self shouldClearBadgeAtIndex:index]) {
                [self clearBadgeAtIndex:index];
            }
        }];
        pageController.pages = @[commentViewController, diggViewController, questionController, noticeViewController];
    } else {
        pageController.pages = @[commentViewController, diggViewController, noticeViewController];
    }
    pageController.delegate = self;
    self.tabControllers = pageController.pages;
    [self.pageController setSelectedIndex:self.initialIndex animated:NO];
}

- (void)setupBackButton {
    //back button
    if (!_backButton) {
        _backButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _backButton.enableHighlightAnim = YES;
        _backButton.imageName = @"lefterbackicon_titlebar";
        _backButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        [self.topTabView addSubview:_backButton];
        [_backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@24);
            make.width.equalTo(@24);
            make.centerY.equalTo(self.topTabView);
            make.left.equalTo(self.topTabView).with.offset([TTDeviceUIUtils tt_padding:9]);
        }];
        [_backButton addTarget:self action:@selector(didTapBackButton:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)refreshData {
    [self setupViewControllers];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self addChildViewController:self.pageController];
    [self.view addSubview:self.pageController.view];
    [self.pageController didMoveToParentViewController:self];
}

- (void)calloutLoginIfNeed {
    if (![TTAccountManager isLogin]) {
        [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeDefault source:@"mine_message" completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
            if (type == TTAccountAlertCompletionEventTypeDone) {
                if ([TTAccountManager isLogin]) {
                    [self reloadCurrentVC];
                }
            }
            else if (type == TTAccountAlertCompletionEventTypeTip) {
                [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:@"mine_message" completion:^(TTAccountLoginState state) {

                }];
            }
        }];
    }
}

- (void)reloadCurrentVC {
    UIViewController <ArticleMessageContainerControllerProtocol> *currentTabController = (UIViewController <ArticleMessageContainerControllerProtocol>*)[self.pageController currentPageViewController];
    if ([currentTabController respondsToSelector:@selector(reloadData)]) {
        [currentTabController reloadData];
    }
}

- (void)didTapBackButton:(id)sender {
    [self dismissSelf];
}

#pragma mark TTSwipePageViewControllerDelegate method
- (void)pageViewController:(TTSwipePageViewController *)pageViewController
           pagingFromIndex:(NSInteger)fromIndex
                   toIndex:(NSInteger)toIndex
           completePercent:(CGFloat)percent {
    [self.topTabView updateInteractiveTransition:percent fromIndex:fromIndex toIndex:toIndex];
}

- (void)pageViewController:(TTSwipePageViewController *)pageViewController
         willPagingToIndex:(NSInteger)toIndex {
}

- (void)pageViewController:(TTSwipePageViewController *)pageViewController
          didPagingToIndex:(NSInteger)toIndex {
    self.topTabView.selectedIndex = toIndex;
}

- (void)pageViewControllerWillBeginDragging:(UIScrollView *)scrollView {
}

#pragma mark -- TTHorizontalCategoryBarDelegate Method
- (CGSize)sizeForEachItem:(TTCategoryItem *)item
{
    CGSize size = [item.title sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:17]]}];
    return CGSizeMake([TTDeviceUIUtils tt_padding:ceil(size.width)], 44.f);
}

- (UIEdgeInsets)insetForSection {
    return UIEdgeInsetsZero;
}

- (UIOffset)offsetOfBadgeViewToTitleView {
    return UIOffsetMake(2.f, -7.f);
}

#pragma mark -- Helper

- (BOOL)shouldClearBadgeAtIndex:(NSUInteger)index {
    BOOL hasShown = NO;
    switch (index) {
        case 0:
            hasShown = !SSIsEmptyArray([ArticleMessageManager sharedManager].commentMessages);
            break;
        case 1:
            hasShown = !SSIsEmptyArray([ArticleMessageManager sharedManager].diggMessages);
            break;
        case 2:
            if ([ArticleMessageManager sharedManager].hasInvitation) {
                hasShown = !SSIsEmptyArray([WDInviteOpenService sharedInstance_tt].questionInvitations);
            } else {
                hasShown = !SSIsEmptyArray([ArticleNotificationManager sharedManager].notifications);
            }
            break;
        case 3:
            hasShown = !SSIsEmptyArray([ArticleNotificationManager sharedManager].notifications);
            break;
        default:
            break;
    }
    NSInteger badgeNumber = self.topTabView.categories[index].badgeNum;
    return index == self.topTabView.selectedIndex && hasShown && badgeNumber > 0;
}

- (void)clearBadgeAtIndex:(NSUInteger)index {
    [self.topTabView setBadgeNumber:0 AtIndex:index];
    self.topTabView.categories[index].badgeNum = 0;
    //    [self.topTabView reloadItemAtIndex:index];
    [[ArticleMessageManager sharedManager] clearBadgeNumberOfIndex:index];
}

+ (NSUInteger)categoryItemCount {
    if ([ArticleMessageManager sharedManager].hasInvitation) {
        return 4;
    } else {
        return 3;
    }
}

+ (NSArray <NSString *> *)titleStringArray
{
    if ([ArticleMessageManager sharedManager].hasInvitation) {
        return @[NSLocalizedString(@"评论", nil), NSLocalizedString(@"赞", nil), NSLocalizedString(@"邀请", nil), NSLocalizedString(@"系统通知", nil)];
    } else {
        return @[NSLocalizedString(@"评论", nil), NSLocalizedString(@"赞", nil), NSLocalizedString(@"系统通知", nil)];
    }
}

+ (NSArray <NSNumber *> *)badgeNumbersArray
{
    if ([ArticleMessageManager sharedManager].hasInvitation) {
        return @[@([ArticleMessageManager sharedManager].commentCount), @([ArticleMessageManager sharedManager].diggCount) ,@([ArticleMessageManager sharedManager].wdInviteCount) ,@([ArticleMessageManager sharedManager].noticeCount)];
    } else {
        return @[@([ArticleMessageManager sharedManager].commentCount), @([ArticleMessageManager sharedManager].diggCount),@([ArticleMessageManager sharedManager].noticeCount)];
    }
}

@end
