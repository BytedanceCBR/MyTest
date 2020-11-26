//
//  FHCustomerServicePage.m
//  FHHouseMine
//
//  Created by wangzhizhou on 2020/9/24.
//

#import "FHCustomerServicePage.h"
#import "TTUIResponderHelper.h"
#import "UIImage+FIconFont.h"
#import "ReactiveObjC.h"
#import "SSWebViewContainer.h"
#import "FHCommonDefines.h"
#import "UIViewAdditions.h"
#import "TTRoute.h"
#import "FHMineAPI.h"
#import "ToastManager.h"
#import "TTReachability.h"
#import "SSWebViewContainer.h"
#import "SSWebViewController.h"
#import "ByteDanceKit.h"
#import "TTRoute.h"
#import "FHBaseViewController.h"
#import "UIViewController+NavbarItem.h"

@implementation FHCustomerServicePage

+ (void)jumpToLinkChatPage:(NSDictionary *)params {
    if(![TTReachability isNetworkConnected]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ToastManager manager] showToast:@"网络不给力，请重试"];
        });
        return;
    }
    [FHMineAPI requestLinkChatPageUrlWithParams:nil completion:^(NSError * _Nonnull error, id  _Nonnull obj) {
        if(error) {
            [[ToastManager manager] showToast:@"网络不给力，请重试"];
            return;;
        }
        if(obj) {
            NSError *error = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:obj options:NSJSONReadingAllowFragments error:&error];
            if(!error) {
                id data = response[@"data"];
                if(data && [data isKindOfClass:NSDictionary.class]) {
                    NSString *linkChatUrl = data[@"link_chat_url"];
                    // 发送网络请求
                    NSMutableDictionary *userInfoDict = [NSMutableDictionary dictionary];
                    userInfoDict[TRACER_KEY] = params;
                    
                    NSURLComponents *urlComponent = [NSURLComponents componentsWithString:@"sslocal://link_chat"];
                    NSURLQueryItem *geckoDisable = [NSURLQueryItem queryItemWithName:@"gecko_enable" value:@"0"];
                    NSURLQueryItem *url = [NSURLQueryItem queryItemWithName:@"url" value:linkChatUrl];
                    urlComponent.queryItems = @[geckoDisable, url];
                    
                    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
                    [[TTRoute sharedRoute] openURLByPushViewController:urlComponent.URL userInfo:userInfo];
                }
            }
        }
    }];
}

+ (void)callCustomerService {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *phone = @"400-6124-360";
        NSString *phoneUrl = [NSString stringWithFormat:@"tel://%@", phone];
        NSURL *url = [NSURL URLWithString:phoneUrl];
        if ([[UIApplication sharedApplication]canOpenURL:url]) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication]openURL:url options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication]openURL:url];
            }
        }
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *titleLabel = [self defaultTitleView];
    titleLabel.text = @"欢迎咨询";
    titleLabel.font = [UIFont themeFontMedium:18];
    self.navigationItem.titleView = titleLabel;
    
    UIButton *callPhone = [UIButton buttonWithType:UIButtonTypeCustom];
    [callPhone setImage:ICON_FONT_IMG(24, @"\U0000E69A", [UIColor themeGray1]) forState:UIControlStateNormal];
    @weakify(self);
    [[[callPhone rac_signalForControlEvents:UIControlEventTouchUpInside] throttle:0.3] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击埋点
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        param[UT_ENTER_FROM] = [self.paramObj.allParams[TRACER_KEY] tta_stringForKey:UT_ENTER_FROM];
        param[UT_PAGE_TYPE] = [self pageType];
        param[@"event_tracking_id"] = @(110836).stringValue;
        TRACK_EVENT(@"click_customer_service_phone", param);
        // 打电话
        [FHCustomerServicePage callCustomerService];
    }];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:callPhone];
}
- (NSString *)pageType {
    return @"ask_page";
}
@end
