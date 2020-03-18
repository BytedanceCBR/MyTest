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
#import "TTActivityContentItemProtocol.h"
#import "TTWechatTimelineContentItem.h"
#import "TTWechatContentItem.h"
#import "TTQQFriendContentItem.h"
#import "TTQQZoneContentItem.h"
#import <BDWebImage/BDWebImage.h>
#import "FHURLSettings.h"
#import "TTWechatTimelineActivity.h"
#import "TTWechatActivity.h"
#import "TTQQFriendActivity.h"
#import "TTQQZoneActivity.h"
#import "FHHouseDetailAPI.h"
#import "TTReachability.h"
#import <FHHouseBase/FHHouseFollowUpHelper.h>
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
#import "HMDTTMonitor.h"
#import "FHIESGeckoManager.h"
#import "FHHouseDetailPhoneCallViewModel.h"
#import "FHHouseDetailViewController.h"
#import <FHHouseBase/FHHouseContactDefines.h>
#import "FHHouseNewsSocialModel.h"
#import "FHUGCConfig.h"
#import "FHLoginViewController.h"
#import "FHHouseUGCAPI.h"
#import "FHHouseNewDetailViewModel.h"
#import "FHDetailBaseCell.h"

NSString *const kFHDetailLoadingNotification = @"kFHDetailLoadingNotification";

@interface FHHouseDetailContactViewModel () <TTShareManagerDelegate>

@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, copy) NSString *houseId;
@property (nonatomic, weak) FHDetailNavBar *navBar;
@property (nonatomic, weak) UILabel *bottomStatusBar;
@property (nonatomic, weak) FHDetailBottomBar *bottomBar;
@property (nonatomic, strong) TTShareManager *shareManager;
@property (nonatomic, copy)     NSDictionary       *shareExtraDic;// 额外分享参数字典
@property (nonatomic, strong)FHHouseDetailPhoneCallViewModel *phoneCallViewModel;
@property (nonatomic, assign)   NSInteger       gotoGroupChatCount;

@end

@implementation FHHouseDetailContactViewModel

- (instancetype)initWithNavBar:(FHDetailNavBar *)navBar bottomBar:(FHDetailBottomBar *)bottomBar houseType:(FHHouseType)houseType houseId:(NSString *)houseId
{
    self = [self initWithNavBar:navBar bottomBar:bottomBar];
    if (self) {
        
        _houseType = houseType;
        _houseId = houseId;
        _showenOnline = NO;
        _onLineName = @"在线联系";
        _phoneCallName = @"电话咨询";
        _gotoGroupChatCount = 0;
        _needRefetchSocialGroupData = NO;
        
        _phoneCallViewModel = [[FHHouseDetailPhoneCallViewModel alloc]initWithHouseType:_houseType houseId:_houseId];

        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshFollowStatus:) name:@"follow_up_did_changed" object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshMessageDot) name:@"kFHMessageUnreadChangedNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshMessageDot) name:@"kFHChatMessageUnreadChangedNotification" object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshBottomBarLoadingState:) name:kFHDetailLoadingNotification object:nil];

        [FHEnvContext sharedInstance].messageManager ;
        
        __weak typeof(self)wself = self;
        _bottomBar.bottomBarContactBlock = ^{
            NSMutableDictionary *extraDic = @{}.mutableCopy;
            if (wself.fromStr.length > 0) {
                extraDic[@"from"] = wself.fromStr;
            }
            [wself contactActionWithExtraDict:extraDic];
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
        
        _bottomBar.bottomBarGroupChatBlock = ^{
            wself.ugcLoginType = FHUGCCommunityLoginTypeMemberTalk;
            [wself groupChatAction];
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

-(instancetype)initWithNavBar:(FHDetailNavBar *)navBar bottomBar:(FHDetailBottomBar *)bottomBar
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
    [self followActionWithExtra:nil];
}

// 关注
- (void)followActionWithExtra:(NSDictionary *)extra {
    NSMutableDictionary *extraDict = @{}.mutableCopy;
    if (self.tracerDict) {
        [extraDict addEntriesFromDictionary:self.tracerDict];
    }
    if (extra.count > 0) {
        [extraDict addEntriesFromDictionary:extra];
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
    if (self.houseType != FHHouseTypeNewHouse) {
          [self.phoneCallViewModel jump2RealtorDetailWithPhone:self.contactPhone isPreLoad:YES extra:nil];
    }
}

- (void)licenseAction
{
    [self.phoneCallViewModel licenseActionWithPhone:self.contactPhone];
}

// 详情页分享
- (void)shareAction {
    [self shareActionWithShareExtra:nil];
}

// 携带埋点参数的分享
- (void)shareActionWithShareExtra:(NSDictionary *)extra {
    self.shareExtraDic = extra;
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
    if (!contactPhone.isInstantData) {
        //非列表页带入数据才报埋点
        [self tryTraceImElementShow];
        if (contactPhone.showRealtorinfo) {
            [self addRealtorShowLog:contactPhone];
            [self addElementShowLog:contactPhone];
        }
        [self addLeadShowLog:contactPhone];
    }
    
    //根DA确认 进入经纪人主页数据太少，因此去掉经纪人主页RN预加载，以提高房源详情性能
    @try {
        // 可能会出现崩溃的代码
        if ([FHHouseDetailPhoneCallViewModel fhRNEnableChannels].count > 0 && [FHHouseDetailPhoneCallViewModel fhRNPreLoadChannels].count > 0 && [[FHHouseDetailPhoneCallViewModel fhRNEnableChannels] containsObject:@"f_realtor_detail"] && [[FHHouseDetailPhoneCallViewModel fhRNPreLoadChannels] containsObject:@"f_realtor_detail"] && contactPhone.showRealtorinfo && [FHIESGeckoManager isHasCacheForChannel:@"f_realtor_detail"]) {
            //保证主线程执行
            [self.phoneCallViewModel creatJump2RealtorDetailWithPhone:contactPhone isPreLoad:YES andIsOpen:NO extra:nil];
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

- (void)setSocialInfo:(FHHouseNewsSocialModel *)socialInfo {
    _socialInfo = socialInfo;
    NSString *groupChatTitle = @"";// 隐藏
    if (socialInfo) {
        if (socialInfo.socialGroupInfo.socialGroupId.length > 0 && ([socialInfo.socialGroupInfo.chatStatus.conversationId integerValue] > 0)) {
            groupChatTitle = socialInfo.groupChatLinkTitle.length > 0 ? socialInfo.groupChatLinkTitle : @"加入看盘群";
        } else {
            groupChatTitle = @"";
        }
    }
    // @"" 隐藏加群看房 按钮
    if (groupChatTitle.length > 0) {
        self.bottomBar.bottomGroupChatBtn.hidden = NO;
        self.bottomBar.bottomGroupChatBtn.titleLabel.text = groupChatTitle;
        [self.bottomBar.bottomGroupChatBtn.titleLabel sizeToFit];
        // 添加埋点
        NSMutableDictionary *params = @{}.mutableCopy;
        [params addEntriesFromDictionary:[self baseParams]];
        params[@"element_type"] = @"community_member_talk";
        [FHUserTracker writeEvent:@"element_show" params:params];
    } else {
        self.bottomBar.bottomGroupChatBtn.hidden = YES;
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
        params[@"enter_from"] = _tracerDict[@"enter_from"];
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
 
    NSString *realtor_pos = @"detail_button";
    if (params && [params isKindOfClass:[NSDictionary class]]) {
        realtor_pos = params[@"realtor_position"] ? : @"detail_button";
    }
    // 目前需要添加：realtor_position element_from item_id
    NSMutableDictionary *imExtra = @{}.mutableCopy;
    imExtra[@"realtor_position"] = realtor_pos;
    imExtra[@"from"] = params[@"from"] ?: (self.contactPhone.realtorType == FHRealtorTypeNormal ? @"app_oldhouse" : @"app_oldhouse_expert");
    if (params[@"source"]) {
        imExtra[@"source"] = params[@"source"];
    }
    if (extraDict && [extraDict isKindOfClass:[NSDictionary class]]) {
        if (extraDict[@"element_from"]) {
            imExtra[@"element_from"] = extraDict[@"element_from"];
        }
        if (extraDict[@"item_id"]) {
            imExtra[@"item_id"] = extraDict[@"item_id"];
        }
        if (extraDict[@"im_open_url"]) {
            imExtra[@"im_open_url"] = extraDict[@"im_open_url"];
        }
        if (extraDict[@"source_from"]) {
            imExtra[@"source_from"] = extraDict[@"source_from"];
        }
        if (extraDict[kFHClueEndpoint]) {
            imExtra[kFHClueEndpoint] = extraDict[kFHClueEndpoint];
        }
        if (extraDict[kFHCluePage]) {
            imExtra[kFHCluePage] = extraDict[kFHCluePage];
        }
        if (extraDict[@"question_id"]) {
            imExtra[@"question_id"] = extraDict[@"question_id"];
        }
        if (extraDict[@"is_login_front"]) {
            imExtra[@"is_login_front"] = extraDict[@"is_login_front"];
        }
    }
    [self.phoneCallViewModel imchatActionWithPhone:self.contactPhone realtorRank:@"0" extraDic:imExtra];
}

- (void)fillFormActionWithExtraDict:(NSDictionary *)extraDict
{
    NSString *title = nil;
    NSString *subtitle = self.subTitle;
    NSString *btnTitle = @"提交";
    NSString *fromStr = self.fromStr;
    NSNumber *cluePage = nil;
    NSString *toast = nil;

    if (extraDict[@"title"]) {
        title = extraDict[@"title"];
    }
    if (extraDict[@"subtitle"]) {
        subtitle = extraDict[@"subtitle"];
    }
    if (extraDict[@"btn_title"]) {
        btnTitle = extraDict[@"btn_title"];
    }
    if (extraDict[@"from"]) {
        fromStr = extraDict[@"from"];
    }
    if (extraDict[kFHCluePage]) {
        cluePage = extraDict[kFHCluePage];
    }
    if (extraDict[@"toast"]) {
        toast = extraDict[@"toast"];
    }
    FHHouseFillFormConfigModel *fillFormConfig = [[FHHouseFillFormConfigModel alloc]init];
    fillFormConfig.houseType = self.houseType;
    fillFormConfig.houseId = self.houseId;
    fillFormConfig.topViewController = self.belongsVC;
    fillFormConfig.from = fromStr;
    fillFormConfig.realtorId = self.contactPhone.realtorId;
    fillFormConfig.customHouseId = self.customHouseId;
    if (self.toast && self.toast.length > 0) {
        fillFormConfig.toast = self.toast;
    }
    if (self.houseType == FHHouseTypeNeighborhood) {
        fillFormConfig.title = @"咨询经纪人";
        fillFormConfig.btnTitle = @"提交";
        fillFormConfig.cluePage = @(FHClueFormPageTypeCNeighborhood);
    }
    if (title.length > 0) {
        fillFormConfig.title = title;
    }
    if (subtitle.length > 0) {
        fillFormConfig.subtitle = subtitle;
    }
    if (cluePage) {
        fillFormConfig.cluePage = cluePage;
    }
    if (toast.length > 0) {
        fillFormConfig.toast = toast;
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
    NSString *fromStr = nil;

    if (actionType == FHFollowActionTypeFloorPan) {
        title = @"开盘通知";
        subtitle = @"订阅开盘通知，楼盘开盘信息会及时发送到您的手机";
        btnTitle = @"提交";
        fromStr = @"app_sellnotice";
    }else if (actionType == FHFollowActionTypePriceChanged) {
        title = @"变价通知";
        subtitle = @"订阅变价通知，楼盘变价信息会及时发送到您的手机";
        btnTitle = @"提交";
        fromStr = @"app_pricenotice";
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
    fillFormConfig.from = fromStr;
    fillFormConfig.chooseAgencyList = self.chooseAgencyList;
    [FHHouseFillFormHelper fillFormActionWithConfigModel:fillFormConfig];
}

// 拨打电话
- (void)callActionWithExtraDict:(NSDictionary *)extraDict {
    WeakSelf;
    NSMutableDictionary *params = @{}.mutableCopy;
    if (self.tracerDict) {
        [params addEntriesFromDictionary:self.tracerDict];
    }
    if (extraDict) {
        [params addEntriesFromDictionary:extraDict];
    }
    FHHouseContactConfigModel *contactConfig = [[FHHouseContactConfigModel alloc]initWithDictionary:params error:nil];
    if (self.targetType>0) {
        contactConfig.houseType = self.targetType;
    }else {
       contactConfig.houseType = self.houseType;
    }
    if (self.customHouseId.length>0) {
        contactConfig.houseId = self.customHouseId;
    }else {
        contactConfig.houseId = self.houseId;
    }
    
    contactConfig.phone = self.contactPhone.phone;
    contactConfig.realtorId = self.contactPhone.realtorId;
    contactConfig.searchId = self.searchId;
    contactConfig.imprId = self.imprId;
    contactConfig.showLoading = YES;
    contactConfig.realtorLogpb = self.contactPhone.realtorLogpb;
    contactConfig.realtorType = self.contactPhone.realtorType;
    if (self.houseType == FHHouseTypeNeighborhood) {
        contactConfig.cluePage = @(FHClueCallPageTypeCNeighborhood);
    }
    if (extraDict[@"from"]) {
        contactConfig.from = extraDict[@"from"];
    }
    
    // 圈子电话咨询数据备份
    self.socialContactConfig = nil;
    if (self.houseType == FHHouseTypeNewHouse) {
        // 拨打电话 弹窗显示的话 本数据保留，否则 删除 nil
        self.socialContactConfig = [[FHHouseContactConfigModel alloc] initWithDictionary:params error:nil];
        self.socialContactConfig.houseType = self.houseType;
        self.socialContactConfig.houseId = self.houseId;
        self.socialContactConfig.phone = self.contactPhone.phone;
        self.socialContactConfig.realtorId = self.contactPhone.realtorId;
    }
    
    [FHHousePhoneCallUtils callWithConfigModel:contactConfig completion:^(BOOL success, NSError * _Nonnull error, FHDetailVirtualNumModel * _Nonnull virtualPhoneNumberModel) {
        if(success && [wself.phoneCallViewModel.belongsVC isKindOfClass:[FHHouseDetailViewController class]]){
            FHHouseDetailViewController *vc = (FHHouseDetailViewController *)wself.phoneCallViewModel.belongsVC;
            vc.isPhoneCallShow = YES;
            vc.phoneCallRealtorId = contactConfig.realtorId;
            vc.phoneCallRequestId = virtualPhoneNumberModel.requestId;
        } else {
            wself.socialContactConfig = nil;
        }
    }];
    
    FHHouseFollowUpConfigModel *configModel = [[FHHouseFollowUpConfigModel alloc]initWithDictionary:params error:nil];
    configModel.houseType = self.houseType;
    configModel.followId = self.houseId;
    configModel.actionType = self.houseType;
    
    // 静默关注功能
    [FHHouseFollowUpHelper silentFollowHouseWithConfigModel:configModel];

}

// 新房 拨打电话后是否需要添加弹窗 留资入口
- (void)checkSocialPhoneCall {
    if (self.socialContactConfig) {
        if (self.socialContactConfig.houseType == FHHouseTypeNewHouse && [self.belongsVC isKindOfClass:[FHHouseDetailViewController class]]) {
            FHHouseDetailViewController *detailVC = (FHHouseDetailViewController *)self.belongsVC;
            FHHouseNewDetailViewModel *viewModel = (FHHouseNewDetailViewModel *)detailVC.viewModel;
            if ([viewModel needShowSocialInfoForm:self.socialContactConfig]) {
                [viewModel showUgcSocialEntrance:nil];
            }
        }
        self.socialContactConfig = nil;
    }
}

- (void)imAction {
    NSMutableDictionary *extraDic = @{@"realtor_position":@"detail_button",
                               @"position":@"button"}.mutableCopy;
    if (self.contactPhone.unregistered && self.contactPhone.imLabel.length > 0) {
        extraDic[@"position"] = @"online";
        extraDic[@"realtor_position"] = @"online";
    }
    if (self.houseType == FHHouseTypeNeighborhood) {
        extraDic[kFHClueEndpoint] = @(FHClueEndPointTypeC);
        extraDic[kFHCluePage] = @(FHClueIMPageTypeCNeighborhood);
    }else if (self.houseType == FHIMHouseTypeNewHouse) {
        extraDic[kFHClueEndpoint] = @(FHClueEndPointTypeC);
        extraDic[kFHCluePage] = @(FHClueIMPageTypeCourt);
        extraDic[@"from"] = @"app_court";
        if (_fromStr.length > 0) {
            extraDic[kFHCluePage] = @([FHHouseDetailContactViewModel imCluePageTypeByFromString:_fromStr]);
            extraDic[@"from"] = _fromStr;
        }
    }else if (self.houseType == FHIMHouseTypeSecondHandHouse) {
        extraDic[@"is_login_front"] = @(1);
    }
    [self onlineActionWithExtraDict:extraDic];
}

+ (FHClueIMPageTypeC)imCluePageTypeByFromString:(NSString *)fromStr
{
    FHClueIMPageTypeC cluePageType = FHClueIMPageTypeCourt;
    if ([fromStr isEqualToString:@"app_floorplan"]) {
        cluePageType = FHClueIMPageTypeFloorplan;
    }else if ([fromStr isEqualToString:@"app_newhouse_detail"]) {
        cluePageType = FHClueIMPageTypeNewHouseDetail;
    }else if ([fromStr isEqualToString:@"app_newhouse_apartmentlist"]) {
        cluePageType = FHClueIMPageTypeApartmentlist;
    }
    return cluePageType;
}

// 新房群聊按钮点击
- (void)groupChatAction {
    if (self.gotoGroupChatCount > 0) {
        return;
    }
    if (self.socialInfo == nil) {
        return;
    }
    if ([TTAccountManager isLogin]) {
        // 已登录
        // 未关注 先关注圈子
        if (![self.socialInfo.socialGroupInfo.hasFollow boolValue]) {
            // 关注后再跳转群聊
            [self startUGCLoading];
            [self followSocialGroup:YES];
        } else {
            // 已登录 已关注 跳转群聊
            [self p_gotoGroupChat_hasLogin];
        }
    } else {
        [self gotoLogin];
    }
}

- (void)p_gotoGroupChat_hasLogin {
    if ([TTAccountManager isLogin]) {
        // 已登录
        if ([IMManager shareInstance].session.state == onAuthSuccessed) {
            // IM 链接成功
            [self endUGCLoading];
            self.gotoGroupChatCount = 0;
            [self p_gotoGroupChat];
        } else {
            // IM 正在链接
            if (self.gotoGroupChatCount >= 5) {
                self.gotoGroupChatCount = 0;
                [self endUGCLoading];
                return;
            }
            __weak typeof(self) weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                weakSelf.gotoGroupChatCount += 1;
                [weakSelf p_gotoGroupChat_hasLogin];
            });
        }
    } else {
        [self endUGCLoading];
        self.gotoGroupChatCount = 0;
    }
}

- (void)p_gotoGroupChat {
    if (self.socialInfo == nil) {
        return;
    }
    self.needRefetchSocialGroupData = YES;
    if ([TTReachability isNetworkConnected]) {
        if (self.socialInfo.socialGroupInfo.chatStatus.currentConversationCount >= self.socialInfo.socialGroupInfo.chatStatus.maxConversationCount && self.socialInfo.socialGroupInfo.chatStatus.maxConversationCount > 0) {
            [[ToastManager manager] showToast:@"成员已达上限"];
        } else if ([self.socialInfo.socialGroupInfo.chatStatus.conversationId integerValue] <= 0) {
            if (self.socialInfo.socialGroupInfo.userAuth > UserAuthTypeNormal) {
                [self gotoGroupChatVC:@"-1" isCreate:YES autoJoin:NO];
            }
        } else if(self.socialInfo.socialGroupInfo.chatStatus.conversationStatus == joinConversation) {
            [self gotoGroupChatVC:self.socialInfo.socialGroupInfo.chatStatus.conversationId isCreate:NO autoJoin:NO];
        } else if (self.socialInfo.socialGroupInfo.chatStatus.conversationStatus == leaveConversation) {
            [self gotoGroupChatVC:@"-1" isCreate:NO autoJoin:YES];
        } else if(self.socialInfo.socialGroupInfo.chatStatus.conversationStatus == KickOutConversation) {
            [[ToastManager manager]showToast:@"你已经被移出群聊"];
        } else {
            [self gotoGroupChatVC:@"-1" isCreate:NO autoJoin:YES];
        }
    } else {
        [[ToastManager manager] showToast:@"网络异常"];
    }
}

- (void)gotoGroupChatVC:(NSString *)convId isCreate:(BOOL)isCreate autoJoin:(BOOL)autoJoin {
    //跳转到群聊页面
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"conversation_id"] = convId;
    dict[@"chat_avatar"] = self.socialInfo.socialGroupInfo.avatar;
    dict[@"chat_name"] = self.socialInfo.socialGroupInfo.socialGroupName;
    dict[@"community_id"] = self.socialInfo.socialGroupInfo.socialGroupId;
    NSMutableDictionary *reportDic = [NSMutableDictionary dictionary];

    NSDictionary *log_pb = self.tracerDict[@"log_pb"];
    NSString *group_id = nil;
    if (log_pb && [log_pb isKindOfClass:[NSDictionary class]]) {
        group_id = log_pb[@"group_id"];
    }
    reportDic[@"group_id"] = group_id ?: @"be_null";
    NSString *pageType = self.tracerDict[@"page_type"] ? : @"be_null";
    [reportDic setValue:pageType forKey:@"enter_from"];
    if (self.ugcLoginType == FHUGCCommunityLoginTypeMemberTalk) {
        // community_member_talk(底部群聊入口)
        [reportDic setValue:@"community_member_talk" forKey:@"element_from"];
    } else if (self.ugcLoginType == FHUGCCommunityLoginTypeTip) {
        // community_tip(群聊引导弹窗)
        [reportDic setValue:@"community_tip" forKey:@"element_from"];
    }
    
    if (isCreate) {
        dict[@"is_create"] = @"1";
        NSString *title = [@"" stringByAppendingFormat:@"%@(%@)", self.socialInfo.socialGroupInfo.socialGroupName, self.socialInfo.socialGroupInfo.followerCount];
        dict[@"chat_title"] = title;
        dict[@"chat_member_count"] = self.socialInfo.socialGroupInfo.followerCount;
        dict[@"idempotent_id"] = isEmptyString(self.socialInfo.socialGroupInfo.chatStatus.idempotentId) ? self.socialInfo.socialGroupInfo.socialGroupId : self.socialInfo.socialGroupInfo.chatStatus.idempotentId;
    } else if (autoJoin) {
        dict[@"auto_join"] = @"1";
        dict[@"conversation_id"] = self.socialInfo.socialGroupInfo.chatStatus.conversationId;
        dict[@"short_conversation_id"] = [[NSNumber numberWithLongLong:self.socialInfo.socialGroupInfo.chatStatus.conversationShortId] stringValue];
        NSString *title = [@"" stringByAppendingFormat:@"%@(%d)", self.socialInfo.socialGroupInfo.socialGroupName, self.socialInfo.socialGroupInfo.chatStatus.currentConversationCount];
        dict[@"chat_title"] = title;
    } else {
        NSInteger count = [[IMManager shareInstance].chatService sdkConversationWithIdentifier:convId].participantsCount;
        NSString *title = [@"" stringByAppendingFormat:@"%@(%d)", self.socialInfo.socialGroupInfo.socialGroupName, count];
        dict[@"chat_title"] = title;
        dict[@"in_conversation"] = @"1";
        dict[@"conversation_id"] = self.socialInfo.socialGroupInfo.chatStatus.conversationId;
        dict[@"short_conversation_id"] = [[NSNumber numberWithLongLong:self.socialInfo.socialGroupInfo.chatStatus.conversationShortId] stringValue];
    }
    dict[@"member_role"] = [NSString stringWithFormat: @"%d", self.socialInfo.socialGroupInfo.userAuth];
    dict[@"is_admin"] = @(self.socialInfo.socialGroupInfo.userAuth > UserAuthTypeNormal);
    dict[@"report_params"] = [[reportDic JSONRepresentation] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    WeakSelf;
    dict[@"group_chat_page_exit_block"] = ^(void) {
        StrongSelf;
        // 返回是否需要刷新数据
    };
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    
    NSURL* url = [NSURL URLWithString:@"sslocal://open_group_chat"];
    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
}

- (void)gotoLogin {
    self.gotoGroupChatCount = 0;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *pageType = self.tracerDict[@"page_type"] ? : @"be_null";
    [params setObject:pageType forKey:@"enter_from"];
    if (self.ugcLoginType == FHUGCCommunityLoginTypeMemberTalk) {
        // community_member_talk(底部群聊入口)
        [params setObject:@"community_member_talk" forKey:@"enter_type"];
    } else if (self.ugcLoginType == FHUGCCommunityLoginTypeTip) {
        // community_tip(群聊引导弹窗)
        [params setObject:@"community_tip" forKey:@"enter_type"];
    }
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];
    params[@"from_ugc"] = @(YES);
    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                [wSelf reQuestSocialData:YES];
            }
        }
    }];
}

// 登录成功之后关注圈子
- (void)followSocialGroup:(BOOL)isFromLogin {
    // 关注
    __weak typeof(self) wSelf = self;
    BOOL hasFollow = [self.socialInfo.socialGroupInfo.hasFollow boolValue];
    if (self.socialInfo && self.socialInfo.socialGroupInfo.socialGroupId.length > 0) {
        [[FHUGCConfig sharedInstance] followUGCBy:self.socialInfo.socialGroupInfo.socialGroupId isFollow:YES completion:^(BOOL isSuccess) {
            if (!hasFollow && isSuccess) {
                // 未关注 执行关注成功
                [wSelf uploadFollowTracerDic];
            }
            if (isFromLogin) {
                [wSelf endUGCLoading];
            }
            if (isSuccess && isFromLogin) {
                // 登录-圈子数据更新-关注-群聊
                wSelf.socialInfo.socialGroupInfo.hasFollow = @"1";
                [wSelf groupChatAction];
            }
        }];
    } else {
        [self endUGCLoading];
    }
}

- (void)uploadFollowTracerDic {
    NSMutableDictionary *tracerDic = [self baseParams].mutableCopy;
    NSDictionary *log_pb = tracerDic[@"log_pb"];
    NSString *group_id = nil;
    if (log_pb && [log_pb isKindOfClass:[NSDictionary class]]) {
        group_id = log_pb[@"group_id"];
    }
    tracerDic[@"log_pb"] = self.socialInfo.socialGroupInfo.logPb ? self.socialInfo.socialGroupInfo.logPb : @"be_null";
    NSString *page_type = tracerDic[@"page_type"];
    tracerDic[@"enter_from"] = page_type ?: @"be_null";
    tracerDic[@"enter_type"] = @"click";
    tracerDic[@"group_id"] = group_id ?: @"be_null";
    if (self.ugcLoginType == FHUGCCommunityLoginTypeMemberTalk) {
         tracerDic[@"click_position"] = @"community_member_talk";
    } else if (self.ugcLoginType == FHUGCCommunityLoginTypeTip) {
        tracerDic[@"click_position"] = @"community_tip";
    }
    tracerDic[@"card_type"] = @"be_null";

    [FHUserTracker writeEvent:@"click_join" params:tracerDic];
}

- (void)startUGCLoading {
    self.bottomBar.bottomGroupChatBtn.enabled = NO;
    self.bottomBar.bottomGroupChatBtn.alpha = 1;
    ((FHBaseViewController *)self.belongsVC).hasValidateData = NO;
    [(FHBaseViewController *)self.belongsVC startLoading];
}

- (void)endUGCLoading {
    self.bottomBar.bottomGroupChatBtn.enabled = YES;
    self.bottomBar.bottomGroupChatBtn.alpha = 1;
    ((FHBaseViewController *)self.belongsVC).hasValidateData = YES;
    [(FHBaseViewController *)self.belongsVC endLoading];
}

// 登录成功重新拉取圈子数据
- (void)reQuestSocialData:(BOOL)isFromLogin {
    if (self.socialInfo && self.socialInfo.socialGroupInfo.socialGroupId.length > 0) {
        if (isFromLogin) {
            // 禁止按钮点击
            [self startUGCLoading];
        }
        __weak typeof(self) weakSelf = self;
        [FHHouseUGCAPI requestCommunityDetail:self.socialInfo.socialGroupInfo.socialGroupId tabName:nil class:[FHUGCScialGroupModel class] completion:^(id <FHBaseModelProtocol> model, NSError *error) {
            if (model && [model isKindOfClass:[FHUGCScialGroupModel class]]) {
                FHUGCScialGroupModel *socialModel = (FHUGCScialGroupModel *)model;
                // 更新数据 主要是群聊
                if (socialModel.data.chatStatus) {
                    weakSelf.socialInfo.socialGroupInfo.chatStatus.conversationId = socialModel.data.chatStatus.conversationId;
                    weakSelf.socialInfo.socialGroupInfo.chatStatus.conversationStatus = socialModel.data.chatStatus.conversationStatus;
                    weakSelf.socialInfo.socialGroupInfo.chatStatus.maxConversationCount = socialModel.data.chatStatus.maxConversationCount;
                    weakSelf.socialInfo.socialGroupInfo.chatStatus.currentConversationCount = socialModel.data.chatStatus.currentConversationCount;
                    weakSelf.socialInfo.socialGroupInfo.chatStatus.conversationShortId = socialModel.data.chatStatus.conversationShortId;
                    weakSelf.socialInfo.socialGroupInfo.chatStatus.idempotentId = socialModel.data.chatStatus.idempotentId;
                }
                // 圈子部分数据
                if (socialModel.data.socialGroupId.length > 0) {
                    weakSelf.socialInfo.socialGroupInfo.hasFollow = socialModel.data.hasFollow;
                    weakSelf.socialInfo.socialGroupInfo.followerCount = socialModel.data.followerCount;
                    weakSelf.socialInfo.socialGroupInfo.countText = socialModel.data.countText;
                    weakSelf.socialInfo.socialGroupInfo.contentCount = socialModel.data.contentCount;
                    
                    weakSelf.socialInfo.socialGroupInfo.userAuth = socialModel.data.userAuth;
                }
                // 刷新Cell
                if (socialModel.data.socialGroupId.length > 0) {
                    NSDictionary *userInfo = @{@"social_group_id":socialModel.data.socialGroupId};
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"kFHDetailNewUGCSocialCellNotiKey" object:nil userInfo:userInfo];
                }
                // 从登录过来的
                if (isFromLogin) {
                    if ([socialModel.data.hasFollow boolValue]) {
                        // 已关注
                        [weakSelf endUGCLoading];
                        [weakSelf groupChatAction];
                    } else {
                        // 未关注
                        [weakSelf followSocialGroup:isFromLogin];
                    }
                }
            } else {
                if (isFromLogin) {
                    [weakSelf endUGCLoading];
                }
            }
        }];
    }
}

// 回调方法
- (void)vc_viewDidAppear:(BOOL)animated
{
    [self.phoneCallViewModel vc_viewDidAppear:animated];
    // 新房重新拉取圈子数据 --  进入下个页面返回就拉新数据吧
    if (self.houseType == FHHouseTypeNewHouse && [TTReachability isNetworkConnected] && [TTAccountManager isLogin]) {
        self.needRefetchSocialGroupData = NO;
        [self reQuestSocialData:NO];
    }
}

- (void)vc_viewDidDisappear:(BOOL)animated
{
    [self.phoneCallViewModel vc_viewDidDisappear:animated];
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
    if (self.shareExtraDic) {
        [params addEntriesFromDictionary:self.shareExtraDic];
    }
    [FHUserTracker writeEvent:@"click_share" params:params];
}

- (void)addShareFormLog:(NSString *)platform
{
    NSMutableDictionary *params = @{}.mutableCopy;
    [params addEntriesFromDictionary:[self baseParams]];
    params[@"platform"] = platform ? : @"be_null";
    if (self.shareExtraDic) {
        [params addEntriesFromDictionary:self.shareExtraDic];
    }
    [FHUserTracker writeEvent:@"share_platform" params:params];
    self.shareExtraDic = nil;// 分享都会走当前方法
}

- (NSString *)elementTypeStringByHouseType:(FHHouseType)houseType
{
    switch (houseType) {
        case FHHouseTypeNeighborhood:
            return @"neighborhood_detail_button";
            break;
        case FHHouseTypeSecondHandHouse:
            return @"old_detail_button";
            break;
        case FHHouseTypeNewHouse:
            return @"new_detail_button";
            break;
            
        default:
            break;
    }
    return @"be_null";
}

- (void)addRealtorShowLog:(FHDetailContactModel *)contactPhone
{
    NSMutableDictionary *tracerDic = @{}.mutableCopy;
    tracerDic[@"page_type"] = self.tracerDict[@"page_type"] ? : @"be_null";
    tracerDic[@"element_type"] = [self elementTypeStringByHouseType:self.houseType];
    tracerDic[@"rank"] = self.tracerDict[@"rank"] ? : @"be_null";
    tracerDic[@"origin_from"] = self.tracerDict[@"origin_from"] ? : @"be_null";
    tracerDic[@"origin_search_id"] = self.tracerDict[@"origin_search_id"] ? : @"be_null";
    tracerDic[@"log_pb"] = self.tracerDict[@"log_pb"] ? : @"be_null";
    tracerDic[@"realtor_id"] = contactPhone.realtorId ?: @"be_null";
    tracerDic[@"realtor_rank"] = @(0);
    tracerDic[@"realtor_position"] = @"detail_button";
    tracerDic[@"realtor_logpb"] = contactPhone.realtorLogpb;
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
    tracerDic[@"element_type"] = [self elementTypeStringByHouseType:self.houseType];
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
    tracerDic[@"conversation_id"] = @"be_null";// 和wanran确认
    if (params[@"item_id"]) {
        tracerDic[@"item_id"] = params[@"item_id"];
    }
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
