//
//  TTStartupOpenURLGroup.m
//  Article
//
//  Created by fengyadong on 17/1/22.
//
//

#import "TTStartupOpenURLGroup.h"
#import "TTQQShareOpenURLTask.h"
#import "TTAppLinkOpenURLTask.h"
#import "TTWeixinOpenURLTask.h"
//#import "TTDingtalkOpenURLTask.h"
#import "TTPayManagerOpenURLTask.h"
//#import "TTAlipayOpenURLTask.h"
#import "TTTrackerOpenURLTask.h"
#import "TTOpenURLFeedBackLogTask.h"
//#import "TTBDSDKOpenURLTask.h"
//#import "TTSFOpenURLTask.h"

@implementation TTStartupOpenURLGroup

- (BOOL)isConcurrent {
    return NO;
}

+ (TTStartupOpenURLGroup *)openURLGroup {
    TTStartupOpenURLGroup *group = [[TTStartupOpenURLGroup alloc] init];
//    [group.tasks addObject:[[self class] openURLStartupForType:TTOpenURLTypeSF]];
    [group.tasks addObject:[[self class] openURLStartupForType:TTOpenURLFeedBackLog]];
    [group.tasks addObject:[[self class] openURLStartupForType:TTOpenURLTypeTTTracker]];
//    [group.tasks addObject:[[self class] openURLStartupForType:TTOpenURLTypeBytedanceSDKs]];
    [group.tasks addObject:[[self class] openURLStartupForType:TTOpenURLTypeQQShare]];
    [group.tasks addObject:[[self class] openURLStartupForType:TTOpenURLTypeAppLink]];
    [group.tasks addObject:[[self class] openURLStartupForType:TTOpenURLTypeWeixin]];
//    [group.tasks addObject:[[self class] openURLStartupForType:TTOpenURLTypeDingtalk]];
    [group.tasks addObject:[[self class] openURLStartupForType:TTOpenURLTypePayManager]];
//    [group.tasks addObject:[[self class] openURLStartupForType:TTOpenURLTypeAlipay]];
    
    return group;
}

+ (TTStartupTask *)openURLStartupForType:(TTOpenURLType)type {
    switch (type) {
        case TTOpenURLFeedBackLog:
            return [[TTOpenURLFeedBackLogTask alloc] init];
            break;
        case TTOpenURLTypeTTTracker:
            return [[TTTrackerOpenURLTask alloc] init];
            break;
        case TTOpenURLTypeQQShare:
            return [[TTQQShareOpenURLTask alloc] init];
            break;
        case TTOpenURLTypeAppLink:
            return [[TTAppLinkOpenURLTask alloc] init];
            break;
        case TTOpenURLTypeWeixin:
            return [[TTWeixinOpenURLTask alloc] init];
            break;
//        case TTOpenURLTypeDingtalk:
//            return [[TTDingtalkOpenURLTask alloc] init];
//            break;
        case TTOpenURLTypePayManager:
            return [[TTPayManagerOpenURLTask alloc] init];
            break;
//        case TTOpenURLTypeSF:
//            return [[TTSFOpenURLTask alloc] init];
//            break;
//        case TTOpenURLTypeAlipay:
//            return [[TTAlipayOpenURLTask alloc] init];
//            break;
//        case TTOpenURLTypeBytedanceSDKs:
//            return [[TTBDSDKOpenURLTask alloc] init];
//            break;
        default:
            return [[TTStartupTask alloc] init];
            break;
    }
    
    return [[TTStartupTask alloc] init];
}

@end
