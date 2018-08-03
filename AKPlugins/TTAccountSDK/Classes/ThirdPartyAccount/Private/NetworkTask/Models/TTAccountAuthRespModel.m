//
//  TTAccountAuthRespModel.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 3/31/17.
//
//

#import "TTAccountAuthRespModel.h"
#import "TTAccountAuthDefine.h"
#import "TTAModelling.h"



#pragma mark - SNS SDK Login Callback

@implementation TTASNSSDKAuthCallbackModel

+ (NSDictionary *)tta_modelCustomPropertyMapper
{
    return @{
             @"user_description"    : @"description",
             @"error_description"   : @"description",
             };
}

@end

@implementation TTASNSSDKAuthCallbackRespModel

- (BOOL)isBindConflict
{
    return [self.data.name isEqualToString:@"connect_switch"];
}

- (BOOL)isAuthPlatformConflict
{
    return [self.data.name isEqualToString:@"connect_exist"];
}

- (BOOL)isBindFailed
{
    return [self.data.name isEqualToString:@"login_failed"];
}

@end



#pragma mark -  SNSSDK Auth SwitchBind

@implementation TTASNSSDKAuthSwitchBindRespModel

@end



#pragma mark - Custom WAP Auth SwitchBind

@implementation TTACustomWAPAuthSwitchBindRespModel

@end



#pragma mark - Custom WAP Auth <login_success redirect snssdk***://callback>
/**
 *  OAuth[WAP] login_success > redirect to <snssdk***://callback?>
 */

@implementation TTACustomWapAuthCallbackModel

@end

static NSString * const TTAWapCallbackResultMsgDescriptionKey  = @"description";
static NSString * const TTAWapCallbackResultErrorDescriptionKey= @"error_description";
static NSString * const TTAWapCallbackResultErrorNameKey       = @"error_name";
static NSString * const TTAWapCallbackResultNameKey            = @"name";
static NSString * const TTAWapCallbackResultSessionKeyKey      = @"session_key";
static NSString * const TTAWapCallbackResultAuthTokenKey       = @"auth_token";
static NSString * const TTAWapCallbackResultNewPlatformKey     = @"new_platform";
static NSString * const TTAWapCallbackResultNewUserKey         = @"new_user";
static NSString * const TTAWapCallbackResultDialogTipsKey      = @"dialog_tips";

@implementation TTACustomWapAuthCallbackRespModel

- (instancetype)initWithWapAuthCallbackURL:(NSURL *)URL
{
    if ((self = [super init])) {
        TTACustomWapAuthCallbackModel *dataMdl = [TTACustomWapAuthCallbackModel new];
        self.data = dataMdl;
        
        // 构造通用的JSON结构，以便被其他模块解析
        NSString *queryString = [URL query];
        if (queryString) {
            
            NSArray *queries = [queryString componentsSeparatedByString:@"&"];
            NSMutableDictionary *mutOtherDict = [NSMutableDictionary dictionaryWithCapacity:10];
            for (NSString *query in queries) {
                NSArray *strs = [query componentsSeparatedByString:@"="];
                if ([strs count] > 1) {
                    NSString *paramKey   = [[strs objectAtIndex:0] lowercaseString];
                    NSString *paramValue = [[strs objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    
                    if([TTAWapCallbackResultErrorDescriptionKey isEqualToString:paramKey]) {
                        dataMdl.error_description = paramValue;
                    } else if ([TTAWapCallbackResultErrorNameKey isEqualToString:paramKey]) {
                        dataMdl.error_name = paramValue;
                    } else if ([TTAWapCallbackResultNameKey isEqualToString:paramKey]) {
                        dataMdl.name = paramValue;
                    } else if([TTAWapCallbackResultSessionKeyKey isEqualToString:paramKey]) {
                        dataMdl.session_key = paramValue;
                    } else if([TTAWapCallbackResultAuthTokenKey isEqualToString:paramKey]) {
                        dataMdl.auth_token = paramValue;
                    } else if ([TTAWapCallbackResultNewPlatformKey isEqualToString:paramKey]) {
                        if ([paramValue isKindOfClass:[NSNumber class]]) {
                            dataMdl.new_platform = [(NSNumber *)paramValue boolValue];
                        } else if ([paramValue isKindOfClass:[NSString class]]) {
                            dataMdl.new_platform = [paramValue boolValue];
                        } else if ([paramValue respondsToSelector:@selector(boolValue)]) {
                            dataMdl.new_platform = [paramValue boolValue];
                        } else {
                            dataMdl.new_platform = NO;
                            NSLog(@"new_platform 数据类型不正确");
                        }
                    } else if ([TTAWapCallbackResultNewUserKey isEqualToString:paramKey]) {
                        if ([paramValue isKindOfClass:[NSNumber class]]) {
                            dataMdl.new_user = [(NSNumber *)paramValue boolValue];
                        } else if ([paramValue isKindOfClass:[NSString class]]) {
                            dataMdl.new_user = [paramValue boolValue];
                        } else if ([paramValue respondsToSelector:@selector(boolValue)]) {
                            dataMdl.new_user = [paramValue boolValue];
                        } else {
                            dataMdl.new_user = @(NO);
                            NSLog(@"new_user 数据类型不正确");
                        }
                    } else if ([TTAWapCallbackResultDialogTipsKey isEqualToString:paramKey]) {
                        dataMdl.dialog_tips = paramValue;
                    } else {
                        [mutOtherDict setObject:paramValue forKey:paramKey];
                    }
                }
            }
            
            {
                dataMdl.otherInfo = [mutOtherDict count] > 0 ? mutOtherDict : nil;
            }
            
            if ([mutOtherDict.allKeys containsObject:TTAWapCallbackResultMsgDescriptionKey]) {
                dataMdl.error_code = TTAccountErrCodeUnknown;
                self.message = @"error";
            } else {
                dataMdl.error_code = TTAccountSuccess;
                self.message = @"success";
            }
            
            if ([self isBindConflict]) {
                dataMdl.error_code = TTAccountErrCodeAccountBoundForbid;
                self.message = @"error";
            } else if ([self isAuthPlatformConflict]) {
                dataMdl.error_code = TTAccountErrCodeAuthPlatformBoundForbid;
                self.message = @"error";
            } else if ([self isBindFailed]) {
                dataMdl.error_code = TTAccountErrCodeAuthorizationFailed;
                self.message = @"error";
            }
            
        } else {
            dataMdl.error_code = TTAccountAuthErrCodeUnknown;
            self.message = @"error";
        }
    }
    return self;
}

- (BOOL)isBindConflict
{
    return [self.data.error_name isEqualToString:@"connect_switch"];
}

- (BOOL)isAuthPlatformConflict
{
    return [self.data.error_name isEqualToString:@"connect_exist"];
}

- (BOOL)isBindFailed
{
    return [self.data.error_name isEqualToString:@"auth_failed"];
}

@end



#pragma mark - 分享App到绑定的第三方平台账号

@implementation TTShareAppToSNSPlatformModel

@end

@implementation TTShareAppToSNSPlatformRespModel

@end
