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

@interface FHHouseDetailWebViewController ()
{
    NSTimeInterval _startTime;
}

@property (nonatomic, strong) SSWebViewContainer *webContainer;
@property (nonatomic, strong) TTRouteUserInfo *realtorUserInfo;
@property (nonatomic, strong) FHHouseDetailPhoneCallViewModel *phoneCallViewModel;
@property (nonatomic, copy) NSString *houseId;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, assign) BOOL isShowTopTip;
@property (nonatomic, strong) NSDictionary *traceDict;
@property (nonatomic, copy) NSString *backUrl;
@end

@implementation FHHouseDetailWebViewController
static NSString *s_oldAgent = nil;

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.realtorUserInfo = paramObj.userInfo;
        _houseId = paramObj.allParams[@"house_id"];
        _houseType = [paramObj.allParams[@"house_type"] integerValue];
        _url = paramObj.allParams[@"url"];
        _traceDict = paramObj.allParams[@"tracer"];
        _backUrl = paramObj.allParams[@"backUrl"];

        if ([_traceDict isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *paramsDict = [NSMutableDictionary dictionaryWithDictionary:_traceDict];
            [paramsDict setValue:@"ios" forKey:@"os"];
            [paramsDict setValue:@"app" forKey:@"source"];
            [paramsDict removeObjectForKey:@"log_pb"];
            [paramsDict removeObjectForKey:@"search_id"];
            NSString *getParamStr = [FHUtils getUrlFormStrFromDict:paramsDict andFirstChar:YES];
            if ([getParamStr isKindOfClass:[NSString class]]) {
                _url = [NSString stringWithFormat:@"%@%@",_url,getParamStr];
                _backUrl = [NSString stringWithFormat:@"%@%@",_backUrl,getParamStr];
            }
        }
       
        if ([paramObj.userInfo.allInfo[@"showTopTip"] respondsToSelector:@selector(boolValue)]) {
            _isShowTopTip = [paramObj.userInfo.allInfo[@"showTopTip"] boolValue];
        }else
        {
            _isShowTopTip = NO;
        }
        
        _isShowTopTip = YES;
        
        _phoneCallViewModel = [[FHHouseDetailPhoneCallViewModel alloc]initWithHouseType:FHHouseTypeSecondHandHouse houseId:self.houseId];
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
        CGRect rect = CGRectMake(0.0f, 65.0f + topTipheight, self.view.bounds.size.width, self.view.bounds.size.height - 65.0f - topTipheight);
        return rect;
    }
}

- (void)setupUI
{
    [self setupDefaultNavBar:NO];
    
    if (_isShowTopTip) {
        UIView *topTipView = [[UIView alloc] initWithFrame:CGRectMake(0, [self frameForListView].origin.y - 30, self.view.frame.size.width, 30)];
        [topTipView setBackgroundColor:[UIColor themeRed2]];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, topTipView.frame.size.width, topTipView.frame.size.height)];
        tipLabel.text = @"温馨提示：当前展示页面为外部链接";
        tipLabel.textColor = [UIColor themeRed3];
        tipLabel.font = [UIFont themeFontRegular:12];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        [topTipView addSubview:tipLabel];
        
        [self.view addSubview:topTipView];
    }
    
    self.webContainer = [[SSWebViewContainer alloc] initWithFrame:[self frameForListView]];
    [_webContainer.ssWebView addDelegate:self];
    [_webContainer hiddenProgressView:YES];
    _webContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _webContainer.ssWebView.opaque = NO;
    _webContainer.ssWebView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    _webContainer.disableEndRefresh = YES;
    _webContainer.disableConnectCheck = YES;
    [self.view addSubview:_webContainer];
    
    if (_url) {
        [_webContainer loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
    }
    
    WeakSelf;
    NSString *loadingText = [SSCommonLogic isNewPullRefreshEnabled] ? nil : @"推荐中";
    
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    _startTime = [NSDate new].timeIntervalSince1970;
    
    [FHUserTracker writeEvent:@"go_detail" params:[self goDetailParams]];
    [self.webContainer.ssWebView setBackgroundColor:[UIColor whiteColor]];
    [self.view setBackgroundColor:[UIColor redColor]];
    
}

#pragma mark -- UIWebViewDelegate

- (void)webViewDidFinishLoad:(YSWebView *)webView
{
    [self.webContainer tt_endUpdataData];
}

- (void)webViewDidStartLoad:(YSWebView *)webView
{
  
}

- (void)webView:(YSWebView *)webView didFailLoadWithError:(NSError *)error {
    [self.webContainer tt_endUpdataData];
}

-(NSMutableDictionary*)goDetailParams {
    
    NSDictionary* params = @{};
    return [params mutableCopy];
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
        [FHMainApi getRequest:_backUrl query:nil params:nil completion:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
            
        }];
    }
}

- (NSString *)getUploadTraceUrlParams
{
    return @"";
}

static NSString * CFPropertyListRefToNSString1(CFPropertyListRef ref) {
    if (ref == NULL) {
        return nil;
    }
    if (CFGetTypeID(ref) == CFStringGetTypeID()) {
        return (NSString *)CFBridgingRelease(ref);
    }
    return nil;
}

@end
