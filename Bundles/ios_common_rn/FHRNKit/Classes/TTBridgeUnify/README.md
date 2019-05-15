# TTBridgeUnify

[![CI Status](https://img.shields.io/travis/renpengcheng/TTBridgeUnify.svg?style=flat)](https://travis-ci.org/renpengcheng/TTBridgeUnify)
[![Version](https://img.shields.io/cocoapods/v/TTBridgeUnify.svg?style=flat)](https://cocoapods.org/pods/TTBridgeUnify)
[![License](https://img.shields.io/cocoapods/l/TTBridgeUnify.svg?style=flat)](https://cocoapods.org/pods/TTBridgeUnify)
[![Platform](https://img.shields.io/cocoapods/p/TTBridgeUnify.svg?style=flat)](https://cocoapods.org/pods/TTBridgeUnify)

## 设计文档
https://docs.bytedance.net/doc/ebbhq0jl9gVhH1oeXd6Jea

## Example

###### 绑定Webview
```objc
    UIWebView *webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    [webview loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://10.2.196.50:8080/feoffline/NO_WEB_CHANNEL/template/bridge-test/home.html"]]];
    [webview tt_connectToBridge:[TTWebViewBridgeEngine new]];
```

###### 注册bridge
```objc

#import <TTBridgeUnify/TTBridgePlugin.h>
#import <TTBridgeUnify/TTBridgeDefines.h>

@interface TTTestPlugin : TTBridgePlugin

TT_BRIDGE_EXPORT_HANDLER(appInfo)

@end

@implementation TTTestPlugin

+ (void)load {
    TTRegisterAllBridge(TTClassBridgeMethod(TTPlugin, appInfo), @"app.getAppInfo");
}


- (void)appInfoWithParam:(NSDictionary *)param callback:(TTBridgeCallback)callback webView:(UIView<TTBridgeEngine> *)webview controller:(UIViewController *)controller {
    callback(TTBridgeMsgSuccess, @{@"device" : @"simulator"});
}

@end
```

###### 需要在plugin类之外实现bridge
```objc
- (void)viewDidLoad
{
    [super viewDidLoad];

    UIWebView *webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    [webview loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://10.2.196.50:8080/feoffline/NO_WEB_CHANNEL/template/bridge-test/home.html"]]];
    [webview tt_connectToBridge:[TTWebViewBridgeEngine new]];
	// Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:webview];
    self.webview = webview;
    [TTTestPlugin registerHandlerBlock:^(NSDictionary *params, TTBridgeCallback callback) {
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        [data setValue:@"registerHandlerBlock" forKey:@"appName"];
        [data setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"AppName"] forKey:@"innerAppName"];
        NSString *netType = @"WIFI";
        [data setValue:netType forKey:@"netType"];
        
        [data setValue:@(1) forKey:@"code"];
        callback(TTBridgeMsgSuccess, data);
    } forEngine:webview.tt_engine selector:TTBridgeSEL(TTPlugin, appInfo)];
}
```

###### 外部回调web/RN/...
```objc
    [TTTestPlugin performCallbackForEngine:self.webview.tt_engine selector:TTBridgeSEL(TTPlugin, onPageVisible) msg:TTBridgeMsgSuccess params:@{@"code" : @"1"}];
```

###### Brief
1. 所有的bridge都会和一个TTBridgePlugin子类中的SEL绑定，bridge name在项目中只会在调用注册方法是出现一次；
2. bridge的外部实现，以及在外部回调web/RN/..端，只能通过对应的TTBridgePlugin子类调用方法来实现，通过"TTBridgePlugin子类类名 + SEL" 来定位bridge实现，避免bridge name分散在各处带来的维护问题。



## Requirements

## Installation

TTBridgeUnify is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'TTBridgeUnify'
```

## Author

renpengcheng, renpengcheng@bytedance.com

## License

TTBridgeUnify is available under the MIT license. See the LICENSE file for more info.
