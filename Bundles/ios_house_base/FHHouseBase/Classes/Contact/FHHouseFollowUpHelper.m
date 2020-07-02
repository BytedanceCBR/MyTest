//
//  FHHouseFollowUpHelper.m
//  FHHouseDetail
//
//  Created by 张静 on 2019/4/22.
//

#import "FHHouseFollowUpHelper.h"
#import "TTReachability.h"
#import "ToastManager.h"
#import "FHDetailBaseModel.h"
#import <FHCommonUI/UIView+FHToast.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "TTUIResponderHelper.h"
#import "TTDeviceHelper.h"
#import <FHHouseBase/FHUserTracker.h>
#import "FHHouseType.h"
#import "FHMainApi+Contact.h"
#import <FHCHousePush/FHPushAuthorizeManager.h>
#import "FHUGCConfig.h"
#import "TTAccountManager.h"

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
    //todo xiefei
    if ([TTAccountManager isLogin]) {
       [self silentFollowHouseWithConfigModel:configModel completionBlock:nil];
    }
}

+ (void)silentFollowHouseWithConfigModel:(FHHouseFollowUpConfigModel *)configModel completionBlock:(void(^)(BOOL isSuccess))completionBlock
{
    if (![TTReachability isNetworkConnected]) {
        if (completionBlock) {
            completionBlock(NO);
        }
        return;
    }
    NSString *followId = configModel.followId;
    FHHouseType houseType = configModel.houseType;
    FHFollowActionType actionType = configModel.actionType ? : configModel.houseType;
    BOOL showTip = configModel.showTip;
    BOOL hideToast = configModel.hideToast;
    
    [self isFollowUpParamsValid:configModel];
    
    [FHMainApi requestFollow:followId houseType:houseType actionType:actionType completion:^(FHDetailUserFollowResponseModel * _Nullable model, NSError * _Nullable error) {
        
        if (!error) {
            BOOL isSuccess = NO;
            if (model.status.integerValue == 0) {
                if (model.data.followStatus == 0) {
                    if (!hideToast) {
                        [self showFollowToast];
                    }
                    isSuccess = YES;
                }
                NSMutableDictionary *userInfo = @{}.mutableCopy;
                userInfo[@"followId"] = followId;
                userInfo[@"followStatus"] = @(1);
                [[NSNotificationCenter defaultCenter]postNotificationName:kFHDetailFollowUpNotification object:nil userInfo:userInfo];
                if(model.data.socialGroupFollowStatus == 0 && model.data.socialGroupId){
                    if ([TTAccountManager isLogin]) {
                        // 修改逻辑 登录状态下 自动关注圈子
                        [[FHUGCConfig sharedInstance] followUGCBy:model.data.socialGroupId isFollow:YES completion:nil];
                    }
                }
                if (completionBlock) {
                    completionBlock(isSuccess);
                }
            }
        }else {
            if (completionBlock) {
                completionBlock(NO);
            }
        }
    }];
}

+(void)showFollowToast
{
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
        style.customX = [UIScreen mainScreen].bounds.size.width - 20 - 50;
        style.verticalOffset = 65 + ([TTDeviceHelper isIPhoneXDevice] ? 20 : 0);
        UIViewController *temp = [TTUIResponderHelper topmostViewController];
        [temp.view makeToast:@"已加入关注列表" duration:3 position:CSToastPositionTop style:style];
        toastCount += 1;
        [[NSUserDefaults standardUserDefaults]setInteger:toastCount forKey:kFHToastCountKey];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
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
    FHFollowActionType actionType = configModel.actionType ? :configModel.houseType;
    
    [FHMainApi requestFollow:followId houseType:houseType actionType:actionType completion:^(FHDetailUserFollowResponseModel * _Nullable model, NSError * _Nullable error) {
        
        if (error) {
            [[ToastManager manager] showToast:@"关注失败"];
        }else {
            if (model.status.integerValue == 0) {
                if ([FHPushAuthorizeManager isFollowAlertEnabled]) {
                    NSMutableDictionary *params = @{}.mutableCopy;
                    params[@"page_type"] = configModel.pageType;
                    [FHPushAuthorizeManager showFollowAlertIfNeeded:params];
                }else {
                    if (model.data.followStatus == 0) {
                        [[ToastManager manager] showToast:@"关注成功"];
                    }else {
                        [[ToastManager manager] showToast:@"已经关注"];
                    }
                }
                NSMutableDictionary *userInfo = @{}.mutableCopy;
                userInfo[@"followId"] = followId;
                userInfo[@"followStatus"] = @(1);
                [[NSNotificationCenter defaultCenter]postNotificationName:kFHDetailFollowUpNotification object:nil userInfo:userInfo];
                if(model.data.socialGroupFollowStatus == 0 && model.data.socialGroupId){
                    if ([TTAccountManager isLogin]) {
                        // 修改逻辑 登录状态下 自动关注圈子
                        [[FHUGCConfig sharedInstance] followUGCBy:model.data.socialGroupId isFollow:YES completion:nil];
                    }
                }
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
    
    [FHMainApi requestCancelFollow:followId houseType:houseType actionType:actionType completion:^(FHDetailUserFollowResponseModel * _Nullable model, NSError * _Nullable error) {
        
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
    if (configModel.itemId.length > 0) {
        params[@"item_id"] = configModel.itemId;
    }
    [FHUserTracker writeEvent:@"click_follow" params:params];
}


@end
