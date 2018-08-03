//
//  FRAPPDelegateHelper.m
//  Article
//
//  Created by ZhangLeonardo on 15/10/15.
//
//

#import "FRAPPDelegateHelper.h"
#import "TTUGCPodBridge.h"

@implementation FRAPPDelegateHelper

- (void)dosomethingWhenCurrentVersionFistLaunch
{
    
}

+ (BOOL)isInThirdTab {
    return [[TTUGCPodBridge sharedInstance] isInThirdTab];
}

+ (BOOL)isConcernTabbar
{
    return [[TTUGCPodBridge sharedInstance] isConcernTabbar];
}

@end
