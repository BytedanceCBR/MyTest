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

+ (FHAppVersion)appVersion;

+ (UIColor *)progressViewLineFillColor;

- (void)showEmptyView:(UIView *)view;

- (void)hideEmptyView;

- (void)showLoading:(UIView *)view;

- (void)hideLoading;
//返回自定义导航栏标题label
+ (UILabel *)defaultTitleView;

+ (NSDictionary *)getRequestCommonParams;

+ (void)onAccountCancellationSuccessCallback:(TTRJSBResponse)callback controller:(UIViewController *)controller;

+ (void)loginWithParam:(NSDictionary *)param webView:(UIView<TTRexxarEngine> *)webview;

@end

NS_ASSUME_NONNULL_END
