//
//  TFFetchInfoManager.h
//  SSTestFlight
//
//  Created by Zhang Leonardo on 13-5-26.
//  Copyright (c) 2013年 Leonardo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kFetchInfoDoneNotification @"kFetchInfoDoneNotification"//获取成功
#define kFetchInfoFailedNotification @"kFetchInfoFailedNotification"//获取失败

/*
 param_error	参数缺失
 email_unmatch	email与udid设备不匹配
 need_register	需要注册
 wait_verify	等待验证身份
 */
#define kErrorType @"kErrorType"

#define vWaitVerifyType @"wait_verify"
#define vNeedRegisterType @"need_register"
#define vEmailUnmatch @"email_unmatch"
#define vParamError @"param_error"
#define kServerError @"kServerError"
#define kNoNetConnectError @"kNoNetConnectError"


@interface TFFetchInfoManager : NSObject

+ (TFFetchInfoManager *)shareManager;
- (void)startFetchInfos:(NSString *)email identity:(NSString *)identity isRegister:(BOOL)regist;

@end
