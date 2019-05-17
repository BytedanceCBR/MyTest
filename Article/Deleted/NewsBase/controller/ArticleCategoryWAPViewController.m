//
//  ArticleCategoryWAPViewController.m
//  Article
//
//  Created by Huaqing Luo on 26/6/15.
//
//

#import "ArticleCategoryWAPViewController.h"
#import "SSWebViewControllerView.h"
#import "ExploreSearchViewController.h"
#import <TTUserSettingsManager+FontSettings.h>
#import "UIImage+TTThemeExtension.h"
#import "TTStringHelper.h"
#import "TTRoute.h"


@interface ArticleCategoryWAPViewController ()

@property(nonatomic, strong)SSJSBridgeWebView * webViewContainer;
@property(nonatomic, strong)SSWebViewBackButtonView *backButton;
@end

@implementation ArticleCategoryWAPViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        
    }
    return self;
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        
        NSDictionary *params = paramObj.allParams;
        NSString *gdExtJson = [params objectForKey:@"gd_ext_json"];
        if (!isEmptyString(gdExtJson)) {
            [TTTrackerWrapper event:@"all_category" label:@"enter" json:gdExtJson];
        }
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webViewContainer = [[SSJSBridgeWebView alloc] initWithFrame:self.view.bounds];
    _webViewContainer.scrollView.bounces = NO;
    _webViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_webViewContainer];
    
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:NSLocalizedString(@"头条频道", nil)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.backButton];
    
    UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setImage:[UIImage themedImageNamed:@"search_topic"] forState:UIControlStateNormal];
    [searchButton setImage:[UIImage themedImageNamed:@"search_topic_press"] forState:UIControlStateHighlighted];
    [searchButton setContentEdgeInsets:UIEdgeInsetsMake(5, 11, 5, -11)];
    [searchButton sizeToFit];
    [searchButton addTarget:self action:@selector(showSearch:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:searchButton];
    
    [self loadURLString];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)showSearch:(id)sender
{
    ExploreSearchViewController *controller = [[ExploreSearchViewController alloc] initWithNavigationBar:YES showBackButton:YES queryStr:nil fromType:ListDataSearchFromTypeTab searchType:ExploreSearchViewTypeChannelSearch];
    [[TTUIResponderHelper topNavigationControllerFor: self] pushViewController:controller animated:YES];
}

- (void)loadURLString
{
    NSString * urlString = @"http://i.snssdk.com/article/category/group_page/v1/";
    
    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    NSString *fontSizeType = [TTUserSettingsManager settedFontShortString];
    urlString = [urlString stringByAppendingFormat:@"#tt_daymode=%d&tt_font=%@", isDayModel, fontSizeType];
    NSURL *url = [TTStringHelper URLWithURLString:urlString];
    [_webViewContainer loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void) backViewControllerActionFired:(id) sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backWebViewActionFired:(id) sender {
    
    if (![self.backButton isCloseButtonShowing]) {
        [self.backButton showCloseButton:self.webViewContainer.canGoBack];
    }
    if ([self.webViewContainer canGoBack]) {
        [self.webViewContainer goBack];
    } else {
        if (self.navigationController) {
            if (self.navigationController.viewControllers.count == 1 && self.navigationController.presentingViewController) {
                [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            if (self.presentingViewController) {
                [self dismissViewControllerAnimated:YES completion:NULL];
            }
        }
    }
}

- (SSWebViewBackButtonView *)backButton {
    if (!_backButton) {
        _backButton = [[SSWebViewBackButtonView alloc] init];
        [_backButton.backButton addTarget:self action:@selector(backWebViewActionFired:) forControlEvents:UIControlEventTouchUpInside];
        [_backButton.closeButton addTarget:self action:@selector(backViewControllerActionFired:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}
@end
