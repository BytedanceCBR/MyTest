//
//  TTTelecomLoggerImp.m
//  Pods
//
//  Created by zuopengl on 21/07/2017.
//
//

#import "TTTelecomLoggerImp.h"
#import <TTTracker.h>
#import <TTMonitor.h>



@implementation TTTelecomLoggerImp
/** 频控请求成功 */
- (void)requestAuthControlDidSuccess
{
    [TTTracker eventV3:@"request_mobile" params:@{@"action_type": @"control_freq",
                                                  @"status": @"success"
                                                  }];
    [[TTMonitor shareManager] trackService:@"tt_telecom_getting_mobile" attributes:@{@"flow_status": @(0),
                                                                                     @"control_auth_status": @(0),
                                                                                     @"action_type": @"control_freq"}];
}

/** 频控请求失败 */
- (void)requestAuthControlDidFail:(NSError * _Nullable)error
{
    [TTTracker eventV3:@"request_mobile" params:@{@"action_type": @"control_freq",
                                                  @"status": @"fail"
                                                  }];
    [[TTMonitor shareManager] trackService:@"tt_telecom_getting_mobile" attributes:@{@"flow_status": @(0),
                                                                                     @"control_auth_status": @(1),
                                                                                     @"action_type": @"control_freq"}];
}

/** 频控请求延时 */
- (void)requestAuthControlDidRetryWithDelay:(NSInteger)delay
{
    [TTTracker eventV3:@"request_mobile" params:@{@"action_type": @"control_freq",
                                                  @"status": @"delay"
                                                  }];
    [[TTMonitor shareManager] trackService:@"tt_telecom_getting_mobile" attributes:@{@"flow_status": @(0),
                                                                                     @"control_auth_status": @(2),
                                                                                     @"action_type": @"control_freq"}];
}

/** 调用电信取号SDK */
- (void)requestTelecomSDKDidStart
{
    [TTTracker eventV3:@"request_mobile" params:@{@"action_type": @"get_sdk_code",
                                                  @"status": @"start"
                                                  }];
    [[TTMonitor shareManager] trackService:@"tt_telecom_getting_mobile" attributes:@{@"flow_status": @(1),
                                                                                     @"telecom_sdk_status": @(0),
                                                                                     @"action_type": @"get_telecom_sdk_code"}];
}

/** 调用电信取号SDK成功 */
- (void)requestTelecomSDKDidSuccess
{
    [TTTracker eventV3:@"request_mobile" params:@{@"action_type": @"get_sdk_code",
                                                  @"status": @"success"
                                                  }];
    [[TTMonitor shareManager] trackService:@"tt_telecom_getting_mobile" attributes:@{@"flow_status": @(1),
                                                                                     @"telecom_sdk_status": @(1),
                                                                                     @"action_type": @"get_telecom_sdk_code"}];
}

/** 调用电信取号SDK失败 */
- (void)requestTelecomSDKDidFail:(NSError * _Nullable)error
{
    [TTTracker eventV3:@"request_mobile" params:@{@"action_type": @"get_sdk_code",
                                                  @"status": @"fail"
                                                  }];
    [[TTMonitor shareManager] trackService:@"tt_telecom_getting_mobile" attributes:@{@"flow_status": @(1),
                                                                                     @"telecom_sdk_status": @(2),
                                                                                     @"action_type": @"get_telecom_sdk_code"}];
}


/** 调用服务端取号接口成功 */
- (void)requestGetPhoneDidSuccess:(NSString *)mobileString
{
    [TTTracker eventV3:@"request_mobile" params:@{@"action_type": @"get_phone_number",
                                                  @"status": @"success"
                                                  }];
    [[TTMonitor shareManager] trackService:@"tt_telecom_getting_mobile" attributes:@{@"flow_status": @(2),
                                                                                     @"get_phone_status": @(0),
                                                                                     @"action_type": @"get_phone_number"}];
}

/** 调用服务端取号接口失败 */
- (void)requestGetPhoneDidFailure:(NSError * _Nullable)error
{
    [TTTracker eventV3:@"request_mobile" params:@{@"action_type": @"get_phone_number",
                                                  @"status": @"fail"
                                                  }];
    [[TTMonitor shareManager] trackService:@"tt_telecom_getting_mobile" attributes:@{@"flow_status": @(2),
                                                                                     @"get_phone_status": @(1),
                                                                                     @"action_type": @"get_phone_number"}];
}

@end
