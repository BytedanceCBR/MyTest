//
//  TTFantasyWebviewAdaptor.m
//  Article
//
//  Created by 钟少奋 on 2017/12/23.
//

#import "TTFantasyWebviewAdaptor.h"
#import "TTSecurityUtil.h"
#import "SmAntiFraud.h"
#import "Base64.h"
#import "SSWebViewContainer.h"

@interface TTFantasyWebviewAdaptor()

@property (nonatomic, strong) SSWebViewContainer *webviewContainer;

@end

@implementation TTFantasyWebviewAdaptor

- (void)dealloc
{
    [_webviewContainer.ssWebView removeDelegate:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _webviewContainer = [[SSWebViewContainer alloc] init];
        [_webviewContainer.ssWebView addDelegate:self];
        _webviewContainer.ssWebView.scrollView.bounces = NO;
        [_webviewContainer hiddenProgressView:YES];
        [self registerSecurityBridge];
        [self registerDeviceInfoBridge];
    }
    return self;
}

#pragma mark - TTFWebViewProtocol
- (void)loadRequest:(NSURLRequest *)request {
    [self.webviewContainer loadRequest:request];
}

- (BOOL)canGoBack {
    return [self.webviewContainer.ssWebView canGoBack];
}

- (void)goBack {
    [self.webviewContainer.ssWebView goBack];
}

- (UIView *)realView {
    return self.webviewContainer;
}

- (JSContext *)jsContext {
    return self.webviewContainer.ssWebView.jsContext;
}

#pragma mark YSWebViewDelegate

- (void)webViewDidStartLoad:(nullable YSWebView *)webView {
    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:webView];
    }
}

- (void)webViewDidFinishLoad:(nullable YSWebView *)webView {
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:webView];
    }
}

- (BOOL)webView:(nullable YSWebView *)webView shouldStartLoadWithRequest:(nullable NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType {
    if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [self.delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return NO;
}

- (void)webView:(nullable YSWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:webView didFailLoadWithError:error];
    }
}

#pragma mark - register security
- (void)registerSecurityBridge {
    [self.webviewContainer.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse completion) {
        NSString *data = [[params tt_stringValueForKey:@"data"] base64DecodedString];
        NSString *token = [params tt_stringValueForKey:@"token"];
        NSString *ret = [[TTSecurityUtil sharedInstance] encrypt:data token:token];
        NSDictionary *dic = @{@"code": @1,
                              @"data": @{ @"value": ret ?: @"" }
                              };
        completion(TTRJSBMsgSuccess,dic);
    } forMethodName:@"encrypt"];
    
    [self.webviewContainer.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse completion) {
        NSString *data = [params tt_stringValueForKey:@"data"];
        NSString *token = [params tt_stringValueForKey:@"token"];
        NSString *ret = [[TTSecurityUtil sharedInstance] decrypt:data token:token];
        NSDictionary *dic = @{@"code": @1,
                              @"data": @{ @"value": ret ?: @"" }
                              };
        completion(TTRJSBMsgSuccess,dic);
    } forMethodName:@"decrypt"];

}

- (void)registerDeviceInfoBridge {
    [self.webviewContainer.ssWebView.ttr_staticPlugin registerHandlerBlock:^(NSDictionary *params, TTRJSBResponse completion) {
        NSDictionary *ret = [[SmAntiFraud shareInstance] getDeviceInfoWithConfiguration:params];
        NSDictionary *dic = @{@"code": @1,
                              @"data": ret ?: @{}
                              };
        completion(TTRJSBMsgSuccess,dic);
    } forMethodName:@"deviceInfo"];
}

@end
