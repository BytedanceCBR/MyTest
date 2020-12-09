//
//  FHHouseFillFormHelper.m
//  FHHouseBase
//
//  Created by 张静 on 2019/4/23.
//

#import "FHHouseFillFormHelper.h"
#import "FHDetailNoticeAlertView.h"
#import "FHHouseType.h"
#import "FHMainApi+Contact.h"
#import "TTRoute.h"
#import "YYCache.h"
#import <FHCommonUI/ToastManager.h>
#import "TTReachability.h"
#import "TTAccount.h"
#import <BDTrackerProtocol/BDTrackerProtocol.h>
#import <FHHouseBase/FHUserTracker.h>
#import <FHHouseBase/FHGeneralBizConfig.h>
#import <FHHouseBase/FHEnvContext.h>
#import "IMManager.h"
#import "HMDTTMonitor.h"
#import "FHHouseFollowUpHelper.h"
#import "FHFillFormAgencyListItemModel.h"
#import "FHHouseDetailViewController.h"
#import "FHHouseNewDetailViewModel.h"
#import <FHHouseBase/FHUserInfoManager.h>
#import "SSCommonLogic.h"
#import <TTAccountSDK/TTAccount.h>
#import "TTAccountLoginManager.h"

extern NSString *const kFHToastCountKey;
@implementation FHHouseFillFormHelper

#pragma mark - associate refactor
+ (void)fillFormActionWithAssociateReport:(NSDictionary *)associateReportDict
{
    FHAssociateFormReportModel *configModel = [[FHAssociateFormReportModel alloc]initWithDictionary:associateReportDict error:nil];
    if (configModel) {
        [self fillFormActionWithAssociateReportModel:configModel];
    }
}

+ (void)fillFormActionWithAssociateReportModel:(FHAssociateFormReportModel *)associateReport
{
    if ([SSCommonLogic isEnableVerifyFormAssociate]) {
        if (![TTAccount sharedAccount].isLogin) {
//            [TTAccountLoginManager showAlertFLoginVCWithParams:<#(NSDictionary *)#> completeBlock:<#^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum)complete#>]
            return;
        }
    }
    NSString *title = associateReport.title;
    NSString *subtitle = associateReport.subtitle;
    NSString *btnTitle = associateReport.btnTitle;

    NSString *phoneNum = [FHUserInfoManager getPhoneNumberIfExist];
//    if (phoneNum.length > 0) {
//        subtitle = [NSString stringWithFormat:@"%@\n已为您填写上次提交时使用的手机号",subtitle];
//    }
    [self addInformShowLogWithAssociateReport:associateReport];
    __weak typeof(self)wself = self;
    FHDetailNoticeAlertView *alertView = [[FHDetailNoticeAlertView alloc]initWithTitle:title subtitle:subtitle btnTitle:btnTitle];
    alertView.phoneNum = phoneNum;
    alertView.confirmClickBlock = ^(NSString *phoneNum,FHDetailNoticeAlertView *alert){
        [wself fillFormRequestWithAssociateReport:associateReport phone:phoneNum alertView:alert];
        [wself addClickConfirmLogWithAssociateReport:associateReport alertView:alert];
    };

    alertView.tipClickBlock = ^{
        NSString *privateUrlStr = [NSString stringWithFormat:@"%@/f100/client/user_privacy&title=个人信息保护声明&hide_more=1",[FHURLSettings baseURL]];
        NSString *urlStr = [privateUrlStr btd_stringByURLEncode];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fschema://webview?url=%@",urlStr]];
        [[TTRoute sharedRoute]openURLByPushViewController:url];
    };
    //加一个判断，如果viewcontroller 不是最上面的 viewcontroller，则替换成最顶部的 viewcontroller
    UIViewController *topViewController = associateReport.topViewController;
    if (topViewController.presentedViewController) {
        topViewController = topViewController.presentedViewController;
    }
    if (topViewController.navigationController) {
        topViewController = topViewController.navigationController.viewControllers.lastObject;
    }
    if ([topViewController isKindOfClass:[UINavigationController class]] ) {
        topViewController = [(UINavigationController *)topViewController viewControllers].lastObject;
    }
    [alertView showFrom:topViewController.view];
}

+ (void)fillFormRequestWithAssociateReport:(FHAssociateFormReportModel *)associateReport phone:(NSString *)phone alertView:(FHDetailNoticeAlertView *)alertView
{
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    NSMutableDictionary *extraInfo = @{}.mutableCopy;
    if (associateReport.extraInfo) {
        extraInfo = associateReport.extraInfo.mutableCopy;
    }
    if (![extraInfo btd_stringValueForKey:@"origin_from"]) {
        extraInfo[@"origin_from"] = associateReport.reportParams[@"origin_from"] ?: @"be_null";
    }
    [FHMainApi requestCallReportByHouseId:associateReport.houseId phone:phone from:nil cluePage:nil clueEndpoint:nil targetType:nil reportAssociate:associateReport.associateInfo agencyList:nil extraInfo:extraInfo.copy completion:^(FHDetailResponseModel * _Nullable model, NSError * _Nullable error) {

        if (model.status.integerValue == 0 && !error) {
            [FHUserInfoManager savePhoneNumber:phone];
            NSString *toast = @"提交成功，经纪人将尽快与您联系";
            if (associateReport.toast && associateReport.toast.length > 0) {
                toast = associateReport.toast;
            }
            
            /*
             不想加这个逻辑，新房填表单之后要弹出另一个弹窗，效果是要衔接，就是一个不消失直接展示另一个，不是不能实现，是要把之前封装好的逻辑打乱，还要加一些XX的代码，不优雅； 数据都不在一个地方，加通知也不太好，oops
             
             1.1.3
             补充，之前的新房留资功能已经删除
             命中新的线索优化实验后，需要出现二次弹框，可以使用之前留资的api
             */
            [[ToastManager manager] showToast:toast];
            // 走之前的逻辑
            [alertView dismiss];

        }else {
            NSString *message = model.message ? : @"提交失败";
            [[ToastManager manager] showToast:message];
        }
    }];
    // 静默关注功能
    NSMutableDictionary *params = @{}.mutableCopy;

    FHHouseFollowUpConfigModel *followConfig = [[FHHouseFollowUpConfigModel alloc]initWithDictionary:params error:nil];
    followConfig.houseType = associateReport.houseType;
    followConfig.followId = associateReport.houseId;
    followConfig.actionType = associateReport.actionType;
    followConfig.showTip = YES;
    
    [FHHouseFollowUpHelper silentFollowHouseWithConfigModel:followConfig];
}

// 表单展示
+ (void)addInformShowLogWithAssociateReport:(FHAssociateFormReportModel *)associateReport
{
    NSMutableDictionary *params = @{}.mutableCopy;
    NSDictionary *reportParams = associateReport.reportParams;
    
    params[@"page_type"] = reportParams[@"page_type"] ? : @"be_null";
    params[@"enter_from"] = reportParams[@"enter_from"] ? : @"be_null";
    params[@"element_from"] = reportParams[@"element_from"] ? : @"be_null";
    params[@"rank"] = reportParams[@"rank"] ? : @"be_null";
    params[@"origin_from"] = reportParams[@"origin_from"] ? : @"be_null";
    params[@"origin_search_id"] = reportParams[@"origin_search_id"] ? : @"be_null";
    params[@"log_pb"] = reportParams[@"log_pb"] ? : @"be_null";
    params[kFHAssociateInfo] = associateReport.associateInfo;
    params[@"card_type"] = reportParams[@"card_type"] ? : @"be_null";
    params[@"position"] = reportParams[@"position"] ? : @"be_null";
    params[@"growth_deepevent"] = @(1);

    params[@"item_id"] = reportParams[@"item_id"] ? : @"be_null";
    if (reportParams[@"event_tracking_id"]) {
        params[@"event_tracking_id"] = reportParams[@"event_tracking_id"];
    }
    if (reportParams[@"picture_type"]) {
        params[@"picture_type"] = reportParams[@"picture_type"];
    }
    params[@"element_type"] = @"";

    [FHUserTracker writeEvent:@"inform_show" params:params];
}

// 表单提交
+ (void)addClickConfirmLogWithAssociateReport:(FHAssociateFormReportModel *)associateReport alertView:(FHDetailNoticeAlertView *)alertView
{
    NSMutableDictionary *params = @{}.mutableCopy;
    NSDictionary *reportParams = associateReport.reportParams;
    params[@"page_type"] = reportParams[@"page_type"] ? : @"be_null";
    params[@"card_type"] = reportParams[@"card_type"] ? : @"be_null";
    params[@"enter_from"] = reportParams[@"enter_from"] ? : @"be_null";
    params[@"element_from"] = reportParams[@"element_from"] ? : @"be_null";
    params[@"rank"] = reportParams[@"rank"] ? : @"be_null";
    params[@"origin_from"] = reportParams[@"origin_from"] ? : @"be_null";
    params[@"origin_search_id"] = reportParams[@"origin_search_id"] ? : @"be_null";
    params[@"log_pb"] = reportParams[@"log_pb"] ? : @"be_null";
    params[kFHAssociateInfo] = associateReport.associateInfo;
    params[@"card_type"] = reportParams[@"card_type"] ? : @"be_null";
    params[@"position"] = reportParams[@"position"] ? : @"be_null";

    params[@"item_id"] = reportParams[@"item_id"] ? : @"be_null";
    if (reportParams[@"picture_type"]) {
        params[@"picture_type"] = reportParams[@"picture_type"];
    }
    params[@"growth_deepevent"] = @(1);
    if (reportParams[@"event_tracking_id"]) {
        params[@"event_tracking_id"] = reportParams[@"event_tracking_id"];
    }
    [FHUserTracker writeEvent:@"click_confirm" params:params];
}

@end

