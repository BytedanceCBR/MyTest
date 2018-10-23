//
//  TTAccountMonitorDispatcher.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 30/07/2017.
//
//

#import "TTAccountMonitorDispatcher.h"
#import "TTAccount.h"
#import "TTAccountConfiguration_Priv.h"
#import "TTAccountMonitorProtocol.h"



@implementation TTAccountMonitorDispatcher

+ (void)dispatchHttpResp:(id)jsonObj
                   error:(NSError *)error
             originalURL:(NSString *)urlString
{
    id<TTAccountMonitorProtocol> monitorDelegate = [TTAccount accountConf].monitorDelegate;
    if ([monitorDelegate respondsToSelector:@selector(onReceiveHttpResp:error:originalURL:)]) {
        [monitorDelegate onReceiveHttpResp:jsonObj error:error originalURL:urlString];
    }
}

+ (void)dispatchSessionExpirationWithUser:(NSString *)userIdString
                                    error:(NSError *)error
                              originalURL:(NSString *)urlString
{
    id<TTAccountMonitorProtocol> monitorDelegate = [TTAccount accountConf].monitorDelegate;
    if ([monitorDelegate respondsToSelector:@selector(onReceiveSessionExpirationWithUser:error:originalURL:)]) {
        [monitorDelegate onReceiveSessionExpirationWithUser:userIdString error:error originalURL:urlString];
    }
}

+ (void)dispatchPlatformExpirationWithUser:(NSString *)userIdString
                                  platform:(NSString *)joinedPlatformString
                                     error:(NSError *)error
                               originalURL:(NSString *)urlString
{
    id<TTAccountMonitorProtocol> monitorDelegate = [TTAccount accountConf].monitorDelegate;
    if ([monitorDelegate respondsToSelector:@selector(onReceivePlatformExpirationWithUser:platform:error:originalURL:)]) {
        [monitorDelegate onReceivePlatformExpirationWithUser:userIdString platform:joinedPlatformString error:error originalURL:urlString];
    }
}

+ (void)dispatchLoginWrongUser:(NSString *)userIdString
                wrongUserPhone:(NSString *)userPhoneString
                 originalPhone:(NSString *)inputtedPhoneString
                   originalURL:(NSString *)urlString
{
    id<TTAccountMonitorProtocol> monitorDelegate = [TTAccount accountConf].monitorDelegate;
    if ([monitorDelegate respondsToSelector:@selector(onReceiveLoginWrongUser:wrongUserPhone:originalPhone:originalURL:)]) {
        [monitorDelegate onReceiveLoginWrongUser:userIdString wrongUserPhone:userPhoneString originalPhone:inputtedPhoneString originalURL:urlString];
    }
}

@end



@implementation TTAccountMonitorDispatcher (WrongUserHelper)

+ (BOOL)isWrongUserForOriginalPhone:(NSString *)originalPhoneString
                   loginedUserPhone:(NSString *)userPhoneString
{
    if (originalPhoneString && userPhoneString) {
        // 移除区号信息
        NSRange areaCodeRange = [userPhoneString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"-: "]];
        if (areaCodeRange.location != NSNotFound) {
            userPhoneString = [userPhoneString substringFromIndex:areaCodeRange.location + 1];
        }
        
        NSString *inputtedPhone = [originalPhoneString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *returnPhone = [userPhoneString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        returnPhone = [returnPhone stringByReplacingOccurrencesOfString:@"*" withString:@"\\w*"];
        returnPhone = [returnPhone stringByReplacingOccurrencesOfString:@"+" withString:@"\\+"];
        returnPhone = [returnPhone stringByAppendingString:@"$"];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:returnPhone options:0 error:NULL];
        if (regex) {
            NSRange range = [regex rangeOfFirstMatchInString:inputtedPhone options:0 range:NSMakeRange(0, inputtedPhone.length)];
            return (range.location == NSNotFound);
        }
        
        {
            returnPhone = [userPhoneString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSUInteger originalIdx = [inputtedPhone length];
            NSUInteger comparedIdx = [returnPhone length];
            while (originalIdx > 0 && comparedIdx > 0) {
                unichar originalChar = [inputtedPhone characterAtIndex:(--originalIdx)];
                unichar comparedChar = [returnPhone characterAtIndex:(--comparedIdx)];
                if (originalChar == '*' || comparedChar == '*') break;
                if (originalChar != comparedChar) {
                    return YES;
                }
            }
            
            originalIdx = 0;
            comparedIdx = 0;
            NSUInteger originalLength = [inputtedPhone length];
            NSUInteger comparedLength = [returnPhone length];
            while (originalIdx < originalLength && comparedIdx < comparedLength) {
                unichar originalChar = [inputtedPhone characterAtIndex:(originalIdx++)];
                unichar comparedChar = [returnPhone characterAtIndex:(comparedIdx++)];
                if (originalChar == '*' || comparedChar == '*') break;
                if (originalChar != comparedChar) {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

+ (BOOL)isWrongUserForOriginalEmail:(NSString *)originalEmailString
                   loginedUserEmail:(NSString *)userEmailString
{
    if (originalEmailString && userEmailString && ![originalEmailString isEqualToString:userEmailString]) {
        NSString *inputtedEmail = [originalEmailString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *returnUserEmail = [userEmailString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        returnUserEmail = [returnUserEmail stringByReplacingOccurrencesOfString:@"*" withString:@"[\\w.]*"];
        returnUserEmail = [returnUserEmail stringByReplacingOccurrencesOfString:@"+" withString:@"\\+"];
        returnUserEmail = [returnUserEmail stringByAppendingString:@"$"];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:returnUserEmail options:0 error:NULL];
        if (regex) {
            NSRange range = [regex rangeOfFirstMatchInString:inputtedEmail options:0 range:NSMakeRange(0, inputtedEmail.length)];
            return (range.location == NSNotFound);
        }
        
        {
            returnUserEmail = [userEmailString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSUInteger originalIdx = [inputtedEmail length];
            NSUInteger comparedIdx = [returnUserEmail length];
            while (originalIdx > 0 && comparedIdx > 0) {
                unichar originalChar = [inputtedEmail characterAtIndex:(--originalIdx)];
                unichar comparedChar = [returnUserEmail characterAtIndex:(--comparedIdx)];
                if (originalChar == '*' || comparedChar == '*') break;
                if (originalChar != comparedChar) {
                    return YES;
                }
            }
            
            originalIdx = 0;
            comparedIdx = 0;
            NSUInteger originalLength = [inputtedEmail length];
            NSUInteger comparedLength = [returnUserEmail length];
            while (originalIdx < originalLength && comparedIdx < comparedLength) {
                unichar originalChar = [inputtedEmail characterAtIndex:(originalIdx++)];
                unichar comparedChar = [returnUserEmail characterAtIndex:(comparedIdx++)];
                if (originalChar == '*' || comparedChar == '*') break;
                if (originalChar != comparedChar) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

@end
