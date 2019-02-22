//
//  FHHouseDetailContactViewModel.m
//  Pods
//
//  Created by 张静 on 2019/2/13.
//

#import "FHHouseDetailContactViewModel.h"
#import "TTRoute.h"
#import "TTShareManager.h"
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TTActivityContentItemProtocol.h>
#import <TTWechatTimelineContentItem.h>
#import <TTWechatContentItem.h>
#import <TTQQFriendContentItem.h>
#import <TTQQZoneContentItem.h>
#import "BDWebImage.h"
#import "TTPhotoScrollViewController.h"
#import "FHURLSettings.h"
#import <FHHouseBase/FHRealtorDetailWebViewControllerDelegate.h>
#import <TTWechatTimelineActivity.h>
#import <TTWechatActivity.h>
#import <TTQQFriendActivity.h>
#import <TTQQZoneActivity.h>
#import "FHHouseDetailAPI.h"
#import "TTReachability.h"
#import "FHHouseDetailFollowUpViewModel.h"
#import "FHHouseDetailPhoneCallViewModel.h"
#import "NSDictionary+TTAdditions.h"
#import "FHDetailNoticeAlertView.h"
#import "YYCache.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "ToastManager.h"
#import "IMManager.h"

NSString *const kFHPhoneNumberCacheKey = @"phonenumber";

extern NSString *const kFHToastCountKey;
@interface FHHouseDetailContactViewModel () <TTShareManagerDelegate, FHRealtorDetailWebViewControllerDelegate>

@property (nonatomic, weak) FHDetailNavBar *navBar;
@property (nonatomic, weak) UILabel *bottomStatusBar;
@property (nonatomic, weak) FHDetailBottomBarView *bottomBar;
@property (nonatomic, strong) TTShareManager *shareManager;
@property (nonatomic, strong)FHHouseDetailFollowUpViewModel *followUpViewModel;
@property (nonatomic, strong)FHHouseDetailPhoneCallViewModel *phoneCallViewModel;
@property(nonatomic , strong) YYCache *sendPhoneNumberCache;
@property(nonatomic , weak) FHDetailNoticeAlertView *alertView;

@end

@implementation FHHouseDetailContactViewModel

-(instancetype)initWithNavBar:(FHDetailNavBar *)navBar bottomBar:(FHDetailBottomBarView *)bottomBar
{
    self = [super init];
    if (self) {
        
        _followUpViewModel = [[FHHouseDetailFollowUpViewModel alloc]init];
        _phoneCallViewModel = [[FHHouseDetailPhoneCallViewModel alloc]init];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshFollowStatus:) name:kFHDetailFollowUpNotification object:nil];
        
        _navBar = navBar;
        _bottomBar = bottomBar;
        
        __weak typeof(self)wself = self;
        _bottomBar.bottomBarContactBlock = ^{
            [wself contactAction];
        };
        _bottomBar.bottomBarLicenseBlock = ^{
            [wself licenseAction];
        };
        _bottomBar.bottomBarRealtorBlock = ^{
            [wself jump2RealtorDetail];
        };
        
        _bottomBar.bottomBarImBlock = ^{
            [wself imAction];
        };
 
        _navBar.collectActionBlock = ^(BOOL followStatus){
            if (!followStatus) {
                
                [wself followAction];
            }else {
                [wself cancelFollowAction];
            }
        };
        _navBar.shareActionBlock = ^{
            [wself shareAction];
        };
        _navBar.messageActionBlock = ^{
            NSString *messageSchema = @"sslocal://message_conversation_list";
            NSURL *openUrl = [NSURL URLWithString:messageSchema];
            [[TTRoute sharedRoute] openURLByPushViewController:openUrl];
        };
        if ([[IMManager shareInstance] getChatMessageUnreadTotalCount] > 0) {
            [_navBar displayMessageDot:YES];
        } else {
            [_navBar displayMessageDot:NO];
        }
    }
    return self;
}

- (void)refreshFollowStatus:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    NSString *followId = [userInfo tt_stringValueForKey:@"followId"];
    BOOL followStatus = [userInfo tt_boolValueForKey:@"followStatus"];
    if (![followId isEqualToString:self.houseId]) {
        return;
    }
    [self.navBar setFollowStatus:followStatus];

}
- (void)setFollowStatus:(BOOL)followStatus
{
    _followStatus = followStatus;
    [self.navBar setFollowStatus:followStatus];
}

- (void)followAction
{
    [self.followUpViewModel followHouseByFollowId:self.houseId houseType:self.houseType actionType:self.houseType];
}

- (void)cancelFollowAction
{
    [self.followUpViewModel cancelFollowHouseByFollowId:self.houseId houseType:self.houseType actionType:self.houseType];
}

- (void)shareAction
{
    
//    var logPB = self.detailPageViewModel?.logPB ?? "be_null"
//    logPB = self.logPB ?? logPB
//    var params = EnvContext.shared.homePageParams <|>
//    self.traceParams <|>
//    toTracerParams("left_pic", key: "card_type") <|>
//    toTracerParams(enterFromByHouseType(houseType: houseType), key: "page_type") <|>
//    toTracerParams(self.logPB ?? logPB, key: "log_pb")
//
//    params = params
//    .exclude("filter")
//    .exclude("icon_type")
//    .exclude("maintab_search")
//    .exclude("search")
//    recordEvent(key: "click_share", params: params)
//    shareParams = params
    
    if (!self.shareInfo) {
        return;
    }
    UIImage *shareImage = [[BDImageCache sharedImageCache]imageFromDiskCacheForKey:self.shareInfo.coverImage] ? : [UIImage imageNamed:@"default_image"];
    NSString *title = self.shareInfo.title ? : @"";
    NSString *desc = self.shareInfo.desc ? : @"";
    NSString *webPageUrl = self.shareInfo.shareUrl ? : @"";

    NSMutableArray *shareContentItems = @[].mutableCopy;
    TTWechatContentItem *wechatItem = [[TTWechatContentItem alloc] initWithTitle:title desc:desc webPageUrl:webPageUrl thumbImage:shareImage shareType:TTShareWebPage];
    [shareContentItems addObject:wechatItem];
    TTWechatTimelineContentItem *timeLineItem = [[TTWechatTimelineContentItem alloc] initWithTitle:title desc:desc webPageUrl:webPageUrl thumbImage:shareImage shareType:TTShareWebPage];
    [shareContentItems addObject:timeLineItem];

    // 大师说PM说微信不用判断
    if ([QQApiInterface isQQInstalled] && [QQApiInterface isQQSupportApi]) {

        TTQQFriendContentItem *qqFriendItem = [[TTQQFriendContentItem alloc] initWithTitle:title desc:desc webPageUrl:webPageUrl thumbImage:shareImage imageUrl:@"" shareTye:TTShareWebPage];
        [shareContentItems addObject:qqFriendItem];
        TTQQZoneContentItem *qqZoneItem = [[TTQQZoneContentItem alloc] initWithTitle:title desc:desc webPageUrl:webPageUrl thumbImage:shareImage imageUrl:@"" shareTye:TTShareWebPage];
        [shareContentItems addObject:qqZoneItem];
    }
    [self.shareManager displayActivitySheetWithContent:shareContentItems];
}

- (void)setContactPhone:(FHDetailContactModel *)contactPhone
{
    _contactPhone = contactPhone;
    NSString *contactTitle = @"电话咨询";
    if (contactPhone.phone.length < 1) {
        if (self.houseType == FHHouseTypeNeighborhood) {
            contactTitle = @"咨询经纪人";
        }else {
            contactTitle = @"询底价";
        }
    }
//    contactPhone.imOpenUrl = @"sslocal://open_single_chat?target_user_id=67597534620&chat_title=谷春晖&house_cover=https://p3.pstatp.com/large/f100-image/R41qHUI3GYuu6B_1Xia0z1&house_type=1&house_title=4室2厅 刘湾小区刘湾小区…&house_des=70平/南北/高层/刘湾小区&house_price=170万&house_avg_price=5000/平&house_id=1231231";
//    contactPhone.agencyName = @"北京我爱我家";
//    contactPhone.showRealtorinfo = 1;
    [self.bottomBar refreshBottomBar:contactPhone contactTitle:contactTitle];
}

- (void)contactAction
{
    if (self.contactPhone.phone.length < 1) {
        // 填表单
        [self fillFormAction];
    }else {
        // 拨打电话
        [self callAction];
    }
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

- (void)callAction
{
    __weak typeof(self)wself = self;
    if (![TTReachability isNetworkConnected]) {
        
        NSString *urlStr = [NSString stringWithFormat:@"tel://%@", wself.contactPhone.phone];
        [self callPhone:urlStr];
        return;
    }
    [self.bottomBar startLoading];
    [FHHouseDetailAPI requestVirtualNumber:self.contactPhone.phone houseId:self.houseId houseType:self.houseType searchId:self.searchId imprId:self.imprId completion:^(FHDetailVirtualNumResponseModel * _Nullable model, NSError * _Nullable error) {
        
        [wself.bottomBar stopLoading];
        NSString *urlStr = [NSString stringWithFormat:@"tel://%@", wself.contactPhone.phone];
        if (!error && model.data.virtualNumber.length > 0) {
            urlStr = [NSString stringWithFormat:@"tel://%@", model.data.virtualNumber];
        }
        [wself callPhone:urlStr];
    }];
    // 静默关注功能
    [self.followUpViewModel silentFollowHouseByFollowId:self.houseId houseType:self.houseType actionType:self.houseType showTip:NO];
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

- (void)licenseAction
{
    // add by zjing for test 缺少title
    NSMutableArray *images = @[].mutableCopy;
    // "营业执照"
    if (self.contactPhone.businessLicense.length > 0) {
        TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithURL:self.contactPhone.businessLicense];
        model.imageType = TTImageTypeLarge;
        if (model) {
            [images addObject:model];
        }
    }
    // "从业人员信息卡"
    if (self.contactPhone.certificate.length > 0) {
        TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithURL:self.contactPhone.certificate];
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


- (void)jump2RealtorDetail
{
    if (self.contactPhone.realtorId.length < 1) {
        return;
    }
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSURL *openUrl = [NSURL URLWithString:@"sslocal://realtor_detail"];
    // add by zjing for test 埋点参数
    NSString *reportParams;
    NSString *jumpUrl = [NSString stringWithFormat:@"%@/f100/client/realtor_detail?realtor_id=%@&report_params=%@",host,self.contactPhone.realtorId,reportParams];
    NSMutableDictionary *info = @{}.mutableCopy;
    info[@"url"] = jumpUrl;
    info[@"title"] = @"经纪人详情页";
    info[@"realtorId"] = self.contactPhone.realtorId;
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

- (void)imAction {
    NSString *utfUrl = [_contactPhone.imOpenUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *openUrl = [NSURL URLWithString:utfUrl];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
}

#pragma mark TTShareManagerDelegate
- (void)shareManager:(TTShareManager *)shareManager clickedWith:(id<TTActivityProtocol>)activity sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
{
    NSString *platform = @"be_null";
    if ([activity isKindOfClass:[TTWechatTimelineActivity class]]) {
        platform = @"weixin_moments";
    }else if ([activity isKindOfClass:[TTWechatActivity class]]) {
        platform = @"weixin";
    }else if ([activity isKindOfClass:[TTQQFriendActivity class]]) {
        platform = @"qq";
    }else if ([activity isKindOfClass:[TTQQZoneActivity class]]) {
        platform = @"qzone";
    }
//    if let shareParams = shareParams {
//        recordEvent(key: "share_platform", params: shareParams <|> toTracerParams(platform, key: "platform"))
//    }
}

- (void)shareManager:(TTShareManager *)shareManager completedWith:(id<TTActivityProtocol>)activity sharePanel:(id<TTActivityPanelControllerProtocol>)panelController error:(NSError *)error desc:(NSString *)desc
{
    
}

- (TTShareManager *)shareManager
{
    if (!_shareManager) {
        _shareManager = [[TTShareManager alloc]init];
    }
    return _shareManager;
}

- (YYCache *)sendPhoneNumberCache
{
    if (!_sendPhoneNumberCache) {
        _sendPhoneNumberCache = [[YYCache alloc]initWithName:@"phonenumber"];
    }
    return _sendPhoneNumberCache;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
