//
//  TTAccountAuthReqModel.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 3/31/17.
//
//

#import "TTAccountAuthReqModel.h"
#import "TTAccountAuthRespModel.h"
#import "TTAccountURLSetting+Platform.h"



@implementation TTASNSSDKAuthCallbackReqModel
- (instancetype)init
{
    if ((self = [super init])) {
        self._host     = [TTAccountURLSetting HTTPSBaseURL];
        self._uri      = [TTAccountURLSetting TTASNSSDKAuthCallbackURLPathString];
        self._method   = @"POST";
        self._response = NSStringFromClass([TTASNSSDKAuthCallbackRespModel class]);
    }
    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [dict setValue:self.aid forKey:NSStringFromSelector(@selector(aid))];
    [dict setValue:self.mid forKey:NSStringFromSelector(@selector(mid))];
    [dict setValue:self.platform forKey:NSStringFromSelector(@selector(platform))];
    [dict setValue:self.uid forKey:NSStringFromSelector(@selector(uid))];
    
    [dict setValue:self.code forKey:NSStringFromSelector(@selector(code))];
    
    [dict setValue:self.access_token forKey:NSStringFromSelector(@selector(access_token))];
    [dict setValue:self.expires_in forKey:NSStringFromSelector(@selector(expires_in))];
    [dict setValue:self.openid forKey:NSStringFromSelector(@selector(openid))];
    
    [dict setValue:self.refresh_token forKey:NSStringFromSelector(@selector(refresh_token))];
    
    return dict;
}
@end



@implementation TTASNSSDKAuthSwitchBindReqModel
- (instancetype)init
{
    if ((self = [super init])) {
        self._host     = [TTAccountURLSetting HTTPSBaseURL];
        self._uri      = [TTAccountURLSetting TTASNSSDKSwitchBindURLPathString];
        self._method   = @"POST";
        self._response = NSStringFromClass([TTASNSSDKAuthSwitchBindRespModel class]);
    }
    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [dict setValue:self.auth_token forKey:NSStringFromSelector(@selector(auth_token))];
    [dict setValue:self.code forKey:NSStringFromSelector(@selector(code))];
    [dict setValue:self.platform forKey:NSStringFromSelector(@selector(platform))];
    [dict setValue:self.mid forKey:NSStringFromSelector(@selector(mid))];
    return dict;
}
@end



@implementation TTACustomWAPAuthSwitchBindReqModel
- (instancetype)init
{
    if ((self = [super init])) {
        self._host     = [TTAccountURLSetting HTTPSBaseURL];
        self._uri      = [TTAccountURLSetting TTACustomWAPLoginContinueURLPathString];
        self._method   = @"POST";
        self._response = NSStringFromClass([TTACustomWAPAuthSwitchBindRespModel class]);
        
        [self defaultInit];
    }
    return self;
}

- (void)defaultInit
{
    _unbind_exist = NO;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [dict setValue:self.auth_token forKey:NSStringFromSelector(@selector(auth_token))];
    [dict setValue:self.platform forKey:NSStringFromSelector(@selector(platform))];
    [dict setValue:self.mid forKey:NSStringFromSelector(@selector(mid))];
    [dict setValue:@(self.unbind_exist) forKey:NSStringFromSelector(@selector(unbind_exist))];
    return dict;
}
@end



@implementation TTShareAppToSNSPlatformReqModel
- (instancetype)init
{
    if ((self = [super init])) {
        self._host     = [TTAccountURLSetting SNSBaseURL];
        self._uri      = [TTAccountURLSetting TTAShareAppToSNSPlatformURLPathString];
        self._method   = @"POST";
        self._response = NSStringFromClass([TTShareAppToSNSPlatformRespModel class]);
    }
    return self;
}

- (NSDictionary *)_requestParams
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[super _requestParams]];
    [dict setValue:self.platform forKey:@"platform"];
    [dict setValue:self.device_id forKey:@"device_id"];
    return dict;
}
@end


