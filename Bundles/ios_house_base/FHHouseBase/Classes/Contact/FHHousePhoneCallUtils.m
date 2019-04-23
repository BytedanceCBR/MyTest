//
//  FHHousePhoneCallUtils.m
//  FHHouseDetail
//
//  Created by 张静 on 2019/4/22.
//

#import "FHHousePhoneCallUtils.h"
#import "FHHouseContactConfigModel.h"
#import "FHHouseType.h"
#import "FHHouseDetailAPI.h"
#import <TTRoute.h>
#import "YYCache.h"
#import <FHCommonUI/ToastManager.h>
#import <TTReachability.h>
#import <FHHouseBase/FHUserTracker.h>
#import <HMDTTMonitor.h>
#import "FHDetailBaseModel.h"

typedef enum : NSUInteger {
    FHPhoneCallTypeSuccessVirtual = 0,
    FHPhoneCallTypeSuccessReal,
    FHPhoneCallTypeNetFailed,
    FHPhoneCallTypeRequestFailed,
} FHPhoneCallType;


@implementation FHHousePhoneCallUtils


+ (BOOL)isPhoneCallParamsValid:(FHHouseContactConfigModel *)configModel
{
    NSString *phone = configModel.phone;
    NSString *houseId = configModel.houseId;
    FHHouseType houseType = configModel.houseType;
    NSString *realtorId = configModel.realtorId;
    NSString *searchId = configModel.searchId;
    NSString *imprId = configModel.imprId;
//    if (phone.length < 1 || houseId.length < 1 || realtorId.length < 1 || searchId.length < 1 || imprId.length < 1) {
    if (realtorId.length < 1) {
        NSAssert(NO, @"请校验以上必填字段！");
        return NO;
    }
    return YES;
}

+ (void)callWithConfig:(NSDictionary *)configDict
{
    FHHouseContactConfigModel *configModel = [[FHHouseContactConfigModel alloc]initWithDictionary:configDict error:nil];
    if (configModel) {
        [self callWithConfigModel:configModel];
    }
}


+ (void)callWithConfigModel:(FHHouseContactConfigModel *)configModel 
{
    __weak typeof(self)wself = self;
    NSString *phone = configModel.phone;
    NSString *houseId = configModel.houseId;
    FHHouseType houseType = configModel.houseType;
    NSString *realtorId = configModel.realtorId;
    NSString *searchId = configModel.searchId;
    NSString *imprId = configModel.imprId;

    if (![TTReachability isNetworkConnected]) {
        
        NSString *urlStr = [NSString stringWithFormat:@"tel://%@", phone];
        [self callPhone:urlStr];
        [self addClickCallLog:configModel isVirtual:0];
        [self addDetailCallExceptionLog:FHPhoneCallTypeNetFailed extraDict:nil errorCode:0 message:nil];
        return;
    }
    // add by zjing for test todo
//    BOOL showLoading = YES;
//    if (extraDict[@"show_loading"]) {
//        showLoading = [extraDict[@"show_loading"]boolValue];
//    }
//    if (showLoading) {
//        [self.bottomBar startLoading];
//    }
    
    [self isPhoneCallParamsValid:configModel];

    [FHHouseDetailAPI requestVirtualNumber:realtorId houseId:houseId houseType:houseType searchId:searchId imprId:imprId completion:^(FHDetailVirtualNumResponseModel * _Nullable model, NSError * _Nullable error) {
        
//        if (showLoading) {
//            [wself.bottomBar stopLoading];
//        }
        NSString *urlStr = [NSString stringWithFormat:@"tel://%@", phone];
        NSInteger isVirtual = model.data.isVirtual;
        if (!error && model.data.virtualNumber.length > 0) {
            urlStr = [NSString stringWithFormat:@"tel://%@", model.data.virtualNumber];
            if (model.data.isVirtual) {
                [self addDetailCallExceptionLog:FHPhoneCallTypeSuccessVirtual extraDict:nil errorCode:0 message:nil];
            }else {
                [self addDetailCallExceptionLog:FHPhoneCallTypeSuccessReal extraDict:nil errorCode:0 message:nil];
            }
        }else {

            NSMutableDictionary *extraDict = @{}.mutableCopy;
            extraDict[@"realtor_id"] = realtorId;
            extraDict[@"house_id"] = houseId;
            [self addDetailCallExceptionLog:FHPhoneCallTypeSuccessReal extraDict:extraDict errorCode:error.code message:model.message ? : error.localizedDescription];
        }
        [wself addClickCallLog:configModel isVirtual:isVirtual];
        [wself callPhone:urlStr];
        
    }];
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
// 拨打电话和经纪人展位拨打电话
+ (void)addClickCallLog:(FHHouseContactConfigModel *)configModel isVirtual:(NSInteger)isVirtual
{
    //    11.realtor_id
    //    12.realtor_rank:经纪人推荐位置，从0开始，底部button的默认为0
    //    13.realtor_position ：detail_button，detail_related
    //    14.has_associate：是否为虚拟号码：是：1，否：0
    //    15.is_dial ：是否为为拨号键盘：是：1，否：0
    NSMutableDictionary *params = @{}.mutableCopy;
    
    params[@"page_type"] = configModel.pageType ? : @"be_null";
    params[@"card_type"] = configModel.cardType ? : @"be_null";
    params[@"enter_from"] = configModel.enterFrom ? : @"be_null";
    params[@"element_from"] = configModel.elementFrom ? : @"be_null";
    params[@"rank"] = configModel.rank ? : @"be_null";
    params[@"origin_from"] = configModel.originFrom ? : @"be_null";
    params[@"origin_search_id"] = configModel.originSearchId ? : @"be_null";
    params[@"log_pb"] = configModel.logPb ? : @"be_null";
    
    params[@"has_auth"] = @(1);
    params[@"realtor_id"] = configModel.realtorId ? : @"be_null";
    params[@"realtor_rank"] = configModel.realtorRank ? : @(0);
    params[@"realtor_position"] = configModel.realtorPosition ? : @"detail_button";
    params[@"has_associate"] = [NSNumber numberWithInteger:isVirtual];
    params[@"is_dial"] = @(1);
    params[@"conversation_id"] = @"be_null";
    [FHUserTracker writeEvent:@"click_call" params:params];
}

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


@end
