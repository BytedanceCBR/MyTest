//
//  TTRNWebViewManager.m
//  Article
//
//  Created by Chen Hong on 16/8/7.
//
//

#import "TTRNWebViewManager.h"
#import "TTRNWebView.h"
#import "RCTBridge.h"
#import "RCTUIManager.h"
#import "UIView+React.h"

@implementation TTRNWebViewManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    TTRNWebView *webView = [[TTRNWebView alloc] init];
    return webView;
}

RCT_EXPORT_VIEW_PROPERTY(source, NSDictionary)
RCT_REMAP_VIEW_PROPERTY(bounces, _webView.scrollView.bounces, BOOL)
RCT_REMAP_VIEW_PROPERTY(scrollEnabled, _webView.scrollView.scrollEnabled, BOOL)
RCT_REMAP_VIEW_PROPERTY(decelerationRate, _webView.scrollView.decelerationRate, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(scalesPageToFit, BOOL)
//RCT_EXPORT_VIEW_PROPERTY(injectedJavaScript, NSString)
RCT_EXPORT_VIEW_PROPERTY(contentInset, UIEdgeInsets)
RCT_EXPORT_VIEW_PROPERTY(automaticallyAdjustContentInsets, BOOL)
//RCT_EXPORT_VIEW_PROPERTY(onLoadingStart, RCTDirectEventBlock)
//RCT_EXPORT_VIEW_PROPERTY(onLoadingFinish, RCTDirectEventBlock)
//RCT_EXPORT_VIEW_PROPERTY(onLoadingError, RCTDirectEventBlock)
//RCT_EXPORT_VIEW_PROPERTY(onShouldStartLoadWithRequest, RCTDirectEventBlock)
//RCT_REMAP_VIEW_PROPERTY(allowsInlineMediaPlayback, _webView.allowsInlineMediaPlayback, BOOL)
//RCT_REMAP_VIEW_PROPERTY(mediaPlaybackRequiresUserAction, _webView.mediaPlaybackRequiresUserAction, BOOL)


RCT_EXPORT_METHOD(goBack:(nonnull NSNumber *)reactTag)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, TTRNWebView *> *viewRegistry) {
        TTRNWebView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[TTRNWebView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RCTWebView, got: %@", view);
        } else {
            [view goBack];
        }
    }];
}

RCT_EXPORT_METHOD(goForward:(nonnull NSNumber *)reactTag)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, UIView *> *viewRegistry) {
        id view = viewRegistry[reactTag];
        if (![view isKindOfClass:[TTRNWebView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RCTWebView, got: %@", view);
        } else {
            [view goForward];
        }
    }];
}

RCT_EXPORT_METHOD(reload:(nonnull NSNumber *)reactTag)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, TTRNWebView *> *viewRegistry) {
        TTRNWebView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[TTRNWebView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RCTWebView, got: %@", view);
        } else {
            [view reload];
        }
    }];
}

RCT_EXPORT_METHOD(stopLoading:(nonnull NSNumber *)reactTag)
{
    [self.bridge.uiManager addUIBlock:^(__unused RCTUIManager *uiManager, NSDictionary<NSNumber *, TTRNWebView *> *viewRegistry) {
        TTRNWebView *view = viewRegistry[reactTag];
        if (![view isKindOfClass:[TTRNWebView class]]) {
            RCTLogError(@"Invalid view returned from registry, expecting RCTWebView, got: %@", view);
        } else {
            [view stopLoading];
        }
    }];
}


@end
