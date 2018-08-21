//
//  TTAccountTestSettings.h
//  Article
//
//  Created by liuzuopeng on 02/08/2017.
//
//

#import <Foundation/Foundation.h>



typedef NS_ENUM(NSInteger, TTAccountReqUserInfo) {
    // 收到将进入前台消息请求UserInfo接口
    TTAccountReqUserInfoWillEnterForeground, /** 默认值 */
    
    // 收到将进入前台通知延迟Ns后请求UserInfo接口
    TTAccountReqUserInfoWillEnterForegroundDelayNs,
    
    // 收到将进入前台通知延迟Ns并确保在前台后请求UserInfo接口
    TTAccountReqUserInfoWillEnterForegroundDelayNsAndInForeground,
};


@interface TTAccountTestSettings : NSObject

+ (void)parseAccountConfFromSettings:(NSDictionary *)settings;

#pragma mark - Test Request UserInfo
/** 请求userInfo条件 */
+ (TTAccountReqUserInfo)reqUserInfoCond;

/** 请求userInfo的延时时间 */
+ (NSTimeInterval)delayTimeInterval;

/** 是否支持线程安全 */
+ (BOOL)threadSafeSupported;

+ (BOOL)httpResponseSerializerHandleAccountMsgEnabled;

/** 是否过滤账号HTTP接口，服务端返回提示错误信息[Default is YES] */
+ (BOOL)filterNormalHTTPServerRespErrorEnabled;

@end

