//
//  TTRMonitor.m
//  Article
//
//  Created by muhuai on 2017/6/26.
//
//

#import "TTRMonitor.h"
#import <TTMonitor/TTMonitor.h>

@implementation TTRMonitor

- (void)statusWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSString *service = [param tt_stringValueForKey:@"service"];
    NSInteger status = [param tt_integerValueForKey:@"status"];
    NSDictionary *extra = [param tt_dictionaryValueForKey:@"extra"];
    [[TTMonitor shareManager] trackService:service status:status extra:extra];
    
    TTR_CALLBACK_SUCCESS
}

- (void)valueWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSString *service = [param tt_stringValueForKey:@"service"];
    if(isEmptyString(service))  {
        TTR_CALLBACK_FAILED_MSG(@"service 不能为空")
    }
    NSNumber *value = @([param tt_floatValueForKey:@"value"]);
    NSDictionary *extra = [param tt_dictionaryValueForKey:@"extra"];
    [[TTMonitor shareManager] trackService:service value:value extra:extra];
    
    TTR_CALLBACK_SUCCESS
}
@end
