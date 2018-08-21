//
//  TTDetailWebviewCotainerProvider.h
//  Pods
//
//  Created by muhuai on 2017/4/26.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TTDetailWebviewContainerProtocol.h"

@class SSJSBridgeWebView, SSJSBridgeWebViewDelegate;
@protocol TTDetailWebviewCotainerProvider <NSObject>

- (UIView<TTDetailWebviewContainerProtocol> *)getContainerWithFrame:(CGRect)frame disableWKWebView:(BOOL)disableWKWebView hiddenWebView:(SSJSBridgeWebView *)hiddenWebView webViewDelegate:(SSJSBridgeWebViewDelegate *)jsBridgeDelegate;

@end
