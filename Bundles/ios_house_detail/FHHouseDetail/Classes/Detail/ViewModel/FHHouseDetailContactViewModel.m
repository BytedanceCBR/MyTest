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

@interface FHHouseDetailContactViewModel () <TTShareManagerDelegate, FHRealtorDetailWebViewControllerDelegate>

@property (nonatomic, weak) FHDetailNavBar *navBar;
@property (nonatomic, weak) UILabel *bottomStatusBar;
@property (nonatomic, weak) FHDetailBottomBarView *bottomBar;

@property (nonatomic, strong) TTShareManager *shareManager;
@property (nonatomic, strong)FHHouseDetailFollowUpViewModel *followUpViewModel;
@property (nonatomic, strong)FHHouseDetailPhoneCallViewModel *phoneCallViewModel;

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
    
    // 静默关注功能
    [self.followUpViewModel silentFollowHouseByFollowId:self.houseId houseType:self.houseType actionType:self.houseType showTip:YES];
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
