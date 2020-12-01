//
//  FHLoginSharedModel+Monkey.m
//  TTDebug
//
//  Created by bytedance on 2020/11/30.
//

#import "FHLoginSharedModel+Monkey.h"

@implementation FHLoginViewModel (Monkey)

- (BOOL)monkey_shouldShowDouyinIcon {
    return NO;
}

@end

@implementation FHLoginSharedModel (Monkey)

- (BOOL)monkey_douyinCanQucikLogin {
    return NO;
}

@end
