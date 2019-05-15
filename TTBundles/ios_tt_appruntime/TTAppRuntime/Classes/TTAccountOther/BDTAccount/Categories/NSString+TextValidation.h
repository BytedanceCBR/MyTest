//
//  NSString+TextValidation.h
//  EyeU
//
//  Created by liuzuopeng on 10/15/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import <Foundation/Foundation.h>



/**
 常用文本格式校验
 */
@interface NSString (TextValidation)

/**
 字符串是否为全数字字符
 
 @return 是返回YES，否则返回NO
 */
- (BOOL)tt_isDecimalDigitals;


/**
 字符串是否为有效手机号，目前手机号不支持国际化，处理同isValidLengthCNTelNumber
 
 @return 是返回YES，否则返回NO
 */
- (BOOL)tt_isValidTelNumber;


/**
 字符串是否为11为长度的手机号
 
 @return 是返回YES，否则返回NO
 */
- (BOOL)tt_isValidLengthCNTelNumber;


/**
 字符串是否为有效密码
 
 @return 是返回YES，否则返回NO
 */
- (BOOL)tt_isValidPassword;


/**
 字符串是否为有效的身份证号码
 
 @return 是返回YES，否则返回NO
 */
- (BOOL)tt_isValidIdentityCard;


/**
 字符串是否为有效的短信验证码-4位验证码
 
 @return 是返回YES，否则返回NO
 */
- (BOOL)tt_isValidSMSCode;


/**
 字符串是否为有效的邮箱
 
 @return 是返回YES，否则返回NO
 */
- (BOOL)tt_isValidEmail;

@end



@interface NSString (PhoneFormatter)

/**
 安全的手机号模式-中间使用***方式
 
 @return 安全手机号
 */
- (NSString *)tt_securePhoneMode;


/**
 空格分割的手机号模式，如150 0144 4673
 
 @return 空格分割手机号
 */
- (NSString *)tt_whitespacePhoneMode;


/**
 连字符分割的手机号模式，如150-0144-4673
 
 @return 连字分割手机号
 */
- (NSString *)tt_hyphensPhoneMode;


/**
 除去分割符（空格、-、\r、\t）的手机号模式
 
 @return 去分隔符的手机号
 */
- (NSString *)tt_trimPhoneMode;

@end
