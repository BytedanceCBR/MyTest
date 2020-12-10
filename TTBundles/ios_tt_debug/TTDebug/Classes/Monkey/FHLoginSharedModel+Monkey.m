//
//  FHLoginSharedModel+Monkey.m
//  TTDebug
//
//  Created by bytedance on 2020/11/30.
//

#import "FHLoginSharedModel+Monkey.h"

@implementation FHLoginViewModel (Monkey)

- (BOOL)monkey_shouldShowDouyinIcon {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"IS_MONKEY"]) {
        return NO;
    }
    return [self monkey_shouldShowDouyinIcon];
}

@end

@implementation FHLoginSharedModel (Monkey)

- (BOOL)monkey_douyinCanQucikLogin {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"IS_MONKEY"]) {
        return NO;
    }
    return [self monkey_douyinCanQucikLogin];
}

@end
