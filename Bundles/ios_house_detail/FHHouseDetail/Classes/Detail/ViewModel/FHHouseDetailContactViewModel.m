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
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "ToastManager.h"
#import "IMManager.h"
#import "TTTracker.h"
#import <FHHouseBase/FHUserTracker.h>


@interface FHHouseDetailContactViewModel () <TTShareManagerDelegate, FHRealtorDetailWebViewControllerDelegate>

@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, copy) NSString *houseId;
@property (nonatomic, weak) FHDetailNavBar *navBar;
@property (nonatomic, weak) UILabel *bottomStatusBar;
@property (nonatomic, weak) FHDetailBottomBarView *bottomBar;
@property (nonatomic, strong) TTShareManager *shareManager;
@property (nonatomic, strong)FHHouseDetailFollowUpViewModel *followUpViewModel;
@property (nonatomic, strong)FHHouseDetailPhoneCallViewModel *phoneCallViewModel;

@end

@implementation FHHouseDetailContactViewModel

- (instancetype)initWithNavBar:(FHDetailNavBar *)navBar bottomBar:(FHDetailBottomBarView *)bottomBar houseType:(FHHouseType)houseType houseId:(NSString *)houseId
{
    self = [self initWithNavBar:navBar bottomBar:bottomBar];
    if (self) {
        
        _houseType = houseType;
        _houseId = houseId;
        
        _followUpViewModel = [[FHHouseDetailFollowUpViewModel alloc]init];
        _phoneCallViewModel = [[FHHouseDetailPhoneCallViewModel alloc]initWithHouseType:_houseType houseId:_houseId];
        _phoneCallViewModel.bottomBar = _bottomBar;
        _phoneCallViewModel.followUpViewModel = _followUpViewModel;

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshFollowStatus:) name:kFHDetailFollowUpNotification object:nil];
        
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
            [wself messageAction];
        };
        if ([[IMManager shareInstance] getChatMessageUnreadTotalCount] > 0) {
            [_navBar displayMessageDot:YES];
        } else {
            [_navBar displayMessageDot:NO];
        }
    }
    return self;
}

-(instancetype)initWithNavBar:(FHDetailNavBar *)navBar bottomBar:(FHDetailBottomBarView *)bottomBar
{
    self = [super init];
    if (self) {
        _navBar = navBar;
        _bottomBar = bottomBar;
    }
    return self;
}

- (void)refreshFollowStatus:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    NSString *followId = [userInfo tt_stringValueForKey:@"followId"];
    NSInteger followStatus = [userInfo tt_integerValueForKey:@"followStatus"];
    if (![followId isEqualToString:self.houseId]) {
        return;
    }
    self.followStatus = followStatus;
}
- (void)setFollowStatus:(NSInteger)followStatus
{
    _followStatus = followStatus;
    [self.navBar setFollowStatus:followStatus];
}

- (void)setTracerDict:(NSDictionary *)tracerDict
{
    _tracerDict = tracerDict;
    _phoneCallViewModel.tracerDict = tracerDict;
    _followUpViewModel.tracerDict = tracerDict;

}

- (void)setBelongsVC:(UIViewController *)belongsVC
{
    _belongsVC = belongsVC;
    _phoneCallViewModel.belongsVC = belongsVC;
}

- (void)followAction
{
    [self.followUpViewModel followHouseByFollowId:self.houseId houseType:self.houseType actionType:self.houseType];
}

- (void)cancelFollowAction
{
    [self.followUpViewModel cancelFollowHouseByFollowId:self.houseId houseType:self.houseType actionType:self.houseType];
}

//todo 增加埋点的东西
- (void)jump2RealtorDetail
{
    [self.phoneCallViewModel jump2RealtorDetailWithPhone:self.contactPhone];
}

- (void)licenseAction
{
    [self.phoneCallViewModel licenseActionWithPhone:self.contactPhone];
}

- (void)shareAction
{
    [self addClickShareLog];
    
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

- (void)messageAction {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@"house_app2c_v2" forKey:@"event_type"];
    [params setValue:[_tracerDict objectForKey:@"page_type"]  forKey:@"page_type"];
    [params setValue:[_tracerDict objectForKey:@"enter_from"]  forKey:@"enter_from"];
    [params setValue:[_tracerDict objectForKey:@"rank"] forKey:@"rank"];
    [params setValue:@"left_pic" forKey:@"card_type"];
    [params setValue:[_tracerDict objectForKey:@"element_from"] forKey:@"element_from"];
    [params setValue:[_tracerDict objectForKey:@"origin_from"] forKey:@"origin_from"];
    [params setValue:[_tracerDict objectForKey:@"origin_search_id"] forKey:@"origin_search_id"];
    [params setValue:[_tracerDict objectForKey:@"log_pb"] forKey:@"log_pb"];
    [TTTracker eventV3:@"click_im_message" params:params];
    
    
    NSString *messageSchema = @"sslocal://message_conversation_list";
    NSURL *openUrl = [NSURL URLWithString:messageSchema];
    [[TTRoute sharedRoute] openURLByPushViewController:openUrl];
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
    [self tryTraceImElementShow];
    if (contactPhone.showRealtorinfo) {
        [self addRealtorShowLog:contactPhone];
    }
}

- (void)tryTraceImElementShow {
    if (!isEmptyString(_contactPhone.imOpenUrl)) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:@"house_app2c_v2" forKey:@"event_type"];
        [params setValue:@"im" forKey:@"element_type"];
        [params setValue:[_tracerDict objectForKey:@"page_type"]  forKey:@"page_type"];
        [params setValue:[_tracerDict objectForKey:@"rank"] forKey:@"rank"];
        [params setValue:[_tracerDict objectForKey:@"origin_from"] forKey:@"origin_from"];
        [params setValue:[_tracerDict objectForKey:@"origin_search_id"] forKey:@"origin_search_id"];
        [params setValue:[_tracerDict objectForKey:@"log_pb"] forKey:@"log_pb"];
        [TTTracker eventV3:@"element_show" params:params];
    }
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
    [self.phoneCallViewModel fillFormAction];
}

- (void)fillFormActionWithTitle:(NSString *)title subtitle:(NSString *)subtitle btnTitle:(NSString *)btnTitle
{
    [self.phoneCallViewModel fillFormActionWithTitle:title subtitle:subtitle btnTitle:btnTitle];
}

- (void)callAction
{
    [self.phoneCallViewModel callWithPhone:self.contactPhone.phone searchId:self.searchId imprId:self.imprId];
    // 静默关注功能
    [self.followUpViewModel silentFollowHouseByFollowId:self.houseId houseType:self.houseType actionType:self.houseType showTip:NO];
}


- (void)imAction {
    [self.phoneCallViewModel imchatActionWithPhone:self.contactPhone realtorRank:@"0" position:@"detail_button"];
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

- (void)addClickShareLog
{
    NSMutableDictionary *params = @{}.mutableCopy;
    [params addEntriesFromDictionary:[self baseParams]];
    [FHUserTracker writeEvent:@"click_share" params:params];
}

- (void)addShareFormLog:(NSString *)platform
{
    NSMutableDictionary *params = @{}.mutableCopy;
    [params addEntriesFromDictionary:[self baseParams]];
    params[@"platform"] = platform ? : @"be_null";
    [FHUserTracker writeEvent:@"share_platform" params:params];
}

- (void)addRealtorShowLog:(FHDetailContactModel *)contactPhone
{
    //    1. event_type ：house_app2c_v2
    //    2. page_type（页面类型）：old_detail（二手房详情页）
    //    3. element_type（组件类型）：底部button：old_detail_button，详情页推荐经纪人：old_detail_related
    //    4. rank
    //    5. origin_from
    //    6. origin_search_id
    //    7.log_pb
    //    8.realtor_id
    //    9.realtor_rank:经纪人推荐位置，从0开始，在底部button的为0
    //    10.realtor_position ：detail_button，detail_related
    NSMutableDictionary *tracerDic = @{}.mutableCopy;
    tracerDic[@"page_type"] = self.tracerDict[@"page_type"] ? : @"be_null";
    tracerDic[@"element_type"] = @"old_detail_button";
    tracerDic[@"rank"] = self.tracerDict[@"rank"] ? : @"be_null";
    tracerDic[@"origin_from"] = self.tracerDict[@"origin_from"] ? : @"be_null";
    tracerDic[@"origin_search_id"] = self.tracerDict[@"origin_search_id"] ? : @"be_null";
    tracerDic[@"log_pb"] = self.tracerDict[@"log_pb"] ? : @"be_null";
    tracerDic[@"realtor_id"] = contactPhone.realtorId ?: @"be_null";
    tracerDic[@"realtor_rank"] = @(0);
    tracerDic[@"realtor_position"] = @"detail_button";
    if (_contactPhone.phone.length < 1) {
        [tracerDic setValue:@"0" forKey:@"phone_show"];
    } else {
        [tracerDic setValue:@"1" forKey:@"phone_show"];
    }
    if (!isEmptyString(_contactPhone.imOpenUrl)) {
        [tracerDic setValue:@"1" forKey:@"im_show"];
    } else {
        [tracerDic setValue:@"0" forKey:@"im_show"];
    }
    [FHUserTracker writeEvent:@"realtor_show" params:tracerDic];
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
    [self addShareFormLog:platform];
}

- (void)shareManager:(TTShareManager *)shareManager completedWith:(id<TTActivityProtocol>)activity sharePanel:(id<TTActivityPanelControllerProtocol>)panelController error:(NSError *)error desc:(NSString *)desc
{
    
}

- (TTShareManager *)shareManager
{
    if (!_shareManager) {
        _shareManager = [[TTShareManager alloc]init];
        _shareManager.delegate = self;
    }
    return _shareManager;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
