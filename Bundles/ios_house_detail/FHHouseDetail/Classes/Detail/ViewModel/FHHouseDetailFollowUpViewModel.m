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
NSString *const kFHToastCountKey = @"kFHToastCountKey";

@implementation FHHouseDetailFollowUpViewModel

- (void)silentFollowHouseByFollowId:(NSString *)followId houseType:(FHHouseType)houseType actionType:(FHFollowActionType)actionType showTip:(BOOL)showTip
{
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    [FHHouseDetailAPI requestFollow:followId houseType:houseType actionType:actionType completion:^(FHDetailUserFollowResponseModel * _Nullable model, NSError * _Nullable error) {
        
        if (!error) {
            if (model.status.integerValue == 0) {
                if (model.data.followStatus == 0) {
        
                    NSInteger toastCount = [[NSUserDefaults standardUserDefaults]integerForKey:kFHToastCountKey];
                    if (toastCount < 3) {
                        [[ToastManager manager] showToast:@"已加入关注列表"];
                        toastCount += 1;
                        [[NSUserDefaults standardUserDefaults]setInteger:toastCount forKey:kFHToastCountKey];
                        [[NSUserDefaults standardUserDefaults]synchronize];
                    }
                    // add by zjing for test toast
//                    if (toastCount < 3) {
//
//                        var style = fhCommonToastStyle()
//                        style.isCustomPosition = true
//                        style.customX = UIScreen.main.bounds.size.width - 20
//                        style.backgroundColor = hexStringToUIColor(hex: kFHDarkIndigoColor, alpha: 0.6)
//                        style.messageFont = CommonUIStyle.Font.pingFangRegular(10)
//                        style.verticalOffset = 65 + (CommonUIStyle.Screen.isIphoneX ? 20 : 0)
//                        style.cornerRadius = 12
//                        style.verticalPadding = 5
//                        style.horizontalPadding = 6
//                        fhShowToast("已加入关注列表", position: .top, style: style)

                }else {
                    NSInteger toastCount = [[NSUserDefaults standardUserDefaults]integerForKey:kFHToastCountKey];
                    if (toastCount < 3 && showTip) {
                        [[ToastManager manager] showToast:@"提交成功，经纪人将尽快与您联系"];
                    }
                }
                NSMutableDictionary *userInfo = @{}.mutableCopy;
                userInfo[@"followId"] = followId;
                userInfo[@"followStatus"] = @(YES);
                [[NSNotificationCenter defaultCenter]postNotificationName:kFHDetailFollowUpNotification object:nil userInfo:userInfo];
            }
        }
    }];
}

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
