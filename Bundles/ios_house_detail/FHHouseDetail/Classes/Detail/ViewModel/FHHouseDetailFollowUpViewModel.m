//
//  FHHouseDetailFollowUpViewModel.m
//  Pods
//
//  Created by 张静 on 2019/2/14.
//

#import "FHHouseDetailFollowUpViewModel.h"
#import "TTReachability.h"
#import "ToastManager.h"
#import "FHDetailBaseModel.h"

NSString *const kFHDetailFollowUpNotification = @"follow_up_did_changed";

@implementation FHHouseDetailFollowUpViewModel

- (void)followHouseByFollowId:(NSString *)followId houseType:(FHHouseType)houseType actionType:(FHFollowActionType)actionType
{
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    [FHHouseDetailAPI requestFollow:followId houseType:houseType actionType:actionType completion:^(FHDetailUserFollowResponseModel * _Nullable model, NSError * _Nullable error) {
        
        if (error) {
            [[ToastManager manager] showToast:@"关注失败"];
        }else {
            if (model.status.integerValue == 0) {
                if (model.data.followStatus == 0) {
                    [[ToastManager manager] showToast:@"关注成功"];
                }else {
                    [[ToastManager manager] showToast:@"已经关注"];
                }
                NSMutableDictionary *userInfo = @{}.mutableCopy;
                userInfo[@"followId"] = followId;
                userInfo[@"followStatus"] = @(YES);
                [[NSNotificationCenter defaultCenter]postNotificationName:kFHDetailFollowUpNotification object:nil userInfo:userInfo];
            }
        }
    }];
}
- (void)cancelFollowHouseByFollowId:(NSString *)followId houseType:(FHHouseType)houseType actionType:(FHFollowActionType)actionType
{
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"取消关注失败"];
        return;
    }
    [FHHouseDetailAPI requestCancelFollow:followId houseType:houseType actionType:actionType completion:^(FHDetailUserFollowResponseModel * _Nullable model, NSError * _Nullable error) {
        
        if (error) {
            [[ToastManager manager] showToast:@"取消关注失败"];
        }else {
            if (model.status.integerValue == 0) {
                [[ToastManager manager] showToast:@"取关成功"];
                NSMutableDictionary *userInfo = @{}.mutableCopy;
                userInfo[@"followId"] = followId;
                userInfo[@"followStatus"] = @(NO);
                [[NSNotificationCenter defaultCenter]postNotificationName:kFHDetailFollowUpNotification object:nil userInfo:userInfo];
            }
        }
        
    }];
}

@end
