//
//  TTRNKitProtocol.h
//  TTRNKit_Example
//
//  Created by liangchao on 2018/6/16.
//  Copyright © 2018年 ByteDance Inc. All rights reserved.
//

#import <React/RCTBridgeModule.h>
#import "TTRNKitMacro.h"
@class TTRNKit;
@class TTRNKitViewWrapper;
typedef NS_ENUM(NSInteger,TTRNKitViewWraperResultType) {
    TypeWeb = 0,//要求展示web且正常展示成功
    TypeReact = 1,//要求展示react且正常展示成功
    TypeNoContent = 2,//展示React失败且没有配置fallbackURL导致回退失败，或者host=webview但是没有配置url参数，此时ViewWrapper无内容！
    TypeFallback = 3,//sdk内部使用，表示进入fallback流程
};

@protocol TTRNKitProtocol <NSObject>
@optional

/**
 解析url时，当host是webview或react时，如果未实现handleWithWrapper:...方法，此方法可以返回一个ViewController以弹出一个包含viewWrapper的ViewController
 */
- (UIViewController *)presentor;

/**
 解析一个url的结果，当host是webview或react时，实现此方法来处理得到的viewWrapper，wrapper中webView和rnView一定不会同时存在（也可能同时不存在！）
 由于解析一个url可能得到webView或者RCTRootView（有时候下载jsbundle资源失败或者js端强制要求，会回退到web，所以host=react不意味着一定得到RCTRootView）
 sdk中嵌入的webview组件来自 'TTRexxar'库中的 TTRUIWebView 和 TTRWKWebView 在系统版本大于8.0时，可以在url参数中配置use_wk=1来启用TTRWKWebView
 由于解析url可能由TTRNKit发起，也可能由ViewWrapper中的RCTRootView或者WebView发起，可以通过sourceWrapper中检查rnView或者webView哪个成员不为nil确定。
 
 @param wrapper 解析得到的TTRNKitViewWrapper,在得到wrapper之后需要给它设置delegate以监听最终的加载结果 (当host是webview或react时,wrapper非空)
 @param specialHost 解析得到的host（host不是webview或者react时，specialHost非空）
 @param url 完整的url
 @param reactCallback RN页面设置的回调(如果回调是由RN页面触发，且RN页面设置了callback，此时参数非空)
 @param webCallBack web页设置的回调（如果回调是由Web页面触发，且Web页面设置了callback，此时参数非空）
 @param sourceWrapper 触发此回调的ViewWrapper（当此回调是由ViewWrapper内部的view触发时非空）
 @param context 触发此回调时的上下文（目前只有一个key，fallback = 1，表示sourceWrapper加载RN页面时失败了，然后去打开fallbackURL）
 
 */
- (void)handleWithWrapper:(TTRNKitViewWrapper *)wrapper
              specialHost:(NSString *)specialHost
                      url:(NSString *)url
            reactCallback:(RCTResponseSenderBlock)reactCallback
              webCallback:(TTRNKitWebViewCallback)webCallBack
            sourceWrapper:(TTRNKitViewWrapper *)sourceWrapper
                  context:(TTRNKit *)context;

/**
 渲染结束时的回调
 
 @param url 完整的请求url
 @param resultType 展示内容的结果，表示成功或者失败的原因
 @param viewWrapper 触发回调的viewWrapper
 */
- (void)renderContentWithUrl:(NSString *)url
                  resultType:(TTRNKitViewWraperResultType)resultType
                 viewWrapper:(TTRNKitViewWrapper *)viewWrapper;

/**
 接入方能否打开此url
 
 sdk在解析url之前会调用此方法询问delegate，如果delegate不实现此方法或者返回NO,那么sdk会进入解析url流程。
 @param url 请求url
 */
- (BOOL)openUrl:(NSString *)url;

/**
 接入方返回一个桥接了bridge的webview用于显示
 
 sdk在解析url之前会调用此方法询问delegate，如果delegate不实现此方法或者返回nil,那么sdk会尝试创建webview。
 注意：业务方需要将webview中的_TTRNKitCallNative方法指向TTRNKitBridgeModule的_TTRNKitCallNativeWithParam:callback:webView:controller:方法
 例如：
[[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRNKitBridgeModule._TTRNKitCallNative" for:@"_TTRNKitCallNative"];
 @param url 请求url
 */
- (UIView *)createWebViewForRequest:(NSURLRequest *)request
                              useWK:(BOOL)useWK;

/**
 接入方处理channel上发生fallback的行为；
 */
- (void)fallBackForChannel:(NSString *)channel jsContextIsValid:(BOOL)valid;
 
 

/**
要处理RCTRootView或者WebView对本地方法的调用，可以实现符合如下格式的方法。其中XXX为RCTRootView或者WebView的bridge想要call本地方法的方法名。
 - (void)XXXparams:(NSDictionary *)params reactCallback:(RCTResponseSenderBlock)reactCallback webCallback:(TTRJSBResponse)webCallback sourceWrapper:(TTRNKitViewWrapper *)wrapper;
 */
@end
