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
#import <TTWechatTimelineActivity.h>
#import <TTWechatActivity.h>
#import <TTQQFriendActivity.h>
#import <TTQQZoneActivity.h>
#import "FHHouseDetailAPI.h"
#import "TTReachability.h"
#import <FHHouseBase/FHHouseFollowUpHelper.h>
#import "FHHouseDetailPhoneCallViewModel.h"
#import "NSDictionary+TTAdditions.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "ToastManager.h"
#import "IMManager.h"
#import "TTTracker.h"
#import <FHHouseBase/FHUserTracker.h>
#import "FHEnvContext.h"
#import "FHMessageManager.h"
#import "FHIMShareActivity.h"
#import "FHIMShareItem.h"
#import "TTAccountManager.h"
#import "TTCopyActivity.h"
#import <TTAccountSDK/TTAccount.h>
#import <FHHouseBase/FHUserTrackerDefine.h>
#import <FHHouseBase/FHHousePhoneCallUtils.h>
#import <FHHouseBase/FHHouseFillFormHelper.h>
#import <HMDTTMonitor.h>
#import <FHIESGeckoManager.h>

NSString *const kFHDetailLoadingNotification = @"kFHDetailLoadingNotification";

@interface FHHouseDetailContactViewModel () <TTShareManagerDelegate>

@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, copy) NSString *houseId;
@property (nonatomic, weak) FHDetailNavBar *navBar;
@property (nonatomic, weak) UILabel *bottomStatusBar;
@property (nonatomic, weak) FHDetailBottomBarView *bottomBar;
@property (nonatomic, strong) TTShareManager *shareManager;
@property (nonatomic, strong)FHHouseDetailPhoneCallViewModel *phoneCallViewModel;

@end

@implementation FHHouseDetailContactViewModel

- (instancetype)initWithNavBar:(FHDetailNavBar *)navBar bottomBar:(FHDetailBottomBarView *)bottomBar houseType:(FHHouseType)houseType houseId:(NSString *)houseId
{
    self = [self initWithNavBar:navBar bottomBar:bottomBar];
    if (self) {
        
        _houseType = houseType;
        _houseId = houseId;
        _showenOnline = NO;
        _onLineName = @"在线联系";
        _phoneCallName = @"电话咨询";
        
        _phoneCallViewModel = [[FHHouseDetailPhoneCallViewModel alloc]initWithHouseType:_houseType houseId:_houseId];

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshFollowStatus:) name:@"follow_up_did_changed" object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshMessageDot) name:@"kFHMessageUnreadChangedNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshMessageDot) name:@"kFHChatMessageUnreadChangedNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshBottomBarLoadingState:) name:kFHDetailLoadingNotification object:nil];

        [FHEnvContext sharedInstance].messageManager ;
        
        __weak typeof(self)wself = self;
        _bottomBar.bottomBarContactBlock = ^{
            [wself contactActionWithExtraDict:nil];
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
        [self refreshMessageDot];
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

- (void)refreshMessageDot {
    if ([[FHEnvContext sharedInstance].messageManager getTotalUnreadMessageCount]) {
        [_navBar displayMessageDot:YES];
    } else {
        [_navBar displayMessageDot:NO];
    }
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

- (void)refreshBottomBarLoadingState:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    NSString *houseId = [userInfo tt_stringValueForKey:@"house_id"];
    NSInteger loading = [userInfo tt_integerValueForKey:@"show_loading"];
    if (![houseId isEqualToString:self.houseId]) {
        return;
    }
    if (loading) {
        [self.bottomBar startLoading];
    }else {
        [self.bottomBar stopLoading];
    }
}

- (void)hideFollowBtn
{
    [self.navBar hideFollowBtn];
}

- (void)setTracerDict:(NSDictionary *)tracerDict
{
    _tracerDict = tracerDict;
    _phoneCallViewModel.tracerDict = tracerDict;
}

- (void)setBelongsVC:(UIViewController *)belongsVC
{
    _belongsVC = belongsVC;
    self.phoneCallViewModel.belongsVC = belongsVC;
}

- (void)followAction
{
    NSMutableDictionary *extraDict = @{}.mutableCopy;
//    extraDict[@"realtor_id"] = contact.realtorId;
//    extraDict[@"realtor_rank"] = @(index);
//    extraDict[@"realtor_position"] = @"detail_related";
    if (self.tracerDict) {
        [extraDict addEntriesFromDictionary:self.tracerDict];
    }
    FHHouseFollowUpConfigModel *configModel = [[FHHouseFollowUpConfigModel alloc]initWithDictionary:extraDict error:nil];
    configModel.houseType = self.houseType;
    configModel.followId = self.houseId;
    configModel.actionType = self.houseType;
    
    [FHHouseFollowUpHelper followHouseWithConfigModel:configModel];
}

- (void)cancelFollowAction
{
    FHHouseFollowUpConfigModel *configModel = [[FHHouseFollowUpConfigModel alloc]init];
    configModel.houseType = self.houseType;
    configModel.followId = self.houseId;
    configModel.actionType = self.houseType;
    [FHHouseFollowUpHelper cancelFollowHouseWithConfigModel:configModel];
}

//todo 增加埋点的东西
- (void)jump2RealtorDetail
{
    [self.phoneCallViewModel jump2RealtorDetailWithPhone:self.contactPhone isPreLoad:YES];
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
    if(TTAccountManager.isLogin &&
       (self.houseType == FHHouseTypeSecondHandHouse || self.houseType == FHHouseTypeRentHouse) &&
       self.imShareInfo != nil &&
       [self hasImUser]) {
        FHIMShareItem* fhImShareItem = [[FHIMShareItem alloc] init];
        fhImShareItem.imShareInfo = self.imShareInfo;
        NSMutableDictionary* dict = [self.tracerDict mutableCopy];
        dict[@"enter_from"] = dict[@"page_type"];
        fhImShareItem.tracer = dict;
        [shareContentItems addObject:fhImShareItem];
    }

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

    TTCopyContentItem *copyContentItem = [[TTCopyContentItem alloc] initWithDesc:webPageUrl];
    [shareContentItems addObject:copyContentItem];
    [self.shareManager displayActivitySheetWithContent:shareContentItems];
}

-(BOOL)hasImUser {
    return [[IMManager shareInstance].chatService numberOfItems] > 0;
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
    NSString *chatTitle = @"在线联系";
    
    if(contactPhone.callButtonText && ![contactPhone.callButtonText isEqualToString:@""]){
        contactTitle = contactPhone.callButtonText;
    }
    
    if(contactPhone.imLabel && ![contactPhone.imLabel isEqualToString:@""]){
        chatTitle = contactPhone.imLabel;
    }
    
    if (contactPhone.phone.length < 1) {
        if (self.houseType == FHHouseTypeNeighborhood) {
            contactTitle = @"咨询经纪人";
        }else {
            if (contactPhone.unregistered && contactPhone.reportButtonText.length > 0) {
                contactTitle = contactPhone.reportButtonText;
            }else{
                contactTitle = @"询底价";
            }
        }
    }
    self.onLineName = chatTitle;
    self.phoneCallName = contactTitle;
    [self.bottomBar refreshBottomBar:contactPhone contactTitle:contactTitle chatTitle:chatTitle];
    self.showenOnline = self.bottomBar.showIM;// 显示在线联系（详情图册页面）
    [self tryTraceImElementShow];
    if (contactPhone.showRealtorinfo) {
        [self addRealtorShowLog:contactPhone];
        [self addElementShowLog:contactPhone];
    }
    [self addLeadShowLog:contactPhone];
    
    @try {
        // 可能会出现崩溃的代码
        if ([FHHouseDetailPhoneCallViewModel fhRNEnableChannels].count > 0 && [FHHouseDetailPhoneCallViewModel fhRNPreLoadChannels].count > 0 && [[FHHouseDetailPhoneCallViewModel fhRNEnableChannels] containsObject:@"f_realtor_detail"] && [[FHHouseDetailPhoneCallViewModel fhRNPreLoadChannels] containsObject:@"f_realtor_detail"] && contactPhone.showRealtorinfo && [FHIESGeckoManager isHasCacheForChannel:@"f_realtor_detail"]) {
            //保证主线程执行
            [self.phoneCallViewModel creatJump2RealtorDetailWithPhone:contactPhone isPreLoad:YES andIsOpen:NO];
        }
    }
    
    @catch (NSException *exception) {
        // 捕获到的异常exception
        if (exception) {
            NSString* descriptionExc = [exception description];
            NSMutableDictionary *excepDict = [NSMutableDictionary dictionary];
            [excepDict setValue:descriptionExc forKey:@"exception"];
            
            [[HMDTTMonitor defaultManager] hmdTrackService:@"rn_monitor_error" status:1 extra:excepDict];
            self.phoneCallViewModel.rnIsUnAvalable = YES;
        }
    }
    @finally {
        // 结果处理
    }

}

- (void)generateImParams:(NSString *)houseId houseTitle:(NSString *)houseTitle houseCover:(NSString *)houseCover houseType:(NSString *)houseType houseDes:(NSString *)houseDes housePrice:(NSString *)housePrice houseAvgPrice:(NSString *)houseAvgPrice {
    [self.phoneCallViewModel generateImParams:houseId houseTitle:houseTitle houseCover:houseCover houseType:houseType houseDes:houseDes housePrice:housePrice houseAvgPrice:houseAvgPrice];
}

- (void)tryTraceImElementShow {
    if (!isEmptyString(_contactPhone.imOpenUrl) || _contactPhone.unregistered) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSString *elementType = _contactPhone.unregistered ? @"online":@"im";
        [params setValue:@"house_app2c_v2" forKey:@"event_type"];
        [params setValue:elementType forKey:@"element_type"];
        [params setValue:[_tracerDict objectForKey:@"page_type"]  forKey:@"page_type"];
        [params setValue:[_tracerDict objectForKey:@"rank"] forKey:@"rank"];
        [params setValue:[_tracerDict objectForKey:@"origin_from"] forKey:@"origin_from"];
        [params setValue:[_tracerDict objectForKey:@"origin_search_id"] forKey:@"origin_search_id"];
        [params setValue:[_tracerDict objectForKey:@"log_pb"] forKey:@"log_pb"];
        [TTTracker eventV3:@"element_show" params:params];
    }
}

// 拨打电话 + 询底价填表单
- (void)contactActionWithExtraDict:(NSDictionary *)extraDict {
    if (self.contactPhone.phone.length < 1) {
        // 填表单
        [self fillFormActionWithExtraDict:extraDict];
    }else {
        // 拨打电话
        [self callActionWithExtraDict:extraDict];
    }
}

// 在线联系点击
- (void)onlineActionWithExtraDict:(NSDictionary *)extraDict {
    NSMutableDictionary *params = [self baseParams].mutableCopy;
    if (extraDict.count > 0) {
        [params addEntriesFromDictionary:extraDict];
    }
 
    if (self.contactPhone.unregistered && self.contactPhone.imLabel.length > 0) {
        
        params[@"is_login"] = [TTAccount sharedAccount].isLogin?@"1":@"0";
        params[@"realtor_id"] = _contactPhone.realtorId?:@"be_null";
        params[@"realtor_rank"] = @(0);
        [self addFakeImClickLog:params];
        NSString *fromStr = nil;
        if (self.houseType == FHHouseTypeSecondHandHouse) {
            fromStr = @"app_oldhouse_chat";
        }else if (self.houseType == FHHouseTypeRentHouse) {
            fromStr = @"app_renthouse_chat";
        }
        self.contactPhone.searchId = self.searchId;
        self.contactPhone.imprId = self.imprId;
        FHHouseFillFormConfigModel *fillFormConfig = [[FHHouseFillFormConfigModel alloc]init];
        fillFormConfig.houseType = self.houseType;
        fillFormConfig.houseId = self.houseId;
        fillFormConfig.topViewController = self.belongsVC;
        fillFormConfig.title = @"预约看房";
        fillFormConfig.subtitle = @"很抱歉，该经纪人暂未开通该服务，请留下您的联系方式，我们会立即短信告知对方，方便与您联系";
        if (self.contactPhone.phone.length > 0) {
            fillFormConfig.btnTitle = @"电话咨询";
            fillFormConfig.leftBtnTitle = @"立即预约";
        }else {
            fillFormConfig.btnTitle = @"立即预约";
        }
        fillFormConfig.fromStr = fromStr;
        fillFormConfig.realtorId = self.contactPhone.realtorId;
        fillFormConfig.phone = self.contactPhone.phone;
        [fillFormConfig setTraceParams:params];
        fillFormConfig.searchId = self.searchId;
        fillFormConfig.imprId = self.imprId;
        fillFormConfig.chooseAgencyList = self.chooseAgencyList;
        [FHHouseFillFormHelper fillOnlineFormActionWithConfigModel:fillFormConfig];
        return;
    }
    NSString *realtor_pos = @"detail_button";
    if (params && [params isKindOfClass:[NSDictionary class]]) {
        realtor_pos = params[@"realtor_position"] ? : @"detail_button";
    }
    [self.phoneCallViewModel imchatActionWithPhone:self.contactPhone realtorRank:@"0" position:realtor_pos];
}

- (void)fillFormActionWithExtraDict:(NSDictionary *)extraDict
{
    FHHouseFillFormConfigModel *fillFormConfig = [[FHHouseFillFormConfigModel alloc]init];
    fillFormConfig.houseType = self.houseType;
    fillFormConfig.houseId = self.houseId;
    fillFormConfig.topViewController = self.belongsVC;
    fillFormConfig.fromStr = self.fromStr;
    fillFormConfig.realtorId = self.contactPhone.realtorId;
    fillFormConfig.customHouseId = self.customHouseId;
    if (self.houseType == FHHouseTypeNeighborhood) {
        fillFormConfig.title = @"咨询经纪人";
        fillFormConfig.btnTitle = @"提交";
    }
    NSMutableDictionary *params = [self baseParams].mutableCopy;
    if (extraDict.count > 0) {
        [params addEntriesFromDictionary:extraDict];
    }
    [fillFormConfig setTraceParams:params];
    fillFormConfig.searchId = self.searchId;
    fillFormConfig.imprId = self.imprId;
    fillFormConfig.chooseAgencyList = self.chooseAgencyList;
    [FHHouseFillFormHelper fillFormActionWithConfigModel:fillFormConfig];
}

- (void)fillFormActionWithActionType:(FHFollowActionType)actionType
{
    NSString *title = nil;
    NSString *subtitle = nil;
    NSString *btnTitle = @"提交";

    if (actionType == FHFollowActionTypeFloorPan) {
        title = @"开盘通知";
        subtitle = @"订阅开盘通知，楼盘开盘信息会及时发送到您的手机";
        btnTitle = @"提交";
    }else if (actionType == FHFollowActionTypePriceChanged) {
        title = @"变价通知";
        subtitle = @"订阅变价通知，楼盘变价信息会及时发送到您的手机";
        btnTitle = @"提交";
    }
    FHHouseFillFormConfigModel *fillFormConfig = [[FHHouseFillFormConfigModel alloc]init];
    fillFormConfig.houseType = self.houseType;
    fillFormConfig.houseId = self.houseId;
    fillFormConfig.topViewController = self.belongsVC;
    if (title.length > 0) {
        fillFormConfig.title = title;
    }
    if (subtitle.length > 0) {
        fillFormConfig.subtitle = subtitle;
    }
    if (btnTitle.length > 0) {
        fillFormConfig.btnTitle = btnTitle;
    }
    fillFormConfig.realtorId = self.contactPhone.realtorId;
    fillFormConfig.actionType = actionType;
    fillFormConfig.topViewController = self.belongsVC;

    NSMutableDictionary *params = @{}.mutableCopy;
    if (self.tracerDict) {
        [params addEntriesFromDictionary:self.tracerDict];
    }
    [fillFormConfig setTraceParams:params];
    fillFormConfig.searchId = self.searchId;
    fillFormConfig.imprId = self.imprId;
    fillFormConfig.chooseAgencyList = self.chooseAgencyList;
    [FHHouseFillFormHelper fillFormActionWithConfigModel:fillFormConfig];
}

// 拨打电话
- (void)callActionWithExtraDict:(NSDictionary *)extraDict {
    NSMutableDictionary *params = @{}.mutableCopy;
    if (self.tracerDict) {
        [params addEntriesFromDictionary:self.tracerDict];
    }
    if (extraDict) {
        [params addEntriesFromDictionary:extraDict];
    }
    FHHouseContactConfigModel *contactConfig = [[FHHouseContactConfigModel alloc]initWithDictionary:params error:nil];
    contactConfig.houseType = self.houseType;
    contactConfig.houseId = self.houseId;
    contactConfig.phone = self.contactPhone.phone;
    contactConfig.realtorId = self.contactPhone.realtorId;
    contactConfig.searchId = self.searchId;
    contactConfig.imprId = self.imprId;
    contactConfig.showLoading = YES;
    [FHHousePhoneCallUtils callWithConfigModel:contactConfig completion:nil];
    
    FHHouseFollowUpConfigModel *configModel = [[FHHouseFollowUpConfigModel alloc]initWithDictionary:params error:nil];
    configModel.houseType = self.houseType;
    configModel.followId = self.houseId;
    configModel.actionType = self.houseType;
    
    // 静默关注功能
    [FHHouseFollowUpHelper silentFollowHouseWithConfigModel:configModel];

}

- (void)imAction {
    NSMutableDictionary *extraDic = @{@"realtor_position":@"detail_button",
                               @"position":@"button"}.mutableCopy;
    if (self.contactPhone.unregistered && self.contactPhone.imLabel.length > 0) {
        extraDic[@"position"] = @"online";
        extraDic[@"realtor_position"] = @"online";
    }
    [self onlineActionWithExtraDict:extraDic];
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

- (void)addElementShowLog:(FHDetailContactModel *)contactPhone
{
//    1. event_type ：house_app2c_v2
//    2. page_type（页面类型）：old_detail（二手房详情页）
//    3. element_type（组件类型）：底部button：old_detail_button，详情页推荐经纪人：old_detail_related
//    4. rank
//    5. origin_from
//    6. origin_search_id
//    7.log_pb
    NSMutableDictionary *tracerDic = @{}.mutableCopy;
    tracerDic[@"page_type"] = self.tracerDict[@"page_type"] ? : @"be_null";
    tracerDic[@"card_type"] = self.tracerDict[@"card_type"] ? : @"be_null";
    tracerDic[@"element_type"] = @"old_detail_button";
    tracerDic[@"rank"] = self.tracerDict[@"rank"] ? : @"be_null";
    tracerDic[@"origin_from"] = self.tracerDict[@"origin_from"] ? : @"be_null";
    tracerDic[@"origin_search_id"] = self.tracerDict[@"origin_search_id"] ? : @"be_null";
    tracerDic[@"log_pb"] = self.tracerDict[@"log_pb"] ? : @"be_null";
    [FHUserTracker writeEvent:@"element_show" params:tracerDic];
}

- (void)addLeadShowLog:(FHDetailContactModel *)contactPhone
{
    NSMutableDictionary *tracerDic = [self baseParams].mutableCopy;
    tracerDic[@"is_im"] = !isEmptyString(contactPhone.imOpenUrl) ? @"1" : @"0";
    tracerDic[@"is_call"] = contactPhone.phone.length < 1 ? @"0" : @"1";
    tracerDic[@"is_report"] = contactPhone.isFormReport ? @"1" : @"0";
    tracerDic[@"is_online"] = _contactPhone.unregistered?@"1":@"0";
    [FHUserTracker writeEvent:@"lead_show" params:tracerDic];
}

-(void)addFakeImClickLog:(NSDictionary *)params
{
    NSMutableDictionary *tracerDic = @{}.mutableCopy;
    tracerDic[@"page_type"] = params[@"page_type"] ? : @"be_null";
    tracerDic[@"card_type"] = params[@"card_type"] ? : @"be_null";
    tracerDic[@"enter_from"] = params[@"enter_from"] ? : @"be_null";
    tracerDic[@"element_from"] = params[@"element_from"] ? : @"be_null";
    tracerDic[@"rank"] = params[@"rank"] ? : @"be_null";
    tracerDic[@"origin_from"] = params[@"origin_from"] ? : @"be_null";
    tracerDic[@"origin_search_id"] = params[@"origin_search_id"] ? : @"be_null";
    tracerDic[@"is_login"] = [TTAccount sharedAccount].isLogin?@"1":@"0";
    tracerDic[@"log_pb"] = params[@"log_pb"] ? : @"be_null";
    tracerDic[@"realtor_id"] = params[@"realtor_id"] ?: @"be_null";
    tracerDic[@"realtor_rank"] = @(0);
    tracerDic[@"realtor_position"] = @"online";
    TRACK_EVENT(@"click_online", tracerDic);
}


#pragma mark TTShareManagerDelegate
- (void)shareManager:(TTShareManager *)shareManager clickedWith:(id<TTActivityProtocol>)activity sharePanel:(id<TTActivityPanelControllerProtocol>)panelController
{
    NSString *platform = @"be_null";
    if ([activity isKindOfClass:[TTWechatTimelineActivity class]]) {
        platform = @"weixin_moments";
    } else if ([activity isKindOfClass:[TTWechatActivity class]]) {
        platform = @"weixin";
    } else if ([activity isKindOfClass:[TTQQFriendActivity class]]) {
        platform = @"qq";
    } else if ([activity isKindOfClass:[TTQQZoneActivity class]]) {
        platform = @"qzone";
    } else if ([activity isKindOfClass:[FHIMShareActivity class]]) {
        platform = @"realtor";
    } else if ([activity isKindOfClass:[TTCopyActivity class]]) {
        platform = @"copy";
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
        FHIMShareActivity* activity = [[FHIMShareActivity alloc] init];
        [TTShareManager addUserDefinedActivity:activity];
    }
    return _shareManager;
}

- (void)destroyRNPreLoadCache
{
    [self.phoneCallViewModel destoryRNPreloadCache];
}

- (void)updateLoadFinish
{
    [self.phoneCallViewModel updateLoadFinish];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


@end
