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
#import "TTTracker.h"
#import <FHHouseBase/FHUserTracker.h>
#import <FHHouseBase/FHGeneralBizConfig.h>
#import <FHHouseBase/FHEnvContext.h>
#import "IMManager.h"
#import "HMDTTMonitor.h"

#import "FHHouseFollowUpHelper.h"
#import "FHFillFormAgencyListItemModel.h"
#import "FHHouseDetailViewController.h"
#import "FHHouseNewDetailViewModel.h"

extern NSString *const kFHPhoneNumberCacheKey;
extern NSString *const kFHToastCountKey;
extern NSString *const kFHPLoginhoneNumberCacheKey;
@implementation FHHouseFillFormHelper

//+ (BOOL)isFillFormParamsValid:(FHHouseFillFormConfigModel *)configModel
//{
//    NSString *phone = configModel.phone;
//    NSString *houseId = configModel.houseId;
//    FHHouseType houseType = configModel.houseType;
//    NSString *realtorId = configModel.realtorId;
//    NSString *searchId = configModel.searchId;
//    NSString *imprId = configModel.imprId;
////    if (houseId.length < 1 || searchId.length < 1 || imprId.length < 1) {
//
//    if (houseId.length < 1 || realtorId.length < 1 || searchId.length < 1 || imprId.length < 1 || configModel.topViewController == nil) {
//        NSAssert(NO, @"请校验以上必填字段！");
//        return NO;
//    }
//    return YES;
//}

//+ (void)fillFormActionWithConfigModel:(FHHouseFillFormConfigModel *)configModel
//{
//    NSString *title = configModel.title;
//    NSString *subtitle = configModel.subtitle;
//    NSString *btnTitle = configModel.btnTitle;
//
//    YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
//    id phoneCache = [sendPhoneNumberCache objectForKey:kFHPhoneNumberCacheKey];
//    id loginPhoneCache = [sendPhoneNumberCache objectForKey:kFHPLoginhoneNumberCacheKey];
//
//    NSString *phoneNum = nil;
//    if ([phoneCache isKindOfClass:[NSString class]]) {
//        NSString *cacheNum = (NSString *)phoneCache;
//        if (cacheNum.length > 0) {
//            phoneNum = cacheNum;
//        }
//    }else if ([loginPhoneCache isKindOfClass:[NSString class]]) {
//        NSString *cacheNum = (NSString *)loginPhoneCache;
//        if (cacheNum.length > 0) {
//            phoneNum = cacheNum;
//        }
//    }
//    if (phoneNum.length > 0) {
//        subtitle = [NSString stringWithFormat:@"%@\n已为您填写上次提交时使用的手机号",subtitle];
//    }
//    [self addInformShowLog:configModel];
//    __weak typeof(self)wself = self;
//    FHDetailNoticeAlertView *alertView = [[FHDetailNoticeAlertView alloc]initWithTitle:title subtitle:subtitle btnTitle:btnTitle];
//    if (configModel.chooseAgencyList.count > 0) {
//        NSInteger selectCount = 0;
//        for (FHFillFormAgencyListItemModel *item in configModel.chooseAgencyList) {
//            if (![item isKindOfClass:[FHFillFormAgencyListItemModel class]]) {
//                continue;
//            }
//            if (item.checked) {
//                selectCount += 1;
//            }
//        }
//        [alertView updateAgencyTitle:[NSString stringWithFormat:@"%ld",selectCount]];
//        alertView.agencyClickBlock = ^(FHDetailNoticeAlertView *alert){
//
//            [alert endEditing:YES];
//            NSMutableDictionary *info = @{}.mutableCopy;
//            info[@"choose_agency_list"] = [alert selectAgencyList] ? : configModel.chooseAgencyList;
//            NSHashTable *delegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
//            [delegateTable addObject:alert];
//            info[@"delegate"] = delegateTable;
//            TTRouteUserInfo* userInfo = [[TTRouteUserInfo alloc]initWithInfo:info];
//            NSURL *url = [NSURL URLWithString:@"fschema://house_agency_list"];
//            [[TTRoute sharedRoute]openURLByPushViewController:url userInfo:userInfo];
//        };
//    }
//    alertView.phoneNum = phoneNum;
//    alertView.confirmClickBlock = ^(NSString *phoneNum,FHDetailNoticeAlertView *alert){
//        [wself fillFormRequest:configModel phone:phoneNum alertView:alert];
//        [wself addClickConfirmLog:configModel alertView:alert];
//    };
//
//    alertView.tipClickBlock = ^{
//
//        NSString *privateUrlStr = [NSString stringWithFormat:@"%@/f100/client/user_privacy&title=个人信息保护声明&hide_more=1",[FHURLSettings baseURL]];
//        NSString *urlStr = [privateUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fschema://webview?url=%@",urlStr]];
//        [[TTRoute sharedRoute]openURLByPushViewController:url];
//    };
//
//    [alertView showFrom:configModel.topViewController.view];
//}

//+ (void)fillFormActionWithConfig:(NSDictionary *)config
//{
//    FHHouseFillFormConfigModel *configModel = [[FHHouseFillFormConfigModel alloc]initWithDictionary:config error:nil];
//    if (configModel) {
//        [self fillFormActionWithConfigModel:configModel];
//    }
//}

//+ (void)fillFormRequest:(FHHouseFillFormConfigModel *)configModel phone:(NSString *)phone alertView:(FHDetailNoticeAlertView *)alertView
//{
//    NSString *customHouseId = configModel.customHouseId;
//    NSString *fromStr = configModel.from;
//
//    if (![TTReachability isNetworkConnected]) {
//        [[ToastManager manager] showToast:@"网络异常"];
//        return;
//    }
//    NSString *houseId = customHouseId.length > 0 ? customHouseId : configModel.houseId;
//    NSString *from = fromStr.length > 0 ? fromStr : [self fromStrByHouseType:configModel.houseType];
//    NSArray *selectAgencyList = [alertView selectAgencyList] ? : configModel.chooseAgencyList;
//    [FHMainApi requestSendPhoneNumbserByHouseId:houseId phone:phone from:from cluePage:configModel.cluePage clueEndpoint:configModel.clueEndpoint targetType:@(configModel.houseType) agencyList:selectAgencyList completion:^(FHDetailResponseModel * _Nullable model, NSError * _Nullable error) {
//
//        if (model.status.integerValue == 0 && !error) {
//            YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
//            [sendPhoneNumberCache setObject:phone forKey:kFHPhoneNumberCacheKey];
//            NSString *toast = @"提交成功，经纪人将尽快与您联系";
//            if (configModel.toast && configModel.toast.length > 0) {
//                toast = configModel.toast;
//            }
//
//            /* 不想加这个逻辑，新房填表单之后要弹出另一个弹窗，效果是要衔接，就是一个不消失直接展示另一个，不是不能实现，是要把之前封装好的逻辑打乱，还要加一些XX的代码，不优雅； 数据都不在一个地方，加通知也不太好，oops
//             */
//            if (configModel.houseType == FHHouseTypeNewHouse && [configModel.topViewController isKindOfClass:[FHHouseDetailViewController class]]) {
//                // 新房详情
//                FHHouseDetailViewController *vc = configModel.topViewController;
//                FHHouseNewDetailViewModel* viewModel = (FHHouseNewDetailViewModel *)vc.viewModel;
//                if ([viewModel needShowSocialInfoForm:configModel]) {
//                    [viewModel showUgcSocialEntrance:alertView];
//                } else {
//                    [[ToastManager manager] showToast:toast];
//                    [alertView dismiss];
//                }
//            } else {
//                [[ToastManager manager] showToast:toast];
//                // 走之前的逻辑
//                [alertView dismiss];
//            }
//        }else {
//            NSString *message = model.message ? : @"提交失败";
//            [[ToastManager manager] showToast:message];
//        }
//    }];
//    // 静默关注功能
//    NSMutableDictionary *params = @{}.mutableCopy;
//    if ([self baseParamsWithConfigModel:configModel]) {
//        [params addEntriesFromDictionary:([self baseParamsWithConfigModel:configModel])];
//    }
//    FHHouseFollowUpConfigModel *followConfig = [[FHHouseFollowUpConfigModel alloc]initWithDictionary:params error:nil];
//    followConfig.houseType = configModel.houseType;
//    followConfig.followId = configModel.houseId;
//    followConfig.actionType = configModel.actionType;
//    followConfig.showTip = YES;
//
//    [FHHouseFollowUpHelper silentFollowHouseWithConfigModel:followConfig];
//}

+ (NSString *)fromStrByHouseType:(FHHouseType)houseType
{
    switch (houseType) {
        case FHHouseTypeNewHouse:
            return @"app_court";
            break;
        case FHHouseTypeSecondHandHouse:
            return @"app_oldhouse";
            break;
        case FHHouseTypeNeighborhood:
            return @"app_neighbourhood";
            break;
        case FHHouseTypeRentHouse:
            return @"app_rent";
            break;
        default:
            break;
    }
    return @"be_null";
}

#pragma mark log


+ (NSDictionary *)baseParamsWithConfigModel:(FHHouseFillFormConfigModel *)configModel
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
    return params;

}

// 表单展示
//+ (void)addInformShowLog:(FHHouseFillFormConfigModel *)configModel
//{
//    NSMutableDictionary *params = @{}.mutableCopy;
//    params[@"page_type"] = configModel.pageType ? : @"be_null";
//    params[@"card_type"] = configModel.cardType ? : @"be_null";
//    params[@"enter_from"] = configModel.enterFrom ? : @"be_null";
//    params[@"element_from"] = configModel.elementFrom ? : @"be_null";
//    params[@"rank"] = configModel.rank ? : @"be_null";
//    params[@"origin_from"] = configModel.originFrom ? : @"be_null";
//    params[@"origin_search_id"] = configModel.originSearchId ? : @"be_null";
//    params[@"log_pb"] = configModel.logPb ? : @"be_null";
//    params[@"position"] = configModel.position ? : @"button";
//    if (configModel.itemId.length > 0) {
//        params[@"item_id"] = configModel.itemId;
//    }
//    params[@"growth_deepevent"] = @(1);
//    [FHUserTracker writeEvent:@"inform_show" params:params];
//}

// 表单提交
//+ (void)addClickConfirmLog:(FHHouseFillFormConfigModel *)configModel alertView:(FHDetailNoticeAlertView *)alertView
//{
//    NSMutableDictionary *params = @{}.mutableCopy;
//    params[@"page_type"] = configModel.pageType ? : @"be_null";
//    params[@"card_type"] = configModel.cardType ? : @"be_null";
//    params[@"enter_from"] = configModel.enterFrom ? : @"be_null";
//    params[@"element_from"] = configModel.elementFrom ? : @"be_null";
//    params[@"rank"] = configModel.rank ? : @"be_null";
//    params[@"origin_from"] = configModel.originFrom ? : @"be_null";
//    params[@"origin_search_id"] = configModel.originSearchId ? : @"be_null";
//    params[@"log_pb"] = configModel.logPb ? : @"be_null";
//    params[@"position"] = configModel.position ? : @"button";
//
//    if (configModel.itemId.length > 0) {
//        params[@"item_id"] = configModel.itemId;
//    }
//
//    NSMutableDictionary *dict = @{}.mutableCopy;
//    NSArray *selectAgencyList = [alertView selectAgencyList] ? : configModel.chooseAgencyList;
//    for (FHFillFormAgencyListItemModel *item in selectAgencyList) {
//        if (item.agencyId.length > 0) {
//            [dict setValue:[NSNumber numberWithInt:item.checked] forKey:item.agencyId];
//        }
//    }
//    params[@"agency_list"] = dict.count > 0 ? dict : @"be_null";
//    params[@"growth_deepevent"] = @(1);
//    [FHUserTracker writeEvent:@"click_confirm" params:params];
//}

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
    NSString *title = associateReport.title;
    NSString *subtitle = associateReport.subtitle;
    NSString *btnTitle = associateReport.btnTitle;

    YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
    id phoneCache = [sendPhoneNumberCache objectForKey:kFHPhoneNumberCacheKey];
    id loginPhoneCache = [sendPhoneNumberCache objectForKey:kFHPLoginhoneNumberCacheKey];

    NSString *phoneNum = nil;
    if ([phoneCache isKindOfClass:[NSString class]]) {
        NSString *cacheNum = (NSString *)phoneCache;
        if (cacheNum.length > 0) {
            phoneNum = cacheNum;
        }
    }else if ([loginPhoneCache isKindOfClass:[NSString class]]) {
        NSString *cacheNum = (NSString *)loginPhoneCache;
        if (cacheNum.length > 0) {
            phoneNum = cacheNum;
        }
    }
    if (phoneNum.length > 0) {
        subtitle = [NSString stringWithFormat:@"%@\n已为您填写上次提交时使用的手机号",subtitle];
    }
    [self addInformShowLogWithAssociateReport:associateReport];
    __weak typeof(self)wself = self;
    FHDetailNoticeAlertView *alertView = [[FHDetailNoticeAlertView alloc]initWithTitle:title subtitle:subtitle btnTitle:btnTitle];
    if (associateReport.chooseAgencyList.count > 0) {
        NSInteger selectCount = 0;
        for (FHFillFormAgencyListItemModel *item in associateReport.chooseAgencyList) {
            if (![item isKindOfClass:[FHFillFormAgencyListItemModel class]]) {
                continue;
            }
            if (item.checked) {
                selectCount += 1;
            }
        }
        [alertView updateAgencyTitle:[NSString stringWithFormat:@"%ld",selectCount]];
        alertView.agencyClickBlock = ^(FHDetailNoticeAlertView *alert){
            
            [alert endEditing:YES];
            NSMutableDictionary *info = @{}.mutableCopy;
            info[@"choose_agency_list"] = [alert selectAgencyList] ? : associateReport.chooseAgencyList;
            NSHashTable *delegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
            [delegateTable addObject:alert];
            info[@"delegate"] = delegateTable;
            TTRouteUserInfo* userInfo = [[TTRouteUserInfo alloc]initWithInfo:info];
            NSURL *url = [NSURL URLWithString:@"fschema://house_agency_list"];
            [[TTRoute sharedRoute]openURLByPushViewController:url userInfo:userInfo];
        };
    }
    alertView.phoneNum = phoneNum;
    alertView.confirmClickBlock = ^(NSString *phoneNum,FHDetailNoticeAlertView *alert){
        [wself fillFormRequestWithAssociateReport:associateReport phone:phoneNum alertView:alert];
        [wself addClickConfirmLogWithAssociateReport:associateReport alertView:alert];
    };

    alertView.tipClickBlock = ^{
        
        NSString *privateUrlStr = [NSString stringWithFormat:@"%@/f100/client/user_privacy&title=个人信息保护声明&hide_more=1",[FHURLSettings baseURL]];
        NSString *urlStr = [privateUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fschema://webview?url=%@",urlStr]];
        [[TTRoute sharedRoute]openURLByPushViewController:url];
    };
    
    [alertView showFrom:associateReport.topViewController.view];
}

+ (void)fillFormRequestWithAssociateReport:(FHAssociateFormReportModel *)associateReport phone:(NSString *)phone alertView:(FHDetailNoticeAlertView *)alertView
{
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    NSArray *selectAgencyList = [alertView selectAgencyList] ? : associateReport.chooseAgencyList;
    [FHMainApi requestCallReportByHouseId:associateReport.houseId phone:phone from:nil cluePage:nil clueEndpoint:nil targetType:nil reportAssociate:associateReport.associateInfo agencyList:selectAgencyList completion:^(FHDetailResponseModel * _Nullable model, NSError * _Nullable error) {

        if (model.status.integerValue == 0 && !error) {
            YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
            [sendPhoneNumberCache setObject:phone forKey:kFHPhoneNumberCacheKey];
            NSString *toast = @"提交成功，经纪人将尽快与您联系";
            if (associateReport.toast && associateReport.toast.length > 0) {
                toast = associateReport.toast;
            }
            
            /* 不想加这个逻辑，新房填表单之后要弹出另一个弹窗，效果是要衔接，就是一个不消失直接展示另一个，不是不能实现，是要把之前封装好的逻辑打乱，还要加一些XX的代码，不优雅； 数据都不在一个地方，加通知也不太好，oops
             */
            if (associateReport.houseType == FHHouseTypeNewHouse && [associateReport.topViewController isKindOfClass:[FHHouseDetailViewController class]]) {
                // 新房详情
                FHHouseDetailViewController *vc = associateReport.topViewController;
                FHHouseNewDetailViewModel* viewModel = (FHHouseNewDetailViewModel *)vc.viewModel;
                //  todo  zjing test
                if ([viewModel needShowSocialInfoForm:associateReport]) {
                    [viewModel showUgcSocialEntrance:alertView];
                } else {
                    [[ToastManager manager] showToast:toast];
                    [alertView dismiss];
                }
            } else {
                [[ToastManager manager] showToast:toast];
                // 走之前的逻辑
                [alertView dismiss];
            }
        }else {
            NSString *message = model.message ? : @"提交失败";
            [[ToastManager manager] showToast:message];
        }
    }];
    // 静默关注功能
    NSMutableDictionary *params = @{}.mutableCopy;
    //  todo   zjing  test
//    if ([self baseParamsWithConfigModel:associateReport]) {
//        [params addEntriesFromDictionary:([self baseParamsWithConfigModel:configModel])];
//    }
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
    params[@"growth_deepevent"] = @(1);

    params[@"item_id"] = reportParams[@"item_id"] ? : @"be_null";

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

    NSMutableDictionary *dict = @{}.mutableCopy;
    NSArray *selectAgencyList = [alertView selectAgencyList] ? : associateReport.chooseAgencyList;
    for (FHFillFormAgencyListItemModel *item in selectAgencyList) {
        if (item.agencyId.length > 0) {
            [dict setValue:[NSNumber numberWithInt:item.checked] forKey:item.agencyId];
        }
    }
    params[@"agency_list"] = dict.count > 0 ? dict : @"be_null";
    params[@"growth_deepevent"] = @(1);
    [FHUserTracker writeEvent:@"click_confirm" params:params];
}

@end

@implementation FHHouseFillFormConfigModel


+(JSONKeyMapper *)keyMapper
{
    return [JSONKeyMapper mapperForSnakeCase];
}

+(BOOL)propertyIsIgnored:(NSString *)propertyName
{
    if ([propertyName isEqualToString:@"topViewController"]) {
        return YES;
    }
    return NO;
}

+(BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _title = @"询底价";
        _subtitle = @"提交后将安排专业经纪人与您联系";
        _btnTitle = @"获取底价";
    }
    return self;
}

- (void)setTraceParams:(NSDictionary *)params
{
    _pageType = params[@"page_type"];
    _cardType = params[@"card_type"];
    _enterFrom = params[@"enter_from"];
    _elementFrom = params[@"element_from"];
    _rank = params[@"rank"];
    _originFrom = params[@"origin_from"];
    _originSearchId = params[@"origin_search_id"];
    _logPb = params[@"log_pb"];
    _searchId = params[@"search_id"];
    _imprId = params[@"impr_id"];
    _position = params[@"position"];
    _realtorPosition = params[@"realtor_position"];
    _itemId = params[@"item_id"];
    if (params[@"from"]) {
        _from = params[@"from"];
    }
    _cluePage = params[kFHCluePage];

}

- (void)setLogPbWithNSString:(NSString *)logpb
{
    if ([@"be_null" isEqualToString:logpb]) {
        self.logPb = nil;
    }else if ([logpb isKindOfClass:[NSString class]]) {
        @try {
            NSData *data = [logpb dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            self.logPb = dict;
        } @catch (NSException *exception) {
#if DEBUG
            NSLog(@"exception is: %@",exception);
#endif
        }
    }
}

@end

