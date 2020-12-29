//
//  FHIMStartupTask.m
//  Article
//
//  Created by leo on 2019/2/17.
//

#import "FHIMStartupTask.h"
#import "IMManager.h"
#import "FHIMConfigManager.h"
#import "TTCookieManager.h"
#import "FHUploaderManager.h"
#import "UIColor+Theme.h"
#import "TTAccount.h"
#import <BDTrackerProtocol/BDTrackerProtocol.h>
#import "FHIMAccountCenterImpl.h"
#import "FHBubbleTipManager.h"
#import "FHURLSettings.h"
#import "TTNetworkManager.h"
#import "FHEnvContext.h"
#import "ToastManager.h"
#import <TTArticleBase/SSCommonLogic.h>
#import <Heimdallr/HMDTTMonitor.h>
#import "FHIMAlertViewListenerImpl.h"
#import "TTLaunchDefine.h"
#import <FHHouseBase/FHMainApi+Contact.h>
#import <TTReachability/TTReachability.h>
#import "TTSandBoxHelper.h"
#import <FHHouseDetail/FHHouseDetailAPI.h>
#import <FHCommonUI/FHFeedbackView.h>
#import <ByteDanceKit/NSDictionary+BTDAdditions.h>
#import "FHMainApi+Contact.h"
#import "FHHousePhoneCallUtils.h"
#import "FHDetailBaseModel.h"
#import "FIMDebugManager.h"
#import "FIMDebugManager+Accelerometer.h"
#import <TTUIWidget/TTNavigationController.h>
#import "TTDialogDirector.h"
#import "TTWeakPushAlertView.h"
#import "FHUserTracker.h"
#import <TTRoute.h>

DEC_TASK("FHIMStartupTask",FHTaskTypeSerial,TASK_PRIORITY_HIGH+16);

@interface FHIMConfigDelegateImpl : NSObject<FHIMConfigDelegate>

@end

@implementation FHIMConfigDelegateImpl

- (ClientType)getClientType {
    return ClientTypeC;
}

- (ThemeType)getThemeType {
    return ClientCTheme;
}

- (UIColor *)getChatBubbleColor {
    return [UIColor themeIMBubbleRed];
}

- (UIColor *)getChatNewTipColor {
    return [UIColor themeIMOrange];
}

- (UIColor *)getChatTipTxtColor {
    return [UIColor themeIMBubbleRed];
}

- (UIColor *)getDefaultTxtColor {
   return [UIColor colorWithHexString:@"999999"];
}

- (NSArray<NSHTTPCookie *>*)getClientCookie {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    return cookies;
}

- (NSString *)sessionId {
    return [[TTAccount sharedAccount] sessionKey] ?: @"";
}

- (void)registerTTRoute {

}

- (BOOL)isBOE {
    if ([TTSandBoxHelper isInHouseApp] && [[NSUserDefaults standardUserDefaults] boolForKey:@"BOE_OPEN_KEY"]) {
        return YES;
    }
    return NO;
}

- (BOOL)isPPE {
    if ([TTSandBoxHelper isInHouseApp] && [[NSUserDefaults standardUserDefaults] boolForKey:@"PPE_OPEN_KEY"]) {
        return YES;
    }
    return NO;
}

- (NSString *)ppeChannelName {
    return [FHEnvContext sharedInstance].ppeChannelName;
}
- (NSString *)boeChannelName {
    return [FHEnvContext sharedInstance].boeChannelName;
}

- (NSString *)appId {
    return [TTSandBoxHelper ssAppID];
}

- (NSString *)deviceId {
    return [BDTrackerProtocol deviceID];
}

- (void)onMessageRecieved:(ChatMsg *)msg {
    // 检查是否应用内通知正在展示
    BOOL isInAppPushWeakAlertViewShowing = NO;
    id presentingDialog = [TTDialogDirector presentingDialog];
    if([presentingDialog isKindOfClass:TTWeakPushAlertView.class]) {
        isInAppPushWeakAlertViewShowing = YES;
    }
    if(!isInAppPushWeakAlertViewShowing) {
        [[FHBubbleTipManager shareInstance] tryShowBubbleTip:msg openUrl:@""];
    }
}

- (NSString *)appVersionCode {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UPDATE_VERSION_CODE"];
}

- (void)tryGetPhoneNumber:(NSString *)userId withImprId:(NSString *)imprId tracer:(NSDictionary *)tracer clueParams:(NSDictionary *)clueParams withBlock:(PhoneCallback)finishBlock
{
    void (^displayPhoneIconAction)(void) = [clueParams[@"displayPhoneIconAction"] copy];
    NSMutableDictionary *copyClueParams = clueParams.mutableCopy;
    copyClueParams[@"displayPhoneIconAction"] = nil;
    clueParams = copyClueParams;
    [FHMainApi requestAssoicateEntrance:clueParams completion:^(NSError * _Nonnull error, id  _Nonnull jsonObj) {
        if(!error && jsonObj) {
            
            NSDictionary* phoneAssociate = nil;
            id data = jsonObj[@"data"];
            if(data && [data isKindOfClass:NSDictionary.class]) {
                id associateInfoDic = data[@"associate_info"];
                if(associateInfoDic && [associateInfoDic isKindOfClass:NSDictionary.class]) {
                    NSError *error = nil;
                    FHClueAssociateInfoModel *associateInfo = [[FHClueAssociateInfoModel alloc] initWithDictionary:associateInfoDic error:&error];
                    if(!error) {
                        phoneAssociate = associateInfo.phoneInfo;
                    }
                }
            }
            
            if (isEmptyString(userId)) {
                
                NSMutableDictionary *dict = @{}.mutableCopy;
                dict[@"impr_id"] = imprId;
                dict[@"associate_info"] = phoneAssociate;
                finishBlock(@"click_call", dict, true);
                
                [[HMDTTMonitor defaultManager] hmdTrackService:IM_PHONE_MONITOR value:IM_PHONE_EMPTY_UID extra:@{@"client_type":@"client_c"}];
                return;
            }
            NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
            NSString* url = [host stringByAppendingString:@"/f100/api/virtual_number"];
            NSMutableDictionary *param = @{}.mutableCopy;
            param[@"realtor_id"] = userId;
            param[@"enterfrom"] = @"app_chat";
            param[@"impr_id"] = imprId ? : @"be_null";
        
            if (phoneAssociate) {
                NSData *data = [NSJSONSerialization dataWithJSONObject:phoneAssociate options:0 error:nil];
                NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (data && string) {
                    param[@"phone_info"] = string;
                }
            }
            NSMutableDictionary *monitorParams = [NSMutableDictionary dictionaryWithDictionary:param];
            [monitorParams setValue:@"client_c" forKey:@"client_type"];
            
            [[TTNetworkManager shareInstance] requestForJSONWithResponse:url params:param  method:@"GET" needCommonParams:YES callback:^(NSError *error, id obj, TTHttpResponse *response) {
                
                NSMutableDictionary *categoryDict = @{}.mutableCopy;
                NSMutableDictionary *extraDict = @{}.mutableCopy;
                if (![TTReachability isNetworkConnected]) {
                    categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeNetFailure];
                }
                NSString *status = @"";
                NSString *message = @"";
                
                if (!error) {
                    NSString *number = @"";
                    NSString *serverImprId = imprId;
                    
                    @try {
                        if ([obj isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *jsonObj = (NSDictionary *)obj;
                            NSDictionary *data = [jsonObj objectForKey:@"data"];
                            number = data[@"virtual_number"];
                            serverImprId = data[@"impr_id"] ?: @"be_null";
                            status = [jsonObj tta_stringForKey:@"status"];
                            message = [jsonObj tta_stringForKey:@"message"];
                        }
                    }
                    @catch(NSException *e) {
                        error = [NSError errorWithDomain:e.reason code:1000 userInfo:e.userInfo ];
                        [monitorParams setValue:error forKey:@"json_error"];
                        [[HMDTTMonitor defaultManager] hmdTrackService:IM_PHONE_MONITOR value:IM_PHONE_JSON_ERROR extra:monitorParams];
                    }
                    
                    NSString *phone = @"";
                    BOOL isAssociate = NO;
                    phone = [number stringByReplacingOccurrencesOfString:@"" withString:@""];
                    isAssociate = YES;
                    
                    NSMutableDictionary *dict = @{}.mutableCopy;
                    dict[@"impr_id"] = serverImprId;
                    dict[@"associate_info"] = phoneAssociate;
                    finishBlock(@"click_call", dict, true);
                    if (phone.length == 0) {
                        [[HMDTTMonitor defaultManager] hmdTrackService:IM_PHONE_MONITOR value:IM_PHONE_NUMBER_EMPTY extra:monitorParams];
                        [[ToastManager manager] showToast:@"获取电话号码失败"];
                        return;
                    }
                    
                    if ([@"be_null" isEqualToString:serverImprId]) {
                        [[HMDTTMonitor defaultManager] hmdTrackService:IM_PHONE_MONITOR value:IM_PHONE_EMPTY_IMPRID extra:monitorParams];
                    }
                    
                    NSString *phoneUrl = [NSString stringWithFormat:@"tel://%@", phone];
                    NSURL *url = [NSURL URLWithString:phoneUrl];
                    if ([[UIApplication sharedApplication]canOpenURL:url]) {
                        if (@available(iOS 10.0, *)) {
                            [[UIApplication sharedApplication]openURL:url options:@{} completionHandler:nil];
                        } else {
                            // Fallback on earlier versions
                            [[UIApplication sharedApplication]openURL:url];
                        }
                    }
                } else {
                    NSString *message = nil;
                    if ([obj isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *jsonObj = (NSDictionary *)obj;
                        message = [jsonObj btd_stringValueForKey:@"message"];
                    }
                    NSString *toastContent = message?:@"网络异常，请稍后重试!";
                    CGFloat duration = MAX(1,toastContent.length * 0.1);
                    [[ToastManager manager] showToast:toastContent duration:duration style:FHToastViewStyleDefault position:FHToastViewPositionCenter verticalOffset:0];
                    
                    [monitorParams setValue:error forKey:@"server_error"];
                    [[HMDTTMonitor defaultManager] hmdTrackService:IM_PHONE_MONITOR value:IM_PHONE_SERVER_ERROR extra:monitorParams];
                    
                    NSMutableDictionary *dict = @{}.mutableCopy;
                    dict[@"impr_id"] = imprId;
                    dict[@"associate_info"] = phoneAssociate;
                    finishBlock(@"click_call", dict,true);
                    
                    if ([obj isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *jsonObj = (NSDictionary *)obj;
                        NSDictionary *data = [jsonObj objectForKey:@"data"];
                        status = [jsonObj tta_stringForKey:@"status"];
                        message = [jsonObj tta_stringForKey:@"message"];
                    }
                }
                
                if (response.statusCode == 200) {
                    if (status.length > 0) {
                        if (status.integerValue != 0 || error != nil) {
                            if (status) {
                                extraDict[@"error_code"] = status;
                            }
                            extraDict[@"message"] = message.length > 0 ? message : error.domain;
                            categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeServerFailure];
                            extraDict[@"request_url"] = response.URL.absoluteString;
                            extraDict[@"response_headers"] = response.allHeaderFields;
                        }else {
                            categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeNone];
                        }
                    }
                }else {
                    categoryDict[@"status"] = [NSString stringWithFormat:@"%ld",FHClueErrorTypeHttpFailure];
                    extraDict[@"error_code"] = [NSString stringWithFormat:@"%ld",response.statusCode];
                }
                [[self class] addClueCallErrorRateLog:categoryDict extraDict:extraDict];
            }];
            
        }
        
        else {
            if(displayPhoneIconAction) {
                displayPhoneIconAction();
            }
        }
    }];
}

- (NSString *)hostStr {
    NSString *host = [FHURLSettings baseURL];
    return host;
}

- (NSString *)cityId {
    return [FHEnvContext getCurrentSelectCityIdFromLocal];
}

- (void)gotoSelectHouse:(nonnull NSString *)covid {
    
}

+ (void)addClueCallErrorRateLog:categoryDict extraDict:(NSDictionary *)extraDict
{
    [[HMDTTMonitor defaultManager]hmdTrackService:@"clue_call_error_rate" metric:nil category:categoryDict extra:extraDict];
}

- (void)submitRealtorEvaluation:(NSString *)content scoreCount:(NSInteger)scoreCount scoreTags:(NSArray<NSString *> *)scoreTags traceParams:(NSDictionary *)traceParams completion:(nullable RealtorEvaluationCallback)completion
{
    NSString *realtorId = traceParams[@"realtor_id"];
    NSString *targetId = traceParams[@"target_id"];
    NSInteger targetType = [traceParams btd_integerValueForKey:@"target_type"];
    NSInteger evaluationType = [traceParams btd_integerValueForKey:@"evaluation_type"];
    NSString *element_from = [traceParams btd_stringValueForKey:@"element_from"];

    [FHHouseDetailAPI requestRealtorEvaluationFeedback:targetId targetType:targetType evaluationType:evaluationType realtorId:realtorId content:content score:scoreCount tags:scoreTags from:element_from completion:^(bool success, NSError *_Nullable error, NSDictionary *jsonObj) {
        if (success) {
            [[ToastManager manager] showToast:@"提交成功，感谢您的评价"];
        }
        else {
            id data = [jsonObj btd_objectForKey:@"data" default:nil];
            BOOL isBlackmailed = NO;
            if(data && [data isKindOfClass:NSDictionary.class]) {
                isBlackmailed = [[data btd_objectForKey:@"punish_status" default:@0] boolValue];
            }
            if(isBlackmailed) {
                // 展现埋点
                NSMutableDictionary *showParams = [NSMutableDictionary dictionary];
                showParams[@"popup_name"] = @"black_popup";
                showParams[UT_PAGE_TYPE] = traceParams[UT_PAGE_TYPE];
                showParams[UT_ELEMENT_TYPE] = @"black_popup";
                showParams[UT_ENTER_FROM] = traceParams[UT_ENTER_FROM];
                showParams[UT_ORIGIN_FROM] = traceParams[UT_ORIGIN_FROM];
                TRACK_EVENT(@"popup_show", showParams);
                // ---
                
                NSString *punishTips = [data btd_stringValueForKey:@"punish_tips"];
                NSString *redirect = [data btd_stringValueForKey:@"redirect"];
                [[IMManager shareInstance] showBlackmailRealtorPopupViewWithContent:punishTips leftTitle:@"其他经纪人" leftAction:^{
                    // 点击埋点
                    NSMutableDictionary *clickParam = [NSMutableDictionary dictionary];
                    clickParam[@"popup_name"] = @"black_popup";
                    clickParam[UT_CLICK_POSITION] = @"other_realtor";
                    clickParam[UT_PAGE_TYPE] = traceParams[UT_PAGE_TYPE];
                    clickParam[UT_ELEMENT_TYPE] = @"black_popup";
                    clickParam[UT_ENTER_FROM] = traceParams[UT_ENTER_FROM];
                    clickParam[UT_ORIGIN_FROM] = traceParams[UT_ORIGIN_FROM];
                    TRACK_EVENT(@"popup_click", clickParam);
                    //---
                    [[IMManager shareInstance] jumpRealtorListH5PageWithUrl:redirect reportParam:clickParam];
                } rightTitle:@"知道了" rightAction:^{
                    // 点击埋点
                    NSMutableDictionary *clickParam = [NSMutableDictionary dictionary];
                    clickParam[@"popup_name"] = @"black_popup";
                    clickParam[UT_CLICK_POSITION] = @"know";
                    clickParam[UT_PAGE_TYPE] = traceParams[UT_PAGE_TYPE];
                    clickParam[UT_ELEMENT_TYPE] = @"black_popup";
                    clickParam[UT_ENTER_FROM] = traceParams[UT_ENTER_FROM];
                    clickParam[UT_ORIGIN_FROM] = traceParams[UT_ORIGIN_FROM];
                    TRACK_EVENT(@"popup_click", clickParam);
                    //---
                }];
            }
            else {
                [[ToastManager manager] showToast:@"提交失败"];
            }
        }
        
        if(completion) {
            completion(success, error, jsonObj);
        }
    }];
}

- (id)getRealtorEvaluationModel
{
    FHConfigDataModel *dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    FHRealtorEvaluatioinConfigModel *evaluationConfig = dataModel.realtorEvaluationConfig;
    if (!evaluationConfig) {
        return nil;
    }
    FHRealtorEvaluationModel *evaluationModel = [[FHRealtorEvaluationModel alloc]init];
    evaluationModel.scoreTags = evaluationConfig.scoreTags;
    evaluationModel.goodPlaceholder = evaluationConfig.goodPlaceholder;
    evaluationModel.badPlaceholder = evaluationConfig.badPlaceholder;
    if (evaluationConfig.goodTags.count > 0) {
        NSMutableArray *tags = @[].mutableCopy;
        for (FHRealtorEvaluatioinTagModel *tag in evaluationConfig.goodTags) {
            FHRealtorEvaluationTagModel *newTag = [[FHRealtorEvaluationTagModel alloc]init];
            newTag.id = tag.id;
            newTag.text = tag.text;
            [tags addObject:newTag];
        }
        evaluationModel.goodTags = tags;
    }
    if (evaluationConfig.badTags.count > 0) {
        NSMutableArray *tags = @[].mutableCopy;
        for (FHRealtorEvaluatioinTagModel *tag in evaluationConfig.badTags) {
            FHRealtorEvaluationTagModel *newTag = [[FHRealtorEvaluationTagModel alloc]init];
            newTag.id = tag.id;
            newTag.text = tag.text;
            [tags addObject:newTag];
        }
        evaluationModel.badTags = tags;
    }
    return evaluationModel;
}
- (BOOL)isEnableRecordVoiceSegment {
    return [SSCommonLogic enableRecordVoiceSegment];
}
- (BOOL)isEnableIMOnlineMonitorLogic {
    return [SSCommonLogic enableIMOnlineMonitorLogic];
}
- (BOOL)enableVoIPAudioCall {
    return [SSCommonLogic enableVoIPAudioCall];
}
- (BOOL)isEnableIMRealtorLocking {
    return [SSCommonLogic enableIMRealtorLocking];
}
- (void)trackEvent:(NSString *)event params:(NSDictionary *)params {
    TRACK_EVENT(event, params);
}
@end

@implementation FHIMStartupTask

- (NSString *)taskIdentifier {
    return @"FHIMStartupTask";
}

- (BOOL)isResident {
    return YES;
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    if ([SSCommonLogic imCanStart]) {
        
        FHIMAccountCenterImpl* accountCenter = [[FHIMAccountCenterImpl alloc] init];
        [IMManager shareInstance].accountCenter = accountCenter;
        
        FHIMConfigDelegateImpl* delegate = [[FHIMConfigDelegateImpl alloc] init];
        [[FHIMConfigManager shareInstance] registerDelegate:delegate];
        
        [IMManager shareInstance].imAlertViewListener = [FHIMAlertViewListenerImpl shareInstance];
        
        NSString* uid = [[TTAccount sharedAccount] userIdString];
        [[IMManager shareInstance] startupWithUid:uid];
        
    
        // 设置摇一摇打开高级调试页面, 受调试开关FIMDebugOptionEntrySwitchShakeDebug控制
        [FIMDebugManager shared].shakeToDebugBlock = ^(BOOL isEnable) {
        
            if(!isEnable) {
                return ;
            }
            
            if (![TTSandBoxHelper isInHouseApp]) {
                return;
            }
            
            UIViewController *topVC = [TTUIResponderHelper visibleTopViewController];
            Class debugVCClass = NSClassFromString(@"SSDebugViewController");
            if(!debugVCClass || [topVC isKindOfClass:debugVCClass]) {
                return;
            }
            
            TTNavigationController *navigationController = [[TTNavigationController alloc] initWithRootViewController:[debugVCClass new]];
            navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
            [topVC presentViewController:navigationController animated:YES completion:NULL];
            [[FIMMediaTool sharedInstance] shakeOnceTime];
        };
    }
}

#pragma mark - 打开Watch Session

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void(^)(NSDictionary *replyInfo))reply {

}

@end
