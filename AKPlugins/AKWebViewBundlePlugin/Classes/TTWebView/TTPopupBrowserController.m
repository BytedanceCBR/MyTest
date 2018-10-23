//
//  TTPopupBrowserController.m
//  TTWebViewBundle
//
//  Created by muhuai on 2017/10/17.
//  Copyright © 2017年 muhuai. All rights reserved.
//

#import "TTPopupBrowserController.h"
#import "SSJSBridgeWebView.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>

@interface TTPopupBrowserController ()
@property (nonatomic, strong) SSJSBridgeWebView *webview;
@property (nonatomic, strong) NSString *url;

@end

@implementation TTPopupBrowserController

+ (void)load {
    [TTRoute registerRouteEntry:@"popup_browser" withObjClass:self];
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        _url = [paramObj.allParams tt_stringValueForKey:@"url"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]] appendBizParams:YES];
}

- (void)setupViews {
    _webview = [[SSJSBridgeWebView alloc] initWithFrame:self.view.bounds disableWKWebView:NO];
    [self.view addSubview:_webview];
}

#pragma mark - TTRouteInitializeProtocol
+ (TTRouteViewControllerOpenStyle)preferredRouteViewControllerOpenStyle {
    return TTRouteViewControllerOpenStylePresent;
}

- (NSString *)presentNavigationControllerName {
    return NSStringFromClass(TTModalContainerController.class);
}

+ (TTRouteUserInfo *)reassginedUserInfoWithParamObj:(nullable TTRouteParamObj *)paramObj {
    NSMutableDictionary * pageCondition = [paramObj.userInfo.allInfo mutableCopy]? :[[NSMutableDictionary alloc] init];
    [pageCondition setValue:@(0) forKey:@"animated"];
    return TTRouteUserInfoWithDict(pageCondition);
}

#pragma mark - TTModalWrapControllerProtocol
- (UIScrollView *)tt_scrollView {
    return self.webview.scrollView;
}

- (NSArray<UIView *> *)simultaneouslyPullGestureViews {
    NSMutableArray *views = [[NSMutableArray alloc] init];
    [views addObject:self.webview.scrollView];
    
    for (UIView *subView in self.webview.scrollView.subviews) {
        if ([NSStringFromClass([subView class]) hasPrefix:@"UIWebBrowserView"]) {
            [views addObject:subView];
            break;
        }
    }
    
    return views;
}

- (BOOL)shouldDisableRightSwipeGesture {
    return YES;
}

- (TTModalControllerTitleType)leftBarItemStyle {
    return TTModalControllerTitleTypeBoth;
}

- (BOOL)hiddenTitleViewBottomLineInModalContainer {
    return YES;
}

- (BOOL)shouldInterceptBackBarItemInModalContainer {
    if (![self.webview canGoBack]) {
        return NO;
    }
    [self.webview goBack];
    return YES;
}
@end
