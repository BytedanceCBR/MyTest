//
//  SSViewControllerBase.m
//  Article
//
//  Created by hudianwei on 15-1-7.
//
//

#import "DiscoverViewController.h"
#import "SSSearchBar.h"
#import "SSNavigationBar.h"
#import "ExploreSearchViewController.h"
#import "SSOperation.h"
#import "ArticleURLSetting.h"
#import "NewsUserSettingManager.h"
#import "AccountManager.h"
#import "NetworkUtilities.h"
#import "TTNetworkUtilities.h"
#import "UIViewController+NavigationBarStyle.h"
#import "TTAlphaThemedButton.h"
#import "TTDeviceHelper.h"
#import "TTStringHelper.h"

@interface DiscoverViewController ()<SSWebViewContainerDelegate, UIScrollViewDelegate> {
 @private
    BOOL _webViewHasLoaded;
}

@property (nonatomic, strong)SSThemedButton     *searchBar;
@property (nonatomic, strong)TTAlphaThemedButton *backButton;
@property (nonatomic, strong)SSWebViewContainer *webView;

@property (nonatomic, strong)NSDate             *lastRefreshDate;
/// 页面加载超时时间
@property (nonatomic) NSTimeInterval             timeoutInterval;
@end

@implementation DiscoverViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.hidesBottomBarWhenPushed = NO;

        self.timeoutInterval = 60;
        [self preloadWebViewIfNeeded];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        self.hidesBottomBarWhenPushed = NO;

        self.timeoutInterval = 60;
        [self preloadWebViewIfNeeded];

    }
    return self;
}

- (void)loadView {
    SSThemedView *themedView = [[SSThemedView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    themedView.backgroundColorThemeKey = kColorBackground3;
    self.view = themedView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"";
    
    UINavigationBar *navigation = self.navigationController.navigationBar;
    navigation.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    
    _backButton = [[TTAlphaThemedButton alloc] init];
    _backButton.imageName = @"lefterbackicon_titlebar";
    [_backButton sizeToFit];
    _backButton.frame = CGRectMake(4, (navigation.frame.size.height - _backButton.frame.size.height) / 2, _backButton.frame.size.width, _backButton.frame.size.height);
    [_backButton addTarget:self action:@selector(dismissSelf) forControlEvents:UIControlEventTouchUpInside];
    
    [navigation addSubview:_backButton];
    
    self.searchBar = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    _searchBar.backgroundColorThemeKey = kColorBackground3;
    [_searchBar setTitle:@" 搜索感兴趣的内容" forState:UIControlStateNormal];
    _searchBar.titleColorThemeKey = kColorText3;
    _searchBar.imageName = @"search_discover";
    _searchBar.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _searchBar.titleLabel.font = [UIFont systemFontOfSize:14.];
    _searchBar.frame = CGRectMake(SSMaxX(_backButton) + 10, (SSHeight(navigation) - 30) / 2, SSWidth(navigation) - 15 - SSMaxX(_backButton) - 10, 30);
    _searchBar.borderColorThemeKey = kColorLine1;
    _searchBar.layer.cornerRadius = 5;
    _searchBar.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    _searchBar.clipsToBounds = YES;
    _searchBar.contentEdgeInsets = UIEdgeInsetsMake(0, 7, 0, 0);
    [_searchBar addTarget:self action:@selector(_searchBarActionFired:) forControlEvents:UIControlEventTouchUpInside];
    [navigation addSubview:_searchBar];
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    
    
//    ArticleSearchBar * searchBar = [[ArticleSearchBar alloc] initWithFrame:CGRectMake(0, [TTDeviceHelper OSVersionNumber]>= 7 ? 20 : 0, SSWidth(self.view), 44)];
//    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    searchBar.backgroundColor = [UIColor clearColor];
//    searchBar.searchField.placeholder = NSLocalizedString(@"搜索感兴趣的内容", nil);
//    searchBar.searchField.userInteractionEnabled = NO;
//    searchBar.bottomLineView.hidden = YES;
//    [searchBar.inputBackgroundView addTarget:self action:@selector(_searchBarActionFired:) forControlEvents:UIControlEventTouchUpInside];
//    self.searchView = searchBar;
    
//    if ([ExploreArchitectureManager UIArchitectureType] != ArticleUIArchitectureABTestTabbarType) {
//
//        UIButton *leftButton = [SSNavigationBar navigationBackButtonWithTarget:self action:@selector(_backActionFired:)];
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
//    }
//    else
//        self.navigationItem.leftBarButtonItem = nil;
//    self.navigationItem.titleView = self.searchView;
    
//    self.ttNavBarStyle = @"Image";
 
    self.webView.frame = CGRectMake(0, 0, SSWidth(self.view), SSHeight(self.view));
    [self.view addSubview:self.webView];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_userStateChangedNotification:) name:kAccountStateChangedNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}


- (void)preloadWebViewIfNeeded {
    if (!self.webView) {
        self.webView = [[SSWebViewContainer alloc] init];
        self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.webView.delegate = self;
        self.webView.ssWebView.scrollView.delegate = self;
        self.webView.backgroundColor = [UIColor clearColor];
        self.webView.ssWebView.backgroundColor = [UIColor clearColor];
        self.webView.ssWebView.scrollView.backgroundColor = [UIColor clearColor];
    }
    [self _loadWebViewRequest];
    
}
- (void)_loadWebViewRequest {
    
    [self.webView.ssWebView stopLoading];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[TTStringHelper URLWithURLString:[self discoverURLString]]]];
}

- (NSString*)discoverURLString
{
    NSString *discoverURLString = [SSCommonLogic discoverURLString]?:[ArticleURLSetting findWebURLString];
    NSString *searchURLString = [SSHttpOperation constructURLStringFrom:discoverURLString getParameter:nil];
    return searchURLString;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self pullAndRefresh];
    UINavigationBar *navigation = self.navigationController.navigationBar;
    [navigation addSubview:_searchBar];
    [navigation addSubview:_backButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_searchBar removeFromSuperview];
    [_backButton removeFromSuperview];
}

- (BOOL)ssWebView:(YSWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType {
    NSString * URLString = request.URL.absoluteString;
    NSString *discoverURLString = [SSCommonLogic discoverURLString]?:[ArticleURLSetting findWebURLString];
    if ([request.URL.scheme isEqualToString:@"sslocal"]) {
        /// 如果是SSLocal的，则同意处理
        [[SSAppPageManager sharedManager] openURL:request.URL];
        return NO;
    } else if ([URLString rangeOfString:discoverURLString].location != NSNotFound) {
        BOOL needTimestamp = NO;
        if ([URLString rangeOfString:@"#tt_daymode"].location != NSNotFound) {
            // 判断如果已经包含了日夜间的fragment
            NSString *fontSizeType = [NewsUserSettingManager settedFontShortString];
            if ([request.URL ss_isValidNativeSettingFragmentWithFontTypeString:fontSizeType]) {
                return YES;
            }
            /// 如果有夜间模式，但是夜间模式不对的情况下，需要加一个临时的时间戳，不然只修改fragment是不行的
            needTimestamp = YES;
        }
        NSMutableURLRequest *URLRequest = [request mutableCopy];
        NSURL *requestURL = needTimestamp ? [request.URL ss_URLByUpdatingParameters:@{@"_timestamp":@([[NSDate date] timeIntervalSince1970])}] : request.URL;
        NSString *fontSizeType = [NewsUserSettingManager settedFontShortString];
        URLRequest.URL = [requestURL ss_URLByAppendingNativeSettingFragmentWithFontTypeString:fontSizeType];
        [webView loadRequest:URLRequest];
        return NO;
    }
    return YES;
}

- (void)ssWebViewDidStartLoad:(YSWebView *)webView {
    _webViewHasLoaded = NO;
}

- (void)ssWebViewDidFinishLoad:(YSWebView *)webView {
    self.lastRefreshDate = [NSDate date];
    _webViewHasLoaded = YES;
}

- (void)ssWebView:(YSWebView *)webView didFailLoadWithError:(NSError *)error {
    // 如果已经不在loading状态了，并且没有任何一帧加载成功，则判定为失败
    if (!webView.isLoading && !_webViewHasLoaded) {
        [self _webviewTimeout];
    }
}

- (void)_webviewTimeout {
    [self.webView.ssWebView stopLoading];
}

- (void)_backActionFired:(id)sender {
  
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)_searchBarActionFired:(id) sender {
    ssTrackEvent(@"explore", @"click_search");
    ExploreSearchViewController *viewController = ExploreSearchViewController.new;
    BOOL animated = NO;
    viewController.animatedWhenDismiss = animated;
    [self.navigationController pushViewController:viewController animated:animated];
}

- (void)_userStateChangedNotification:(NSNotification *)notification {
    [self _loadWebViewRequest];
}

- (void)pullAndRefresh {
    // 如果没有刷新成功过，或者距离上次刷新时间超过指定时间
    BOOL shouldReload = (!self.lastRefreshDate) || ([[NSDate date] timeIntervalSinceDate:self.lastRefreshDate] > [SSCommonLogic discoverRefreshTimeInterval]);
    if (shouldReload) {
        // 如果已经加载成功过了，但是现在没网，也不加载
        if (SSNetworkConnected() || !_webViewHasLoaded) {
            [self _loadWebViewRequest];
        }
    }
}

@end

