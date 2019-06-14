//
//  TTStartupUIGroup.m
//  Article
//
//  Created by fengyadong on 17/1/18.
//
//

#import "TTStartupUIGroup.h"
#import "TTStartupUITask.h"
//#import "TTIntroduceViewTask.h"
//#import "TTStartupWebViewTask.h"
//#import "TTWenDaCellRegisterTask.h"
#import "TTFabricSDKRegister.h"
//#import "TTSFActivityUITask.h"

@implementation TTStartupUIGroup

- (BOOL)isConcurrent {
    return NO;
}

+ (TTStartupUIGroup *)UIGroup {
    TTStartupUIGroup *group = [[TTStartupUIGroup alloc] init];
    
    [group.tasks addObject:[[self class] UIStartupForType:TTUIStartupTypeMainUI]];
//    [group.tasks addObject:[[self class] UIStartupForType:TTUIStartupTypeIntroduceView]];
    
    return group;
}

+ (TTStartupUIGroup *)webviewGroup {
    TTStartupUIGroup *group = [[TTStartupUIGroup alloc] init];
    
    [group.tasks addObject:[[TTFabricSDKRegister alloc] init]];
    
    return group;

}

+ (TTStartupTask *)UIStartupForType:(TTUIStartupType)type {
    switch (type) {
        case TTUIStartupTypeMainUI:
            return [[TTStartupUITask alloc] init];
            break;
//        case TTUIStartupTypeIntroduceView:
//            return [[TTIntroduceViewTask alloc] init];
//            break;
        default:
            return [[TTStartupTask alloc] init];
            break;
    }
    
    return [[TTStartupTask alloc] init];
}

@end