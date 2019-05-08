//
//  TTAdPromotionManager.m
//  Article
//
//  Created by carl on 2016/12/14.
//
//

#import "TTAdPromotionManager.h"

#import "SSThemed.h"
#import "TTRoute.h"
#import "TTURLUtils.h"
#import <UIKit/UIKit.h>
#import "TTAdTrackManager.h"
#import <TTTrackerProxy.h>


@implementation TTActivityModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return NO;
}

- (BOOL)validate:(NSError *__autoreleasing *)error {
    if (isEmptyString(self.label)) {
        *error = [JSONModelError errorInvalidDataWithMessage:@"label empty"];
        return NO;
    }
    
    if (isEmptyString(self.icon_url)) {
        *error = [JSONModelError errorInvalidDataWithMessage:@"icon_url empty"];
        return NO;
    }
    
    if (isEmptyString(self.target_url)) {
        *error = [JSONModelError errorInvalidDataWithMessage:@"target_url empty"];
        return NO;
    }
    
    return YES;
}

@end

@implementation TTAdPromotionManager

+ (BOOL)handleModel:(TTActivityModel *)model  condition:(NSDictionary *)baseCondition {
    if (!model) {
        NSAssert(model != nil, @"号外 模型不能为空");
        return NO;
    }
    NSURL *target_url = [TTURLUtils URLWithString:model.target_url];
    if ([[TTRoute sharedRoute] canOpenURL:target_url]) {
        [[TTRoute sharedRoute] openURLByPushViewController:target_url userInfo:TTRouteUserInfoWithDict(baseCondition)];
    } else {
        NSMutableDictionary *condition = [NSMutableDictionary dictionary];
        condition[@"url"] = model.target_url;
        condition[@"title"] = @" ";
        if (!SSIsEmptyDictionary(baseCondition)) {
            [condition addEntriesFromDictionary:baseCondition];
        }
        NSURL *url = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:condition];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:TTRouteUserInfoWithDict(condition)];
    }
    return YES;
}

@end

@implementation TTAdPromotionManager (TTAdTracker)
+ (void)trackEvent:(NSString *)tag label:(NSString *)label extra:(NSDictionary *)extra {
    NSParameterAssert(label != nil);
    NSParameterAssert(tag != nil);
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:3];
    [dict setValue:@"umeng" forKey:@"category"];
    [dict setValue:tag forKey:@"tag"];
    [dict setValue:label forKey:@"label"];
    [dict setValue:@"1" forKey:@"is_ad_event"];
    TTInstallNetworkConnection nt = [[TTTrackerProxy sharedProxy] connectionType];
    [dict setValue:@(nt) forKey:@"nt"];
    if (!SSIsEmptyDictionary(extra)) {
        [dict addEntriesFromDictionary:extra];
    }
    [TTAdTrackManager trackWithTag:tag label:label value:nil extraDic:dict];
}
@end
