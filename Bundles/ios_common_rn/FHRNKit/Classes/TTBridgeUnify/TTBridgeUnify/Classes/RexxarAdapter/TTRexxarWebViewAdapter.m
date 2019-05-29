//
//  TTRexxarWebViewAdapter.m
//  TTBridgeUnify
//
//  Created by 李琢鹏 on 2019/3/29.
//

#import "TTRexxarWebViewAdapter.h"
#import <objc/runtime.h>
#import "TTBridgeForwarding.h"
#import "TTWebViewBridgeEngine.h"
#import "TTBridgeAuthManager.h"

static NSString * kTTBridgeScheme = @"bytedance";
static NSString * kTTBridgeDomReadyHost = @"domReady";
static NSString * kTTBridgeHost = @"dispatch_message";
static NSString * kTTBridgeObject= @"ToutiaoJSBridge";
static NSString * kTTBridgeHandleMessageMethod = @"_handleMessageFromToutiao";
static NSString * kTTBridgeFetchQueueMethod = @"_fetchQueue";


@interface TTBridgeCommand (TTRexxarAdapter)

@property(nonatomic, assign) BOOL isRexxar;

@end

@implementation TTBridgeCommand (TTRexxarAdapter)

- (BOOL)isRexxar {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)setIsRexxar:(BOOL)isRexxar {
    objc_setAssociatedObject(self, @selector(isRexxar), @(isRexxar), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@interface TTBridgeAuthManager (TTRexxarAdapter)

@end

@implementation TTBridgeAuthManager (TTRexxarAdapter)

+ (void)load {
    Method originalMethod = class_getInstanceMethod(TTBridgeAuthManager.class, @selector(hasAuthForCommand:engine:domain:));
    Method replacementMethod = class_getInstanceMethod(TTBridgeAuthManager.class, @selector(ttra_hasAuthForCommand:engine:domain:));
    method_exchangeImplementations(originalMethod, replacementMethod);
}

+ (NSDictionary<NSString *, NSNumber *> *)publicBridge {
    return @{@"config" : @YES,
             @"appInfo" : @YES,
             @"adInfo" : @YES,
             @"login" : @YES,
             @"comment" : @YES,
             @"close" : @YES,
             @"isVisible" : @YES,
             @"is_visible" : @YES,
             @"is_login" : @YES,
             @"playVideo" : @YES,
             @"gallery" : @YES,
             @"shareInfo" : @YES,
             @"searchParams" : @YES,
             @"requestChangeOrientation" : @YES,
             @"formDialogClose" : @YES,
             @"showActionSheet" : @YES,
             @"dislike" : @YES,
             @"typos" : @YES,
             @"user_follow_action" : @YES,
             @"toggleGalleryBars" : @YES,
             @"slideShow" : @YES,
             @"relatedShow" : @YES,
             @"adImageShow" : @YES,
             @"slideDownload" : @YES,
             @"zoomStatus" : @YES,
             @"adImageLoadFinish" : @YES,
             @"adImageClick" : @YES,
             @"setupFollowButton" : @YES,
             @"tellClientRetryPrefetch" : @YES,
             @"report" : @YES,
             @"openComment" : @YES,
             @"commentDigg" : @YES};
}

+ (BOOL)ttra_hasAuthForCommand:(TTBridgeCommand *)command
                   engine:(id<TTBridgeEngine>)engine
                   domain:(NSString *)domain {
    if (self.class.publicBridge[command.fullName] && command.isRexxar) {
        return YES;
    }
    return [self ttra_hasAuthForCommand:command engine:engine domain:domain];
}

+ (NSDictionary<NSString *, NSNumber *> *)publicEvent {
    return @{
             @"login" : @YES,
             @"logout" : @YES,
             @"close" : @YES,
             @"visible" : @YES,
             @"invisible" : @YES,
             };
}

- (BOOL)engine:(id<TTBridgeEngine>)engine isAuthorizedEvent:(NSString *)eventName domain:(NSString *)domain {
    if (self.class.publicEvent[eventName]) {
        return YES;
    }
    
    TTBridgeCommand *command = [[TTBridgeCommand alloc] init];
    command.fullName = eventName;
    return [self engine:engine isAuthorizedBridge:command domain:domain];
}

@end

@interface WKWebView ()

@property(nonatomic, assign) BOOL tt_rexxarAdapterEnabled;

@end

@interface UIWebView ()

@property(nonatomic, assign) BOOL tt_rexxarAdapterEnabled;

@end

@interface TTRexxarWebViewAdapter ()

+ (BOOL)handleBridgeRequest:(NSURLRequest *)request engine:(TTWebViewBridgeEngine *)engine;

@end

@interface _TTWebViewDynamicDelegate : NSProxy<UIWebViewDelegate>

@property(nonatomic, weak) id realDelegate;

@end

@implementation _TTWebViewDynamicDelegate

- (BOOL)respondsToSelector:(SEL)aSelector {
    return  [super respondsToSelector:aSelector] || class_respondsToSelector(object_getClass(self), aSelector) || [self.realDelegate respondsToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    if ([self.realDelegate methodSignatureForSelector:aSelector]) {
        return [self.realDelegate methodSignatureForSelector:aSelector];
    }
    else if (class_respondsToSelector(object_getClass(self), aSelector)) {
        return [object_getClass(self) methodSignatureForSelector:aSelector];
    }
    return [[NSObject class] methodSignatureForSelector:aSelector];
}


- (void)forwardInvocation:(NSInvocation *)invocation {
    if ([self.realDelegate respondsToSelector:invocation.selector]) {
        [invocation invokeWithTarget:self.realDelegate];
    }
}


@end

@interface _TTWKWebViewDynamicDelegate : _TTWebViewDynamicDelegate<WKNavigationDelegate>

@end

@implementation _TTWKWebViewDynamicDelegate


- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([TTRexxarWebViewAdapter handleBridgeRequest:navigationAction.request engine:webView.tt_engine]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    id realDelegate = self.realDelegate;
    if (realDelegate && [realDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        [realDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }
    else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

@end

@implementation WKWebView (TTRexxarAdapter)

- (void)setTt_rexxarAdapterEnabled:(BOOL)tt_rexxarAdapterEnabled {
    objc_setAssociatedObject(self, @selector(tt_rexxarAdapterEnabled), @(tt_rexxarAdapterEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)tt_rexxarAdapterEnabled {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)ttra_setNavigationDelegate:(id<WKNavigationDelegate>)navigationDelegate {
    if (!self.tt_rexxarAdapterEnabled) {
        [self ttra_setNavigationDelegate:navigationDelegate];
        return;
    }
    _TTWKWebViewDynamicDelegate *dynamicDelegate = objc_getAssociatedObject(self, _cmd);
    if (!dynamicDelegate) {
        dynamicDelegate = _TTWKWebViewDynamicDelegate.alloc;
        objc_setAssociatedObject(self, _cmd, dynamicDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    dynamicDelegate.realDelegate = navigationDelegate;
    if (self.navigationDelegate != dynamicDelegate) {
        [self ttra_setNavigationDelegate:dynamicDelegate];
    }
}

- (void)tt_enableRexxarAdapter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod(WKWebView.class,  @selector(setNavigationDelegate:));
        Method replacementMethod = class_getInstanceMethod(WKWebView.class, @selector(ttra_setNavigationDelegate:));
        method_exchangeImplementations(originalMethod, replacementMethod);
    });
    if (!self.tt_rexxarAdapterEnabled) {
        self.tt_rexxarAdapterEnabled = YES;
    }
}
@end

@interface _TTUIWebViewDynamicDelegate : _TTWebViewDynamicDelegate<UIWebViewDelegate>

@end

@implementation _TTUIWebViewDynamicDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([TTRexxarWebViewAdapter handleBridgeRequest:request engine:webView.tt_engine]) {
        return NO;
    }
    id realDelegate = self.realDelegate;
    if (realDelegate && [realDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [realDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    return YES;
}

@end

@implementation UIWebView(TTRexxarAdapter)

- (void)setTt_rexxarAdapterEnabled:(BOOL)tt_rexxarAdapterEnabled {
    objc_setAssociatedObject(self, @selector(tt_rexxarAdapterEnabled), @(tt_rexxarAdapterEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)tt_rexxarAdapterEnabled {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (void)ttra_setDelegate:(id<UIWebViewDelegate>)delegate{
    if (!self.tt_rexxarAdapterEnabled) {
        [self ttra_setDelegate:delegate];
        return;
    }
    _TTUIWebViewDynamicDelegate *dynamicDelegate = objc_getAssociatedObject(self, _cmd);
    if (!dynamicDelegate) {
        dynamicDelegate = _TTUIWebViewDynamicDelegate.alloc;
        objc_setAssociatedObject(self, _cmd, dynamicDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    dynamicDelegate.realDelegate = delegate;
    if (self.delegate != dynamicDelegate) {
        [self ttra_setDelegate:dynamicDelegate];
    }
}

- (void)tt_enableRexxarAdapter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method originalMethod = class_getInstanceMethod(UIWebView.class,  @selector(setDelegate:));
        Method replacementMethod = class_getInstanceMethod(UIWebView.class, @selector(ttra_setDelegate:));
        method_exchangeImplementations(originalMethod, replacementMethod);
    });
    if (!self.tt_rexxarAdapterEnabled) {
        self.tt_rexxarAdapterEnabled = YES;
    }
}

@end

@implementation TTRexxarWebViewAdapter


static void invokeJSBCallbackWithCommand(TTBridgeCommand *command,
                                         TTBridgeMsg msg,
                                         NSDictionary *response,
                                         TTWebViewBridgeEngine *engine,
                                         void (^resultBlock)(NSString *result)) {
    if (!command) {
        return;
    }
    
    TTBridgeCommand *newCommand = [command copy];
    NSMutableDictionary *param = response.mutableCopy;
    [param setValue:@"1" forKey:@"rexxar_adapter"];
    switch (msg) {
        case TTBridgeMsgSuccess:
            [param setValue:@"JSB_SUCCESS" forKey:@"ret"];
            break;
        case TTBridgeMsgFailed:
            [param setValue:@"JSB_FAILED" forKey:@"ret"];
            break;
        case TTBridgeMsgParamError:
            [param setValue:@"JSB_PARAM_ERROR" forKey:@"ret"];
            break;
        case TTBridgeMsgNoHandler:
            [param setValue:@"JSB_NO_HANDLER" forKey:@"ret"];
            break;
        case TTBridgeMsgNoPermission:
            [param setValue:@"JSB_NO_PERMISSION" forKey:@"ret"];
            break;
        default:
            [param setValue:@"JSB_UNKNOW_ERROR" forKey:@"ret"];
            break;
    }
    newCommand.messageType = @"callback";
    newCommand.params = [param copy];
    newCommand.endTime = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
    
    NSString *jsonCommand = [newCommand toJSONString];
    NSString *invokeJS = [NSString stringWithFormat:@";window.%@ && %@.%@(%@)", kTTBridgeObject, kTTBridgeObject, kTTBridgeHandleMessageMethod, jsonCommand];
    [engine evaluateJavaScript:invokeJS completionHandler:^(id result, NSError *error) {
        if (resultBlock) {
            resultBlock([result isKindOfClass:[NSString class]] ? result : nil);
        }
    }];
}

+ (BOOL)handleBridgeRequest:(NSURLRequest *)request engine:(TTWebViewBridgeEngine *)engine {
    NSURL *url = request.URL;
    if (![url.scheme isEqualToString:kTTBridgeScheme] || ![url.host isEqualToString:kTTBridgeHost]) {
        return NO;
    }
    
    [engine evaluateJavaScript:[NSString stringWithFormat:@";window.%@ && %@.%@();", kTTBridgeObject, kTTBridgeObject, kTTBridgeFetchQueueMethod] completionHandler:^(NSString *result, NSError *error) {
        NSArray *messageData = nil;
        if ([result isKindOfClass:NSString.class] && result.length > 0) {
            __auto_type data = [result dataUsingEncoding:NSUTF8StringEncoding];
            if (data) {
                messageData = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            }
        }
        for(NSDictionary *message in messageData) {
            // 将 Rexxar bridge 转发到 TTBridgeUnify 的类处理
            __auto_type forwardMessage = ^{
                TTBridgeCommand *command = [[TTBridgeCommand alloc] initWithDictonary:message];
                command.isRexxar = YES;
                command.startTime = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
                [[TTBridgeForwarding sharedInstance] forwardWithCommand:command weakEngine:engine completion:^(TTBridgeMsg msg, NSDictionary *params, void (^resultBlock)(NSString *result)) {
                    invokeJSBCallbackWithCommand(command, msg, params, engine, resultBlock);
                }];
            };
            
            if (self.bridgeFilter) {
                // 如果设置了 filter, 且符合 Adapt 的条件，则转发 Rexxar bridge 到 TTBridgeUnify
                if ([self.bridgeFilter respondsToSelector:@selector(shouldAdaptBridge:engine:)] &&
                    [self.bridgeFilter shouldAdaptBridge:message engine:engine]) {
                    forwardMessage();
                }
            }
            else {// 没有设置 filter 的情况下默认转发所有的 Rexxar bridge
                forwardMessage();
            }
        }
    }];
    
    return YES;
}



+ (void)fireEvent:(NSString *)eventName data:(NSDictionary *)data engine:(TTWebViewBridgeEngine *)engine {
    if ([engine respondsToSelector:@selector(authorization)] &&
        [engine.authorization respondsToSelector:@selector(engine:isAuthorizedEvent:domain:)]) {
        if (![engine.authorization engine:engine isAuthorizedEvent:eventName domain:engine.sourceURL.absoluteString]) {
            return;
        }
    }
    
    TTBridgeCommand *command = [[TTBridgeCommand alloc] init];
    command.messageType = @"event";
    command.eventID = [eventName copy];
    NSMutableDictionary *param = data.mutableCopy;
    [param setValue:@"1" forKey:@"rexxar_adapter"];
    command.params = [param copy];
    
    NSString *jsonCommand = [command toJSONString];
    NSString *invokeJS = [NSString stringWithFormat:@";window.%@ && %@.%@(%@)", kTTBridgeObject, kTTBridgeObject, kTTBridgeHandleMessageMethod, jsonCommand];
    [engine evaluateJavaScript:invokeJS completionHandler:^(id result, NSError *error) {
        
    }];
}

static Class<TTRexxarWebViewAdapterFilter> _bridgeFilter;

+ (void)setBridgeFilter:(Class<TTRexxarWebViewAdapterFilter>)bridgeFilter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _bridgeFilter = bridgeFilter;
    });
}

+ (Class<TTRexxarWebViewAdapterFilter>)bridgeFilter {
    return _bridgeFilter;
}

@end
