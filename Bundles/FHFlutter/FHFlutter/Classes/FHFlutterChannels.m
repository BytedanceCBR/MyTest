//
//  FHFlutterChannels.m
//  ABRInterface
//
//  Created by 谢飞 on 2020/9/6.
//

#import "FHFlutterChannels.h"
#import <ByteDanceKit/ByteDanceKit.h>
#import "TTReachability.h"
#import "ToastManager.h"
#import <TTRoute.h>
#import "FHChatUserInfoManager.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHNeighborhoodDetailViewModel.h"
#import <FHHouseDetail/FHDetailBaseModel.h>
#import <FHHouseBase/FHAssociateIMModel.h>
#import <FHHouseBase/FHAssociateReportParams.h>
#import <FHHouseBase/FHHouseIMClueHelper.h>
#import <FHHouseBase/FHAssociateFormReportModel.h>
#import <FHHouseBase/FHHouseFillFormHelper.h>
#import <TTBaseLib/TTUIResponderHelper.h>
#import <FHHouseBase/FHAssociatePhoneModel.h>
#import <FHHouseBase/FHHousePhoneCallUtils.h>

@interface FHFlutterChannels()

//@property (nonatomic, strong) FHBCustomerDetailViewModel *callModel;

@property (nonatomic, weak) FHNeighborhoodDetailViewModel *tempNeighborhoodViewModel;

@property (nonatomic, copy) void (^phoneCallBlock)(BOOL finished);

@end

@implementation FHFlutterChannels

+(instancetype)sharedInstance
{
    static FHFlutterChannels * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshBottomBarLoadingState:) name:@"kFHDetailLoadingNotification" object:nil];
    }
    return self;
}

- (void)refreshBottomBarLoadingState:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    NSInteger loading = [userInfo btd_integerValueForKey:@"show_loading"];
    if (loading) {
        //开始加载
    }else {
        //结束加载
        if (self.phoneCallBlock) {
            self.phoneCallBlock(YES);
        }
    }
}

- (void)updateTempNeighborhoodViewModel:(FHNeighborhoodDetailViewModel *)viewModel {
    self.tempNeighborhoodViewModel = viewModel;
}

+ (void)processChannelsImp:(FlutterMethodCall *)call callback:(FlutterResult)resultCallBack{
    
    NSString *methodName = call.method;
    if ([methodName isEqualToString:@"callPhone"]) {
        [self callPhoneWithParam:call callback:resultCallBack];
    } else if ([methodName isEqualToString:@"showConsultForm"]) {
        [self showConsultFormWithParam:call callback:resultCallBack];
    } else if ([methodName isEqualToString:@"jumpToIM"]) {
        [self jumpToIMWithParam:call callback:resultCallBack];
    }
//    if ([@"invalidReasonDialog" isEqualToString:call.method]) {
//        [FHFlutterChannels invalidReasonDialogWithParam:call callback:resultCallBack];
//    } else if([@"callPhone" isEqualToString:call.method]) {
//        [FHFlutterChannels callPhoneWithParam:call callback:resultCallBack];
//    }else if([@"broadcastInfo" isEqualToString:call.method]) {
//        [FHFlutterChannels broadCasetNotifyWithParam:call callback:resultCallBack];
//    }else if([@"broadcastEnter" isEqualToString:call.method]) {
//        [FHFlutterChannels broadCastEnterPageNotifyWithParam:call callback:resultCallBack];
//    }else if([@"searchNewHouse" isEqualToString:call.method]) {
//        [[FHFlutterChannels sharedInstance] searchNewHouseParam:call callback:resultCallBack];
//    }
//
    
}

//电话线索
+ (void)callPhoneWithParam:(FlutterMethodCall *)call callback:(FlutterResult)resultCallBack{
    
    if (call.arguments && [call.arguments isKindOfClass:[NSDictionary class]]) {
        NSDictionary *argumentsDict = (NSDictionary *)call.arguments;
        if (argumentsDict[@"params"] && argumentsDict[@"report_params"]) {
            
            [[FHFlutterChannels sharedInstance] setPhoneCallBlock:^(BOOL finished) {
                resultCallBack(@(YES));
                [FHFlutterChannels sharedInstance].phoneCallBlock = nil;
            }];
            
            NSDictionary *params = [self checkInvalidJsonString:argumentsDict[@"params"]];
            NSDictionary *reportParams = [self checkInvalidJsonString:argumentsDict[@"report_params"]];
            
            FHClueAssociateInfoModel *associateInfo = [[FHClueAssociateInfoModel alloc] initWithDictionary:[self checkInvalidJsonString:[params btd_stringValueForKey:@"associate_info"]] error:nil];
            
            FHAssociatePhoneModel *associatePhone = [[FHAssociatePhoneModel alloc] init];
            associatePhone.reportParams = reportParams.copy;
            associatePhone.associateInfo = associateInfo.phoneInfo;
            
            associatePhone.houseType = [params btd_intValueForKey:@"house_type"];;
            associatePhone.houseId = [params btd_stringValueForKey:@"group_id"];
            //
            associatePhone.searchId = [reportParams btd_stringValueForKey:@"search_id" default:@"be_null"];
            associatePhone.imprId = [reportParams btd_stringValueForKey:@"impr_id" default:@"be_null"];
            associatePhone.showLoading = YES;
            associatePhone.realtorId = [params btd_stringValueForKey:@"realtor_id" default:@"be_null"];
            
            associatePhone.extraDict = @{@"biz_trace": [params btd_stringValueForKey:@"biz_trace" default:@"be_null"]};
            
            [FHHousePhoneCallUtils callWithAssociatePhoneModel:associatePhone completion:^(BOOL success, NSError * _Nonnull error, FHDetailVirtualNumModel * _Nonnull virtualPhoneNumberModel) {
                if ([FHFlutterChannels sharedInstance].phoneCallBlock) {
                    [FHFlutterChannels sharedInstance].phoneCallBlock(YES);
                }
            }];
        } else {
            resultCallBack(nil);
        }
    } else {
        resultCallBack(nil);
    }
   
    
//    FHNeighborhoodDetailViewModel *tempNeighborhoodViewModel = [FHFlutterChannels sharedInstance].tempNeighborhoodViewModel;
//    FHHouseDetailContactViewModel *tempAssociateViewModel = tempNeighborhoodViewModel.contactViewModel;
//    FHDetailContactModel *contactPhone = tempAssociateViewModel.contactPhone;
//    if (tempNeighborhoodViewModel && tempAssociateViewModel && contactPhone.enablePhone) {
//
//        [[FHFlutterChannels sharedInstance] setPhoneCallBlock:^(BOOL finished) {
//            resultCallBack(@(YES));
//            [FHFlutterChannels sharedInstance].phoneCallBlock = nil;
//        }];
//        NSMutableDictionary *extraDic = @{
//            @"realtor_position": @"detail_button",
//            @"enter_from": @"neighborhood_detail",
//            @"element_from": @"average_price",
//            @"page_type": @"average_price_detail",
//            UT_ELEMENT_TYPE: @"be_null"
//        }.mutableCopy;
////        [extraDic addEntriesFromDictionary:self.tracerDict];
//        extraDic[kFHAssociateInfo] = tempNeighborhoodViewModel.detailData.data.priceTrendAssociateInfo.phoneInfo;
//        [tempAssociateViewModel contactActionWithExtraDict:extraDic];
//    } else {
//        resultCallBack(nil);
//    }
}

//表单线索
+ (void)showConsultFormWithParam:(FlutterMethodCall *)call callback:(FlutterResult)resultCallBack {
    if (call.arguments && [call.arguments isKindOfClass:[NSDictionary class]]) {
        NSDictionary *argumentsDict = (NSDictionary *)call.arguments;
        if (argumentsDict[@"params"] && argumentsDict[@"report_params"]) {
            NSDictionary *params = [self checkInvalidJsonString:argumentsDict[@"params"]];
            NSDictionary *reportParams = [self checkInvalidJsonString:argumentsDict[@"report_params"]];
            
            FHClueAssociateInfoModel *associateInfo = [[FHClueAssociateInfoModel alloc] initWithDictionary:[self checkInvalidJsonString:[params btd_stringValueForKey:@"associate_info"]] error:nil];
            
            FHAssociateFormReportModel *formReportModel = [[FHAssociateFormReportModel alloc] init];
            formReportModel.associateInfo = associateInfo.reportFormInfo;
            
            NSMutableDictionary *tracerDic = reportParams.mutableCopy;

            formReportModel.reportParams = reportParams.copy;
            formReportModel.houseType = [params btd_intValueForKey:@"house_type"];
            formReportModel.title = @"咨询经纪人";
            formReportModel.btnTitle = @"提交";
            formReportModel.subtitle = @"提交后将安排专业经纪人与您联系。";
            formReportModel.topViewController = [TTUIResponderHelper topmostViewController];
            [FHHouseFillFormHelper fillFormActionWithAssociateReportModel:formReportModel completion:^{
            }];
        }
    }
//    FHNeighborhoodDetailViewModel *tempNeighborhoodViewModel = [FHFlutterChannels sharedInstance].tempNeighborhoodViewModel;
//    FHHouseDetailContactViewModel *tempAssociateViewModel = tempNeighborhoodViewModel.contactViewModel;
//    if (tempNeighborhoodViewModel && tempAssociateViewModel) {
//
//        NSMutableDictionary *extraDic = @{
//            @"position": @"button",
//            @"enter_from": @"neighborhood_detail",
//            @"element_from": @"average_price",
//            @"page_type": @"average_price_detail",
//            UT_ELEMENT_TYPE: @"be_null"
//        }.mutableCopy;
////        [extraDic addEntriesFromDictionary:self.tracerDict];
//
//        NSDictionary *associateInfoDict = nil;
//        FHDetailContactModel *contactPhone = tempAssociateViewModel.contactPhone;
//        if (contactPhone.enablePhone) {
//            associateInfoDict = tempNeighborhoodViewModel.detailData.data.priceTrendAssociateInfo.phoneInfo;
//        }else {
//            associateInfoDict = tempNeighborhoodViewModel.detailData.data.priceTrendAssociateInfo.reportFormInfo;
//        }
//        extraDic[kFHAssociateInfo] = associateInfoDict;
//        [tempAssociateViewModel contactActionWithExtraDict:extraDic];
//    }
    resultCallBack(nil);
}

//IM线索
+ (void)jumpToIMWithParam:(FlutterMethodCall *)call callback:(FlutterResult)resultCallBack {
    if (call.arguments && [call.arguments isKindOfClass:[NSDictionary class]]) {
        NSDictionary *argumentsDict = (NSDictionary *)call.arguments;
        if (argumentsDict[@"params"] && argumentsDict[@"report_params"]) {
            NSDictionary *params = [self checkInvalidJsonString:argumentsDict[@"params"]];
            NSDictionary *reportParams = [self checkInvalidJsonString:argumentsDict[@"report_params"]];
            
            FHClueAssociateInfoModel *associateInfo = [[FHClueAssociateInfoModel alloc] initWithDictionary:[self checkInvalidJsonString:[params btd_stringValueForKey:@"associate_info"]] error:nil];
            
            // IM 透传数据模型
            FHAssociateIMModel *associateIMModel = [[FHAssociateIMModel alloc] init];
            associateIMModel.houseId = [params btd_stringValueForKey:@"group_id"];
            associateIMModel.houseType = [params btd_intValueForKey:@"house_type"];
            associateIMModel.associateInfo = associateInfo;
            associateIMModel.extraInfo = @{@"biz_trace": [params btd_stringValueForKey:@"biz_trace" default:@"be_null"]};

            
            // IM 相关埋点上报参数
            FHAssociateReportParams *reportModel = [[FHAssociateReportParams alloc] init];
            reportModel.enterFrom = [reportParams btd_stringValueForKey:@"enter_from" default:@"be_null"];
            reportModel.elementFrom = [reportParams btd_stringValueForKey:@"element_from" default:@"be_null"];
            reportModel.elementType = [reportParams btd_stringValueForKey:@"element_type" default:@"be_null"];
            reportModel.logPb = [self checkInvalidJsonString:[reportParams btd_stringValueForKey:@"log_pb"]];
            reportModel.originFrom = [reportParams btd_stringValueForKey:@"origin_from" default:@"be_null"];
            reportModel.rank = [reportParams btd_stringValueForKey:@"rank" default:@"be_null"];
            reportModel.originSearchId = [reportParams btd_stringValueForKey:@"origin_search_id" default:@"be_null"];
            reportModel.searchId = [reportParams btd_stringValueForKey:@"search_id" default:@"be_null"];
            reportModel.pageType = [reportParams btd_stringValueForKey:@"page_type" default:@"be_null"];
            reportModel.realtorId = [params btd_stringValueForKey:@"realtor_id" default:@"be_null"];
            reportModel.realtorRank = @(0);
            reportModel.conversationId = @"be_null";
            reportModel.realtorLogpb = [self checkInvalidJsonString:[reportParams btd_stringValueForKey:@"realtor_logpb"]];
//            reportModel.realtorPosition = @"house_model";
//            reportModel.sourceFrom = @"house_model";
//            reportModel.extra = @{@"house_model_rank":@(index)};
            associateIMModel.reportParams = reportModel;
            
            // IM跳转链接
            associateIMModel.imOpenUrl = [params btd_stringValueForKey:@"chat_open_url"];
            // 跳转IM
            [FHHouseIMClueHelper jump2SessionPageWithAssociateIM:associateIMModel];
        }


    }
//    FHNeighborhoodDetailViewModel *tempNeighborhoodViewModel = [FHFlutterChannels sharedInstance].tempNeighborhoodViewModel;
//    FHHouseDetailContactViewModel *tempAssociateViewModel = tempNeighborhoodViewModel.contactViewModel;
//    if (tempNeighborhoodViewModel && tempAssociateViewModel) {
//        NSMutableDictionary *extraDic = @{
//            @"realtor_position": @"detail_button",
//            @"enter_from": @"neighborhood_detail",
//            @"element_from": @"average_price",
//            @"page_type": @"average_price_detail",
//            UT_ELEMENT_TYPE: @"be_null"
//        }.mutableCopy;
//        if(tempNeighborhoodViewModel.detailData.data.priceTrendAssociateInfo) {
//            extraDic[kFHAssociateInfo] = tempNeighborhoodViewModel.detailData.data.priceTrendAssociateInfo;
//        }
//        [tempAssociateViewModel onlineActionWithExtraDict:extraDic];
//    }
    resultCallBack(nil);
}

+ (void)invalidReasonDialogWithParam:(FlutterMethodCall *)call callback:(FlutterResult)resultCallBack
{
//    if ([@"invalidReasonDialog" isEqualToString:call.method]) {
//        NSDictionary *param = call.arguments;
//        NSString *customerID = param[@"customer_id"];
//        NSString *reportParamsStr = param[@"reportParams"];
//        NSDictionary *reportPramsDict = [reportParamsStr btd_jsonDictionary];
//
//        [FHBInvalidReasonChooserDialog showWithCustomterId:customerID reportParams:reportPramsDict complete:^(NSString *submitId, BOOL success) {
//            if (resultCallBack) {
//                //                NSMutableDictionary *data = [NSMutableDictionary dictionary];
//                //                [data setValue:@(success)  forKey:@"success"];
//                resultCallBack(@(success));
//            }
//        }];
//    }
}




+ (void)broadCastEnterPageNotifyWithParam:(FlutterMethodCall *)call callback:(FlutterResult)resultCallBack{
    NSDictionary *param = call.arguments;
    if (![param isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSString *data = param[@"data"];
    NSDictionary *dataDict = @{};
    NSMutableDictionary *notifyParams = @{}.mutableCopy;
    if ([data isKindOfClass:[NSDictionary class]]) {
        dataDict = data;
    }
    if([data isKindOfClass:[NSString class]]){
        dataDict = [data btd_jsonDictionary];
    }
    
    if ([dataDict isKindOfClass:[NSDictionary class]]) {
        [notifyParams addEntriesFromDictionary:dataDict];
    }
    
    if (notifyParams) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"_CUSTOMER_DETAIL_ENTER_NOTIFICATION_" object:notifyParams];
        if (notifyParams[@"customer_id"]) {
            [[FHChatUserInfoManager shareInstance] updateCustomerInfo:notifyParams[@"customer_id"] info:notifyParams];
        }
    }
    
    
    if(resultCallBack){
        resultCallBack(nil);
    }
}

+ (void)broadCasetNotifyWithParam:(FlutterMethodCall *)call callback:(FlutterResult)resultCallBack{
    NSDictionary *param = call.arguments;
    if (![param isKindOfClass:[NSDictionary class]]) {
        return;
    }
    NSString *data = param[@"data"];
    NSDictionary *dataDict = @{};
    NSMutableDictionary *notifyParams = @{}.mutableCopy;
    if ([data isKindOfClass:[NSDictionary class]]) {
        dataDict = data;
    }
    if([data isKindOfClass:[NSString class]]){
        dataDict = [data btd_jsonDictionary];
    }
    
    if ([dataDict isKindOfClass:[NSDictionary class]]) {
        [notifyParams addEntriesFromDictionary:dataDict];
    }
    NSString *notifyKey = dataDict[@"key"] ?: @"";
    
    if (notifyParams) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"_CUSTOMER_RETURE_FROM_H5_NOTIFICATION_" object:notifyParams];
        if (notifyParams[@"customer_id"]) {
            [[FHChatUserInfoManager shareInstance] updateCustomerInfo:notifyParams[@"customer_id"] info:notifyParams];
        }
    }
    
    if(resultCallBack){
        resultCallBack(nil);
    }
}




#pragma mark - Utility
+ (NSDictionary *)checkInvalidJsonString:(NSString *)jsonString {
    if ([jsonString isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)jsonString;
    } else if ([jsonString isKindOfClass:[NSString class]]) {
        return [jsonString btd_jsonDictionary];
    }
    return nil;
}

@end
