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

#define FH_MINE_LINK_CHAT_PAGE_URL_KEY @"linkchat_url_key"

@interface FHCustomerServicePage ()
@property (nonatomic, strong) SSWebViewContainer *webView;
@property (nonatomic, copy)   NSString *linkChatPageUrlStr;
@end

@implementation FHCustomerServicePage

+ (void)jumpToLinkChatPage:(NSDictionary *)params {
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
                    userInfoDict[FH_MINE_LINK_CHAT_PAGE_URL_KEY] = linkChatUrl;
                    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
                    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://linkchat_customer_service"] userInfo:userInfo];
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

- (SSWebViewContainer *)webView {
    if(!_webView) {
        _webView = [[SSWebViewContainer alloc] init];
    }
    return _webView;
}
- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if(self = [super initWithRouteParamObj:paramObj]) {
        self.linkChatPageUrlStr = paramObj.allParams[FH_MINE_LINK_CHAT_PAGE_URL_KEY];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupDefaultNavBar:NO];
    [self.customNavBarView.leftBtn setBackgroundImage:nil forState:UIControlStateNormal];
    [self.customNavBarView.leftBtn setBackgroundImage:nil forState:UIControlStateHighlighted];
    UIImage *backImage = ICON_FONT_IMG(24, @"\U0000E68A", [UIColor themeGray1]);
    [self.customNavBarView.leftBtn setImage:backImage forState:UIControlStateHighlighted];
    [self.customNavBarView.leftBtn setImage:backImage forState:UIControlStateNormal];
    
    UIButton *callPhone = [UIButton buttonWithType:UIButtonTypeCustom];
    [callPhone setImage:ICON_FONT_IMG(24, @"\U0000E69A", [UIColor themeGray1]) forState:UIControlStateNormal];
    @weakify(self);
    [[[callPhone rac_signalForControlEvents:UIControlEventTouchUpInside] throttle:0.3] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击埋点
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        param[UT_ENTER_FROM] = self.tracerModel.enterFrom;
        param[UT_PAGE_TYPE] = [self pageType];
        param[@"event_tracking_id"] = @(110836).stringValue;
        TRACK_EVENT(@"click_customer_service_phone", param);
        // 打电话
        [FHCustomerServicePage callCustomerService];
    }];
    [self.customNavBarView addRightViews:@[callPhone] viewsWidth:@[@(44)] viewsHeight:@[@(44)] viewsRightOffset:@[@(15)]];
    
    self.customNavBarView.title.text = @"欢迎咨询";
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.customNavBarView.mas_bottom);
    }];
    
    [self loadContent];
}

- (void)loadContent {
    if(self.linkChatPageUrlStr.length > 0) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.linkChatPageUrlStr]]];
    }
}

- (NSString *)pageType {
    return @"ask_page";
}
@end
