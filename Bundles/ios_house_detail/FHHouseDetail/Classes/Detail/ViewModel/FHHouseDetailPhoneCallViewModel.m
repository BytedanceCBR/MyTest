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

extern NSString *const kFHToastCountKey;
NSString *const kFHPhoneNumberCacheKey = @"phonenumber";

@interface FHHouseDetailPhoneCallViewModel ()

@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, copy) NSString *houseId;
@property(nonatomic , weak) FHDetailNoticeAlertView *alertView;
@property(nonatomic , strong) YYCache *sendPhoneNumberCache;

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
    __weak typeof(self)wself = self;
    FHDetailNoticeAlertView *alertView = [[FHDetailNoticeAlertView alloc]initWithTitle:title subtitle:subtitle btnTitle:btnTitle];
    alertView.phoneNum = [self.sendPhoneNumberCache objectForKey:kFHPhoneNumberCacheKey];
    alertView.confirmClickBlock = ^(NSString *phoneNum){
        [wself fillFormRequest:phoneNum];
    };
    alertView.tipClickBlock = ^{
        
        NSString *privateUrlStr = [NSString stringWithFormat:@"%@/f100/client/user_privacy&title=个人信息保护声明&hide_more=1",[FHURLSettings baseURL]];
        NSString *urlStr = [privateUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"fschema://webview?url=%@",urlStr]];
        [[TTRoute sharedRoute]openURLByPushViewController:url];
    };
    [alertView showFrom:nil];
    self.alertView = alertView;
}

- (void)callWithPhone:(FHDetailContactModel *)contactPhone searchId:(NSString *)searchId imprId:(NSString *)imprId
{
//    _contactPhone = contactPhone;
    __weak typeof(self)wself = self;
    if (![TTReachability isNetworkConnected]) {
        
        NSString *urlStr = [NSString stringWithFormat:@"tel://%@", contactPhone.phone];
        [self callPhone:urlStr];
        return;
    }
    [self.bottomBar startLoading];
    [FHHouseDetailAPI requestVirtualNumber:contactPhone.phone houseId:self.houseId houseType:self.houseType searchId:searchId imprId:imprId completion:^(FHDetailVirtualNumResponseModel * _Nullable model, NSError * _Nullable error) {
        
        [wself.bottomBar stopLoading];
        NSString *urlStr = [NSString stringWithFormat:@"tel://%@", contactPhone.phone];
        if (!error && model.data.virtualNumber.length > 0) {
            urlStr = [NSString stringWithFormat:@"tel://%@", model.data.virtualNumber];
        }
        [wself callPhone:urlStr];
    }];
}

- (void)fillFormRequest:(NSString *)phoneNum
{
    __weak typeof(self)wself = self;
    [FHHouseDetailAPI requestSendPhoneNumbserByHouseId:self.houseId phone:phoneNum from:[self fromStrByHouseType:self.houseType] completion:^(FHDetailResponseModel * _Nullable model, NSError * _Nullable error) {
        
        if (model.status.integerValue == 0 && !error) {
            
            [wself.alertView dismiss];
            [wself.sendPhoneNumberCache setObject:phoneNum forKey:kFHPhoneNumberCacheKey];
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
    // add by zjing for test 缺少title
    NSMutableArray *images = @[].mutableCopy;
    // "营业执照"
    if (contactPhone.businessLicense.length > 0) {
        TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithURL:contactPhone.businessLicense];
        model.imageType = TTImageTypeLarge;
        if (model) {
            [images addObject:model];
        }
    }
    // "从业人员信息卡"
    if (contactPhone.certificate.length > 0) {
        TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithURL:contactPhone.certificate];
        model.imageType = TTImageTypeLarge;
        if (model) {
            [images addObject:model];
        }
    }
    if (images.count == 0) {
        return;
    }
    
    TTPhotoScrollViewController *vc = [[TTPhotoScrollViewController alloc] init];
    vc.dragToCloseDisabled = YES;
    vc.mode = PhotosScrollViewSupportBrowse;
    vc.startWithIndex = 0;
    vc.imageInfosModels = images;
    
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
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://realtor_detail"];
    // add by zjing for test 埋点参数
    NSString *reportParams;
    NSString *jumpUrl = [NSString stringWithFormat:@"%@/f100/client/realtor_detail?realtor_id=%@&report_params=%@",host,contactPhone.realtorId,reportParams];
    NSMutableDictionary *info = @{}.mutableCopy;
    info[@"url"] = jumpUrl;
    info[@"title"] = @"经纪人详情页";
    info[@"realtorId"] = contactPhone.realtorId;
    info[@"delegate"] = self;
    //    info[@"trace"] = theTraceModel;
    
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc]initWithInfo:info];
    [[TTRoute sharedRoute]openURLByViewController:openUrl userInfo:userInfo];
    
    //        let traceModel = self.detailPageViewModel?.tracerModel {
    //            traceModel.elementFrom = "old_detail_button"
    //            let reportParams = getRealtorReportParams(traceModel: traceModel, rank: "0")
    //            let theTraceModel = traceModel.copy() as? HouseRentTracer
    //            theTraceModel?.elementFrom = "old_detail_button"
    //            theTraceModel?.enterFrom = "old_detal"
    //            let info: [String: Any] = ["url": jumpUrl,
    //                                       "title": "经纪人详情页",
    //                                       "realtorId": realtorId,
    //                                       "delegate": delegate,
    //                                       "trace": theTraceModel]
    
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

- (YYCache *)sendPhoneNumberCache
{
    if (!_sendPhoneNumberCache) {
        _sendPhoneNumberCache = [[YYCache alloc]initWithName:@"phonenumber"];
    }
    return _sendPhoneNumberCache;
}

@end
