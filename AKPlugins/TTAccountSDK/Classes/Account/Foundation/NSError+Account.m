//
//  NSError+Account.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 12/5/16.
//  Copyright © 2016 Toutiao. All rights reserved.
//

#import "NSError+Account.h"
#import "TTAccountStatusCodeDef.h"



@implementation NSError (Account)

- (BOOL)isSessionExpired
{
    return (self.code == TTAccountErrCodeSessionExpired);
}

- (BOOL)isPlatformExpired
{
    return (self.code == TTAccountErrCodePlatformExpired);
}

- (BOOL)isLoginAccountConflict
{
    return (self.code == TTAccountErrCodeAccountBoundForbid);
}

- (BOOL)isAuthAccountConflict
{
    return (self.code == TTAccountErrCodeAuthPlatformBoundForbid);
}

- (BOOL)isAuthFailed
{
    return self.code == TTAccountErrCodeAuthorizationFailed;
}

- (BOOL)isRedirectURL
{
    return abs(self.code) == 302;
}

- (BOOL)isServerError
{
    return (self.code == TTAccountErrCodeServerDataFormatInvalid ||
            self.code == TTAccountErrCodeServerException);
}

- (BOOL)isClientError
{
    return (self.code == TTAccountErrCodeClientParamsInvalid ||
            self.code == TTAccountErrCodeUserNotLogin);
}

- (BOOL)isNetworkError
{
    return (self.code == TTAccountErrCodeNetworkFailure ||
            self.code == NSURLErrorTimedOut ||
            self.code == NSURLErrorCannotFindHost ||
            self.code == NSURLErrorCannotConnectToHost ||
            self.code == NSURLErrorNetworkConnectionLost ||
            self.code == NSURLErrorNotConnectedToInternet ||
            self.code == NSURLErrorDNSLookupFailed);
}

@end
