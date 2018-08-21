//
//  TTNetwork.m
//  Article
//
//  Created by muhuai on 2017/7/3.
//
//

#import "TTNetwork.h"
#import "TTNetworkUtilities.h"

@implementation TTNetwork

- (void)commonParamsWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSDictionary *commonParams = [TTNetworkUtilities commonURLParameters];
    
    if (!commonParams) {
        if (callback) {
            callback(TTRJSBMsgFailed, @{@"msg": @"通用参数为空..请联系客户端相关人士"});
        }
        return;
    }
    
    if (callback) {
        callback(TTRJSBMsgSuccess, @{@"data": commonParams});
    }
}
@end
