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

@interface FHHouseDetailWebViewController ()
{
    NSTimeInterval _startTime;
}

@property (nonatomic, strong) SSWebViewContainer *webContainer;
@property (nonatomic, strong) TTRouteUserInfo *realtorUserInfo;
@property (nonatomic, strong) FHHouseDetailPhoneCallViewModel *phoneCallViewModel;
@property (nonatomic, copy) NSString *houseId;
@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, assign) BOOL isShowTopTip;
@end

@implementation FHHouseDetailWebViewController
static NSString *s_oldAgent = nil;

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.realtorUserInfo = paramObj.userInfo;
        _houseId = paramObj.userInfo.allInfo[@"house_id"];
        _houseType = [paramObj.userInfo.allInfo[@"house_type"] integerValue];
        
        if ([paramObj.userInfo.allInfo[@"house_type"] respondsToSelector:@selector(boolValue)]) {
            _isShowTopTip = [paramObj.userInfo.allInfo[@"house_type"] boolValue];
        }else
        {
            _isShowTopTip = NO;
        }
        
        _phoneCallViewModel = [[FHHouseDetailPhoneCallViewModel alloc]initWithHouseType:FHHouseTypeSecondHandHouse houseId:self.houseId];
    }
    return self;
}

- (CGRect)frameForListView
{
    if (@available(iOS 11.0 , *)) {
        CGRect rect = CGRectMake(0.0f, 44.f + self.view.tt_safeAreaInsets.top, self.view.bounds.size.width, self.view.bounds.size.height - (44.f + self.view.tt_safeAreaInsets.top));
        return rect;
    } else {
        CGRect rect = CGRectMake(0.0f, 65.0f, self.view.bounds.size.width, self.view.bounds.size.height - 65.0f);
        return rect;
    }
}

- (void)setupUI
{
    [self setupDefaultNavBar:NO];
    
    self.webContainer = [[SSWebViewContainer alloc] initWithFrame:[self frameForListView]];
    [_webContainer.ssWebView addDelegate:self];
    [_webContainer hiddenProgressView:YES];
    _webContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _webContainer.ssWebView.opaque = NO;
    _webContainer.ssWebView.backgroundColor = [UIColor colorWithHexString:@"f5f5f5"];
    _webContainer.disableEndRefresh = YES;
    _webContainer.disableConnectCheck = YES;
    [self.view addSubview:_webContainer];
    
    [_webContainer loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]]];
    
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
    //    _delegate = [self.realtorUserInfo allInfo][@"delegate"];
    
    [FHUserTracker writeEvent:@"go_detail" params:[self goDetailParams]];
    [self.webContainer.ssWebView setBackgroundColor:[UIColor redColor]];
    [self.view setBackgroundColor:[UIColor redColor]];
    
//    [self tt_startUpdate];
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
