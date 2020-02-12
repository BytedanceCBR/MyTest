//
//  FHHouseESituationViewController.m
//  Pods
//
//  Created by liuyu on 2020/2/6.
//

#import "FHHouseESituationViewController.h"
#import <TTUIWidget/UIView+Refresh_ErrorHandler.h>
#import "UIScrollView+Refresh.h"
#import "TTStringHelper.h"
#import "BDImageView.h"
#import "SSWebViewContainer.h"
#import "FHEnvContext.h"
#import "FHErrorView.h"
#import "masonry.h"

@interface FHHouseESituationViewController ()<YSWebViewDelegate>
@property(nonatomic, retain)SSWebViewContainer * webContainer;
@end

@implementation FHHouseESituationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webContainer = [[SSWebViewContainer alloc] initWithFrame:self.view.bounds baseCondition:@{@"use_wk":@(YES)}];
    if (@available(iOS 11.0 , *)) {
        _webContainer.ssWebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _webContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _webContainer.ssWebView.opaque = NO;
    [_webContainer.ssWebView addDelegate:self];
    _webContainer.ssWebView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    //     _webContainer.ssWebView.backgroundColor = [UIColor redColor];
    _webContainer.disableEndRefresh = YES;
    _webContainer.disableConnectCheck = YES;
    [self.view addSubview:_webContainer];
    FHConfigCenterTabModel *centerTabConfig = [[FHEnvContext sharedInstance] getConfigFromCache].opTab;
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:[TTStringHelper URLWithURLString:centerTabConfig.openUrl]];
    [self.webContainer.ssWebView loadRequest:request];
    
    if (![FHEnvContext isNetworkConnected]) {
        FHErrorView * noDataErrorView = [[FHErrorView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 0.7)];
        //        [noDataErrorView setBackgroundColor:[UIColor redColor]];
        [self.view addSubview:noDataErrorView];
        
        __weak typeof(self) weakSelf = self;
        FHErrorView * noDataErrorViewWeak = noDataErrorView;
        noDataErrorView.retryBlock = ^{
            if (weakSelf.webContainer.ssWebView.request && [FHEnvContext isNetworkConnected]) {
                [noDataErrorViewWeak hideEmptyView];
                [weakSelf.webContainer.ssWebView loadRequest:weakSelf.webContainer.ssWebView.request];
            }
        };
        
        [noDataErrorView showEmptyWithTip:@"网络异常,请检查网络链接" errorImageName:@"group-4"
                                showRetry:YES];
        noDataErrorView.retryButton.userInteractionEnabled = YES;
        [noDataErrorView.retryButton setTitle:@"刷新" forState:UIControlStateNormal];
        [noDataErrorView setBackgroundColor:self.view.backgroundColor];
        [noDataErrorView.retryButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(104, 30));
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)finishLoadingWeb
{
    //    if (self.delegate && [self.delegate respondsToSelector:@selector(listViewStopLoading:)]) {
    //        [self.delegate listViewStopLoading:self];
    //    }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
- (void)webView:(YSWebView *)webView didFailLoadWithError:(NSError *)error {
    [_webContainer tt_endUpdataData];
    //    [_webContainer.ssWebView.scrollView  finishPullDownWithSuccess:YES];
}

- (void)webViewDidFinishLoad:(YSWebView *)webView
{
    [_webContainer tt_endUpdataData];
    
}@end
