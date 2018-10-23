//
//  SSJSBridgeWebView.m
//  Article
//
//  Created by Dianwei on 14-10-11.
//
//

#import "SSJSBridgeWebView.h"
#import "SSJSBridgeWebViewDelegate.h"
#import "SSWeakObject.h"
#import "SSThemed.h"


static NSString *const kHasMessageHost = @"dispatch_message";
static NSString *const kJSBridgeScheme = @"bytedance";

@interface SSJSBridgeWebView()<YSWebViewDelegate>
@property(nonatomic, strong)SSJSBridgeWebViewDelegate *jsBridgeDelegate;
@property(nonatomic, readwrite, strong)SSJSBridge *bridge;
@end

@implementation SSJSBridgeWebView

- (void)dealloc
{
    [self.bridge unregisterAllHandlerBlocks];
}

+ (Class)JSBridgeClass
{
    return [SSJSBridge class];
}


- (instancetype)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if(self)
    {
        self.jsBridgeDelegate = [SSJSBridgeWebViewDelegate JSBridgeWebViewDelegateWithMainDelegate:self];
        self.delegate = _jsBridgeDelegate;
        self.bridge = [[[self class] JSBridgeClass] JSBridgeWithWebView:self];
        self.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    }
    
    return self;
    
}
    
- (instancetype)initWithFrame:(CGRect)frame disableWKWebView:(BOOL)disableWKWebView {

    self = [super initWithFrame:frame disableWKWebView:disableWKWebView];
    if(self)
    {
        self.jsBridgeDelegate = [SSJSBridgeWebViewDelegate JSBridgeWebViewDelegateWithMainDelegate:self];
        self.delegate = _jsBridgeDelegate;
        self.bridge = [[[self class] JSBridgeClass] JSBridgeWithWebView:self];
        self.backgroundColor = SSGetThemedColorWithKey(kColorBackground4);
    }
    
    return self;
}

- (void)addDelegate:(NSObject<YSWebViewDelegate> *)delegate {
    __block SSWeakObject *object;
    [_jsBridgeDelegate.delegates enumerateObjectsUsingBlock:^(SSWeakObject * obj, NSUInteger idx, BOOL *stop) {
        if ([obj.content isEqual:delegate]) {
            object = obj;
            *stop = YES;
        }
    }];
    if (!object) {
        object = [SSWeakObject weakObjectWithContent:delegate];
        [_jsBridgeDelegate.delegates addObject:object];
    }
}

- (void)removeDelegate:(NSObject<UIWebViewDelegate> *) delegate {
    __block SSWeakObject *object;
    [_jsBridgeDelegate.delegates enumerateObjectsUsingBlock:^(SSWeakObject * obj, NSUInteger idx, BOOL *stop) {
        if ([obj.content isEqual:delegate]) {
            object = obj;
            *stop = YES;
        }
    }];
    if (object) {
        [_jsBridgeDelegate.delegates removeObject:object];
    }
}


- (BOOL)webView:(YSWebView *)wView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(YSWebViewNavigationType)navigationType
{
    BOOL result = NO;
    NSURL *URL = request.URL;
    if ([URL.scheme isEqualToString:@"bytedance"] && [URL.host isEqualToString:@"custom_event"]) {
        // 发送统计事件的拦截
        NSMutableDictionary * parameters = [[SSCommon parametersOfURLString:URL.query] mutableCopy];
        if (![parameters valueForKey:@"category"]) {
            [parameters setValue:@"umeng" forKey:@"category"];
        }
        [SSTracker eventData:parameters];
        return NO;
    }
    
    // bridge logic
    if([request.URL.scheme isEqualToString:kJSBridgeScheme])
    {
        if([request.URL.host isEqualToString:kHasMessageHost])
        {
            [_bridge flushMessages];
        }
    }
    for(SSWeakObject *obj in _jsBridgeDelegate.delegates) {
        NSObject<YSWebViewDelegate> *target = (NSObject<YSWebViewDelegate> *)obj.content;
        if([target respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
            result = [target webView:self shouldStartLoadWithRequest:request navigationType:navigationType];
            break;
        }
    };
    return result;
}

@end
