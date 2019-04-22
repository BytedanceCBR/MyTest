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
#import "TTAccount.h"
#import "TTTracker.h"
#import <FHHouseBase/FHUserTracker.h>
#import <FHHouseBase/FHGeneralBizConfig.h>
#import <FHHouseBase/FHEnvContext.h>
#import "IMManager.h"
#import <HMDTTMonitor.h>
#import <FHUtils.h>
#import <NSDictionary+TTAdditions.h>

extern NSString *const kFHToastCountKey;
extern NSString *const kFHPhoneNumberCacheKey;

typedef enum : NSUInteger {
    FHPhoneCallTypeSuccessVirtual = 0,
    FHPhoneCallTypeSuccessReal,
    FHPhoneCallTypeNetFailed,
    FHPhoneCallTypeRequestFailed,
} FHPhoneCallType;


@implementation FHHouseDetailFormAlertModel

@end


@interface FHHouseDetailPhoneCallViewModel () <FHRealtorDetailWebViewControllerDelegate>

@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, copy) NSString *houseId;
@property (nonatomic, weak) FHDetailNoticeAlertView *alertView;
@property (nonatomic, strong) NSMutableDictionary *imParams; //用于IM跟前端交互的字段
@property (nonatomic, strong) TTRouteObject *routeAgentObj; //预加载经纪人详情页

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

- (void)fillFormActionWithCustomHouseId:(NSString *)customHouseId fromStr:(NSString *)fromStr withExtraDict:(NSDictionary *)extraDict
{
    NSString *title = @"询底价";
    NSString *subtitle = @"提交后将安排专业经纪人与您联系";
    NSString *btnTitle = @"获取底价";
    if (self.houseType == FHHouseTypeNeighborhood) {
        title = @"咨询经纪人";
        btnTitle = @"提交";
    }
    [self fillFormActionWithTitle:title subtitle:subtitle btnTitle:btnTitle customHouseId:customHouseId fromStr:fromStr withExtraDict:extraDict];
}

- (void)fillFormActionWithTitle:(NSString *)title subtitle:(NSString *)subtitle btnTitle:(NSString *)btnTitle withExtraDict:(NSDictionary *)extraDict
{
    [self fillFormActionWithTitle:title subtitle:subtitle btnTitle:btnTitle customHouseId:nil fromStr:nil withExtraDict:extraDict];
}

- (void)fillFormAction:(FHHouseDetailFormAlertModel *)alertModel contactPhone:(FHDetailContactModel *)contactPhone customHouseId:(NSString *)customHouseId fromStr:(NSString *)fromStr withExtraDict:(NSDictionary *)extraDict
{
    NSString *title = alertModel.title ? : @"询底价";
    NSString *subtitle = alertModel.subtitle ? : @"提交后将安排专业经纪人与您联系";
    NSString *btnTitle = alertModel.btnTitle ? : @"获取底价";
    NSString *leftBtnTitle = alertModel.leftBtnTitle;

    __weak typeof(self)wself = self;
    FHDetailNoticeAlertView *alertView = nil;
    if (leftBtnTitle.length > 0) {
        [self addReservationShowLog];
        alertView = [[FHDetailNoticeAlertView alloc]initWithTitle:title subtitle:subtitle btnTitle:btnTitle leftBtnTitle:leftBtnTitle];
        alertView.confirmClickBlock = ^(NSString *phoneNum){
            NSMutableDictionary *params = @{}.mutableCopy;
            if (extraDict) {
                [params addEntriesFromDictionary:extraDict];
                params[@"show_loading"] = @(NO);
            }
            [wself callWithPhone:contactPhone.phone realtorId:contactPhone.realtorId searchId:contactPhone.searchId imprId:contactPhone.imprId extraDict:params];
            [wself.alertView dismiss];
        };
        alertView.leftClickBlock = ^(NSString * _Nonnull phoneNum) {
            [wself fillFormRequest:phoneNum customHouseId:customHouseId fromStr:fromStr];
            [wself addClickConfirmLogWithExtra:extraDict];
        };
    }else {
        [self addInformShowLog];
        alertView = [[FHDetailNoticeAlertView alloc]initWithTitle:title subtitle:subtitle btnTitle:btnTitle];
        alertView.confirmClickBlock = ^(NSString *phoneNum){
            [wself fillFormRequest:phoneNum customHouseId:customHouseId fromStr:fromStr];
            [wself addClickConfirmLogWithExtra:extraDict];
        };
    }
    YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
    alertView.phoneNum = [sendPhoneNumberCache objectForKey:kFHPhoneNumberCacheKey];
    alertView.tipClickBlock = ^{
        
        NSString *privateUrlStr = [NSString stringWithFormat:@"%@/f100/client/user_privacy&title=个人信息保护声明&hide_more=1",[FHURLSettings baseURL]];
        NSString *urlStr = [privateUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fschema://webview?url=%@",urlStr]];
        [[TTRoute sharedRoute]openURLByPushViewController:url];
    };
    [alertView showFrom:self.belongsVC.view];
    self.alertView = alertView;
    
}

- (void)fillFormActionWithTitle:(NSString *)title subtitle:(NSString *)subtitle btnTitle:(NSString *)btnTitle customHouseId:(NSString *)customHouseId fromStr:(NSString *)fromStr withExtraDict:(NSDictionary *)extraDict
{
    FHHouseDetailFormAlertModel *alertModel = [[FHHouseDetailFormAlertModel alloc]init];
    alertModel.title = title;
    alertModel.subtitle = subtitle;
    alertModel.btnTitle = btnTitle;

    [self fillFormAction:alertModel contactPhone:nil customHouseId:customHouseId fromStr:fromStr withExtraDict:extraDict];
}
- (void)addDetailCallExceptionLog:(NSInteger)status realtorId:(NSString *)realtorId errorCode:(NSInteger)errorCode message:(NSString *)message
{
    NSMutableDictionary *attr = @{}.mutableCopy;
    if (status != FHPhoneCallTypeSuccessVirtual && status != FHPhoneCallTypeSuccessReal) {
        attr[@"realtor_id"] = realtorId;
        attr[@"house_id"] = self.houseId;
    }
    if (status == FHPhoneCallTypeRequestFailed) {
        attr[@"error_code"] = @(errorCode);
        attr[@"message"] = message;
    }
    attr[@"desc"] = [self exceptionStatusStrBy:status];
    [[HMDTTMonitor defaultManager]hmdTrackService:@"detail_call_exception" status:status extra:attr];
}

- (NSString *)exceptionStatusStrBy:(NSInteger)status
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

- (void)callWithPhone:(NSString *)phone realtorId:(NSString *)realtorId searchId:(NSString *)searchId imprId:(NSString *)imprId extraDict:(NSDictionary *)extraDict
{
    __weak typeof(self)wself = self;
    if (![TTReachability isNetworkConnected]) {
        
        NSString *urlStr = [NSString stringWithFormat:@"tel://%@", phone];
        [self callPhone:urlStr];
        [self addClickCallLogWithExtra:extraDict isVirtual:0];
        [self addDetailCallExceptionLog:FHPhoneCallTypeNetFailed realtorId:realtorId errorCode:0 message:nil];
        return;
    }
    BOOL showLoading = YES;
    if (extraDict[@"show_loading"]) {
        showLoading = [extraDict[@"show_loading"]boolValue];
    }
    if (showLoading) {
        [self.bottomBar startLoading];
    }
    [FHHouseDetailAPI requestVirtualNumber:realtorId houseId:self.houseId houseType:self.houseType searchId:searchId imprId:imprId completion:^(FHDetailVirtualNumResponseModel * _Nullable model, NSError * _Nullable error) {
        
        if (showLoading) {
            [wself.bottomBar stopLoading];
        }
        NSString *urlStr = [NSString stringWithFormat:@"tel://%@", phone];
        NSInteger isVirtual = model.data.isVirtual;
        if (!error && model.data.virtualNumber.length > 0) {
            urlStr = [NSString stringWithFormat:@"tel://%@", model.data.virtualNumber];
            if (model.data.isVirtual) {
                [wself addDetailCallExceptionLog:FHPhoneCallTypeSuccessVirtual realtorId:realtorId errorCode:0 message:nil];
            }else {
                [wself addDetailCallExceptionLog:FHPhoneCallTypeSuccessReal realtorId:realtorId errorCode:0 message:nil];
            }
        }else {
            [wself addDetailCallExceptionLog:FHPhoneCallTypeRequestFailed realtorId:realtorId errorCode:error.code message:model.message ? : error.localizedDescription];
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
        [self addRealtorClickCallLogWithExtra:reportParams isVirtual:0];
        NSError *error = [[NSError alloc]initWithDomain:NSURLErrorDomain code:-1 userInfo:nil];
        failBlock(error);
        [self addDetailCallExceptionLog:FHPhoneCallTypeNetFailed realtorId:realtorId errorCode:0 message:nil];
        return;
    }
    
    [self.bottomBar startLoading];
    [FHHouseDetailAPI requestVirtualNumber:realtorId houseId:self.houseId houseType:self.houseType searchId:searchId imprId:imprId completion:^(FHDetailVirtualNumResponseModel * _Nullable model, NSError * _Nullable error) {
        
        [wself.bottomBar stopLoading];
        NSString *urlStr = [NSString stringWithFormat:@"tel://%@", phone];
        NSInteger isVirtual = model.data.isVirtual;
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
            if (model.data.isVirtual) {
                [wself addDetailCallExceptionLog:FHPhoneCallTypeSuccessVirtual realtorId:realtorId errorCode:0 message:nil];
            }else {
                [wself addDetailCallExceptionLog:FHPhoneCallTypeSuccessReal realtorId:realtorId errorCode:0 message:nil];
            }
        }else {
            failBlock(error);
            [wself addDetailCallExceptionLog:FHPhoneCallTypeRequestFailed realtorId:realtorId errorCode:error.code message:model.message ? : error.localizedDescription];
        }
        [wself callPhone:urlStr];
        successBlock(YES);
    }];
    
}

- (void)imchatActionWithPhone:(FHDetailContactModel *)contactPhone realtorRank:(NSString *)rank position:(NSString *)position {
    
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"event_type"] = @"house_app2c_v2";
    dict[@"enter_from"] = self.tracerDict[@"enter_from"] ? : @"be_null";
    dict[@"element_from"] = self.tracerDict[@"element_from"] ? : @"be_null";
    dict[@"origin_from"] = self.tracerDict[@"origin_from"] ? : @"be_null";
    dict[@"log_pb"] = self.tracerDict[@"log_pb"];
    dict[@"search_id"] = self.tracerDict[@"search_id"] ? : @"be_null";
    dict[@"origin_search_id"] = self.tracerDict[@"origin_search_id"] ? : @"be_null";
    dict[@"group_id"] = self.tracerDict[@"group_id"] ? : @"be_null";
    dict[@"rank"] = self.tracerDict[@"rank"] ? : @"be_null";
    dict[@"card_type"] = self.tracerDict[@"card_type"] ? : @"be_null";
    if ([self.tracerDict[@"log_pb"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *logPbDict = self.tracerDict[@"log_pb"];
        dict[@"impr_id"] = logPbDict[@"impr_id"] ? : @"be_null";
        dict[@"search_id"] = logPbDict[@"search_id"] ? : @"be_null";
        dict[@"group_id"] = logPbDict[@"group_id"] ? : @"be_null";
    }
    dict[@"page_type"] = self.tracerDict[@"page_type"] ?: @"be_null";
    dict[@"is_login"] = [[TTAccount sharedAccount] isLogin] ? @"1" : @"0";
    dict[@"realtor_id"] = contactPhone.realtorId;
    dict[@"realtor_rank"] = rank ?: @"0";
    dict[@"realtor_position"] = position ?: @"detail_button";
    dict[@"conversation_id"] = @"be_null";
    
    [TTTracker eventV3:@"click_im" params:dict];
    
    NSURL *openUrl = [NSURL URLWithString:contactPhone.imOpenUrl];
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:@{@"tracer":dict}];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
}

- (void)generateImParams:(NSString *)houseId houseTitle:(NSString *)houseTitle houseCover:(NSString *)houseCover houseType:(NSString *)houseType houseDes:(NSString *)houseDes housePrice:(NSString *)housePrice houseAvgPrice:(NSString *)houseAvgPrice {
    if (houseTitle.length > 20) {
        houseTitle = [houseTitle substringToIndex:20];
    }
    if (houseDes.length > 20) {
        houseDes = [houseDes substringToIndex:20];
    }
    _imParams = [NSMutableDictionary dictionary];
    [_imParams setValue:houseId forKey:@"house_id"];
    [_imParams setValue:houseTitle forKey:@"house_title"];
    [_imParams setValue:houseDes forKey:@"house_des"];
    [_imParams setValue:houseCover forKey:@"house_cover"];
    [_imParams setValue:housePrice forKey:@"house_price"];
    [_imParams setValue:houseAvgPrice forKey:@"house_avg_price"];
    [_imParams setValue:houseType forKey:@"house_type"];
}

- (void)fillFormRequest:(NSString *)phoneNum customHouseId:(NSString *)customHouseId fromStr:(NSString *)fromStr
{
    __weak typeof(self)wself = self;
    if (![TTReachability isNetworkConnected]) {
        
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    NSString *houseId = customHouseId.length > 0 ? customHouseId : self.houseId;
    NSString *from = fromStr.length > 0 ? fromStr : [self fromStrByHouseType:self.houseType];
    [FHHouseDetailAPI requestSendPhoneNumbserByHouseId:houseId phone:phoneNum from:from completion:^(FHDetailResponseModel * _Nullable model, NSError * _Nullable error) {
        
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


- (void)jump2RealtorDetailWithPhone:(FHDetailContactModel *)contactPhone isPreLoad:(BOOL)isPre
{
    
    if ([FHHouseDetailPhoneCallViewModel isEnableCurrentChannel]) {
        if (isPre) {
            if ([self.routeAgentObj.instance isKindOfClass:[UIViewController class]]) {
                [self.belongsVC.navigationController pushViewController:self.routeAgentObj.instance animated:YES];
            }else
            {
                TTRouteObject *routeObj = [self creatJump2RealtorDetailWithPhone:contactPhone isPreLoad:NO andIsOpen:NO];
                if ([routeObj.instance isKindOfClass:[UIViewController class]]) {
                    [self.belongsVC.navigationController pushViewController:routeObj.instance animated:YES];
                }
            }
        }else
        {
            TTRouteObject *routeObj = [self creatJump2RealtorDetailWithPhone:contactPhone isPreLoad:NO andIsOpen:NO];
            if ([routeObj.instance isKindOfClass:[UIViewController class]]) {
                [self.belongsVC.navigationController pushViewController:routeObj.instance animated:YES];
            }
        }
    }else
    {
        [self creatJump2RealtorDetailWithPhone:contactPhone isPreLoad:NO andIsOpen:YES];
    }
}

- (TTRouteObject *)creatJump2RealtorDetailWithPhone:(FHDetailContactModel *)contactPhone isPreLoad:(BOOL)isPre andIsOpen:(BOOL)isOpen
{
    if (contactPhone.realtorId.length < 1) {
        return nil;
    }
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    //    NSString *host = @"http://10.1.15.29:8889";
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
    dict[@"card_type"] = self.tracerDict[@"card_type"] ? : @"be_null";
    if ([self.tracerDict[@"log_pb"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *logPbDict = self.tracerDict[@"log_pb"];
        dict[@"impr_id"] = logPbDict[@"impr_id"] ? : @"be_null";
        dict[@"search_id"] = logPbDict[@"search_id"] ? : @"be_null";
        dict[@"group_id"] = logPbDict[@"group_id"] ? : @"be_null";
    }
    dict[@"realtor_rank"] = @"be_null";
    dict[@"realtor_position"] = @"be_null";
    dict[@"is_login"] = [[TTAccount sharedAccount] isLogin] ? @"1" : @"0";
    IMConversation* conv = [[[IMManager shareInstance] chatService] conversationWithUserId:contactPhone.realtorId];
    if ([conv.identifier isEqualToString:@"-1"]) {
        dict[@"conversation_id"] = @"be_null";
    } else {
        dict[@"conversation_id"] = conv.identifier ?: @"be_null";
    }


    NSError *parseError = nil;
    NSString *reportParams = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&parseError];
    if (!parseError) {
        reportParams = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    NSMutableDictionary *imdic = [NSMutableDictionary dictionaryWithDictionary:_imParams];
    [imdic setValue:contactPhone.realtorId forKey:@"target_user_id"];
    [imdic setValue:contactPhone.realtorName forKey:@"chat_title"];
    NSString *imParams = nil;
    NSError *imParseError = nil;
    NSData *imJsonData = [NSJSONSerialization dataWithJSONObject:imdic options:0 error:&imParseError];
    if (!imParseError) {
        imParams = [[NSString alloc] initWithData:imJsonData encoding:NSUTF8StringEncoding];
    }
    NSString *realtorDeUrl = contactPhone.realtorDetailUrl;
    //    realtorDeUrl = [realtorDeUrl stringByReplacingOccurrencesOfString:@"https://i.haoduofangs.com" withString:@"http://10.1.15.29:8889"];
    NSString *jumpUrl =@"";

    if (isEmptyString(realtorDeUrl)) {
        jumpUrl = [NSString stringWithFormat:@"%@?realtor_id=%@&report_params=%@&im_params=%@",host,contactPhone.realtorId,reportParams ? : @"", imParams ?: @""];
    } else {
        jumpUrl = [NSString stringWithFormat:@"%@&report_params=%@",realtorDeUrl,reportParams ? : @""];
    }
    //    jumpUrl = [NSString stringWithFormat:@"%@/f100/client/realtor_detail?realtor_id=%@&report_params=%@&im_params=%@",host,contactPhone.realtorId,reportParams ? : @"", imParams ?: @""];
    NSMutableDictionary *info = @{}.mutableCopy;
    info[@"url"] = jumpUrl;
    info[@"title"] = @"经纪人主页";
    info[@"realtor_id"] = contactPhone.realtorId;
    info[@"delegate"] = self;
    info[@"trace"] = self.tracerDict;
    info[@"house_id"] = _houseId;
    info[@"house_type"] = @(_houseType);


    if (isOpen) {
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc]initWithInfo:info];
        [[TTRoute sharedRoute]openURLByViewController:openUrl userInfo:userInfo];
        return nil;
    }else
    {
        NSURL *openUrlRn = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://react?module_name=FHRNAgentDetailModule_home&realtorId=%@&can_multi_preload=%ld&channelName=f_realtor_detail&debug=0&report_params=%@&im_params=%@&bundle_name=%@",contactPhone.realtorId,isPre ? 1 : 0,[FHUtils getJsonStrFrom:_tracerDict],[FHUtils getJsonStrFrom:imdic],@"agent_detail.bundle"]];
        
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc]initWithInfo:info];
        //    [[TTRoute sharedRoute]openURLByViewController:openUrlRn userInfo:userInfo];
        //
        TTRouteObject *routeObj = [[TTRoute sharedRoute] routeObjWithOpenURL:openUrlRn userInfo:userInfo];
        if (isPre) {
            self.routeAgentObj = routeObj;
            return nil;
        }else
        {
            return routeObj;
        }
    }

}


- (void)destoryRNPreloadCache
{
    if ([self.routeAgentObj.instance respondsToSelector:@selector(destroyRNView)]) {
        [self.routeAgentObj.instance performSelector:@selector(destroyRNView) withObject:nil];
    }
    self.routeAgentObj.instance = nil;
    self.routeAgentObj = nil;
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
- (void)addClickCallLogWithExtra:(NSDictionary *)extraDict isVirtual:(NSInteger)isVirtual
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
    params[@"conversation_id"] = @"be_null";
    [FHUserTracker writeEvent:@"click_call" params:params];
}

- (void)addRealtorClickCallLogWithExtra:(NSDictionary *)extraDict isVirtual:(NSInteger)isVirtual
{
    //    11.realtor_id
    //    12.realtor_rank:经纪人推荐位置，从0开始，底部button的默认为0
    //    13.realtor_position ：detail_button，detail_related
    //    14.has_associate：是否为虚拟号码：是：1，否：0
    //    15.is_dial ：是否为为拨号键盘：是：1，否：0
    NSMutableDictionary *params = @{}.mutableCopy;
    [params addEntriesFromDictionary:[self baseParams]];
    params[@"page_type"] = @"realtor_detail";
    params[@"card_type"] = @"left_pic";
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
    params[@"conversation_id"] = @"be_null";
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

// 表单展示
- (void)addReservationShowLog
{
//    1. event_type：house_app2c_v2
//    2. page_type：old_detail（二手房详情页），rent_detail（租房详情页）
//    3. card_type
//    4. enter_from
//    5. element_from
//    6. rank
//    7. origin_from
//    8. origin_search_id
//    9.log_pb
//    10.position:通过在线联系点击立即预约：online
    NSMutableDictionary *params = @{}.mutableCopy;
    [params addEntriesFromDictionary:[self baseParams]];
    params[@"position"] = @"online";
    [FHUserTracker writeEvent:@"reservation_show" params:params];
}


// 表单提交
- (void)addClickConfirmLogWithExtra:(NSDictionary *)extraDict
{
    NSMutableDictionary *params = @{}.mutableCopy;
    [params addEntriesFromDictionary:[self baseParams]];
    if (extraDict && [extraDict isKindOfClass:[NSDictionary class]]) {
        params[@"position"] = extraDict[@"position"] ? : @"button";
    } else {
        params[@"position"] = @"button";
    }
    [FHUserTracker writeEvent:@"click_confirm" params:params];
}

#pragma mark 判读setting

+ (BOOL)isPreLoadCurrentChannel
{
    if([FHHouseDetailPhoneCallViewModel fhRNEnableChannels].count > 0 && [FHHouseDetailPhoneCallViewModel fhRNPreLoadChannels].count > 0 && [[FHHouseDetailPhoneCallViewModel fhRNEnableChannels] containsObject:@"f_realtor_detail"] && [[FHHouseDetailPhoneCallViewModel fhRNPreLoadChannels] containsObject:@"f_realtor_detail"])
    {
        return YES;
    }else
    {
        return NO;
    }
}

+ (BOOL)isEnableCurrentChannel
{
    if([FHHouseDetailPhoneCallViewModel fhRNEnableChannels].count > 0 && [[FHHouseDetailPhoneCallViewModel fhRNEnableChannels] containsObject:@"f_realtor_detail"])
    {
        return YES;
    }else
    {
        return NO;
    }
}

+ (NSArray *)fhRNPreLoadChannels
{
    NSDictionary *fhSettings = [self fhSettings];
    NSArray * f_rn_preload_channels = [fhSettings tt_arrayValueForKey:@"f_rn_preload_channels"];
    if ([f_rn_preload_channels isKindOfClass:[NSArray class]]) {
        return f_rn_preload_channels;
    }
    return @[];
}

+ (NSArray *)fhRNEnableChannels
{
    NSDictionary *fhSettings = [self fhSettings];
    NSArray * f_rn_enable = [fhSettings tt_arrayValueForKey:@"f_rn_enable"];
    if ([f_rn_enable isKindOfClass:[NSArray class]]) {
        return f_rn_enable;
    }
    return @[];
}

+ (NSDictionary *)fhSettings {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kFHSettingsKey"]){
        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kFHSettingsKey"];
    } else {
        return nil;
    }
}


- (void)dealloc
{
    NSLog(@"phonecall model dealloc");
}

@end
