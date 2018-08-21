//
//  YSWebView.h
//
//  Created by Bogdan Hapca on 07/01/15.
//  Copyright (c) 2015 Yardi. All rights reserved.
//

@import UIKit;
@import WebKit;
@import JavaScriptCore;
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, YSWebViewNavigationType) {
    YSWebViewNavigationTypeLinkClicked,
    YSWebViewNavigationTypeFormSubmitted,
    YSWebViewNavigationTypeBackForward,
    YSWebViewNavigationTypeReload,
    YSWebViewNavigationTypeFormResubmitted,
    YSWebViewNavigationTypeOther
};


@class YSWebView;

@protocol YSWebViewDelegate <NSObject>

@optional
- (void)webViewDidStartLoad:(nullable YSWebView *)webView;
- (void)webViewDidFinishLoad:(nullable YSWebView *)webView;
- (void)webviewDidLayoutSubviews:(nullable YSWebView *)webview;
- (void)webView:(nullable YSWebView *)webView didFailLoadWithError:(nullable NSError *)error;
- (BOOL)webView:(nullable YSWebView *)webView shouldStartLoadWithRequest:(nullable NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType;

@end


typedef void(^JavaScriptCompletionBlock)(NSString * _Nullable result, NSError * _Nullable error);

typedef void(^WebViewLogHandler)(NSString * _Nullable msg);

/**
 *  Generic web view class that wraps a UIWebView or WKWebView,
 *  depending on which one is available, as its internal implementation
 */
@interface YSWebView : UIView

@property (nonatomic, weak, nullable) id<YSWebViewDelegate> delegate;
@property (nonatomic, readonly, weak, nullable) UIScrollView *scrollView;
//@property (nonatomic, readonly, weak, nullable) id innerWebView;


//init the webview and set disableWK
- (nullable instancetype)initWithFrame:(CGRect)frame disableWKWebView:(BOOL)disableWKWebView;

/**

 忽略kWKWebViewSettingSwitchKey, 根据enable来判断是否开启WK
 
 @param frame frame
 @param enable 是否开启WK
 @return instance
 */
- (nullable instancetype)initWithFrame:(CGRect)frame disableWKWebView:(BOOL)disableWKWebView ignoreGlobalSwitchKey:(BOOL)ignore;

- (BOOL)isWKWebView;
/**
 * 成为FirstResponder，主要为了修改第一次长按出menuView的系统问题
 */
- (void)tt_becomeFirstResponder;

/**
 * 暴露正在使用的webView
 */
- (nullable id)tt_webViewInUse;

/**
 * Loads the web view with content returned by an url request
 * @params request - the url request
 */
- (void)loadRequest:(nullable NSURLRequest *)request;

- (void)loadRequest:(NSURLRequest *)request shouldTransferedHttps:(BOOL)shouldTransfered shouldAppendQuery:(BOOL)shouldAppendQuery;

/**
 * Loads the web view with content returned by an url request
 * @params request - the url request
 * @params timeOut - max time imterval to wait for the page to load
 */
- (void)loadRequest:(nullable NSURLRequest *)request timeOut:(NSTimeInterval)timeOut;

- (void)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL;
/**
 * Loads the web view with HTML content
 * @params string - the string to use as the contents of the webpage
 * @params baseUrl - a URL that's used for resolving relative URLs within the document
 */
- (void)loadHTMLString:(nullable NSString *)string baseURL:(nullable NSURL *)baseURL;

/**
 * Loads the web view with HTML content
 * @params string - the string to use as the contents of the webpage
 * @params baseUrl - a URL that's used for resolving relative URLs within the document
 * @params timeOut - max time imterval to wait for the page to load
 */
- (void)loadHTMLString:(nullable NSString *)string baseURL:(nullable NSURL *)baseURL timeOut:(NSTimeInterval)timeOut;

/**
 * Returns the result of running a script
 * @params script - the script to run
 */
- (void)evaluateJavaScriptFromString:(nullable NSString *)script completionBlock:(JavaScriptCompletionBlock _Nullable)block;

/**
 * Stops the loading of web view
 */
- (void)stopLoading;

- (BOOL)isLoading;

- (void)reload;

- (void)goBack;

- (void)goForward;

- (nullable NSString *)stringByEvaluatingJavaScriptFromString:(NSString * _Nullable)javaScriptString completionHandler:(void (^ __nullable)(__nullable id, NSError * __nullable error))completionHandler;

- (nullable JSContext *)jsContext;

@property (nullable, nonatomic, readonly, strong) NSURLRequest *request;

@property (nullable, nonatomic, readonly, strong) NSURL *currentURL;

@property (nonatomic, readonly) BOOL canGoBack;

@property (nonatomic, readonly) BOOL canGoForward;

///是否根据视图大小来缩放页面  默认为YES
@property (nonatomic, assign) BOOL scalesPageToFit;

@property (nonatomic) UIDataDetectorTypes dataDetectorTypes;

@end

#pragma mark - YSInnerWebViewDelegate

@interface YSInnerWebViewDelegate : NSObject<UIWebViewDelegate, WKNavigationDelegate>

@property(nonatomic, weak, nullable) YSWebView *ysWebView;

@end
NS_ASSUME_NONNULL_END
