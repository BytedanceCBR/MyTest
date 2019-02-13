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

@interface FHHouseDetailContactViewModel () <TTShareManagerDelegate>

@property (nonatomic, weak) FHDetailNavBar *navBar;
@property (nonatomic, weak) UILabel *bottomStatusBar;
@property (nonatomic, weak) FHDetailBottomBarView *bottomBar;

@property (nonatomic, strong) TTShareManager *shareManager;

@end

@implementation FHHouseDetailContactViewModel

-(instancetype)initWithNavBar:(FHDetailNavBar *)navBar bottomBar:(FHDetailBottomBarView *)bottomBar
{
    self = [super init];
    if (self) {
        
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
 
        _navBar.collectActionBlock = ^{
            [wself collectAction];
        };
        _navBar.shareActionBlock = ^{
            [wself shareAction];
        };
    }
    return self;
}

- (void)collectAction
{

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
    }else {
        // 拨打电话
        NSString *urlStr = [NSString stringWithFormat:@"tel://%@", self.contactPhone.phone];
        NSURL *url = [NSURL URLWithString:urlStr];
        if ([[UIApplication sharedApplication]canOpenURL:url]) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication]openURL:url options:@{} completionHandler:nil];
            } else {
                // Fallback on earlier versions
                [[UIApplication sharedApplication]openURL:url];
            }
        }
    }
    // 关注功能
}

- (void)licenseAction
{
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
//    __weak typeof(self) weakSelf = self;
//    vc.indexUpdatedBlock = ^(NSInteger lastIndex, NSInteger currentIndex) {
//        if (currentIndex >= 0 && currentIndex < weakSelf.images.count) {
//            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:currentIndex + 1 inSection:0];
//            [weakSelf.colletionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
//        }
//    };
    [vc presentPhotoScrollView];
}


- (void)jump2RealtorDetail
{
    
    
//    if let realtorId = contactPhone.realtorId ,
//        let traceModel = self.detailPageViewModel?.tracerModel {
//            traceModel.elementFrom = "old_detail_button"
//            let reportParams = getRealtorReportParams(traceModel: traceModel, rank: "0")
//            let openUrl = "fschema://realtor_detail"
//            let jumpUrl = "\(EnvContext.networkConfig.host)/f100/client/realtor_detail?realtor_id=\(realtorId)&report_params=\(reportParams)"
//            let theTraceModel = traceModel.copy() as? HouseRentTracer
//            theTraceModel?.elementFrom = "old_detail_button"
//            theTraceModel?.enterFrom = "old_detal"
//            let info: [String: Any] = ["url": jumpUrl,
//                                       "title": "经纪人详情页",
//                                       "realtorId": realtorId,
//                                       "delegate": delegate,
//                                       "trace": theTraceModel]
//            let userInfo = TTRouteUserInfo(info: info)
//            TTRoute.shared()?.openURL(byViewController: URL(string: openUrl), userInfo: userInfo)
}

#pragma mark TTShareManagerDelegate
- (void)shareManager:(TTShareManager *)shareManager clickedWith:(id<TTActivityProtocol>)activity sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
{
//    guard let activity = activity else {
//        return
//    }
//    var platform = "be_null"
//    if activity.isKind(of: TTWechatTimelineActivity.self)  { // 微信朋友圈
//        platform = "weixin_moments"
//    } else if activity.isKind(of: TTWechatActivity.self)  { // 微信朋友分享
//        platform = "weixin"
//    } else if activity.isKind(of: TTQQFriendActivity.self)  { //
//        platform = "qq"
//    } else if activity.isKind(of: TTQQZoneActivity.self)  {
//        platform = "qzone"
//    }
//
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
@end
