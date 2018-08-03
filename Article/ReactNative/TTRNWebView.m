//
//  TTRNWebView.m
//  Article
//
//  Created by Chen Hong on 16/8/8.
//
//

#import "TTRNWebView.h"

#import "RCTAutoInsetsProtocol.h"
#import "RCTConvert.h"
#import "RCTEventDispatcher.h"
#import "RCTLog.h"
#import "RCTUtils.h"
#import "RCTView.h"
#import "UIView+React.h"

#import "SSJSBridgeWebView.h"

/**
 *  
 import {requireNativeComponent} from 'react-native';
 
 var TTWebView = requireNativeComponent('TTRNWebView', TTWebView);
 
 <TTWebView
     source={{uri: 'http://m.toutiao.com/m6103999542'}}
     style={{height: 320}}
 />
 
 */

@interface TTRNWebView () <YSWebViewDelegate, RCTAutoInsetsProtocol>
@property(nonatomic, strong)SSJSBridgeWebView *webView;
@end

@implementation TTRNWebView

- (void)dealloc
{
    [_webView removeDelegate:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        super.backgroundColor = [UIColor clearColor];
        _automaticallyAdjustContentInsets = YES;
        _contentInset = UIEdgeInsetsZero;
        _webView = [[SSJSBridgeWebView alloc] initWithFrame:self.bounds];
        _webView.opaque = NO;
        [_webView addDelegate:self];
        [self addSubview:_webView];
    }
    return self;
}

RCT_NOT_IMPLEMENTED(- (instancetype)initWithCoder:(NSCoder *)aDecoder)

- (void)goForward
{
    [_webView goForward];
}

- (void)goBack
{
    [_webView goBack];
}

- (void)reload
{
    NSURLRequest *request = [RCTConvert NSURLRequest:self.source];
    if (request.URL && !_webView.request.URL.absoluteString.length) {
        [_webView loadRequest:request];
    }
    else {
        [_webView reload];
    }
}

- (void)stopLoading
{
    [_webView stopLoading];
}

- (void)setSource:(NSDictionary *)source
{
    if (![_source isEqualToDictionary:source]) {
        _source = [source copy];
        
        // Check for a static html source first
        NSString *html = [RCTConvert NSString:source[@"html"]];
        if (html) {
            NSURL *baseURL = [RCTConvert NSURL:source[@"baseUrl"]];
            if (!baseURL) {
                baseURL = [NSURL URLWithString:@"about:blank"];
            }
            [_webView loadHTMLString:html baseURL:baseURL];
            return;
        }
        
        NSURLRequest *request = [RCTConvert NSURLRequest:source];
        // Because of the way React works, as pages redirect, we actually end up
        // passing the redirect urls back here, so we ignore them if trying to load
        // the same url. We'll expose a call to 'reload' to allow a user to load
        // the existing page.
        if ([request.URL isEqual:_webView.request.URL]) {
            return;
        }
        if (!request.URL) {
            // Clear the webview
            [_webView loadHTMLString:@"" baseURL:nil];
            return;
        }
        [_webView loadRequest:request];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _webView.frame = self.bounds;
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    _contentInset = contentInset;
    [RCTView autoAdjustInsetsForView:self
                      withScrollView:_webView.scrollView
                        updateOffset:NO];
}

- (void)setScalesPageToFit:(BOOL)scalesPageToFit
{
    if (_webView.scalesPageToFit != scalesPageToFit) {
        _webView.scalesPageToFit = scalesPageToFit;
        [_webView reload];
    }
}

- (BOOL)scalesPageToFit
{
    return _webView.scalesPageToFit;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    CGFloat alpha = CGColorGetAlpha(backgroundColor.CGColor);
    self.opaque = _webView.opaque = (alpha == 1.0);
    _webView.backgroundColor = backgroundColor;
}

- (UIColor *)backgroundColor
{
    return _webView.backgroundColor;
}

- (NSMutableDictionary<NSString *, id> *)baseEvent
{
    NSMutableDictionary<NSString *, id> *event = [[NSMutableDictionary alloc] initWithDictionary:@{
                                                                                                   @"url": _webView.request.URL.absoluteString ?: @"",
                                                                                                   @"loading" : @(_webView.isLoading),
                                                                                                   @"canGoBack": @(_webView.canGoBack),
                                                                                                   @"canGoForward" : @(_webView.canGoForward),
                                                                                                   }];
    
    return event;
}

- (void)refreshContentInset
{
    [RCTView autoAdjustInsetsForView:self
                      withScrollView:_webView.scrollView
                        updateOffset:YES];
}

#pragma mark - YSWebViewDelegate methods

- (BOOL)webView:(__unused YSWebView *)webView shouldStartLoadWithRequest:(nullable NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType
{
    return YES;
}

- (void)webView:(__unused YSWebView *)webView didFailLoadWithError:(NSError *)error
{
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
}

@end
