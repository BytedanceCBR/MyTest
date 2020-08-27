//
//  FHUserInfoManager.h
//  FHHouseBase
//
//  Created by 谢思铭 on 2019/10/16.
//

#import <Foundation/Foundation.h>
#import "FHUserInfoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUserInfoManager : NSObject

@property(nonatomic, strong) FHUserInfoModel *userInfo;

+(instancetype)sharedInstance;

/**
 这个获取手机号的方法主要是给提交表单的地方使用
 优先获取yycache中kFHPhoneNumberCacheKey的手机号
 如果为空，继续获取登录态用户带掩码的手机号
 */
+ (NSString *)getPhoneNumberIfExist;

/**
 格式化手机号 ，返回带掩码的格式，统一处理
 15901218853 -> 159*****853
 */
+ (NSString *)formattMaskPhoneNumber:(NSString *)phoneNumber;

/**
 判断手机号是否是登录用户的手机号
 */
+ (BOOL)isLoginPhoneNumber:(NSString *)phoneNumber;

/**
 判断手机号是否合法，如果是登录手机号，返回YES，否则进行整形类型判断
 */
+ (BOOL)checkPureIntFormatted:(NSString *)phoneNumber;

/**
 通过yycache存储kFHPhoneNumberCacheKey的手机号
 如果判断是登录掩码，则返回
 */
+ (void)savePhoneNumber:(NSString *)phoneNumber;

@end

NS_ASSUME_NONNULL_END
