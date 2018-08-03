//
//  SSJSBridgeWebView.h
//  Article
//
//  Created by Dianwei on 14-10-11.
//
//

#import <UIKit/UIKit.h>
#import "YSWebView.h"
#import <TTRexxar/TTRexxarEngine.h>

extern NSString *const TTWebViewDidBlockRequestNotification;
extern NSString *const TTWebViewRequestKey;

@interface SSJSBridgeWebView : YSWebView<TTRexxarEngine>

- (void)addDelegate:(NSObject<YSWebViewDelegate> *)delegate;

- (void)removeDelegate:(NSObject<YSWebViewDelegate> *) delegate;

- (void)removeAllDelegates;

+ (Class)JSBridgeClass;

- (void)invokeVisibleEvent;

- (void)invokeInvisibleEvent;

@property(nonatomic, readonly)BOOL isDomReady;

@property(nonatomic)BOOL useCustomVisibleEvent;

@property(nonatomic, assign) BOOL disableThemedMask;

@property(nonatomic, assign) NSInteger colorKey;
@property(nonatomic, assign) BOOL disableNightBackground;
@property(nonatomic, assign) BOOL shouldInterceptUrls;

- (void)loadRequest:(NSURLRequest *)request appendBizParams:(BOOL)append;

// [aikan] 强制通知前端setVisible，轻量级刷新，解决reloadWebView闪的问题
- (void)weakReload;

@end
