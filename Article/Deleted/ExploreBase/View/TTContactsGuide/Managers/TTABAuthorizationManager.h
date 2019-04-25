//
//  TTABAuthorizationManager.h
//  Article
//  通讯录弹窗状态管理，之前作为电信取号授权弹窗
//
//  Created by zuopengl on 9/19/16.
//
//


#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, TTABAuthorizationStatus) {
    kTTABAuthorizationStatusNotDetermined = 0, // 未弹出过通讯录弹窗
    kTTABAuthorizationStatusRestricted    = 1,
    kTTABAuthorizationStatusDenied        = 2, // 通讯录弹窗点击了关闭
    kTTABAuthorizationStatusAuthorized    = 3, // 通讯录弹窗点击了现在看看
};

/**
 * 自定义通讯录弹窗状态管理
 */
@interface TTABAuthorizationManager : NSObject

/**
 * 是否显示过授权弹窗，仅仅第一次显示弹窗前返回 YES
 * @return
 */
+ (BOOL)hasShownAuthorizedGuideDialog;

/**
 * 是否点击了现在看看
 * @return
 */
+ (BOOL)hasBeenAuthorized;

/**
 * 获取授权弹窗状态
 * @return
 */
+ (TTABAuthorizationStatus)authorizationStatus;

/**
 * 保存授权弹窗状态
 * @param status
 */
+ (void)setAuthorizationStatusForValue:(TTABAuthorizationStatus)status;

@end
