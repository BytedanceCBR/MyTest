//
//  FHHouseDetailWebViewController.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/5/28.
//

#import "FHHouseDetailWebViewController.h"
#import <TTRJSBForwarding.h>
#import <TTRStaticPlugin.h>
#import <FHHouseDetail/FHHouseDetailPhoneCallViewModel.h>
#import "TTRoute.h"
#import <TTTracker/TTTracker.h>
#import "FHUserTracker.h"
#import "NetworkUtilities.h"
#import <FHHouseBase/FHHousePhoneCallUtils.h>
#import <FHHouseBase/FHHouseFillFormHelper.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <SSCommonLogic.h>
#import <FHEnvContext.h>
#import <FHErrorView.h>
#import <Masonry.h>
#import <UIViewController+Refresh_ErrorHandler.h>
#import <UIViewAdditions.h>
#import "UIView+Refresh_ErrorHandler.h"
#import <FHUtils.h>
#import <FHMainApi.h>
#import <UIFont+House.h>
#import <UIColor+Theme.h>

@interface FHHouseDetailWebViewController ()
{
    
}

//@property (nonatomic, strong) SSWebViewContainer *webContainer;
//@property (nonatomic, strong) UIWebView *webContainer;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) BOOL isShowTopTip;
@property (nonatomic, strong) NSDictionary *traceDict;
@property (nonatomic, copy) NSString *backUrl;
@property (nonatomic, strong) TTHttpTask *requestTask;
@property (nonatomic, strong) UIView *topTipView;
@end

@implementation FHHouseDetailWebViewController
- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    _url = paramObj.allParams[@"url"];
    _traceDict = paramObj.allParams[@"tracer"];
    _backUrl = paramObj.allParams[@"backUrl"];
    
    if ([_traceDict isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *paramsDict = [NSMutableDictionary dictionaryWithDictionary:_traceDict];
        [paramsDict setValue:@"ios" forKey:@"os"];
        [paramsDict setValue:@"app" forKey:@"source"];
        [paramsDict removeObjectForKey:@"log_pb"];
        [paramsDict removeObjectForKey:@"search_id"];
        [paramsDict setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
        
        NSString *getParamStr = [FHUtils getUrlFormStrFromDict:paramsDict andFirstChar:YES];
        if ([getParamStr isKindOfClass:[NSString class]]) {
            _url = [NSString stringWithFormat:@"%@%@",_url,getParamStr];
            _backUrl = [NSString stringWithFormat:@"%@%@",_backUrl,getParamStr];
        }
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:paramObj.allParams];
    [params setValue:_url forKey:@"url"];
    TTRouteParamObj *routeObj = [[TTRouteParamObj alloc] initWithAllParams:params];
    
    self = [super initWithRouteParamObj:routeObj];
    if (self) {
        if ([paramObj.userInfo.allInfo[@"showTopTip"] respondsToSelector:@selector(boolValue)]) {
            _isShowTopTip = [paramObj.userInfo.allInfo[@"showTopTip"] boolValue];
        }else
        {
            _isShowTopTip = NO;
        }
        
        _isShowTopTip = YES;
        
    }
    return self;
}

- (CGRect)frameForListView
{
    CGFloat topTipheight = _isShowTopTip ? 30 : 0 ;
    if (@available(iOS 11.0 , *)) {
        CGRect rect = CGRectMake(0.0f, 44.f + self.view.tt_safeAreaInsets.top + topTipheight, self.view.bounds.size.width, self.view.bounds.size.height - (44.f + self.view.tt_safeAreaInsets.top) - topTipheight);
        return rect;
    } else {
        CGRect rect = CGRectMake(0.0f,topTipheight, self.view.bounds.size.width, self.view.bounds.size.height - 65.0f - topTipheight);
        return rect;
    }
}

- (void)setupUI
{
    if (_isShowTopTip) {
        self.topTipView = [[UIView alloc] initWithFrame:CGRectMake(0, [self frameForListView].origin.y - 30, self.view.frame.size.width, 30)];
        [self.topTipView setBackgroundColor:[UIColor themeRed2]];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.topTipView.frame.size.width, self.topTipView.frame.size.height)];
        tipLabel.text = @"温馨提示：当前展示页面为外部链接";
        tipLabel.textColor = [UIColor themeRed3];
        tipLabel.font = [UIFont themeFontRegular:12];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        [self.topTipView addSubview:tipLabel];
        
        [self.view addSubview:self.topTipView];
    }
    
//    self.webContainer = [[UIWebView alloc] initWithFrame:[self frameForListView]];
//    self.webContainer.delegate = self;
////    [_webContainer.ssWebView addDelegate:self];
////    [_webContainer hiddenProgressView:YES];
////    _webContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
////    _webContainer.ssWebView.opaque = NO;
////    _webContainer.ssWebView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
////    _webContainer.disableEndRefresh = YES;
////    _webContainer.disableConnectCheck = YES;
////    _webContainer.ssWebView.isCheckOpenUrlNameList = YES;
//    [self.view addSubview:_webContainer];
//
//    @try {
//        // 可能会出现崩溃的代码
//        [_webContainer loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
//    }
//
//    @catch (NSException *exception) {
//        // 捕获到的异常exception
//        if (exception) {
//
//        }
//    }
//    @finally {
//        // 结果处理
//    }
//
//    [self tt_startUpdate];
    
    
    if (![FHEnvContext isNetworkConnected]) {
        FHErrorView * noDataErrorView = [[FHErrorView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 0.7)];
        //        [noDataErrorView setBackgroundColor:[UIColor redColor]];
        [self.view addSubview:noDataErrorView];
        
        __weak typeof(self) weakSelf = self;
        FHErrorView * noDataErrorViewWeak = noDataErrorView;
        noDataErrorView.retryBlock = ^{
            [weakSelf.ssWebView.ssWebContainer.ssWebView reload];
//            if (weakSelf.webContainer.ssWebView.request && [FHEnvContext isNetworkConnected]) {
//                [noDataErrorViewWeak hideEmptyView];
//                [weakSelf.webContainer.ssWebView loadRequest:weakSelf.webContainer.ssWebView.request];
//            }
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    
    self.ssWebView.ssWebContainer.ssWebView.isCheckOpenUrlNameList = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.ssWebView.ssWebContainer.ssWebView setFrame:CGRectMake(0.0f, self.topTipView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.topTipView.frame.origin.y - self.topTipView.frame.size.height)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)webView:(YSWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([self respondsToSelector:@selector(tt_endUpdataData)]) {
        [self tt_endUpdataData];
    }
}


- (void)willMoveToParentViewController:(UIViewController*)parent{
    [super willMoveToParentViewController:parent];
    if(!parent){
    }else
    {
       
    }
}
- (void)didMoveToParentViewController:(UIViewController*)parent{
    [super didMoveToParentViewController:parent];
    if(!parent){
      self.requestTask = [FHMainApi getRequest:_backUrl query:nil params:nil completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {

        }];
    }
}

- (void)dealloc
{
    if (self.requestTask) {
        self.requestTask = nil;
    }
}


@end
