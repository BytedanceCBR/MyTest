//
//  FRForumGossipViewController.m
//  Article
//
//  Created by 王霖 on 15/10/18.
//
//

#import "FRForumGossipViewController.h"
#import "SSWebViewContainer.h"
#import "SSNavigationBar.h"
#import "FRConcernHomepageViewController.h"
#import "FRRouteHelper.h"
#import "TTActivityShareManager.h"
#import "TTThemedAlertController.h"
#import "TTStringHelper.h"
#import "TTDeviceHelper.h"
#import "TTPostThreadViewController.h"
#import "TTRoute.h"

@interface FRForumGossipViewController ()

@property (nonatomic, strong)NSString *urlStr;
@property (nonatomic, strong)NSString *cid;//关心ID

@property (nonatomic, strong)SSWebViewContainer *webViewContainer;
@property (nonatomic, assign)BOOL refreshTag;
@property (nonatomic, assign)BOOL hideMore;
@end

@implementation FRForumGossipViewController

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    NSDictionary *params = paramObj.allParams;
    NSString * urlStr = nil;
    if ([params.allKeys containsObject:@"url"]) {
        urlStr = [params objectForKey:@"url"];
        if ([params.allKeys containsObject:@"ttencoding"]) {
            if ([[params objectForKey:@"ttencoding"] isEqualToString:@"base64"]) {
                urlStr = [TTStringHelper decodeStringFromBase64Str:urlStr];
            }
        }
    }
    
    NSString *cid = [params objectForKey:@"cid"];
    if (isEmptyString(cid)) {
        //服务器切了话题到关心，跳转到本页面的schema缓存可能没有更新。Hard-code concern id
        cid = @"6216118333691922945";
    }
    self = [self initWithUrlString:urlStr andConcernId:cid];
    
    self.hideMore = NO;
    if ([params.allKeys containsObject:@"hide_more"]) {
        self.hideMore = [params[@"hide_more"] boolValue];
    }
    
    return self;
}

- (instancetype)initWithUrlString:(NSString *)urlString andConcernId:(NSString *)cid {
    self = [super initWithRouteParamObj:nil];
    if (self) {
        self.urlStr = urlString;
        self.cid = cid;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.titleView = [SSNavigationBar navigationTitleViewWithTitle:NSLocalizedString(@"我要爆料", nil)];
    
    if (!self.hideMore) {
        SSThemedButton *rightButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake(0, 0, 60, 60);
        [rightButton setImageEdgeInsets:UIEdgeInsetsMake(0, 40, 0, -6)];
        rightButton.imageName = @"new_more_titlebar.png";
        rightButton.highlightedImageName = @"new_more_titlebar_press.png";
        [rightButton addTarget:self action:@selector(moreActionFired:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    }

    self.webViewContainer = [[SSWebViewContainer alloc] initWithFrame:self.view.bounds];
    [_webViewContainer hiddenProgressView:YES];
    _webViewContainer.backgroundColorThemeName = kColorBackground4;
    _webViewContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    if (@available(iOS 11.0, *)) {
        _webViewContainer.ssWebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
    }
    [self.view addSubview:_webViewContainer];

    BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
    _urlStr = [NSString stringWithFormat:@"%@#tt_daymode=%d",_urlStr,isDayModel];
    [_webViewContainer loadRequest:[NSURLRequest requestWithURL:[TTStringHelper URLWithURLString:_urlStr]]];
    
    //关心版本的发帖通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postFinish:) name:kForumPostThreadFinish object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_refreshTag) {
        self.refreshTag = NO;
        [_webViewContainer loadRequest:[NSURLRequest requestWithURL:[TTStringHelper URLWithURLString:_urlStr]]];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Notification
- (void)postFinish:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    if ([[userInfo objectForKey:@"cid"] isKindOfClass:[NSString class]]) {
        NSString *cid = [userInfo objectForKey:@"cid"];
        if (!isEmptyString(cid) && [cid isEqualToString:_cid]) {
            self.refreshTag = YES;
            [self.navigationController popToViewController:self animated:NO];
            FRConcernHomepageViewController *concernHomePageVC = [[FRConcernHomepageViewController alloc] initWithConcernID:cid baseCondition:nil apiParameter:nil enterTabName:nil];
            [self.navigationController pushViewController:concernHomePageVC animated:NO];
        }
    }
}

#pragma mark - Action
- (void)moreActionFired:(id)sender {
    NSString *refreshTitle = NSLocalizedString(@"刷新", nil)?:@"刷新";
    NSString *copyTitle = NSLocalizedString(@"复制链接", nil)?:@"复制链接";
    NSString *safariTitle = NSLocalizedString(@"使用Safari打开", nil)?:@"使用Safari打开";
    NSString *cancelTitle = NSLocalizedString(@"取消", nil)?:@"取消";
    if (![TTDeviceHelper isPadDevice]) {
        TTThemedAlertController *actionSheet = [[TTThemedAlertController alloc] initWithTitle:nil message:nil preferredType:TTThemedAlertControllerTypeActionSheet];
        [actionSheet addActionWithTitle:refreshTitle actionType:TTThemedAlertActionTypeNormal actionBlock:^{
            [_webViewContainer.ssWebView reload];
        }];
        [actionSheet addActionWithTitle:copyTitle actionType:TTThemedAlertActionTypeNormal actionBlock:^{
            [TTActivityShareManager copyText:[_webViewContainer.ssWebView.request.URL absoluteString]];
        }];
        [actionSheet addActionWithTitle:safariTitle actionType:TTThemedAlertActionTypeNormal actionBlock:^{
            [[UIApplication sharedApplication] openURL:_webViewContainer.ssWebView.request.URL];
        }];
        [actionSheet addActionWithTitle:cancelTitle actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
        [actionSheet showFrom:self animated:YES];
    }
}

@end
