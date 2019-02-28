//
//  FHHouseDetailPhoneCallViewModel.m
//  Pods
//
//  Created by 张静 on 2019/2/14.
//

#import "FHHouseDetailPhoneCallViewModel.h"
#import "FHDetailNoticeAlertView.h"
#import "FHHouseType.h"
#import "FHHouseDetailAPI.h"
#import <TTRoute.h>
#import "YYCache.h"
#import <FHCommonUI/ToastManager.h>
#import <TTReachability.h>
#import <TTPhotoScrollVC/TTPhotoScrollViewController.h>
#import "FHDetailBottomBarView.h"
#import <FHHouseBase/FHRealtorDetailWebViewControllerDelegate.h>
#import <FHHouseBase/FHUserTracker.h>
#import <FHHouseBase/FHGeneralBizConfig.h>
#import <FHHouseBase/FHEnvContext.h>

extern NSString *const kFHToastCountKey;
extern NSString *const kFHPhoneNumberCacheKey;

@interface FHHouseDetailPhoneCallViewModel () <FHRealtorDetailWebViewControllerDelegate>

@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, copy) NSString *houseId;
@property(nonatomic , weak) FHDetailNoticeAlertView *alertView;

@end

@implementation FHHouseDetailPhoneCallViewModel

- (instancetype)initWithHouseType:(FHHouseType)houseType houseId:(NSString *)houseId
{
    self = [super init];
    if (self) {
        _houseType = houseType;
        _houseId = houseId;
    }
    return self;
}

- (void)fillFormAction
{
    NSString *title = @"询底价";
    NSString *subtitle = @"提交后将安排专业经纪人与您联系";
    NSString *btnTitle = @"获取底价";
    if (self.houseType == FHHouseTypeNeighborhood) {
        title = @"咨询经纪人";
        btnTitle = @"提交";
    }
    [self fillFormActionWithTitle:title subtitle:subtitle btnTitle:btnTitle];
}

- (void)fillFormActionWithTitle:(NSString *)title subtitle:(NSString *)subtitle btnTitle:(NSString *)btnTitle
{
    [self addInformShowLog];
    __weak typeof(self)wself = self;
    FHDetailNoticeAlertView *alertView = [[FHDetailNoticeAlertView alloc]initWithTitle:title subtitle:subtitle btnTitle:btnTitle];
    YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
    alertView.phoneNum = [sendPhoneNumberCache objectForKey:kFHPhoneNumberCacheKey];
    alertView.confirmClickBlock = ^(NSString *phoneNum){
        [wself fillFormRequest:phoneNum];
        [wself addClickConfirmLog];
    };
    alertView.tipClickBlock = ^{
        
        NSString *privateUrlStr = [NSString stringWithFormat:@"%@/f100/client/user_privacy&title=个人信息保护声明&hide_more=1",[FHURLSettings baseURL]];
        NSString *urlStr = [privateUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fschema://webview?url=%@",urlStr]];
        [[TTRoute sharedRoute]openURLByPushViewController:url];
    };
    [alertView showFrom:self.belongsVC.view];
    self.alertView = alertView;
}

- (void)callWithPhone:(NSString *)phone realtorId:(NSString *)realtorId searchId:(NSString *)searchId imprId:(NSString *)imprId extraDict:(NSDictionary *)extraDict
{
    __weak typeof(self)wself = self;
    if (![TTReachability isNetworkConnected]) {
        
        NSString *urlStr = [NSString stringWithFormat:@"tel://%@", phone];
        [self callPhone:urlStr];
        [self addClickCallLogWithExtra:extraDict isVirtual:NO];
        return;
    }
    [self.bottomBar startLoading];
    [FHHouseDetailAPI requestVirtualNumber:realtorId houseId:self.houseId houseType:self.houseType searchId:searchId imprId:imprId completion:^(FHDetailVirtualNumResponseModel * _Nullable model, NSError * _Nullable error) {
        
        [wself.bottomBar stopLoading];
        NSString *urlStr = [NSString stringWithFormat:@"tel://%@", phone];
        BOOL isVirtual = model.data.isVirtual == 1 ? YES : NO;
        if (!error && model.data.virtualNumber.length > 0) {
            urlStr = [NSString stringWithFormat:@"tel://%@", model.data.virtualNumber];
        }
        NSMutableDictionary *extra = @{}.mutableCopy;
        if (extraDict) {
            [extra addEntriesFromDictionary:extraDict];
        }
        if (model.data.realtorId.length > 0) {
            extra[@"realtor_id"] = model.data.realtorId;
        }
        [wself addClickCallLogWithExtra:extra isVirtual:isVirtual];
        [wself callPhone:urlStr];

    }];
}

- (void)callWithPhone:(NSString *)phone realtorId:(NSString *)realtorId searchId:(NSString *)searchId imprId:(NSString *)imprId
{
    [self callWithPhone:phone realtorId:realtorId searchId:searchId imprId:imprId extraDict:nil];
}

- (void)callWithPhone:(NSString *)phone realtorId:(NSString *)realtorId searchId:(NSString *)searchId imprId:(NSString *)imprId reportParams:(NSDictionary *)reportParams successBlock:(FHHouseDetailPhoneCallSuccessBlock)successBlock failBlock:(FHHouseDetailPhoneCallFailBlock)failBlock
{
    __weak typeof(self)wself = self;
    if (![TTReachability isNetworkConnected]) {
        
        NSString *urlStr = [NSString stringWithFormat:@"tel://%@", phone];
        [self callPhone:urlStr];
        [self addRealtorClickCallLogWithExtra:reportParams isVirtual:NO];
        NSError *error = [[NSError alloc]initWithDomain:NSURLErrorDomain code:-1 userInfo:nil];
        failBlock(error);
        return;
    }
    [self.bottomBar startLoading];
    [FHHouseDetailAPI requestVirtualNumber:realtorId houseId:self.houseId houseType:self.houseType searchId:searchId imprId:imprId completion:^(FHDetailVirtualNumResponseModel * _Nullable model, NSError * _Nullable error) {
        
        [wself.bottomBar stopLoading];
        NSString *urlStr = [NSString stringWithFormat:@"tel://%@", phone];
        BOOL isVirtual = model.data.isVirtual == 1 ? YES : NO;
        if (!error && model.data.virtualNumber.length > 0) {
            urlStr = [NSString stringWithFormat:@"tel://%@", model.data.virtualNumber];
            NSMutableDictionary *extra = @{}.mutableCopy;
            if (reportParams) {
                [extra addEntriesFromDictionary:reportParams];
            }
            if (model.data.realtorId.length > 0) {
                extra[@"realtor_id"] = model.data.realtorId;
            }
            [wself addRealtorClickCallLogWithExtra:extra isVirtual:isVirtual];
        }else {
            failBlock(error);
        }
        [wself callPhone:urlStr];
        successBlock(YES);
    }];
    
}

- (void)fillFormRequest:(NSString *)phoneNum
{
    __weak typeof(self)wself = self;
    if (![TTReachability isNetworkConnected]) {
        
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    [FHHouseDetailAPI requestSendPhoneNumbserByHouseId:self.houseId phone:phoneNum from:[self fromStrByHouseType:self.houseType] completion:^(FHDetailResponseModel * _Nullable model, NSError * _Nullable error) {
        
        if (model.status.integerValue == 0 && !error) {
            
            [wself.alertView dismiss];
            YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
            [sendPhoneNumberCache setObject:phoneNum forKey:kFHPhoneNumberCacheKey];
            NSInteger toastCount = [[NSUserDefaults standardUserDefaults]integerForKey:kFHToastCountKey];
            if (toastCount >= 3) {
                [[ToastManager manager] showToast:@"提交成功，经纪人将尽快与您联系"];
            }
        }else {
            [[ToastManager manager] showToast:[NSString stringWithFormat:@"提交失败 %@",model.message]];
        }
    }];
    // 静默关注功能
    [self.followUpViewModel silentFollowHouseByFollowId:self.houseId houseType:self.houseType actionType:self.houseType showTip:YES];
}

- (NSString *)fromStrByHouseType:(FHHouseType)houseType
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

- (void)licenseActionWithPhone:(FHDetailContactModel *)contactPhone
{
    NSMutableArray *images = @[].mutableCopy;
    NSMutableArray *imageTitles = @[].mutableCopy;

    // "营业执照"
    if (contactPhone.businessLicense.length > 0) {
        TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithURL:contactPhone.businessLicense];
        model.imageType = TTImageTypeLarge;
        if (model) {
            [images addObject:model];
        }
        [imageTitles addObject:@"营业执照"];
    }
    // "从业人员信息卡"
    if (contactPhone.certificate.length > 0) {
        TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithURL:contactPhone.certificate];
        model.imageType = TTImageTypeLarge;
        if (model) {
            [images addObject:model];
        }
        [imageTitles addObject:@"从业人员信息卡"];
    }
    if (images.count == 0) {
        return;
    }
    
    TTPhotoScrollViewController *vc = [[TTPhotoScrollViewController alloc] init];
    vc.dragToCloseDisabled = YES;
    vc.mode = PhotosScrollViewSupportBrowse;
    vc.startWithIndex = 0;
    vc.imageInfosModels = images;
    vc.imageTitles = imageTitles;

    UIImage *placeholder = [UIImage imageNamed:@"default_image"];
    NSMutableArray *placeholders = [[NSMutableArray alloc] initWithCapacity:images.count];
    for (NSInteger i = 0 ; i < images.count; i++) {
        [placeholders addObject:placeholder];
    }
    vc.placeholders = placeholders;
    [vc presentPhotoScrollView];
}


- (void)jump2RealtorDetailWithPhone:(FHDetailContactModel *)contactPhone
{
    if (contactPhone.realtorId.length < 1) {
        return;
    }
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSURL *openUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://realtor_detail?realtor_id=%@",contactPhone.realtorId]];
    
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"enter_from"] = self.tracerDict[@"enter_from"] ? : @"be_null";
    dict[@"element_from"] = self.tracerDict[@"element_from"] ? : @"be_null";
    dict[@"origin_from"] = self.tracerDict[@"origin_from"] ? : @"be_null";
    dict[@"log_pb"] = self.tracerDict[@"log_pb"];
    dict[@"search_id"] = self.tracerDict[@"search_id"] ? : @"be_null";
    dict[@"origin_search_id"] = self.tracerDict[@"origin_search_id"] ? : @"be_null";
    dict[@"group_id"] = self.tracerDict[@"group_id"] ? : @"be_null";
    dict[@"rank"] = self.tracerDict[@"rank"] ? : @"be_null";
    if ([self.tracerDict[@"log_pb"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *logPbDict = self.tracerDict[@"log_pb"];
        dict[@"impr_id"] = logPbDict[@"impr_id"] ? : @"be_null";
        dict[@"search_id"] = logPbDict[@"search_id"] ? : @"be_null";
        dict[@"group_id"] = logPbDict[@"group_id"] ? : @"be_null";
    }
    NSError *parseError = nil;
    NSString *reportParams = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&parseError];
    if (!parseError) {
        
        reportParams = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSString *jumpUrl = [NSString stringWithFormat:@"%@/f100/client/realtor_detail?realtor_id=%@&report_params=%@",host,contactPhone.realtorId,reportParams ? : @""];
    NSMutableDictionary *info = @{}.mutableCopy;
    info[@"url"] = jumpUrl;
    info[@"title"] = @"经纪人详情页";
    info[@"realtor_id"] = contactPhone.realtorId;
    info[@"delegate"] = self;
    info[@"trace"] = self.tracerDict;
    info[@"house_id"] = _houseId;
    info[@"house_type"] = @(_houseType);

    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc]initWithInfo:info];
    [[TTRoute sharedRoute]openURLByViewController:openUrl userInfo:userInfo];
}


- (void)callPhone:(NSString *)phone
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

#pragma mark delegate
- (void)followUpActionByFollowId:(NSString *)followId houseType:(FHHouseType)houseType
{
    [self.followUpViewModel silentFollowHouseByFollowId:followId houseType:houseType actionType:houseType showTip:NO];
}


#pragma mark 埋点相关
- (NSDictionary *)baseParams
{
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"page_type"] = self.tracerDict[@"page_type"] ? : @"be_null";
    params[@"card_type"] = self.tracerDict[@"card_type"] ? : @"be_null";
    params[@"enter_from"] = self.tracerDict[@"enter_from"] ? : @"be_null";
    params[@"element_from"] = self.tracerDict[@"element_from"] ? : @"be_null";
    params[@"rank"] = self.tracerDict[@"rank"] ? : @"be_null";
    params[@"origin_from"] = self.tracerDict[@"origin_from"] ? : @"be_null";
    params[@"origin_search_id"] = self.tracerDict[@"origin_search_id"] ? : @"be_null";
    params[@"log_pb"] = self.tracerDict[@"log_pb"] ? : @"be_null";
    return params;
}

// 拨打电话和经纪人展位拨打电话
- (void)addClickCallLogWithExtra:(NSDictionary *)extraDict isVirtual:(BOOL)isVirtual
{
    //    11.realtor_id
    //    12.realtor_rank:经纪人推荐位置，从0开始，底部button的默认为0
    //    13.realtor_position ：detail_button，detail_related
    //    14.has_associate：是否为虚拟号码：是：1，否：0
    //    15.is_dial ：是否为为拨号键盘：是：1，否：0
    NSMutableDictionary *params = @{}.mutableCopy;
    [params addEntriesFromDictionary:[self baseParams]];
    params[@"has_auth"] = @(1);
    params[@"realtor_id"] = extraDict[@"realtor_id"] ? : @"be_null";
    params[@"realtor_rank"] = extraDict[@"realtor_rank"] ? : @(0);
    params[@"realtor_position"] = extraDict[@"realtor_position"] ? : @"detail_button";
    params[@"has_associate"] = [NSNumber numberWithInteger:isVirtual];
    params[@"is_dial"] = @(1);
    [FHUserTracker writeEvent:@"click_call" params:params];
}

- (void)addRealtorClickCallLogWithExtra:(NSDictionary *)extraDict isVirtual:(BOOL)isVirtual
{
    //    11.realtor_id
    //    12.realtor_rank:经纪人推荐位置，从0开始，底部button的默认为0
    //    13.realtor_position ：detail_button，detail_related
    //    14.has_associate：是否为虚拟号码：是：1，否：0
    //    15.is_dial ：是否为为拨号键盘：是：1，否：0
    NSMutableDictionary *params = @{}.mutableCopy;
    [params addEntriesFromDictionary:[self baseParams]];
    params[@"page_type"] = @"realtor_detail";
    params[@"page_type"] = @"left_pic";
    if (extraDict[@"card_type"]) {
        params[@"card_type"] = extraDict[@"card_type"];
    }
    if (extraDict[@"enter_from"]) {
        params[@"enter_from"] = extraDict[@"enter_from"];
    }
    if (extraDict[@"element_from"]) {
        params[@"element_from"] = extraDict[@"element_from"];
    }
    if (extraDict[@"rank"]) {
        params[@"rank"] = extraDict[@"rank"];
    }
    if (extraDict[@"origin_from"]) {
        params[@"origin_from"] = extraDict[@"origin_from"];
    }
    if (extraDict[@"origin_search_id"]) {
        params[@"origin_search_id"] = extraDict[@"origin_search_id"];
    }
    if (extraDict[@"log_pb"]) {
        params[@"log_pb"] = extraDict[@"log_pb"];
    }
    params[@"has_auth"] = @(1);
    params[@"realtor_id"] = extraDict[@"realtor_id"] ? : @"be_null";
    params[@"realtor_rank"] = extraDict[@"realtor_rank"] ? : @(0);
    params[@"realtor_position"] = extraDict[@"realtor_position"] ? : @"detail_button";
    params[@"has_associate"] = [NSNumber numberWithInteger:isVirtual];
    params[@"is_dial"] = @(1);
    [FHUserTracker writeEvent:@"click_call" params:params];
}

// 表单展示
- (void)addInformShowLog
{
//    1. event_type：house_app2c_v2
//    2. page_type（页面类型）：old_detail（二手房详情页），rent_detail（租房详情页）
//    3. card_type ：left_pic（左图）
//    4. enter_from ：search_related_list（搜索结果推荐）
//    5. element_from ：search_related
//    6. rank
//    7. origin_from
//    8. origin_search_id
//    9.log_pb
    NSMutableDictionary *params = @{}.mutableCopy;
    [params addEntriesFromDictionary:[self baseParams]];
    [FHUserTracker writeEvent:@"inform_show" params:params];
}

// 表单提交
- (void)addClickConfirmLog
{
    NSMutableDictionary *params = @{}.mutableCopy;
    [params addEntriesFromDictionary:[self baseParams]];
    [FHUserTracker writeEvent:@"click_confirm" params:params];
}



@end
