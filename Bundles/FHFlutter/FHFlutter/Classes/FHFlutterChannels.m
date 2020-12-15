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
    FHNeighborhoodDetailViewModel *tempNeighborhoodViewModel = [FHFlutterChannels sharedInstance].tempNeighborhoodViewModel;
    FHHouseDetailContactViewModel *tempAssociateViewModel = tempNeighborhoodViewModel.contactViewModel;
    FHDetailContactModel *contactPhone = tempAssociateViewModel.contactPhone;
    if (tempNeighborhoodViewModel && tempAssociateViewModel && contactPhone.enablePhone) {
        
        [[FHFlutterChannels sharedInstance] setPhoneCallBlock:^(BOOL finished) {
            resultCallBack(@(YES));
            [FHFlutterChannels sharedInstance].phoneCallBlock = nil;
        }];
        NSMutableDictionary *extraDic = @{
            @"realtor_position": @"detail_button",
            @"enter_from": @"neighborhood_detail",
            @"element_from": @"average_price",
            @"page_type": @"average_price_detail"
        }.mutableCopy;
//        [extraDic addEntriesFromDictionary:self.tracerDict];
        extraDic[kFHAssociateInfo] = tempNeighborhoodViewModel.detailData.data.priceTrendAssociateInfo.phoneInfo;
        [tempAssociateViewModel contactActionWithExtraDict:extraDic];
    } else {
        resultCallBack(nil);
    }
}

//表单线索
+ (void)showConsultFormWithParam:(FlutterMethodCall *)call callback:(FlutterResult)resultCallBack {
    FHNeighborhoodDetailViewModel *tempNeighborhoodViewModel = [FHFlutterChannels sharedInstance].tempNeighborhoodViewModel;
    FHHouseDetailContactViewModel *tempAssociateViewModel = tempNeighborhoodViewModel.contactViewModel;
    if (tempNeighborhoodViewModel && tempAssociateViewModel) {

        NSMutableDictionary *extraDic = @{
            @"realtor_position": @"detail_button",
            @"enter_from": @"neighborhood_detail",
            @"element_from": @"average_price",
            @"page_type": @"average_price_detail"
        }.mutableCopy;
//        [extraDic addEntriesFromDictionary:self.tracerDict];

        NSDictionary *associateInfoDict = nil;
        FHDetailContactModel *contactPhone = tempAssociateViewModel.contactPhone;
        if (contactPhone.enablePhone) {
            associateInfoDict = tempNeighborhoodViewModel.detailData.data.priceTrendAssociateInfo.phoneInfo;
        }else {
            associateInfoDict = tempNeighborhoodViewModel.detailData.data.priceTrendAssociateInfo.reportFormInfo;
        }
        extraDic[kFHAssociateInfo] = associateInfoDict;
        [tempAssociateViewModel contactActionWithExtraDict:extraDic];
    }
    resultCallBack(nil);
}

//IM线索
+ (void)jumpToIMWithParam:(FlutterMethodCall *)call callback:(FlutterResult)resultCallBack {
    FHNeighborhoodDetailViewModel *tempNeighborhoodViewModel = [FHFlutterChannels sharedInstance].tempNeighborhoodViewModel;
    FHHouseDetailContactViewModel *tempAssociateViewModel = tempNeighborhoodViewModel.contactViewModel;
    if (tempNeighborhoodViewModel && tempAssociateViewModel) {
        NSMutableDictionary *extraDic = @{
            @"realtor_position": @"detail_button",
            @"enter_from": @"neighborhood_detail",
            @"element_from": @"average_price",
            @"page_type": @"average_price_detail"
        }.mutableCopy;
        if(tempNeighborhoodViewModel.detailData.data.priceTrendAssociateInfo) {
            extraDic[kFHAssociateInfo] = tempNeighborhoodViewModel.detailData.data.priceTrendAssociateInfo;
        }
        [tempAssociateViewModel onlineActionWithExtraDict:extraDic];
    }
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






@end
