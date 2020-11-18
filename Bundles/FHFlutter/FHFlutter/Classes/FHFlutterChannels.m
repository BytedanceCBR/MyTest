//
//  FHFlutterChannels.m
//  ABRInterface
//
//  Created by 谢飞 on 2020/9/6.
//

#import "FHFlutterChannels.h"
#import "NSString+BTDAdditions.h"
#import "TTReachability.h"
#import "ToastManager.h"
#import "NSDictionary+BTDAdditions.h"
#import <TTRoute.h>
#import "FHChatUserInfoManager.h"
#import <NSDictionary+BTDAdditions.h>

@interface FHFlutterChannels()

//@property (nonatomic, strong) FHBCustomerDetailViewModel *callModel;

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

+ (void)processChannelsImp:(FlutterMethodCall *)call callback:(FlutterResult)resultCallBack{
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

+ (void)callPhoneWithParam:(FlutterMethodCall *)call callback:(FlutterResult)resultCallBack{
    /*
    if ([[TTReachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    
    NSDictionary *param = call.arguments;
    if (![param isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSString *houseType = [param btd_stringValueForKey:@"houseType"];
    NSString *realtorId = [param btd_stringValueForKey:@"realtorId"];
    NSString *customerId = [param btd_stringValueForKey:@"customerId"];
    NSString *customer_id = [param btd_stringValueForKey:@"customer_id"];
    //    NSString *enterFrom = [param btd_stringValueForKey:@"enterFrom"];
    NSString *associateId = [param btd_stringValueForKey:@"report_id"];
    
    
    //    NSString *reportParams = [param btd_stringValueForKey:@"report_params"];
    NSString *reportParamsStr = [param btd_stringValueForKey:@"report_params"];
    NSMutableString *processString = [NSMutableString stringWithString:reportParamsStr];
    NSString *character = nil;
    for (int i = 0; i < processString.length; i ++) {
        character = [processString substringWithRange:NSMakeRange(i, 1)];
        
        if ([character isEqualToString:@"\\"])
            [processString deleteCharactersInRange:NSMakeRange(i, 1)];
    }
    
    NSDictionary *reportParamsDict = [processString btd_jsonDictionary];
    
    NSMutableDictionary *callParams = [NSMutableDictionary dictionaryWithDictionary:param];
    if ([reportParamsDict isKindOfClass:[NSDictionary class]]) {
        [callParams addEntriesFromDictionary:reportParamsDict];
    }
    if (realtorId) {
        [callParams setValue:realtorId forKey:@"realtor_id"];
    }
    
    if (!IS_EMPTY_STRING(customerId))
    {
        [callParams setValue:customerId forKey:@"customer_id"];
    }
    
    if (!IS_EMPTY_STRING(customer_id))
    {
        [callParams setValue:customer_id forKey:@"customer_id"];
    }
    
    if (houseType) {
        [callParams setValue:houseType forKey:@"house_type"];
    }
    
    if([callParams[@"group_id"] isKindOfClass:[NSString class]])
    {
        if (![callParams[@"group_id"] isEqualToString:@"be_null"]) {
            callParams[@"follow_id"] = callParams[@"group_id"];
        }
    }
    
    if(associateId)
    {
        [callParams setValue:associateId forKey:@"associate_id"];
    }
    
    if([callParams[@"group_id"] isKindOfClass:[NSString class]])
    {
        if (![callParams[@"group_id"] isEqualToString:@"be_null"]) {
            callParams[@"house_id"] = callParams[@"group_id"];
        }
    }
    
    if([callParams[@"assignment_id"] isKindOfClass:[NSString class]])
    {
        if ([callParams[@"assignment_id"] isEqualToString:@"be_null"]) {
            callParams[@"assignment_id"] = @"0";
        }
    }
    
    if ([callParams[@"log_pb"] isKindOfClass:[NSString class]]) {
        callParams[@"log_pb"] = [@"log_pb" btd_jsonDictionary];
    }
    
    NSString *enterFrom = [param btd_stringValueForKey:@"enter_from"];
    
    if ([enterFrom isKindOfClass:[NSString class]]) {
        callParams[@"enterfrom"] = enterFrom;
    }
    
    callParams[@"endpoint"] = param[@"endpoint"];
    
    callParams[@"page"] = param[@"page"];
    

    [FHFlutterChannels sharedInstance].callModel =  [FHBCustomerDetailViewModel new];
    [[FHFlutterChannels sharedInstance].callModel callPhone:callParams];
    
    if(resultCallBack){
        resultCallBack(nil);
    }
     */
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
