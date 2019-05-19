//
//  FHWebViewConfigProtocol.h
//  FHWebView
//
//  Created by 谢思铭 on 2019/5/15.
//

#import <Foundation/Foundation.h>
#import "TTRJSBDefine.h"
#import <TTRexxar/TTRDynamicPlugin.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FHAppVersion)
{
    FHAppVersionC = 0,
    FHAppVersionB,
};

@protocol FHWebViewConfigProtocol <NSObject>

//客户端版本
+ (FHAppVersion)appVersion;
//启动条颜色
+ (UIColor *)progressViewLineFillColor;
//显示网络错误页
- (void)showEmptyView:(UIView *)view retryBlock:(void (^)(void))retryBlock;
//隐藏网络错误页
- (void)hideEmptyView;
//加载中
- (void)showLoading:(UIView *)view;
//停止加载
- (void)hideLoading;
//返回自定义导航栏标题样式
+ (UILabel *)defaultTitleView;
//返回请求的公共参数
+ (NSDictionary *)getRequestCommonParams;
//登录取消时回调
+ (void)onAccountCancellationSuccessCallback:(TTRJSBResponse)callback controller:(UIViewController *)controller;
//登录时调用
+ (void)loginWithParam:(NSDictionary *)param webView:(UIView<TTRexxarEngine> *)webview;

@end

NS_ASSUME_NONNULL_END

