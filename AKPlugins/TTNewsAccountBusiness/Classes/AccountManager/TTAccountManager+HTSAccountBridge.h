//
//  TTAccountManager+HTSAccountBridge.h
//  Article
//
//  Created by liuzuopeng on 21/06/2017.
//
//

#import "TTAccountManager.h"



@interface TTAccountManager (HTSAccountBridge)

+ (void)registerHTSAccountActions;

+ (void)unregisterHTSAccountActions;

+ (void)notifyHTSLoginSuccess;

+ (void)notifyHTSLoginFailure;

+ (void)notifyHTSLogout;

+ (void)notifyHTSSessionExpire;

@end
