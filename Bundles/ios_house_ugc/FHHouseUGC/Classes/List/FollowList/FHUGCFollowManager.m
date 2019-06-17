//
//  FHUGCFollowManager.m
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/16.
//

#import "FHUGCFollowManager.h"
#import "FHHouseUGCAPI.h"
#import "TTReachability.h"
#import "ToastManager.h"

@interface FHUGCFollowManager ()

@end

@implementation FHUGCFollowManager

+ (instancetype)sharedInstance {
    static FHUGCFollowManager *_sharedInstance = nil;
    if (!_sharedInstance) {
        _sharedInstance = [[FHUGCFollowManager alloc] init];
    }
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)loadFollowData {
    [FHHouseUGCAPI requestFollowListByType:1 class:[FHUGCModel class] completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        if (model && [model isKindOfClass:[FHUGCModel class]]) {
            FHUGCModel *u_model = model;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.followData = u_model;
                [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCLoadFollowDataFinishedNotification object:nil];
            });
        }
    }];
}

// 关注 & 取消关注 follow ：YES为关注 NO为取消关注
- (void)followUGCBy:(NSString *)social_group_id isFollow:(BOOL)follow completion:(void (^ _Nullable)(BOOL isSuccess))completion {
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        if (completion) {
            completion(NO);
        }
        return;
    }
    NSInteger action = 1;
    if (follow) {
        action = 1;
    } else {
        action = 0;
    }
    [FHHouseUGCAPI requestFollow:social_group_id action:action completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        if (model && error == nil) {
            // 请求成功
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([model.status isEqualToString:@"0"]) {
                    if (follow) {
                        // [[ToastManager manager] showToast:@"关注成功"];
                    } else {
                        // [[ToastManager manager] showToast:@"取消关注成功"];
                    }
                    // 关注或者取消关注后 重新拉取 关注列表
                    [self loadFollowData];
                }
                if (completion) {
                    completion(YES);
                }
                NSMutableDictionary *dict = [NSMutableDictionary new];
                dict[@"social_group_id"] = social_group_id;
                dict[@"followStatus"] = @(action);// 0 取消关注 1 关注
                [dict setValue:model.status forKey:@"status"];
                [dict setValue:model.message forKey:@"message"];
                // 发送通知
                [[NSNotificationCenter defaultCenter] postNotificationName:kFHUGCFollowNotification object:nil userInfo:dict];
            });
        } else {
            if (follow) {
                // [[ToastManager manager] showToast:@"关注失败"];
            } else {
                // [[ToastManager manager] showToast:@"取消关注失败"];
            }
            if (completion) {
                completion(NO);
            }
        }
    }];
  
}

@end
