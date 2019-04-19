//
//  TTWebViewBridgeEngine.h
//  NewsInHouse
//
//  Created by 李琢鹏 on 2018/10/23.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "TTBridgeEngine.h"
#import "TTBridgeAuthorization.h"

@class TTWebViewBridgeEngine, TTRStaticPlugin;

@interface UIWebView (TTBridge)

@property (nonatomic, strong, readonly) TTWebViewBridgeEngine *tt_engine;

- (void)tt_installBridgeEngine:(TTWebViewBridgeEngine *)bridge;

@end

@interface WKWebView (TTBridge)

@property (nonatomic, strong, readonly) TTWebViewBridgeEngine *tt_engine;

- (void)tt_installBridgeEngine:(TTWebViewBridgeEngine *)bridge;
- (void)tt_uninstallBridgeEngine;

@end

@interface TTWebViewBridgeEngine : NSObject<TTBridgeEngine>

@property (nonatomic, weak) UIViewController *sourceController;

@property (nonatomic, strong, readonly) NSURL *sourceURL;

@property (nonatomic, strong) id<TTBridgeAuthorization> authorization;

@property (nonatomic, weak, readonly) NSObject *sourceObject;

- (void)installOnUIWebView:(UIWebView *)webView;
- (void)installOnWKWebView:(WKWebView *)webView;

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id result, NSError *error))completionHandler;

@end
