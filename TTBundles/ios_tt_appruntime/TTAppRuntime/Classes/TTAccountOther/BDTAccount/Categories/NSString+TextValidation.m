//
//  NSString+TextValidation.m
//  EyeU
//
//  Created by liuzuopeng on 10/15/16.
//  Copyright © 2016 Toutiao.EyeU. All rights reserved.
//

#import "NSString+TextValidation.h"
#import <NSStringAdditions.h>



@implementation NSString (TextValidation)

- (BOOL)tt_isDecimalDigitals
{
    NSString *pattern = @"^[0-9]+$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatched = [pred evaluateWithObject:self];
    return isMatched;
    
}

- (BOOL)tt_isValidTelNumber
{
    //    /**
    //     * 手机号码
    //     * 移动：134,135,136,137,138,139,147,150,151,152,157,158,159,170,178,182,183,184,187,188
    //     * 联通：130,131,132,145,152,155,156,1709,171,176,185,186
    //     * 电信：133,134,153,1700,177,180,181,189
    //     */
    //    NSString * MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|7[01678]|8[0-9])\\d{8}$";
    //    /**
    //     * 中国移动：China Mobile
    //     * 134,135,136,137,138,139,147,150,151,152,157,158,159,170,178,182,183,184,187,188
    //     */
    //    NSString * CM = @"^1(3[4-9]|4[7]|5[0-27-9]|7[0]|7[8]|8[2-478])\\d{8}$";
    //    /**
    //     * 中国联通：China Unicom
    //     * 130,131,132,145,152,155,156,1709,171,176,185,186
    //     */
    //    NSString * CU = @"^1(3[0-2]|4[5]|5[56]|709|7[1]|7[6]|8[56])\\d{8}$";
    //    /**
    //     * 中国电信：China Telecom
    //     * 133,134,153,1700,177,180,181,189
    //     */
    //    NSString * CT = @"^1(3[34]|53|77|700|8[019])\\d{8}$";
    //    /**
    //     * 大陆地区固话及小灵通
    //     * 区号：010,020,021,022,023,024,025,027,028,029
    //     * 号码：七位或八位
    //     */
    //    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    //
    //    NSPredicate *mobilePred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    //    NSPredicate *cmPred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    //    NSPredicate *cuPred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    //    NSPredicate *ctPred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    //
    //    if (([mobilePred evaluateWithObject:self] == YES) ||
    //        ([cmPred evaluateWithObject:self] == YES) ||
    //        ([cuPred evaluateWithObject:self] == YES) ||
    //        ([ctPred evaluateWithObject:self] == YES)) {
    //        return YES;
    //    } else {
    //        return NO;
    //    }
    //
    return [self tt_isValidLengthCNTelNumber];
}

- (BOOL)tt_isValidLengthCNTelNumber
{
    NSString *regex = @"^1\\d{10}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([predicate evaluateWithObject:self]) {
        return YES;
    }
    return NO;
}

- (BOOL)tt_isValidPassword
{
    return [[self trimmed] length] >= 6;
}

- (BOOL)tt_isValidIdentityCard
{
    NSString *pattern = @"(^[0-9]{15}$)|([0-9]{17}([0-9]|X)$)";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatched = [pred evaluateWithObject:self];
    return isMatched;
}

/**
 *  4位验证码
 */
- (BOOL)tt_isValidSMSCode
{
    return [self tt_isDecimalDigitals] && ([self trimmed].length == 4);
}

- (BOOL)tt_isValidEmail
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

@end



@implementation NSString (PhoneFormatter)

- (NSString *)tt_securePhoneMode
{
    NSString *trimString = [self tt_trimPhoneMode];
    if ([trimString length] >= 8) {
        return [trimString stringByReplacingCharactersInRange:NSMakeRange(3, 5) withString:@"*****"];
    }
    return trimString;
}

- (NSString *)tt_whitespacePhoneMode
{
    NSString *trimString = [self tt_trimPhoneMode];
    if ([trimString length] >= 8) {
        return [[trimString stringByReplacingCharactersInRange:NSMakeRange(3, 0) withString:@" "] stringByReplacingCharactersInRange:NSMakeRange(8, 0) withString:@" "];
    }
    if ([trimString length] >= 4) {
        return [trimString stringByReplacingCharactersInRange:NSMakeRange(3, 0) withString:@" "];
    }
    return trimString;
}

- (NSString *)tt_hyphensPhoneMode
{
    NSString *trimString = [self tt_trimPhoneMode];
    if ([trimString length] >= 8) {
        return [[trimString stringByReplacingCharactersInRange:NSMakeRange(3, 0) withString:@"-"] stringByReplacingCharactersInRange:NSMakeRange(8, 0) withString:@"-"];
    }
    return trimString;
    
}

- (NSString *)tt_trimPhoneMode
{
    NSString *string = [self copy];
    if ([string length] > 0) {
        string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        string = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    return string;
}

@end


