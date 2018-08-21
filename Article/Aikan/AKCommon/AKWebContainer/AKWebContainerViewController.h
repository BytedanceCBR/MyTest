//
//  AKWebContainerViewController.h
//  Article
//
//  Created by 冯靖君 on 2018/3/2.
//

#import "SSViewControllerBase.h"
#import <SSJSBridgeWebView.h>

@interface AKWebContainerViewController : SSViewControllerBase

// webView容器底部是否抬高tabbar高度，默认44
@property (nonatomic, assign) BOOL adjustBottomBarInset;

// 便捷初始化方法
// @param urlString     h5完整url，包含本身或客户端主动拼接的query参数
// @param params        schema参数，端上解析
- (instancetype)initWithURL:(NSString *)urlString
                     params:(NSDictionary *)params;


// 外部注册业务JSB
- (void)registerServiceJSBHandler:(TTRJSBStaticHandler)handler
                    forMethodName:(NSString *)method;

// 手动刷新
- (void)reloadWebContainer;

// 发visible 消息，轻量级刷新
- (void)weakReloadWebContainer;

@end
