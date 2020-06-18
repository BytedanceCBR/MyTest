//
//  FHHousePhoneCallUtils.m
//  FHHouseDetail
//
//  Created by 张静 on 2019/4/22.
//

#import "FHHousePhoneCallUtils.h"
#import "FHHouseType.h"
#import "FHMainApi+Contact.h"
#import "TTRoute.h"
#import "YYCache.h"
#import <FHCommonUI/ToastManager.h>
#import "TTReachability.h"
#import <FHHouseBase/FHUserTracker.h>
#import "HMDTTMonitor.h"
#import "FHDetailBaseModel.h"

typedef enum : NSUInteger {
    FHPhoneCallTypeSuccessVirtual = 0,
    FHPhoneCallTypeSuccessReal,
    FHPhoneCallTypeNetFailed,
    FHPhoneCallTypeRequestFailed,
} FHPhoneCallType;


@implementation FHHousePhoneCallUtils

+ (NSString *)fromStrByContact:(FHHouseContactConfigModel *)configModel
{
    switch (configModel.houseType) {
        case FHHouseTypeNewHouse:
            return @"app_court";
            break;
        case FHHouseTypeSecondHandHouse:
            return configModel.realtorType == FHRealtorTypeNormal ? @"app_oldhouse" :@"app_oldhouse_expert";
            break;
        case FHHouseTypeNeighborhood:
            return @"app_neighbourhood";
            break;
        case FHHouseTypeRentHouse:
            return @"app_renthouse";
            break;
        default:
            break;
    }
    return @"be_null";
}


+ (void)callPhone:(NSString *)phone
{
    NSURL *url = [NSURL URLWithString:phone];
    if ([[UIApplication sharedApplication]canOpenURL:url]) {
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication]openURL:url options:@{} completionHandler:nil];
        } else {
            // Fallback on earlier versions
            [[UIApplication sharedApplication]openURL:url];
        }
    }
}

#pragma mark - log


+ (void)addDetailCallExceptionLog:(NSInteger)status extraDict:(NSDictionary *)extraDict errorCode:(NSInteger)errorCode message:(NSString *)message
{
    NSMutableDictionary *attr = @{}.mutableCopy;
    if (extraDict.count > 0) {
        [attr addEntriesFromDictionary:extraDict];
    }
    if (status == FHPhoneCallTypeRequestFailed) {
        attr[@"error_code"] = @(errorCode);
        attr[@"message"] = message;
    }
    attr[@"desc"] = [self exceptionStatusStrBy:status];
    [[HMDTTMonitor defaultManager]hmdTrackService:@"detail_call_exception" status:status extra:attr];
}

+ (NSString *)exceptionStatusStrBy:(NSInteger)status
{
    switch (status) {
        case FHPhoneCallTypeSuccessVirtual:
            return @"success_virtual";
            break;
        case FHPhoneCallTypeSuccessReal:
            return @"success_real";
            break;
        case FHPhoneCallTypeNetFailed:
            return @"net_failed";
            break;
        case FHPhoneCallTypeRequestFailed:
            return @"request_failed";
            break;
            
        default:
            return @"be_null";
            break;
    }
}

#pragma mark - refactor
+ (void)callWithAssociatePhoneDict:(NSDictionary *)associatePhoneDict completion:(FHHousePhoneCallCompletionBlock)completionBlock
{
    FHAssociatePhoneModel *associateModel = [[FHAssociatePhoneModel alloc]initWithDictionary:associatePhoneDict error:nil];
    if (associateModel) {
        [self callWithAssociatePhoneModel:associateModel completion:completionBlock];
    }
}

+ (void)callWithAssociatePhoneModel:(FHAssociatePhoneModel *)associatePhoneModel completion:(FHHousePhoneCallCompletionBlock)completionBlock
{
    NSDictionary *associateInfo = associatePhoneModel.associateInfo;
    NSString *houseId = associatePhoneModel.houseId;
    FHHouseType houseType = associatePhoneModel.houseType;
    
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常，请稍后重试!"];
        [self addDetailCallExceptionLog:FHPhoneCallTypeNetFailed extraDict:nil errorCode:0 message:nil];
        NSError *error = [[NSError alloc]initWithDomain:NSURLErrorDomain code:-1 userInfo:nil];
        if (completionBlock) {
            completionBlock(NO,error,nil);
        }
        return;
    }
    
    if (associatePhoneModel.showLoading) {
        NSMutableDictionary *userInfo = @{}.mutableCopy;
        userInfo[@"house_id"] = houseId;
        userInfo[@"show_loading"] = @(1);
        [[NSNotificationCenter defaultCenter]postNotificationName:@"kFHDetailLoadingNotification" object:nil userInfo:userInfo];
    }
    [FHMainApi requestVirtualNumberWithAssociateInfo:associateInfo realtorId:associatePhoneModel.realtorId houseId:associatePhoneModel.houseId houseType:associatePhoneModel.houseType searchId:associatePhoneModel.searchId imprId:associatePhoneModel.imprId extraInfo:nil completion:^(FHDetailVirtualNumResponseModel * _Nullable model, NSError * _Nullable error) {
        
        NSMutableDictionary *userInfo = @{}.mutableCopy;
        userInfo[@"house_id"] = houseId;
        userInfo[@"show_loading"] = @(0);
        [[NSNotificationCenter defaultCenter]postNotificationName:@"kFHDetailLoadingNotification" object:nil userInfo:userInfo];
        
        if (!error && model.data.virtualNumber.length > 0) {
            NSInteger isVirtual = model.data.isVirtual;
            NSString *urlStr = [NSString stringWithFormat:@"tel://%@", model.data.virtualNumber];
            if (model.data.isVirtual) {
                [self addDetailCallExceptionLog:FHPhoneCallTypeSuccessVirtual extraDict:nil errorCode:0 message:nil];
            }else {
                [self addDetailCallExceptionLog:FHPhoneCallTypeSuccessReal extraDict:nil errorCode:0 message:nil];
            }
            [self addClickCallWith:associatePhoneModel isVirtual:isVirtual];
            [self callPhone:urlStr];
            if (completionBlock) {
                completionBlock(YES,nil,model.data);
            }
            return;
        }
        [[ToastManager manager] showToast:@"网络异常，请稍后重试!"];
        NSMutableDictionary *extraDict = @{}.mutableCopy;
//        extraDict[@"realtor_id"] = realtorId;
        extraDict[@"house_id"] = houseId;
        [self addDetailCallExceptionLog:FHPhoneCallTypeRequestFailed extraDict:extraDict errorCode:error.code message:model.message ? : error.localizedDescription];
        if (completionBlock) {
            completionBlock(NO,nil,nil);
        }
    }];
}

// 拨打电话和经纪人展位拨打电话
+ (void)addClickCallWith:(FHAssociatePhoneModel *)phoneAssociate isVirtual:(NSInteger)isVirtual
{
    NSMutableDictionary *params = @{}.mutableCopy;
    NSDictionary *reportParams = phoneAssociate.reportParams;
    
    params[@"page_type"] = reportParams[@"page_type"] ? : @"be_null";
    params[@"card_type"] = reportParams[@"card_type"] ? : @"be_null";
    params[@"enter_from"] = reportParams[@"enter_from"] ? : @"be_null";
    params[@"element_from"] = reportParams[@"element_from"] ? : @"be_null";
    params[@"rank"] = reportParams[@"rank"] ? : @"be_null";
    params[@"origin_from"] = reportParams[@"origin_from"] ? : @"be_null";
    params[@"origin_search_id"] = reportParams[@"origin_search_id"] ? : @"be_null";
    params[@"log_pb"] = reportParams[@"log_pb"] ? : @"be_null";
    params[kFHAssociateInfo] = phoneAssociate.associateInfo;
    params[@"has_auth"] = @(1);
    params[@"has_associate"] = [NSNumber numberWithInteger:isVirtual];
    params[@"is_dial"] = @(1);
    params[@"realtor_logpb"] = reportParams[@"realtor_logpb"];
    params[@"growth_deepevent"] = @(1);
    params[@"realtor_position"] = reportParams[@"realtor_position"] ? : @"detail_button";
    params[@"realtor_rank"] = reportParams[@"realtor_rank"] ? : @(0);
    params[@"realtor_id"] = reportParams[@"realtor_id"] ? : @"be_null";
    if (reportParams[@"picture_type"]) {
        params[@"picture_type"] = reportParams[@"picture_type"];
    }

    params[@"position"] = reportParams[@"position"] ? : @"be_null";
    if (reportParams[@"item_id"]) {
        params[@"item_id"] = reportParams[@"item_id"];
    }

    [FHUserTracker writeEvent:@"click_call" params:params];
}


@end
