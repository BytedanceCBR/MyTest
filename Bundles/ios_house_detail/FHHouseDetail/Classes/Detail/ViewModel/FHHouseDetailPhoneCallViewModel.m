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

extern NSString *const kFHToastCountKey;
extern NSString *const kFHPhoneNumberCacheKey;

@interface FHHouseDetailPhoneCallViewModel () <FHRealtorDetailWebViewControllerDelegate>

@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, copy) NSString *houseId;
@property (nonatomic, weak) FHDetailNoticeAlertView *alertView;
@property (nonatomic, strong) NSMutableDictionary *imParams; //用于IM跟前端交互的字段

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

- (void)callWithPhone:(NSString *)phone searchId:(NSString *)searchId imprId:(NSString *)imprId extraDict:(NSDictionary *)extraDict
{
    __weak typeof(self)wself = self;
    if (![TTReachability isNetworkConnected]) {
        
        NSString *urlStr = [NSString stringWithFormat:@"tel://%@", phone];
        [self callPhone:urlStr];
        [self addClickCallLogWithExtra:extraDict isVirtual:NO];
        return;
    }
    [self.bottomBar startLoading];
    [FHHouseDetailAPI requestVirtualNumber:phone houseId:self.houseId houseType:self.houseType searchId:searchId imprId:imprId completion:^(FHDetailVirtualNumResponseModel * _Nullable model, NSError * _Nullable error) {
        
        [wself.bottomBar stopLoading];
        NSString *urlStr = [NSString stringWithFormat:@"tel://%@", phone];
        BOOL isVirtual = NO;
        if (!error && model.data.virtualNumber.length > 0) {
            urlStr = [NSString stringWithFormat:@"tel://%@", model.data.virtualNumber];
            isVirtual = YES;
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

- (void)callWithPhone:(NSString *)phone searchId:(NSString *)searchId imprId:(NSString *)imprId
{
    [self callWithPhone:phone searchId:searchId imprId:imprId extraDict:nil];
}

- (void)callWithPhone:(NSString *)phone searchId:(NSString *)searchId imprId:(NSString *)imprId successBlock:(FHHouseDetailPhoneCallSuccessBlock)successBlock failBlock:(FHHouseDetailPhoneCallFailBlock)failBlock
{
    __weak typeof(self)wself = self;
    if (![TTReachability isNetworkConnected]) {
        
        NSString *urlStr = [NSString stringWithFormat:@"tel://%@", phone];
        [self callPhone:urlStr];
        [self addClickCallLogWithExtra:nil isVirtual:NO];
        // add by zjing for test 返回什么错误呢？
        NSError *error = [[NSError alloc]initWithDomain:NSURLErrorDomain code:-1 userInfo:nil];
        failBlock(error);
        return;
    }
    [self.bottomBar startLoading];
    [FHHouseDetailAPI requestVirtualNumber:phone houseId:self.houseId houseType:self.houseType searchId:searchId imprId:imprId completion:^(FHDetailVirtualNumResponseModel * _Nullable model, NSError * _Nullable error) {
        
        [wself.bottomBar stopLoading];
        NSString *urlStr = [NSString stringWithFormat:@"tel://%@", phone];
        BOOL isVirtual = NO;
        if (!error && model.data.virtualNumber.length > 0) {
            urlStr = [NSString stringWithFormat:@"tel://%@", model.data.virtualNumber];
            NSMutableDictionary *extra = @{}.mutableCopy;
            if (model.data.realtorId.length > 0) {
                extra[@"realtor_id"] = model.data.realtorId;
            }
            [wself addClickCallLogWithExtra:extra isVirtual:isVirtual];
        }else {
            failBlock(error);
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
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    CGRect frame = [self.bottomBar convertRect:self.bottomBar.bounds toView:window];
    NSMutableArray *frames = [[NSMutableArray alloc] initWithCapacity:index+1];
    NSMutableArray *placeholders = [[NSMutableArray alloc] initWithCapacity:images.count];
    for (NSInteger i = 0 ; i < images.count ; i++) {
        [frames addObject:[NSNull null]];
    }
    for (NSInteger i = 0 ; i < images.count; i++) {
        [placeholders addObject:placeholder];
    }
    
    NSValue *frameValue = [NSValue valueWithCGRect:frame];
    [frames addObject:frameValue];
    vc.placeholderSourceViewFrames = frames;
    vc.placeholders = placeholders;
    [vc presentPhotoScrollView];
}


- (void)jump2RealtorDetailWithPhone:(FHDetailContactModel *)contactPhone
{
    if (contactPhone.realtorId.length < 1) {
        return;
    }
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
//    NSString *host = @"http://10.1.15.29:8889";
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://realtor_detail"];
    
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
    dict[@"conversation_id"] = conv.identifier ?: @"be_null";
    
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
    info[@"title"] = @"经纪人详情页";
    info[@"realtorId"] = contactPhone.realtorId;
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
    [self.followUpViewModel followHouseByFollowId:followId houseType:houseType actionType:houseType];
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
