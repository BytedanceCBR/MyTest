//
//  TTABAuthorizationManager.m
//  Article
//
//  Created by zuopengl on 9/19/16.
//
//

#import "TTABAuthorizationManager.h"


NSString *const TTABAuthorizationStatusKey = @"TTABAuthorizationStatusValue";

@implementation TTABAuthorizationManager

+ (BOOL)hasBeenAuthorized {
    return ([self authorizationStatus] == kTTABAuthorizationStatusAuthorized);
}

+ (BOOL)hasShownAuthorizedGuideDialog {
    return ([self authorizationStatus] != kTTABAuthorizationStatusNotDetermined);
}

+ (TTABAuthorizationStatus)authorizationStatus {
    return (TTABAuthorizationStatus) [[NSUserDefaults standardUserDefaults] integerForKey:TTABAuthorizationStatusKey];
}

+ (void)setAuthorizationStatusForValue:(TTABAuthorizationStatus)status {
    [[NSUserDefaults standardUserDefaults] setInteger:status forKey:TTABAuthorizationStatusKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
