//
//  TTRSecurity.m
//  Article
//
//  Created by muhuai on 2017/9/20.
//
//

#import "TTRSecurity.h"
#import "TTSecurityUtil.h"

#import "Base64.h"
#import <TTRexxar/TTRJSBForwarding.h>

@implementation TTRSecurity
+ (void)load {
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRSecurity.encrypt" for:@"encrypt"];
    [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRSecurity.decrypt" for:@"decrypt"];
    
}

- (void)encryptWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSString *data = [[param tt_stringValueForKey:@"data"] base64DecodedString];
    NSString *token = [param tt_stringValueForKey:@"token"];
    if (!data.length) {
        TTR_CALLBACK_FAILED_MSG(@"data为空");
        return;
    }
    
    NSString *encrypt = [[TTSecurityUtil sharedInstance] encrypt:data token:token];
    
    if (isEmptyString(encrypt)) {
        TTR_CALLBACK_FAILED_MSG(@"加密失败");
        return;
    }
    
    if (callback) {
        callback(TTRJSBMsgSuccess, @{@"data": @{@"value": encrypt}});
    }
}

- (void)decryptWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSString *data = [param tt_stringValueForKey:@"data"];
    NSString *token = [param tt_stringValueForKey:@"token"];
    if (isEmptyString(data)) {
        TTR_CALLBACK_FAILED_MSG(@"data为空");
        return;
    }
    
    NSString *decrypt = [[TTSecurityUtil sharedInstance] decrypt:data token:token];
    
    if (isEmptyString(decrypt)) {
        TTR_CALLBACK_FAILED_MSG(@"解密失败");
        return;
    }
    
    if(callback) {
        callback(TTRJSBMsgSuccess, @{@"data": @{@"value": decrypt}});
    }
    
}

@end
