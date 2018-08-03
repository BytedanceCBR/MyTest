//
//  TTRNBridge+Call.m
//  Article
//
//  Created by Chen Hong on 16/8/17.
//
//

#import "TTRNBridge+Call.h"

/*
    前端希望与jsBridge使用方式保持一致
 
    ToutiaoJSBridge.call('user_follow_action', {
        id: authorId,
    action: isFollowing ? 'unfollow' : 'dofollow'
    }, function (event) {
        clearTimeout(subscribeTimeoutTimer);
    });

    对应RNBridge需要导出的OC方法
 
    - (void)call:(NSString *)methodName params:(NSDictionary *)params callback:(RCTResponseSenderBlock)callback;

    具体的method需要统一参数类型和数量
 */


@implementation TTRNBridge (Call)

- (void)registerHandler:(TTRNMethod)handler forMethod:(NSString *)method {
    if (!self.methodHandlers) {
        self.methodHandlers = [NSMutableDictionary dictionary];
    }
    [self.methodHandlers setValue:handler forKey:method];
}

- (void)unregisterAllHandlers {
    [self.methodHandlers removeAllObjects];
}

RCT_EXPORT_METHOD(call:(NSString *)methodName params:(NSDictionary *)params callback:(RCTResponseSenderBlock)callback) {
    TTRNMethod method = [self.methodHandlers valueForKey:methodName];
    if (method) {
        method(params, callback);
    }
}

@end
