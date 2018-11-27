//
//  FHWebviewController.m
//  Article
//
//  Created by 张元科 on 2018/11/26.
//

#import "FHWebviewViewController.h"
#import "FHWebviewViewModel.h"
#import <TTRJSBForwarding.h>
#import <TTRStaticPlugin.h>
#import "UIViewController+NavbarItem.h"
#import "TTRoute.h"
#import "TTRWebViewProgressView.h"
#import "SSNavigationBar.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "FHErrorMaskView.h"
#import "TTReachability.h"

@interface FHWebviewViewController ()<TTRouteInitializeProtocol, TTRWebViewDelegate, UIViewControllerErrorHandler>
{
    BOOL _isWebViewLoading;
}
@property (nonatomic, strong) FHWebviewViewModel *viewModel;
@property (nonatomic, strong) TTRouteUserInfo *userInfo;
@property (nonatomic, copy)   NSString *url;
@property (nonatomic, strong) FHErrorMaskView *maskView;

@end

@implementation FHWebviewViewController

-(void)initNavbar
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:[SSNavigationBar navigationBackButtonWithTarget:self action:@selector(backAction)]];

    self.navigationItem.leftBarButtonItem = backItem;
    
    UILabel *label = [self defaultTitleView];
    label.text = [self.userInfo.allInfo objectForKey:@"title"];
    [label sizeToFit];

    self.navigationItem.titleView = label;
}

-(void)backAction
{
    if ([self.webview ttr_canGoBack]) {
        [self.webview ttr_goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super init];
    if (self) {
        self.userInfo = paramObj.userInfo;
        self.url = [self.userInfo.allInfo objectForKey:@"url"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11.0 , *)) {
        self.webview.ttr_scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        UIEdgeInsets inset = UIEdgeInsetsZero;
        inset.bottom = [[UIApplication sharedApplication] keyWindow].safeAreaInsets.bottom;
        self.webview.ttr_scrollView.contentInset = inset;
    }
    
    self.webview.frame = CGRectMake(0, 44.f + self.view.tt_safeAreaInsets.top, UIScreen.mainScreen.bounds.size.width, UIScreen.mainScreen.bounds.size.height - (44.f + self.view.tt_safeAreaInsets.top));
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initNavbar];
    self.viewModel = [[FHWebviewViewModel alloc] initWithViewController:self];
    NSDictionary *jsParam =  [self.userInfo.allInfo objectForKey:@"jsParams"];
    [self.viewModel registerJSBridge:self.webview.ttr_staticPlugin jsParamDic:jsParam];
    self.webview.backgroundColor = UIColor.whiteColor;
    
    [self setupMaskView];
    
    [self reloadingWebView];
}

- (void)showMaskView:(BOOL)showen {
    self.maskView.hidden = !showen;
    self.webview.hidden = showen;
}

- (void)setupMaskView {
    _maskView = [[FHErrorMaskView alloc] init];
    [self.view addSubview:_maskView];
    [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    self.maskView.hidden = YES;
    
    __weak typeof(self) wself = self;
    _maskView.retryBlock = ^{
        [wself reloadingWebView];
    };
}

- (void)reloadingWebView {
    if ([TTReachability isNetworkConnected]) {
        // 加载url
        NSURL *u = [NSURL URLWithString:self.url];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:u];
        [self.webview ttr_loadRequest:request];
        [self showMaskView:NO];
    } else {
        [self showMaskView:YES];
        [self.maskView showErrorWithTip:@"网络不给力，试试刷新页面"];
        [self.maskView showRetry:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - TTRWebViewDelegate

- (void)webViewDidStartLoad:(UIView<TTRWebView> *)webView {
    _isWebViewLoading = YES;
    [self tt_startUpdate];
}

- (void)webViewDidFinishLoad:(UIView<TTRWebView> *)webView {
    _isWebViewLoading = NO;
    [self tt_endUpdataData];
    [self showMaskView:NO];
}

- (void)webView:(UIView<TTRWebView> *)webView didFailLoadWithError:(NSError *)error {
    _isWebViewLoading = NO;
    [self tt_endUpdataData];
    
    [self showMaskView:YES];
    [self.maskView showErrorWithTip:@"网络不给力，试试刷新页面"];
    [self.maskView showRetry:YES];
}

#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData
{
    return NO;
}

@end
