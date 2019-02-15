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
#import "UIView+Toast.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "TTUIResponderHelper.h"
#import "TTDeviceHelper.h"

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
                    if (toastCount < 83) {
                        [[ToastManager manager] showToast:@"已加入关注列表"];
                        CSToastStyle *style = [[CSToastStyle alloc]initWithDefaultStyle];
                        style.cornerRadius = 12;
                        style.messageAlignment = NSTextAlignmentCenter;
                        style.messageColor = [UIColor whiteColor];
                        style.backgroundColor = [UIColor colorWithHexString:@"#081f33" alpha:0.96];
                        style.messageFont = [UIFont themeFontRegular:10];
                        style.verticalPadding = 5;
                        style.horizontalPadding = 6;
                        style.isCustomPosition = YES;
                        style.customX = [UIScreen mainScreen].bounds.size.width - 20;
                        style.verticalOffset = 65 + ([TTDeviceHelper isIPhoneXDevice] ? 20 : 0);
                        toastCount += 1;
                        [[TTUIResponderHelper topmostViewController].view makeToast:@"已加入关注列表" duration:3 position:CSToastPositionTop style:style];
                        [[NSUserDefaults standardUserDefaults]setInteger:toastCount forKey:kFHToastCountKey];
                        [[NSUserDefaults standardUserDefaults]synchronize];
                    }

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
