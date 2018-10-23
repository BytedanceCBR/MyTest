//
//  ExploreSearchViewController.m
//  Article
//
//  Created by SunJiangting on 14-9-10.
//
//

#import "ExploreSearchViewController.h"
#import "TTViewWrapper.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTDeviceHelper.h"
#import "TTThemeManager.h"
#import "UIView+CustomTimingFunction.h"
#import "TTRoute.h"
#import "SSCommonLogic.h"

#import "TTNavigationController.h"
#import <objc/runtime.h>
#import "TTCustomAnimationDelegate.h"
#import "TTArticleSearchManager.h"
#import "TTTopBar.h"
#import "TTTopBarManager.h"
#import "ExploreSearchView.h"
#import "ArticleSearchBar.h"

static char keyboardShowingKey;

@interface ExploreSearchViewController()<UIGestureRecognizerDelegate>
{
    BOOL _showNavigationBar;
    BOOL _showBackButton;
    ListDataSearchFromType _fromType;
    ExploreSearchViewType _searchType;
    NSString    *_from;
    NSString    *_apiParam;
    NSString    *_curTab;
}

@property (nonatomic, copy)     NSString *queryStr;
@property (nonatomic, strong)   UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong)   SSThemedView *maskView;
@property (nonatomic, assign) BOOL hasSetEdit; //iOS11以上用

@end

@implementation ExploreSearchViewController

- (void)dealloc
{
    if ([SSCommonLogic searchHintSuggestEnable]) {
        if ([self.fromTabName isEqualToString:@"home"]) {
            [TTArticleSearchManager tryFetchSearchTipIfNeedWithTabName:@"home" categoryID:self.searchView.categoryID];
        } else if ([self.fromTabName isEqualToString:@"video"]) {
            [TTArticleSearchManager tryFetchSearchTipIfNeedWithTabName:@"video" categoryID:self.searchView.categoryID];
        } else {
        }
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    NSDictionary *contextInfo = paramObj.allParams;
    NSString *keyword = [contextInfo tt_stringValueForKey:@"keyword"];
    BOOL nav = YES;
    if ([contextInfo.allKeys containsObject:@"nav"]) {
        nav = [contextInfo tt_boolValueForKey:@"nav"];
    }
    BOOL backBtn = NO;
    if ([contextInfo.allKeys containsObject:@"backBtn"]) {
        backBtn = [contextInfo tt_boolValueForKey:@"backBtn"];
    }
    
    ListDataSearchFromType tab = ListDataSearchFromTypeTab;
    if ([contextInfo.allKeys containsObject:@"typeTab"]) {
        tab = (ListDataSearchFromType)[contextInfo tt_integerValueForKey:@"typeTab"];
    }
    
    self = [self initWithNavigationBar:YES showBackButton:NO queryStr:keyword fromType:ListDataSearchFromTypeTab];
    self.groupID = @([contextInfo tt_longlongValueForKey:@"groupID"]);
    if (self) {
        NSString *from = [contextInfo tt_stringValueForKey:@"from"];
        _from = [from copy];
        
        NSString *growthFrom = [contextInfo tt_stringValueForKey:@"growth_from"];
        if (growthFrom) {
            wrapperTrackEvent(@"search_detail", growthFrom);
        }

        NSString *apiParam = [contextInfo tt_stringValueForKey:@"api_param"];
        _apiParam = [apiParam copy];
        
        NSString *curTab = [contextInfo tt_stringValueForKey:@"cur_tab"];
        _curTab = [curTab copy];
    }
    
    return self;
}

- (id)initWithNavigationBar:(BOOL)showNavigationBar showBackButton:(BOOL)showBackButton queryStr:(NSString *)queryStr fromType:(ListDataSearchFromType)type {
    return [self initWithNavigationBar:showNavigationBar showBackButton:showBackButton queryStr:queryStr fromType:type searchType:ExploreSearchViewTypeWapSearch];
}

- (id)initWithNavigationBar:(BOOL)showNavigationBar showBackButton:(BOOL)showBackButton queryStr:(NSString *)queryStr fromType:(ListDataSearchFromType)type searchType:(ExploreSearchViewType)searchType
{
    self = [super init];
    if (self) {
        _showNavigationBar = showNavigationBar;
        _fromType = type;
        _searchType = searchType;
        _showBackButton = showBackButton;
        
        // https://wiki.bytedance.com/pages/viewpage.action?pageId=67307548
        if (type == ListDataSearchFromTypeVideo) {
            _from = @"video";
        } else if (type == ListDataSearchFromDetail) {
            _from = @"search_detail";
        } else if (type == ListDataSearchFromTypeContent) {
            _from = @"content";
        } else if (type == ListDataSearchFromTypeTab ||
                   type == ListDataSearchFromTypeConcern) {
            _from = @"search_tab";
        } else if (type == ListDataSearchFromTypeWeitoutiao) {
            _from = @"weitoutiao";
        } else if (type == ListDataSearchFromTypeHotsoonVideo) {
            _from = kTTUGCVideoCategoryID;
        }
        
        self.queryStr = queryStr;
        self.animatedWhenDismiss = YES;
        
        self.hidesBottomBarWhenPushed = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        if (ListDataSearchFromTypeTab == type || ListDataSearchFromTypeVideo == type) {
            if ([SSCommonLogic useNewSearchTransitionAnimation] && [SSCommonLogic isSearchTransitionEnabled]) {
                self.ttNavBarStyle = @"Red";
            }
        }
    }
    return self;
}

- (id)initWithNavigationBar:(BOOL)showNavigationBar
{
    self = [self initWithNavigationBar:YES showBackButton:![TTDeviceHelper isPadDevice] queryStr:nil fromType:ListDataSearchFromTypeTab];
    if (self) {
        if (![SSCommonLogic useNewSearchTransitionAnimation] || ![SSCommonLogic isSearchTransitionEnabled]) {
            self.statusBarStyle = SSViewControllerStatsBarDayBlackNightWhiteStyle;
        }
        self.animatedWhenDismiss = YES;
    }
    return self;
}

- (id)init
{
    self = [self initWithNavigationBar:YES];
    if (self) {

        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (CGRect)frameForSearchView
{
    if ([TTDeviceHelper isPadDevice]) {
        CGFloat padding = [TTUIResponderHelper paddingForViewWidth:0];
        return CGRectInset(self.view.frame, padding, 0);
    }
    return self.view.bounds;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.searchView.frame = [self frameForSearchView];
    if ([TTDeviceHelper OSVersionNumber] >= 11.0 && [TTDeviceHelper isPadDevice]){
        self.searchView.searchBar.width = [TTUIResponderHelper mainWindow].width;
        self.navigationItem.titleView = self.searchView.searchBar;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![TTDeviceHelper isPadDevice]){
        _maskView = [[SSThemedView alloc] initWithFrame:CGRectMake(0, 0, SSScreenWidth, SSScreenHeight)];
        _maskView.backgroundColor = [UIColor colorWithHexString:@"0000007f"];
    }
    
    if ([SSCommonLogic useNewSearchTransitionAnimation] && [SSCommonLogic isSearchTransitionEnabled] && (ListDataSearchFromTypeTab == _fromType || ListDataSearchFromTypeVideo == _fromType)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    } else {
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
        }
    }
    
    self.navigationItem.leftBarButtonItems = nil;
    
    ExploreSearchViewContext *context = [[ExploreSearchViewContext alloc] init];
    context.showNavigationBar = _showNavigationBar;
    context.searchViewType = _searchType;
    context.searchFromType = _fromType;
    context.from = _from;
    context.defaultQuery = _queryStr;
    context.apiParam = _apiParam;
    context.curTab = _curTab;
    context.fromTabName = _fromTabName;
    
    self.searchView = [[ExploreSearchView alloc] initWithFrame:[self frameForSearchView] searchViewContext:context];
    _searchView.fromTabName = _fromTabName;
    _searchView.searchUrlString = self.searchUrlString;//传递进入一个searchURL 4.6 add nickyu
    if (ListDataSearchFromTypeTab == _fromType || ListDataSearchFromTypeVideo == _fromType) {
        if ([SSCommonLogic useNewSearchTransitionAnimation] && [SSCommonLogic isSearchTransitionEnabled]) {
            _searchView.searchBar.useWhiteCancelButton = YES;
            if ([TTTopBarManager sharedInstance_tt].topBarConfigValid.boolValue) {
                [_searchView.searchBar.searchImageView removeFromSuperview];
                
                SSThemedImageView *bgImageView = [[SSThemedImageView alloc] initWithFrame:_searchView.searchBar.inputBackgroundView.frame];
                bgImageView.image = [TTTopBar searchBarImage];
                [_searchView.searchBar.contentView addSubview:bgImageView];
                for(UIView *subView in _searchView.searchBar.inputBackgroundView.subviews) {
                    [bgImageView addSubview:subView];
                    bgImageView.userInteractionEnabled = YES;
                }
                [_searchView.searchBar.inputBackgroundView removeFromSuperview];
            }
        }
    }
    
    if (_fromType == ListDataSearchFromTypeVideo) {
        //视频搜索隐藏hotView from 5.0
        _searchView.hotSearchView.hidden = YES;
    }
    
    _searchView.animatedWhenDismiss = self.animatedWhenDismiss;
    _searchView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _searchView.groupID = self.groupID;
    _searchView.searchBar.bottomLineView.hidden = YES;
    
    if ([TTDeviceHelper isPadDevice]) {
        TTViewWrapper *wrapperView = [[TTViewWrapper alloc] initWithFrame:self.view.bounds];
        [wrapperView addSubview:_searchView];
        wrapperView.targetView = _searchView;
        wrapperView.backgroundColorThemeKey = kColorBackground2;
        [self.view addSubview:wrapperView];
    }
    else {
        [self.view addSubview:_searchView];
    }
    
    NSString * umengEventString;
    switch (_fromType) {
        case ListDataSearchFromTypeContent:
            umengEventString = @"article_keyword_search";
            wrapperTrackEvent(umengEventString, @"enter");
            break;
        case ListDataSearchFromTypeTag:
            wrapperTrackEvent(umengEventString, @"enter");
            break;
        case ListDataSearchFromTypeConcern:
            umengEventString = @"concern_search";
            break;
        case ListDataSearchFromDetail:
            umengEventString = @"search_detail";
            break;
        default:
            umengEventString = @"search_tab";
            break;
    }
    self.searchView.umengEventString = umengEventString;
    // 统计 - 所有入口进入搜索页
    wrapperTrackEvent(@"search_tab", @"enter");
    if ([SSCommonLogic useNewSearchTransitionAnimation] && [SSCommonLogic isSearchTransitionEnabled]
         && [TTTopBarManager sharedInstance_tt].topBarConfigValid.boolValue && (ListDataSearchFromTypeTab == _fromType || ListDataSearchFromTypeVideo == _fromType)) {
        CGFloat topInset = 20;
        if (@available(iOS 11.0, *)) {
            topInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.top;
        }
        
        self.searchView.searchBar.top = topInset;
        self.ttHideNavigationBar = YES;
        [self.view addSubview:self.searchView.searchBar];
    } else {
        self.navigationItem.titleView = self.searchView.searchBar;
    }
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;

    [self setUpPanAction];
    
    if ([SSCommonLogic useNewSearchTransitionAnimation] && [SSCommonLogic isSearchTransitionEnabled] && (ListDataSearchFromTypeTab == _fromType || ListDataSearchFromTypeVideo == _fromType)) {
        self.ttStatusBarStyle = UIStatusBarStyleLightContent;
    }
}

- (void)setGroupID:(NSNumber *)groupID {
    _groupID = groupID;
    
    if (_searchView) {
        _searchView.groupID = groupID;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_searchView willAppear];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_searchView didAppear];
    if (!_hasSetEdit && [TTDeviceHelper OSVersionNumber] >= 11.0 && isEmptyString(_queryStr)){
        [self.searchView.searchBar setEditing:YES];
        _hasSetEdit = YES;
    }
    
    __weak typeof(self) wself = self;
    if ([SSCommonLogic useNewSearchTransitionAnimation] && [SSCommonLogic isSearchTransitionEnabled] && (ListDataSearchFromTypeTab == _fromType || ListDataSearchFromTypeVideo == _fromType)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __strong typeof(wself) self = wself;
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            self.ttStatusBarStyle = UIStatusBarStyleLightContent;
        });
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_searchView didDisappear];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_searchView willDisappear];
}

- (void)showInViewWithCustomAnimation:(UIView *)view searchViewDelegate:(id<ExploreSearchViewDelegate>)searchViewDelegate {
    
    if ([TTDeviceHelper isPadDevice]) {
        UINavigationController * rootController = [TTUIResponderHelper topNavigationControllerFor: self];
        [rootController pushViewController:self animated:YES];
        return;
    }
    
    self.animatedWhenDismiss = NO;
    
    [self view]; //preload view
    
    self.searchView.useCustomAnimation = YES;
    self.searchView.searchViewDelegate = searchViewDelegate;
    
    UIView *snapShot = [self.searchView.contentView snapshotViewAfterScreenUpdates:YES];
    CGFloat oldH = snapShot.height;
    snapShot.alpha = 0;
    snapShot.top = 0;
    snapShot.height = 0;
    [view addSubview:snapShot];
    
    [UIView animateWithDuration:0.3 animations:^{
        snapShot.alpha = 1;
        snapShot.height = oldH;
    } completion:^(BOOL finished) {
        UINavigationController * rootController = [TTUIResponderHelper topNavigationControllerFor: self];
        [rootController pushViewController:self animated:NO];
        self.ttDisableDragBack = YES;
        
        [snapShot removeFromSuperview];
    }];
}

- (void)dismissFromViewWithCustomAnimation:(UIView *)view {
    if ([TTDeviceHelper isPadDevice]) {
        return;
    }
    
    UIView *snapShot = [self.searchView.contentView snapshotViewAfterScreenUpdates:YES];
    snapShot.top = 0;
    [view addSubview:snapShot];
    
    [UIView animateWithDuration:0.3 animations:^{
        snapShot.alpha = 0;
        snapShot.height = 0;
    } completion:^(BOOL finished) {
        [snapShot removeFromSuperview];
    }];
}

+ (ArticleSearchBar *)searchBarWithWidth:(CGFloat)width {
    ArticleSearchBar * searchBar = [[ArticleSearchBar alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
    searchBar.cancelButton.left -= kCancelButtonPadding;
    searchBar.width = width - searchBar.cancelButton.width;
    
    searchBar.backgroundColor = [UIColor clearColor];
    searchBar.inputBackgroundView.backgroundColorThemeKey = kColorBackground3;
    
    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    searchBar.showsCancelButton = YES;
    
    searchBar.searchField.placeholder = @"请输入关键字";
    return searchBar;
}

-(void)applicationDidEnterBackground:(NSNotification *)notification {
    if (self.isViewLoaded && self.view.window){
        [self.searchView sendStayPageTrack];
    }
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    if (self.isViewLoaded && self.view.window) {
        [self.searchView resetStayPageTrack];
    }
}

- (void)setUpPanAction
{
    WeakSelf;
    self.panBeginAction = ^{
        StrongSelf;
        objc_setAssociatedObject(self, &keyboardShowingKey, @([self.searchView.searchBar isFirstResponder]), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self.searchView.searchBar resignFirstResponder];
    };
    
    self.panRestoreAction = ^{
        StrongSelf;
        BOOL isKeyboardShowing = [objc_getAssociatedObject(self, &keyboardShowingKey) boolValue];
        if (isKeyboardShowing) {
            [self.searchView.searchBar becomeFirstResponder];
        }
    };
}

- (void)pushAnimationCompletion
{
    //在iOS11上键盘没办法自动调起，在这里再调一次
    if ([TTDeviceHelper OSVersionNumber] >= 11.0 && isEmptyString(_queryStr)){
        [self.searchView.searchBar setEditing:YES];
    }
}

@end
