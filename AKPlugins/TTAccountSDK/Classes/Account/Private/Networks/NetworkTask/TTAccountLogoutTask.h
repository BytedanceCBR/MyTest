//
//  TTAccountLogoutTask.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 4/26/17.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import <Foundation/Foundation.h>



/**
 *  退出登录网络请求
 */
@protocol TTAccountSessionTask;
@interface TTAccountLogoutTask : NSObject

/**
 *  登出账户
 *
 *  @param completedBlock   完成后的回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)requestLogout:(void (^)(BOOL success, NSError *error))completedBlock;


/**
 *  登出账户
 *
 *  @param completedBlock   完成后的回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)requestLogoutClearCookie:(void (^)(BOOL success, NSError *error))completedBlock;

#pragma mark - 解绑第三方账号
/**
 *  注销绑定的第三方平台账号
 *
 *  @param platformName     第三方平台名称
 *  @param completedBlock   完成后的回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)requestLogoutPlatform:(NSString *)platformName
                                       completion:(void(^)(BOOL success, NSError *error))completedBlock;


@end
