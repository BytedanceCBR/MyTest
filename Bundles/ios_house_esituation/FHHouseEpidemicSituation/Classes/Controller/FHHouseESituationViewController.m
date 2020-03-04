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
#import "UIViewController+Track.h"
#import "FHSpringHangView.h"
#import "FHUserTracker.h"
#import "TTDeviceHelper.h"

@interface FHHouseESituationViewController ()<YSWebViewDelegate>
@property(nonatomic, strong)SSWebViewContainer * webContainer;
//春节活动运营位
@property (nonatomic, strong) FHSpringHangView *springView;
@property (nonatomic, assign) NSTimeInterval stayTime; //页面停留时间
@end

@implementation FHHouseESituationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webContainer = [[SSWebViewContainer alloc] initWithFrame:CGRectMake(0, [TTDeviceHelper isIPhoneXDevice]?44:20, self.view.bounds.size.width, self.view.bounds.size.height-([TTDeviceHelper isIPhoneXDevice]?44+83:20+49)) baseCondition:@{@"use_wk":@(YES)}];
    if (@available(iOS 11.0 , *)) {
        _webContainer.ssWebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    _webContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _webContainer.ssWebView.opaque = NO;
    [_webContainer.ssWebView addDelegate:self];
    _webContainer.ssWebView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    //     _webContainer.ssWebView.backgroundColor = [UIColor redColor];
    _webContainer.disableEndRefresh = YES;
    _webContainer.disableConnectCheck = YES;
    [self.view addSubview:_webContainer];
     YYCache *epidemicSituationCache = [[FHEnvContext sharedInstance].generalBizConfig epidemicSituationCache];
    FHConfigCenterTabModel *cacheTab = [epidemicSituationCache objectForKey:@"tab_cache"];
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:[TTStringHelper URLWithURLString:cacheTab.openUrl]];
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
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self startTrack];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    //春节活动运营位
    if([FHEnvContext isSpringHangOpen]){
        [self addSpringView];
        [self.springView show:[FHEnvContext enterTabLogName]];
    }
}

- (void)_willEnterForeground:(NSNotification *)notification
{
    //春节活动运营位
    if([FHEnvContext isSpringHangOpen]){
        [self addSpringView];
        [self.springView show:[FHEnvContext enterTabLogName]];
    }
}

- (void)finishLoadingWeb
{
    //    if (self.delegate && [self.delegate respondsToSelector:@selector(listViewStopLoading:)]) {
    //        [self.delegate listViewStopLoading:self];
    //    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self endTrack];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent]; 
    [self addStayCategoryLog:self.stayTime];
}

- (void)webView:(YSWebView *)webView didFailLoadWithError:(NSError *)error {
    [_webContainer tt_endUpdataData];
    //    [_webContainer.ssWebView.scrollView  finishPullDownWithSuccess:YES];
}

- (void)webViewDidFinishLoad:(YSWebView *)webView
{
    [_webContainer tt_endUpdataData];
    
}
- (void)addSpringView {
    if(!_springView){
        self.springView = [[FHSpringHangView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:_springView];
        _springView.hidden = YES;
        
        CGFloat bottom = 49;
        if (@available(iOS 11.0 , *)) {
            bottom += [[[[UIApplication sharedApplication] delegate] window] safeAreaInsets].bottom;
        }
        
        [_springView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.view).offset(-bottom - 85);
            make.width.mas_equalTo(82);
            make.height.mas_equalTo(82);
            make.right.mas_equalTo(self.view).offset(-11);
        }];
    }
}
-(void)addStayCategoryLog:(NSTimeInterval)stayTime {
    
    NSTimeInterval duration = stayTime * 1000.0;
    if (duration == 0) {//当前页面没有在展示过
        return;
    }
    NSMutableDictionary *tracerDict = [self categoryLogDict].mutableCopy;
    tracerDict[@"stay_time"] = [NSNumber numberWithInteger:duration];
    TRACK_EVENT(@"stay_tab", tracerDict);
}

-(NSDictionary *)categoryLogDict {
    NSMutableDictionary *tracerDict = @{}.mutableCopy;
    
     YYCache *epidemicSituationCache = [[FHEnvContext sharedInstance].generalBizConfig epidemicSituationCache];
    FHConfigCenterTabModel *centerTabConfig = [epidemicSituationCache objectForKey:@"tab_cache"];
    tracerDict[@"enter_type"] = @"click_tab";
    tracerDict[@"tab_name"] = @"operation_tab";
    tracerDict[@"with_tips"] = @"0";
    tracerDict[@"log_pb"] = centerTabConfig.logPb;
    return tracerDict;
}

- (void)startTrack
{
    self.stayTime = [[NSDate date] timeIntervalSince1970];
}

- (void)endTrack
{
    self.stayTime = [[NSDate date] timeIntervalSince1970] - self.stayTime;
}


@end