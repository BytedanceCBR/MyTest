//
//  FHHouseFollowUpHelper.m
//  FHHouseDetail
//
//  Created by 张静 on 2019/4/22.
//

#import "FHHouseFollowUpHelper.h"
#import "FHHouseFollowUpConfigModel.h"
#import "TTReachability.h"
#import "ToastManager.h"
#import "FHDetailBaseModel.h"
#import "UIView+Toast.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "TTUIResponderHelper.h"
#import "TTDeviceHelper.h"
#import <FHHouseBase/FHUserTracker.h>
#import "FHHouseType.h"
#import "FHHouseDetailAPI.h"

NSString *const kFHDetailFollowUpNotification = @"follow_up_did_changed";
NSString *const kFHToastCountKey = @"kFHToastCountKey";

@implementation FHHouseFollowUpHelper

+ (BOOL)isFollowUpParamsValid:(FHHouseFollowUpConfigModel *)configModel
{
    NSString *followId = configModel.followId;
    if (followId.length < 1) {
        NSAssert(NO, @"请校验以上必填字段！");
        return NO;
    }
    return YES;
}

+ (void)silentFollowHouseWithConfigModel:(FHHouseFollowUpConfigModel *)configModel
{
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    NSString *followId = configModel.followId;
    FHHouseType houseType = configModel.houseType;
    FHFollowActionType actionType = configModel.actionType;
    UIViewController *topVC = configModel.topVC;
    BOOL showTip = configModel.showTip;

    [self isFollowUpParamsValid:configModel];
    
    [FHHouseDetailAPI requestFollow:followId houseType:houseType actionType:actionType completion:^(FHDetailUserFollowResponseModel * _Nullable model, NSError * _Nullable error) {
        
        if (!error) {
            if (model.status.integerValue == 0) {
                if (model.data.followStatus == 0) {
                    if (topVC && topVC.childViewControllers.count == 0) {
                        
                        NSInteger toastCount = [[NSUserDefaults standardUserDefaults]integerForKey:kFHToastCountKey];
                        if (toastCount < 3) {
                            CSToastStyle *style = [[CSToastStyle alloc]initWithDefaultStyle];
                            style.cornerRadius = 12;
                            style.messageAlignment = NSTextAlignmentCenter;
                            style.messageColor = [UIColor whiteColor];
                            style.backgroundColor = [[UIColor themeGray1] colorWithAlphaComponent:0.96];
                            style.messageFont = [UIFont themeFontRegular:10];
                            style.verticalPadding = 5;
                            style.horizontalPadding = 6;
                            style.isCustomPosition = YES;
                            style.customX = [UIScreen mainScreen].bounds.size.width - 20;
                            style.verticalOffset = 65 + ([TTDeviceHelper isIPhoneXDevice] ? 20 : 0);
                            toastCount += 1;
                            UIViewController *temp = [TTUIResponderHelper topmostViewController];
                            UIView *v = temp.view;
                            [topVC.view makeToast:@"已加入关注列表" duration:3 position:CSToastPositionTop style:style];
                            [[NSUserDefaults standardUserDefaults]setInteger:toastCount forKey:kFHToastCountKey];
                            [[NSUserDefaults standardUserDefaults]synchronize];
                        }
                    }
                }else {
                    NSInteger toastCount = [[NSUserDefaults standardUserDefaults]integerForKey:kFHToastCountKey];
                    if (toastCount < 3 && showTip) {
                        [[ToastManager manager] showToast:@"提交成功，经纪人将尽快与您联系"];
                    }
                }
                NSMutableDictionary *userInfo = @{}.mutableCopy;
                userInfo[@"followId"] = followId;
                userInfo[@"followStatus"] = @(1);
                [[NSNotificationCenter defaultCenter]postNotificationName:kFHDetailFollowUpNotification object:nil userInfo:userInfo];
            }
        }
    }];
}

+ (void)silentFollowHouseWithConfig:(NSDictionary *)config
{
    FHHouseFollowUpConfigModel *configModel = [[FHHouseFollowUpConfigModel alloc]initWithDictionary:config error:nil];
    if (configModel) {
        [self silentFollowHouseWithConfigModel:configModel];
    }
}

+ (void)followHouseWithConfigModel:(FHHouseFollowUpConfigModel *)configModel
{
    [self addClickFollowLog:configModel];
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    NSString *followId = configModel.followId;
    FHHouseType houseType = configModel.houseType;
    FHFollowActionType actionType = configModel.actionType;
    
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
                userInfo[@"followStatus"] = @(1);
                [[NSNotificationCenter defaultCenter]postNotificationName:kFHDetailFollowUpNotification object:nil userInfo:userInfo];
            }
        }
    }];
}

+ (void)followHouseWithConfig:(NSDictionary *)config
{
    FHHouseFollowUpConfigModel *configModel = [[FHHouseFollowUpConfigModel alloc]initWithDictionary:config error:nil];
    if (configModel) {
        [self followHouseWithConfigModel:configModel];
    }
}

+ (void)cancelFollowHouseWithConfigModel:(FHHouseFollowUpConfigModel *)configModel
{
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    NSString *followId = configModel.followId;
    FHHouseType houseType = configModel.houseType;
    FHFollowActionType actionType = configModel.actionType;
    
    [FHHouseDetailAPI requestCancelFollow:followId houseType:houseType actionType:actionType completion:^(FHDetailUserFollowResponseModel * _Nullable model, NSError * _Nullable error) {
        
        if (error) {
            [[ToastManager manager] showToast:@"取消失败"];
        }else {
            if (model.status.integerValue == 0) {
                [[ToastManager manager] showToast:@"取消关注"];
                NSMutableDictionary *userInfo = @{}.mutableCopy;
                userInfo[@"followId"] = followId;
                userInfo[@"followStatus"] = @(0);
                [[NSNotificationCenter defaultCenter]postNotificationName:kFHDetailFollowUpNotification object:nil userInfo:userInfo];
            }
        }
        
    }];
}

+ (void)cancelFollowHouseWithConfig:(NSDictionary *)config
{
    FHHouseFollowUpConfigModel *configModel = [[FHHouseFollowUpConfigModel alloc]initWithDictionary:config error:nil];
    if (configModel) {
        [self cancelFollowHouseWithConfigModel:configModel];
    }
}

#pragma mark 埋点相关
//- (NSDictionary *)baseParams
//{
//    NSMutableDictionary *params = @{}.mutableCopy;
//    params[@"page_type"] = self.tracerDict[@"page_type"] ? : @"be_null";
//    params[@"card_type"] = self.tracerDict[@"card_type"] ? : @"be_null";
//    params[@"enter_from"] = self.tracerDict[@"enter_from"] ? : @"be_null";
//    params[@"element_from"] = self.tracerDict[@"element_from"] ? : @"be_null";
//    params[@"rank"] = self.tracerDict[@"rank"] ? : @"be_null";
//    params[@"origin_from"] = self.tracerDict[@"origin_from"] ? : @"be_null";
//    params[@"origin_search_id"] = self.tracerDict[@"origin_search_id"] ? : @"be_null";
//    params[@"log_pb"] = self.tracerDict[@"log_pb"] ? : @"be_null";
//    return params;
//}

+ (void)addClickFollowLog:(FHHouseFollowUpConfigModel *)configModel
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"page_type"] = configModel.pageType ? : @"be_null";
    params[@"card_type"] = configModel.cardType ? : @"be_null";
    params[@"enter_from"] = configModel.enterFrom ? : @"be_null";
    params[@"element_from"] = configModel.elementFrom ? : @"be_null";
    params[@"rank"] = configModel.rank ? : @"be_null";
    params[@"origin_from"] = configModel.originFrom ? : @"be_null";
    params[@"origin_search_id"] = configModel.originSearchId ? : @"be_null";
    params[@"log_pb"] = configModel.logPb ? : @"be_null";
    [FHUserTracker writeEvent:@"click_follow" params:params];
}


@end
