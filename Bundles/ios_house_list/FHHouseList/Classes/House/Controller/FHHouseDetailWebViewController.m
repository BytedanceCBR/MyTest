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
#import "FHErrorView.h"
#import "Masonry.h"
#import <UIViewController+Refresh_ErrorHandler.h>
#import "UIViewAdditions.h"
#import "UIView+Refresh_ErrorHandler.h"
#import "FHUtils.h"
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
        [paramsDict setValue:@"outside_detail" forKey:@"page_type"];
        [paramsDict removeObjectForKey:@"log_pb"];
        [paramsDict removeObjectForKey:@"search_id"];
        [paramsDict setValue:[[TTInstallIDManager sharedInstance] deviceID] forKey:@"device_id"];
        
        NSString *getParamStr = [FHUtils getUrlFormStrFromDict:paramsDict andFirstChar:YES];
        if ([getParamStr isKindOfClass:[NSString class]] && _url && _backUrl) {
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
        CGRect rect = CGRectMake(0.0f,topTipheight + 65.0f, self.view.bounds.size.width, self.view.bounds.size.height - 65.0f - topTipheight);
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
