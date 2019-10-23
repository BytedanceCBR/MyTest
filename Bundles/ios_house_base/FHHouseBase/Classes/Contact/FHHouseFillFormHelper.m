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
#import <TTRoute.h>
#import "YYCache.h"
#import <FHCommonUI/ToastManager.h>
#import <TTReachability.h>
#import "TTAccount.h"
#import "TTTracker.h"
#import <FHHouseBase/FHUserTracker.h>
#import <FHHouseBase/FHGeneralBizConfig.h>
#import <FHHouseBase/FHEnvContext.h>
#import "IMManager.h"
#import <HMDTTMonitor.h>
#import "FHHousePhoneCallUtils.h"
#import "FHHouseFollowUpHelper.h"
#import "FHFillFormAgencyListItemModel.h"
#import "FHHouseDetailViewController.h"

extern NSString *const kFHPhoneNumberCacheKey;
extern NSString *const kFHToastCountKey;

@implementation FHHouseFillFormHelper

+ (BOOL)isFillFormParamsValid:(FHHouseFillFormConfigModel *)configModel
{
    NSString *phone = configModel.phone;
    NSString *houseId = configModel.houseId;
    FHHouseType houseType = configModel.houseType;
    NSString *realtorId = configModel.realtorId;
    NSString *searchId = configModel.searchId;
    NSString *imprId = configModel.imprId;
//    if (houseId.length < 1 || searchId.length < 1 || imprId.length < 1) {

    if (houseId.length < 1 || realtorId.length < 1 || searchId.length < 1 || imprId.length < 1 || configModel.topViewController == nil) {
        NSAssert(NO, @"请校验以上必填字段！");
        return NO;
    }
    return YES;
}

+ (void)fillFormActionWithConfigModel:(FHHouseFillFormConfigModel *)configModel
{
    NSString *title = configModel.title;
    NSString *subtitle = configModel.subtitle;
    NSString *btnTitle = configModel.btnTitle;

    YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
    id phoneCache = [sendPhoneNumberCache objectForKey:kFHPhoneNumberCacheKey];
    NSString *phoneNum = (NSString *)phoneCache;
    if (phoneNum.length > 0) {
        subtitle = [NSString stringWithFormat:@"%@\n已为您填写上次提交时使用的手机号",subtitle];
    }
    [self addInformShowLog:configModel];
    __weak typeof(self)wself = self;
    FHDetailNoticeAlertView *alertView = [[FHDetailNoticeAlertView alloc]initWithTitle:title subtitle:subtitle btnTitle:btnTitle];
    if (configModel.chooseAgencyList.count > 0) {
        NSInteger selectCount = 0;
        for (FHFillFormAgencyListItemModel *item in configModel.chooseAgencyList) {
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
            info[@"choose_agency_list"] = [alert selectAgencyList] ? : configModel.chooseAgencyList;
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
        [wself fillFormRequest:configModel phone:phoneNum alertView:alert];
        [wself addClickConfirmLog:configModel alertView:alertView];
    };

    alertView.tipClickBlock = ^{
        
        NSString *privateUrlStr = [NSString stringWithFormat:@"%@/f100/client/user_privacy&title=个人信息保护声明&hide_more=1",[FHURLSettings baseURL]];
        NSString *urlStr = [privateUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fschema://webview?url=%@",urlStr]];
        [[TTRoute sharedRoute]openURLByPushViewController:url];
    };
    
    [alertView showFrom:configModel.topViewController.view];
}

+ (void)fillFormActionWithConfig:(NSDictionary *)config
{
    FHHouseFillFormConfigModel *configModel = [[FHHouseFillFormConfigModel alloc]initWithDictionary:config error:nil];
    if (configModel) {
        [self fillFormActionWithConfigModel:configModel];
    }
}

+ (void)fillOnlineFormActionWithConfigModel:(FHHouseFillFormConfigModel *)configModel
{
    NSString *title = configModel.title;
    NSString *subtitle = configModel.subtitle;
    NSString *btnTitle = configModel.btnTitle;
    NSString *leftBtnTitle = configModel.leftBtnTitle;
    YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
    id phoneCache = [sendPhoneNumberCache objectForKey:kFHPhoneNumberCacheKey];
    NSString *phoneNum = (NSString *)phoneCache;
    if (phoneNum.length > 0) {
        subtitle = [NSString stringWithFormat:@"%@\n已为您填写上次提交时使用的手机号",subtitle];
    }
    __weak typeof(self)wself = self;
    FHDetailNoticeAlertView *alertView = nil;
    [self addReservationShowLog:configModel];
    if (leftBtnTitle.length > 0) {
        alertView = [[FHDetailNoticeAlertView alloc]initWithTitle:title subtitle:subtitle btnTitle:btnTitle leftBtnTitle:leftBtnTitle];
        alertView.confirmClickBlock = ^(NSString *phoneNum,FHDetailNoticeAlertView *alert){
            [wself phoneCallAction:configModel];
            [alert dismiss];
        };
        alertView.leftClickBlock = ^(NSString * _Nonnull phoneNum,FHDetailNoticeAlertView *alert) {
            [wself fillFormRequest:configModel phone:phoneNum alertView:alert];
            [wself addClickConfirmLog:configModel alertView:alertView];
        };
    }else {
        alertView = [[FHDetailNoticeAlertView alloc]initWithTitle:title subtitle:subtitle btnTitle:btnTitle];
        alertView.confirmClickBlock = ^(NSString *phoneNum,FHDetailNoticeAlertView *alert){
            [wself fillFormRequest:configModel phone:phoneNum alertView:alert];
            [wself addClickConfirmLog:configModel alertView:alertView];
        };
    }
    if (configModel.chooseAgencyList.count > 0) {
        NSInteger selectCount = 0;
        for (FHFillFormAgencyListItemModel *item in configModel.chooseAgencyList) {
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
            info[@"choose_agency_list"] = [alert selectAgencyList] ? : configModel.chooseAgencyList;
            NSHashTable *delegateTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
            [delegateTable addObject:alert];
            info[@"delegate"] = delegateTable;
            TTRouteUserInfo* userInfo = [[TTRouteUserInfo alloc]initWithInfo:info];
            NSURL *url = [NSURL URLWithString:@"fschema://house_agency_list"];
            [[TTRoute sharedRoute]openURLByPushViewController:url userInfo:userInfo];
        };
    }
    alertView.phoneNum = phoneNum;
    alertView.tipClickBlock = ^{
        
        NSString *privateUrlStr = [NSString stringWithFormat:@"%@/f100/client/user_privacy&title=个人信息保护声明&hide_more=1",[FHURLSettings baseURL]];
        NSString *urlStr = [privateUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fschema://webview?url=%@",urlStr]];
        [[TTRoute sharedRoute]openURLByPushViewController:url];
    };
    [alertView showFrom:configModel.topViewController.view];
}

+(void)phoneCallAction:(FHHouseFillFormConfigModel *)configModel
{
    NSDictionary *tracerDict = [configModel toDictionary];
    FHHouseContactConfigModel *contactConfig = [[FHHouseContactConfigModel alloc]init];
    [contactConfig setTraceParams:tracerDict];
    contactConfig.houseType = configModel.houseType;
    contactConfig.houseId = configModel.houseId;
    contactConfig.phone = configModel.phone;
    contactConfig.realtorId = configModel.realtorId;
    contactConfig.searchId = configModel.searchId;
    contactConfig.imprId = configModel.imprId;
    [FHHousePhoneCallUtils callWithConfigModel:contactConfig completion:^(BOOL success, NSError * _Nonnull error, FHDetailVirtualNumModel * _Nonnull virtualPhoneNumberModel) {
        if(success && [configModel.topViewController isKindOfClass:[FHHouseDetailViewController class]]){
            FHHouseDetailViewController *vc = (FHHouseDetailViewController *)configModel.topViewController;
            vc.isPhoneCallShow = YES;
            vc.phoneCallRealtorId = contactConfig.realtorId;
            vc.phoneCallRequestId = virtualPhoneNumberModel.requestId;
        }
    }];
}

+ (void)fillOnlineFormActionWithConfig:(NSDictionary *)config
{
    FHHouseFillFormConfigModel *configModel = [[FHHouseFillFormConfigModel alloc]initWithDictionary:config error:nil];
    if (configModel) {
        [self fillOnlineFormActionWithConfigModel:configModel];
    }
}

+ (void)fillFormRequest:(FHHouseFillFormConfigModel *)configModel phone:(NSString *)phone alertView:(FHDetailNoticeAlertView *)alertView
{
    NSString *customHouseId = configModel.customHouseId;
    NSString *fromStr = configModel.from;
    
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    NSString *houseId = customHouseId.length > 0 ? customHouseId : configModel.houseId;
    NSString *from = fromStr.length > 0 ? fromStr : [self fromStrByHouseType:configModel.houseType];
    NSArray *selectAgencyList = [alertView selectAgencyList] ? : configModel.chooseAgencyList;
    [FHMainApi requestSendPhoneNumbserByHouseId:houseId phone:phone from:from agencyList:selectAgencyList completion:^(FHDetailResponseModel * _Nullable model, NSError * _Nullable error) {
        
        if (model.status.integerValue == 0 && !error) {
            
            [alertView dismiss];
            YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
            [sendPhoneNumberCache setObject:phone forKey:kFHPhoneNumberCacheKey];
            [[ToastManager manager] showToast:@"提交成功，经纪人将尽快与您联系"];
        }else {
            NSString *message = model.message ? : @"提交失败";
            [[ToastManager manager] showToast:message];
        }
    }];
    // 静默关注功能
    NSMutableDictionary *params = @{}.mutableCopy;
    if ([self baseParamsWithConfigModel:configModel]) {
        [params addEntriesFromDictionary:([self baseParamsWithConfigModel:configModel])];
    }
    FHHouseFollowUpConfigModel *followConfig = [[FHHouseFollowUpConfigModel alloc]initWithDictionary:params error:nil];
    followConfig.houseType = configModel.houseType;
    followConfig.followId = configModel.houseId;
    followConfig.actionType = configModel.actionType;
    followConfig.showTip = YES;
    
    [FHHouseFollowUpHelper silentFollowHouseWithConfigModel:followConfig];
}

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
+ (void)addReservationShowLog:(FHHouseFillFormConfigModel *)configModel
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
    params[@"position"] = @"online";
    if (configModel.itemId.length > 0) {
        params[@"item_id"] = configModel.itemId;
    }
    [FHUserTracker writeEvent:@"reservation_show" params:params];
}

// 表单展示
+ (void)addInformShowLog:(FHHouseFillFormConfigModel *)configModel
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
    params[@"position"] = configModel.position ? : @"button";
    if (configModel.itemId.length > 0) {
        params[@"item_id"] = configModel.itemId;
    }
    [FHUserTracker writeEvent:@"inform_show" params:params];
}

// 表单提交
+ (void)addClickConfirmLog:(FHHouseFillFormConfigModel *)configModel alertView:(FHDetailNoticeAlertView *)alertView
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
    params[@"position"] = configModel.position ? : @"button";

    if (configModel.itemId.length > 0) {
        params[@"item_id"] = configModel.itemId;
    }

    NSMutableDictionary *dict = @{}.mutableCopy;
    NSArray *selectAgencyList = [alertView selectAgencyList] ? : configModel.chooseAgencyList;
    for (FHFillFormAgencyListItemModel *item in selectAgencyList) {
        if (item.agencyId.length > 0) {
            [dict setValue:[NSNumber numberWithInt:item.checked] forKey:item.agencyId];
        }
    }
    params[@"agency_list"] = dict.count > 0 ? dict : @"be_null";

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

