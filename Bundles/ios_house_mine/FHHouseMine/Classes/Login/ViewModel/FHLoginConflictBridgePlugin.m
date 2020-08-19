//
//  FHLoginConflictBridgePlugin.m
//  Pods
//
//  Created by bytedance on 2020/5/7.
//

#import "FHLoginConflictBridgePlugin.h"
#import <TTAccountSDK/TTAccount.h>
#import <TTAccountSDK/TTAccount+NetworkTasks.h>
#import <ByteDanceKit/NSDictionary+BTDAdditions.h>
#import <TTAccountSDK/TTAccountMulticastDispatcher.h>
#import <TTAccountSDK/TTAccount+PlatformAuthLogin.h>

NSString * const kFHLoginConflictResolvedSuccess = @"kFHLoginConflictResolvedSuccess";

NSString * const kFHLoginConflictResolvedFail = @"kFHLoginConflictResolvedFail";

NSString * const kFHLoginConflictResolvedBindMobile = @"kFHLoginConflictResolvedBindMobile";

@implementation FHLoginConflictBridgePlugin

- (void)postMessageToNativeWithParam:(NSDictionary *)param callback:(TTRJSBResponse)callback webView:(UIView<TTRexxarEngine> *)webview controller:(UIViewController *)controller {
    NSLog(@"param : %@",param);
    if (param[@"type"] && [param[@"type"] isEqualToString:@"douyin_open_conflict_resolved"]) {
        if (param[@"data"] && [param[@"data"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *data = param[@"data"];
            NSUInteger code = [data btd_integerValueForKey:@"code"];
            /** code
             0：解决冲突成功，端上跳转至抖音一键登录页面
             1：解决冲突失败，端上跳转至手机验证码登录页面
             2：放弃解决冲突：端上跳转至绑定手机号页面
             */
            NSString *profileKey = [data btd_stringValueForKey:@"profile_key"];
            switch (code) {
                case 0: {
                    [TTAccount getUserInfoWithScene:TTAccountRequestAfterLogin completion:^(TTAccountUserEntity * _Nullable userEntity, NSError * _Nullable error) {
                        TTAccountUserEntity *entity = userEntity;
                        if (userEntity == nil) {
                            entity = [[TTAccountUserEntity alloc] initWithDictionary:[param btd_dictionaryValueForKey:@"data"]];
                        }
                        [[TTAccount sharedAccount] setUser:entity];
                        [[TTAccount sharedAccount] setIsLogin:YES];
                        
                        [TTAccountMulticastDispatcher dispatchAccountLoginSuccess:entity platform:[TTAccount platformNameForAccountAuthType:TTAccountAuthTypeDouyin] reason:TTAccountStatusChangedReasonTypeAuthPlatformLogin bisectBlock:nil];
                        
                        
                        //notification
                        [[NSNotificationCenter defaultCenter] postNotificationName:kFHLoginConflictResolvedSuccess object:entity];
                    }];
                    break;
                }
                case 1: {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kFHLoginConflictResolvedFail object:nil];
                    break;
                }
                case 2: {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kFHLoginConflictResolvedBindMobile object:@{@"profile_key": profileKey?:@""}];
                    break;
                }
                    
                default:
                    break;
            }
        }
    }
}

@end
