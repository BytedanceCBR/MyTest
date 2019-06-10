//
//  TTWebViewBridgeEngine.m
//  NewsInHouse
//
//  Created by 李琢鹏 on 2018/10/23.
//

#import "TTWebViewBridgeEngine.h"
#import "TTBridgeForwarding.h"
#import <JavaScriptCore/JSContext.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <JavaScriptCore/JSExport.h>
#import "BDAssert.h"

static NSString * kJSObject= @"Native2JSBridge";
static NSString * kJSHandleMessageMethod = @"_handleMessageFromApp";

void TTWebViewBridgeEngineSwapInstanceMethods(Class cls, SEL original, SEL replacement)
{
    Method originalMethod = class_getInstanceMethod(cls, original);
    IMP originalImplementation = method_getImplementation(originalMethod);
    const char *originalArgTypes = method_getTypeEncoding(originalMethod);
    
    Method replacementMethod = class_getInstanceMethod(cls, replacement);
    IMP replacementImplementation = method_getImplementation(replacementMethod);
    const char *replacementArgTypes = method_getTypeEncoding(replacementMethod);
    
    if (class_addMethod(cls, original, replacementImplementation, replacementArgTypes)) {
        class_replaceMethod(cls, replacement, originalImplementation, originalArgTypes);
    } else {
        method_exchangeImplementations(originalMethod, replacementMethod);
    }
}


static void invokeJSBCallbackWithCommand(TTBridgeCommand *command,
                                         TTBridgeMsg msg,
                                         NSDictionary *response,
                                         TTWebViewBridgeEngine *engine,
                                         void (^resultBlock)(NSString *result)) {
    if (!command) {
        return;
    }
    
    TTBridgeCommand *newCommand = [command copy];
    newCommand.endTime = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
    newCommand.messageType = @"callback";
    
    NSMutableDictionary *newResponse = [response mutableCopy] ? : [NSMutableDictionary dictionary];
    newResponse[@"recvJsCallTime"] = newCommand.startTime;
    newResponse[@"respJsTime"] = newCommand.endTime;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"code"] = @(msg);
    param[@"data"] = [newResponse copy];
    
    newCommand.params = [param copy];
    NSString *jsonCommand = [newCommand toJSONString];
    NSString *invokeJS = [NSString stringWithFormat:@";window.%@ && %@.%@(%@)", kJSObject, kJSObject, kJSHandleMessageMethod, jsonCommand];
    dispatch_async(dispatch_get_main_queue(), ^{
        [engine evaluateJavaScript:invokeJS completionHandler:^(id result, NSError *error) {
            if (resultBlock) {
                resultBlock([result isKindOfClass:[NSString class]] ? result : nil);
            }
        }];
    });
    
}

@implementation TTBridgeCommand (TTBridgeExtension)

+ (instancetype)commandWithMethod:(NSString *)method params:(NSDictionary *)params {
    NSMutableDictionary *mutableParams = [params mutableCopy];
    mutableParams[@"func"] = method;
    mutableParams[@"__msg_type"] = @"call";
    TTBridgeCommand *command = [[TTBridgeCommand alloc] initWithDictonary:[mutableParams copy]];
    return command;
}

@end

static void call(id<TTBridgeEngine> engine, NSString *method, NSDictionary *params) {
    if (!engine) {
        return;
    }
    __weak typeof(engine) weakEngine = engine;
    void (^invockBlock)(void) = ^{
        TTBridgeCommand *command = [TTBridgeCommand commandWithMethod:method params:params];
        command.startTime = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970] * 1000];
        command.bridgeType = TTBridgeTypeCall;
        [[TTBridgeForwarding sharedInstance] forwardWithCommand:command weakEngine:engine completion:^(TTBridgeMsg msg, NSDictionary *response, void (^resultBlock)(NSString *result)) {
            invokeJSBCallbackWithCommand(command, msg, response, weakEngine, resultBlock);
        }];
    };
    dispatch_async(dispatch_get_main_queue(), invockBlock);
}

static void on(id<TTBridgeEngine> engine, NSString *method, NSDictionary *params) {
    if (!engine) {
        return;
    }
    __weak typeof(engine) weakEngine = engine;
    void (^invockBlock)(void) = ^{
        TTBridgeCommand *command = [TTBridgeCommand commandWithMethod:method params:params];
        command.bridgeType = TTBridgeTypeOn;
        [[TTBridgeForwarding sharedInstance] forwardWithCommand:command weakEngine:engine completion:^(TTBridgeMsg msg, NSDictionary *response, void (^resultBlock)(NSString *result)) {
            invokeJSBCallbackWithCommand(command, msg, response, weakEngine, resultBlock);
        }];
    };
    dispatch_async(dispatch_get_main_queue(), invockBlock);
}

@interface TTWebViewBridgeEngine ()<WKScriptMessageHandler>

@property (nonatomic, weak, readonly) UIWebView *webView;
@property (nonatomic, weak) NSObject *sourceObject;

- (void)didCreateJavaScriptContext:(JSContext*)context;

@end

@interface UIWebView ()

@property (nonatomic, strong) TTWebViewBridgeEngine *tt_engine;

@end

@implementation UIWebView (TTBridge)

- (void)tt_installBridgeEngine:(TTWebViewBridgeEngine *)bridge {
    [bridge installOnUIWebView:self];
}

- (void)tt_uninstallBridgeEngine {
    [self.tt_engine uninstallFromUIWebView:self];
}

- (void)setTt_engine:(TTWebViewBridgeEngine *)tt_engine {
    objc_setAssociatedObject(self, @selector(tt_engine), tt_engine, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TTWebViewBridgeEngine *)tt_engine {
    return objc_getAssociatedObject(self, @selector(tt_engine));
}

@end

@interface WKWebView ()

@property (nonatomic, strong) TTWebViewBridgeEngine *tt_engine;

@end

@implementation WKWebView (TTBridge)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TTWebViewBridgeEngineSwapInstanceMethods(WKWebView.class, NSSelectorFromString(@"dealloc"), @selector(wkbridgeengine_dealloc));
    });
}

- (void)wkbridgeengine_dealloc {
    [self tt_uninstallBridgeEngine];
    [self wkbridgeengine_dealloc];
}

- (void)tt_installBridgeEngine:(TTWebViewBridgeEngine *)bridge {
    [bridge installOnWKWebView:self];
}

- (void)tt_uninstallBridgeEngine {
    [self.tt_engine uninstallFromWKWebView:self];
}

- (void)setTt_engine:(TTWebViewBridgeEngine *)tt_engine {
    objc_setAssociatedObject(self, @selector(tt_engine), tt_engine, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TTWebViewBridgeEngine *)tt_engine {
    return objc_getAssociatedObject(self, @selector(tt_engine));
}

@end


static NSHashTable* kWebViewEngines = nil;

@implementation NSObject (TTJavaScriptContext)

- (void)webView:(id)unused didCreateJavaScriptContext:(JSContext*)context forFrame:(id)frame {
    if (![NSThread isMainThread]) {
        BDAssert(NO, @"注入JS必须在主线程");
        return;
    }
    
    for (TTWebViewBridgeEngine* engine in kWebViewEngines) {
        if (!engine.webView) {
            continue;
        }
        NSString* cookie = [NSString stringWithFormat:@"ts_jscWebView_%lud", (unsigned long)engine.webView.hash];
        [engine.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat: @"var %@ = '%@'", cookie, cookie]];
        if ([context[cookie].toString isEqualToString:cookie]) {
            [engine didCreateJavaScriptContext:context];
            break;
        }
    }
}

@end



@implementation TTWebViewBridgeEngine

- (void)dealloc {

}

- (instancetype)initWithAuthorization:(id<TTBridgeAuthorization>)authorization {
    self = [super init];
    if (self) {
        _authorization = authorization;
    }
    return self;
}

- (void)didCreateJavaScriptContext:(JSContext*)context {
    __weak TTWebViewBridgeEngine *weakSelf = self;
    //这里有内存泄漏，暂时没找到办法解决，用block方式注入
    //    context[@"JS2NativeBridge"] = weakSelf;
    context[@"callMethodParams"] = ^(NSString *method, NSDictionary *params) {
        call(weakSelf, method, params);
    };
    context[@"onMethodParams"] = ^(NSString *method, NSDictionary *params) {
        on(weakSelf, method, params);
    };
}

+ (void)createGlobalEnginTable {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        kWebViewEngines = [NSHashTable weakObjectsHashTable];
    });
}

- (void)installOnUIWebView:(UIWebView *)webView {
    if (webView.tt_engine) {
        BDAssert(NO, @"%@ already has a bridge engine.", webView);
        return;
    }
    BDParameterAssert(webView != nil);
    [TTWebViewBridgeEngine createGlobalEnginTable];
    [kWebViewEngines addObject:self];
    self.sourceObject = webView;
    webView.tt_engine = self;
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    if (context && ![context[@"callMethodParams"] toObject]) {
        [self didCreateJavaScriptContext:context];
    }
}

- (void)uninstallFromUIWebView:(UIWebView *)webView {
    if (webView.tt_engine != self) {
        BDAssert(NO, @"%@ is not from %@.", self, webView);
        return;
    }
    JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    if (context) {
        JSStringRef callMethodParams = JSStringCreateWithUTF8CString(@"callMethodParams".UTF8String);
        JSObjectDeleteProperty(context.JSGlobalContextRef, JSContextGetGlobalObject(context.JSGlobalContextRef), callMethodParams, NULL);
        JSStringRelease(callMethodParams);
        
        JSStringRef onMethodParams = JSStringCreateWithUTF8CString(@"onMethodParams".UTF8String);
        JSObjectDeleteProperty(context.JSGlobalContextRef, JSContextGetGlobalObject(context.JSGlobalContextRef), onMethodParams, NULL);
        JSStringRelease(onMethodParams);
    }
    webView.tt_engine = nil;
}

- (void)installOnWKWebView:(WKWebView *)webView {
    if (webView.tt_engine) {
        BDAssert(NO, @"%@ already has a bridge engine.", webView);
        return;
    }
    BDParameterAssert(webView != nil);
    [TTWebViewBridgeEngine createGlobalEnginTable];
    [kWebViewEngines addObject:self];
    self.sourceObject = webView;
    webView.tt_engine = self;
    [webView.configuration.userContentController addScriptMessageHandler:self name:@"callMethodParams"];
    [webView.configuration.userContentController addScriptMessageHandler:self name:@"onMethodParams"];
}

- (void)uninstallFromWKWebView:(WKWebView *)webView {
    if (webView.tt_engine != self) {
        BDAssert(NO, @"%@ is not from %@.", self, webView);
        return;
    }
    [webView.configuration.userContentController removeScriptMessageHandlerForName:@"callMethodParams"];
    [webView.configuration.userContentController removeScriptMessageHandlerForName:@"onMethodParams"];
    webView.tt_engine = nil;
}

- (UIWebView *)webView {
    return [self.sourceObject isKindOfClass:[UIWebView class]] ? (UIWebView *)self.sourceObject : nil;
}

- (WKWebView *)wkWebView {
    return [self.sourceObject isKindOfClass:[WKWebView class]] ? (WKWebView *)self.sourceObject : nil;
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary *body = [message.body isKindOfClass:NSDictionary.class] ? message.body : nil;
    if (!body) {
        return;
    }
    if ([message.name isEqualToString:@"callMethodParams"]) {
        call(self, body[@"func"], body);
    } else if ([message.name isEqualToString:@"onMethodParams"]) {
        on(self, body[@"func"], body);
    }
}


#pragma mark - TTBridgeEngine
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id result, NSError *error))completionHandler {
    if (![NSThread isMainThread]) {
        BDAssert(NO, @"注入JS必须在主线程");
        return;
    }
    if ([self.sourceObject isKindOfClass:[UIWebView class]]) {
        NSString *result = [self.webView stringByEvaluatingJavaScriptFromString:javaScriptString];
        if (completionHandler) {
            completionHandler(result, nil);
        }
    }
    else if ([self.sourceObject isKindOfClass:[WKWebView class]]) {
        [self.wkWebView evaluateJavaScript:javaScriptString completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            if (completionHandler) {
                completionHandler(result, nil);
            }
        }];
    }
}

- (NSURL *)sourceURL {
    if ([self.sourceObject isKindOfClass:[UIWebView class]]) {
        NSString *hrefURLString = [self.webView stringByEvaluatingJavaScriptFromString:@"window.location.href"];
        return hrefURLString.length ? [NSURL URLWithString:hrefURLString] : self.webView.request.URL;
    }
    else if ([self.sourceObject isKindOfClass:[WKWebView class]]) {
        return self.wkWebView.URL;
    }
    return nil;
}

- (UIViewController *)sourceController {
    if (!_sourceController) {
        return [self.class correctTopViewControllerFor:(UIView *)self.sourceObject];
    }
    return _sourceController;
}

- (void)callbackBridge:(TTBridgeName)bridgeName params:(NSDictionary *)params {
    [self callbackBridge:bridgeName params:params resultBlock:nil];
}

- (void)callbackBridge:(TTBridgeName)bridgeName params:(NSDictionary *)params resultBlock:(void (^)(NSString *))resultBlock {
    [self callbackBridge:bridgeName msg:TTBridgeMsgSuccess params:params resultBlock:resultBlock];
}

- (void)callbackBridge:(TTBridgeName)bridgeName msg:(TTBridgeMsg)msg params:(NSDictionary *)params resultBlock:(void (^)(NSString *))resultBlock {
    TTBridgeCommand *command = [TTBridgeCommand new];
    command.callbackID = bridgeName;
    command.origName = bridgeName;
    command.bridgeType = TTBridgeTypeOn;
    if ([self.authorization respondsToSelector:@selector(engine:isAuthorizedBridge:domain:completion:)]) {
        if (![self.authorization engine:self isAuthorizedBridge:command domain:self.sourceURL.host.lowercaseString]) {
            if (resultBlock) {
                resultBlock([NSString stringWithFormat:@"'%@' is not permitted at '%@'.", bridgeName, self.sourceURL]);
            }
            return;
        }
    }
    invokeJSBCallbackWithCommand(command, msg, params, self, resultBlock);
}


- (TTBridgeRegisterEngineType)engineType {
    return TTBridgeRegisterWebView;
}

+ (UIViewController*)correctTopViewControllerFor:(UIResponder*)responder
{
    UIResponder *topResponder = responder;
    for (; topResponder; topResponder = [topResponder nextResponder]) {
        if ([topResponder isKindOfClass:[UIViewController class]]) {
            UIViewController *viewController = (UIViewController *)topResponder;
            while (viewController.parentViewController && viewController.parentViewController != viewController.navigationController && viewController.parentViewController != viewController.tabBarController) {
                viewController = viewController.parentViewController;
            }
            return viewController;
        }
    }
    if(!topResponder)
    {
        topResponder = [[[UIApplication sharedApplication] delegate].window rootViewController];
    }
    
    return (UIViewController*)topResponder;
}

@end
