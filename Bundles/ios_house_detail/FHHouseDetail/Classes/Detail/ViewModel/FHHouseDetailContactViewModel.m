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
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "ToastManager.h"
#import "IMManager.h"
#import <BDTrackerProtocol/BDTrackerProtocol.h>

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
#import "FHErrorHubManagerUtil.h"
#import "FHDetailNewModel.h"
#import "FHDetailOldModel.h"
#import "FHDetailNeighborhoodModel.h"
#import "FHFloorMoreCoreInfoViewController.h"
#import "FHDetailNewCoreDetailModel.h"
#import "FHFloorPanListViewController.h"
#import "FHDetailRentModel.h"
#import "TTAccountLoginManager.h"
#import "FHUtils.h"
#import "BDABTestManager.h"
#import <ByteDanceKit/NSDictionary+BTDAdditions.h>
#import "FHNewHouseDetailViewController.h"
#import "FHNeighborhoodDetailViewController.h"
#import <FHShareManager.h>
#import "SSCommonLogic.h"

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
        
//        [FHEnvContext sharedInstance].messageManager ;
        
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
        [_navBar displayMessageDot:[[FHEnvContext sharedInstance].messageManager getTotalUnreadMessageCount]];
    } else {
        [_navBar displayMessageDot:0];
    }
}

- (void)refreshFollowStatus:(NSNotification *)noti
{
    NSDictionary *userInfo = noti.userInfo;
    NSString *followId = [userInfo btd_stringValueForKey:@"followId"];
    NSInteger followStatus = [userInfo btd_integerValueForKey:@"followStatus"];
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
    NSString *houseId = [userInfo btd_stringValueForKey:@"house_id"];
    NSInteger loading = [userInfo btd_integerValueForKey:@"show_loading"];
    if (![houseId isEqualToString:self.houseId]) {
        return;
    }
    if (loading) {
        [self.bottomBar startLoading];
    }else {
        [self.bottomBar stopLoading];
    }
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
- (void)followActionWithExtra:(NSDictionary * _Nullable)extra {
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
    if (![TTAccount sharedAccount].isLogin) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSString *page_type = self.tracerDict[@"page_type"] ?: @"be_null";
        [params setObject:page_type forKey:@"enter_from"];
        [params setObject:@"click_favorite" forKey:@"enter_type"];
        [params setObject:@"click_favorite" forKey:@"enter_method"];
        // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
        [params setObject:@(YES) forKey:@"need_pop_vc"];
        __weak typeof(self) wSelf = self;
        self.isShowLogin = YES;
        [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
            if (type == TTAccountAlertCompletionEventTypeDone) {
                // 登录成功
                if ([TTAccountManager isLogin]) {
                    wSelf.isShowLogin = NO;
                    [FHHouseFollowUpHelper followHouseWithConfigModel:configModel];
                }else{
//                    [[ToastManager manager] showToast:@"需要先登录才能进行操作哦"];
                }
            }
        }];
    }else{
        [FHHouseFollowUpHelper followHouseWithConfigModel:configModel];
    }
  
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
        [self.phoneCallViewModel jump2RealtorDetailWithPhone:self.contactPhone isPreLoad:YES extra:@{}];
    }
}

- (void)licenseAction
{
    [self.phoneCallViewModel licenseActionWithPhone:self.contactPhone];
}

// 详情页分享
- (void)shareAction {
    if([[FHShareManager shareInstance] isShareOptimization]) {
        [self showSharePanel];
        return;
    }
    
    [self shareActionWithShareExtra:@{}];
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

- (void)showSharePanel {
    FHShareDataModel *dataModel = [[FHShareDataModel alloc] init];
    
    NSMutableArray *itemArray = [NSMutableArray arrayWithArray: @[@(FHShareChannelTypeWeChat),@(FHShareChannelTypeWeChatTimeline),@(FHShareChannelTypeQQFriend),@(FHShareChannelTypeQQZone),@(FHShareChannelTypeCopyLink)]];
    
    FHShareCommonDataModel *commonDataModel = [[FHShareCommonDataModel alloc] init];
    commonDataModel.title = self.shareInfo.title;
    commonDataModel.desc = self.shareInfo.desc;
    commonDataModel.shareUrl = self.shareInfo.shareUrl;
    commonDataModel.thumbImage = [[BDImageCache sharedImageCache]imageFromDiskCacheForKey:self.shareInfo.coverImage] ? : [UIImage imageNamed:@"default_image"];
    commonDataModel.shareType = BDUGShareWebPage;
    dataModel.commonDataModel = commonDataModel;
    

    if(TTAccountManager.isLogin && (self.houseType == FHHouseTypeSecondHandHouse || self.houseType == FHHouseTypeRentHouse) && self.imShareInfo && [self hasImUser]) {
        FHShareIMDataModel *imDataModel = [[FHShareIMDataModel alloc] init];
        imDataModel.imShareInfo = self.imShareInfo;
        NSMutableDictionary* dict = [self.tracerDict mutableCopy] ;
        dict[@"enter_from"] = dict[@"page_type"];
        imDataModel.tracer = dict;
        if (self.houseInfoBizTrace) {
            imDataModel.extraInfo = @{@"biz_trace":self.houseInfoBizTrace};
        }
        dataModel.imDataModel = imDataModel;
        [itemArray insertObject:@(FHShareChannelTypeIM) atIndex:0];
    }
    NSArray *contentItemArray = @[itemArray];


    FHShareContentModel *model = [[FHShareContentModel alloc] initWithDataModel:dataModel contentItemArray:contentItemArray];
    [[FHShareManager shareInstance] showSharePanelWithModel:model tracerDict:[self baseParams]];
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
    [params setValue:self.houseInfoBizTrace forKey:@"biz_trace"];
    [params setValue: [[FHEnvContext sharedInstance].messageManager getTotalUnreadMessageCount] >0?@"1":@"0" forKey:@"with_tips"];
    [FHUserTracker writeEvent:@"click_im_message" params:params];
    
    
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
    
    if (!contactPhone.enablePhone) {
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
    if (self.bottomBar) {
        self.showenOnline = self.bottomBar.showIM;// 显示在线联系（详情图册页面）
    }
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
            [self.phoneCallViewModel creatJump2RealtorDetailWithPhone:contactPhone isPreLoad:YES andIsOpen:NO extra:@{}];
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
    _phoneCallViewModel.houseInfoBizTrace = self.houseInfoBizTrace;
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
        [FHUserTracker writeEvent:@"element_show" params:params];
    }
}

// 拨打电话 + 询底价填表单
- (void)contactAction
{
    NSMutableDictionary *extraDict = @{}.mutableCopy;
    NSDictionary *associateInfoDict = self.contactPhone.enablePhone ? self.highlightedRealtorAssociateInfo.phoneInfo : self.highlightedRealtorAssociateInfo.reportFormInfo;
    extraDict[kFHAssociateInfo] = associateInfoDict?:@{};
    extraDict[@"position"] = @"button";
    extraDict[@"enter_type"] = @"click_button";
    [self contactActionWithExtraDict:extraDict];
}

- (void)contactActionWithExtraDict:(NSDictionary *)extraDict
{
    NSDictionary *associateInfoDict = nil;
    if (extraDict[kFHAssociateInfo]) {
        associateInfoDict = extraDict[kFHAssociateInfo];
    }
    NSMutableDictionary *reportParamsDict = [self baseParams].mutableCopy;
    reportParamsDict[@"realtor_logpb"] = self.contactPhone.realtorLogpb;
    reportParamsDict[@"realtor_id"] = self.contactPhone.realtorId ? : @"be_null";
    
    if (extraDict.count > 0) {
        [reportParamsDict addEntriesFromDictionary:extraDict];
    }
    if (!self.contactPhone.enablePhone) {
        // 填表单
        NSMutableDictionary *associateParamDict = @{}.mutableCopy;
        associateParamDict[kFHReportParams] = reportParamsDict;
        associateParamDict[kFHAssociateInfo] = associateInfoDict;
        
        NSString *title = nil;
        NSString *subtitle = nil;
        NSString *btnTitle = nil;
        if (self.houseType == FHHouseTypeNeighborhood) {
            title = @"咨询经纪人";
            btnTitle = @"提交";
        }
        if ([SSCommonLogic isEnableVerifyFormAssociate]) {
            switch (self.houseType) {
                case FHHouseTypeSecondHandHouse:
                case FHHouseTypeNeighborhood:
                    title = @"询底价";
                    subtitle = @"提交后，我们将给您匹配专业的经纪人为您提供咨询服务。";
                    btnTitle = @"获取底价";
                    break;
                case FHHouseTypeNewHouse:
                    title = @"询底价";
                    subtitle = @"提交后，我们将给您匹配专业的置业顾问为您提供咨询服务。";
                    btnTitle = @"获取底价";
                    break;
                default:
                    break;
            }
        }
        
        if (title.length) {
            associateParamDict[@"title"] = title;
        }
        if (subtitle.length) {
            associateParamDict[@"subtitle"] = subtitle;
        }
        if (btnTitle.length) {
            associateParamDict[@"btn_title"] = btnTitle;
        }
        [self fillFormActionWithParams:associateParamDict.copy];
    }else {
        
        //        associatePhone.realtorType = self.contactPhone.realtorType;
        FHAssociatePhoneModel *associatePhone = [[FHAssociatePhoneModel alloc]init];
        associatePhone.reportParams = reportParamsDict;
        associatePhone.associateInfo = associateInfoDict;
        
        associatePhone.houseType = self.houseType;
        associatePhone.houseId = self.houseId;
        //
        associatePhone.searchId = self.searchId;
        associatePhone.imprId = self.imprId;
        associatePhone.showLoading = YES;
        associatePhone.realtorId = self.contactPhone.realtorId;
        //如果是底部展位用自己的biz_trace，其余用详情页的biz_trace
        if (self.contactPhone.bizTrace && extraDict[@"position"] && [extraDict[@"position"] isEqualToString:@"button"]) {
            associatePhone.extraDict = @{@"biz_trace":self.contactPhone.bizTrace};
        }else{
            if(self.houseInfoBizTrace){
                associatePhone.extraDict = @{@"biz_trace":self.houseInfoBizTrace};
            }
        }
        // 拨打电话
        [self callActionWithAssociatePhone:associatePhone];
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
    imExtra[@"from"] = params[@"from"];
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
        
        if(extraDict[kFHAssociateInfo]) {
            imExtra[kFHAssociateInfo] = extraDict[kFHAssociateInfo];
            //        if ([extraDict[@"source_from"] isEqualToString:@"loan"]) {
            //           imExtra[@"realtor_position"] = @"loan";
        }
        //099 大图详情新增 picture_type
        if (extraDict[@"picture_type"]) {
            imExtra[@"picture_type"] = extraDict[@"picture_type"];
        }
        //100 户型详情页新增 click_position
        if (extraDict[@"click_position"]) {
            imExtra[@"click_position"] = extraDict[@"click_position"];
        }
        if (extraDict[@"enter_from"]) {
            imExtra[@"enter_from"] = extraDict[@"enter_from"];
        }
        if (extraDict[@"page_type"]) {
            imExtra[@"page_type"] = extraDict[@"page_type"];
        }
        if (extraDict[@"event_tracking_id"]) {
            imExtra[@"event_tracking_id"] = extraDict[@"event_tracking_id"];
        }
        if (extraDict[@"position"]) {
            imExtra[@"position"] = extraDict[@"position"];
        }
    }
    [self.phoneCallViewModel imchatActionWithPhone:self.contactPhone realtorRank:@"0" extraDic:imExtra];
}

#pragma mark - associate refactor
- (void)callActionWithAssociatePhone:(FHAssociatePhoneModel *)associatePhone
{
    WeakSelf;
//    NSDictionary *associateInfoDict = associatePhone.associateInfo;
    NSDictionary *reportParamsDict = associatePhone.reportParams;

    NSString *realtorId = associatePhone.realtorId;
    [FHHousePhoneCallUtils callWithAssociatePhoneModel:associatePhone completion:^(BOOL success, NSError * _Nonnull error, FHDetailVirtualNumModel * _Nonnull virtualPhoneNumberModel) {
        
        if(success && [wself.phoneCallViewModel.belongsVC isKindOfClass:[FHHouseDetailViewController class]]){
            FHHouseDetailViewController *vc = (FHHouseDetailViewController *)wself.phoneCallViewModel.belongsVC;
            vc.isPhoneCallShow = YES;
            vc.phoneCallRealtorId = realtorId;
            vc.phoneCallRequestId = virtualPhoneNumberModel.requestId;
        }
    }];
    FHHouseFollowUpConfigModel *configModel = [[FHHouseFollowUpConfigModel alloc]initWithDictionary:reportParamsDict error:nil];
    configModel.houseType = associatePhone.houseType;
    configModel.followId = associatePhone.houseId;
    configModel.actionType = associatePhone.houseType;
    
    // 静默关注功能
    [FHHouseFollowUpHelper silentFollowHouseWithConfigModel:configModel];
}
- (void)fillFormActionWithParams:(NSDictionary *)formParamsDict
{
    NSString *title = nil;
    NSString *subtitle = self.subTitle;
    NSString *btnTitle = @"获取底价";
    NSString *toast = self.toast;
    NSDictionary *associateInfoDict = formParamsDict[kFHAssociateInfo];
    NSDictionary *reportParamsDict = formParamsDict[kFHReportParams];
    
    
    if (formParamsDict[@"title"]) {
        title = formParamsDict[@"title"];
    }
    if (formParamsDict[@"subtitle"]) {
        subtitle = formParamsDict[@"subtitle"];
    }
    if (formParamsDict[@"btn_title"]) {
        btnTitle = formParamsDict[@"btn_title"];
    }
    if (formParamsDict[@"toast"]) {
        toast = formParamsDict[@"toast"];
    }
    
    FHAssociateFormReportModel *associateReport = [[FHAssociateFormReportModel alloc] init];

    if (title.length > 0) {
        associateReport.title = title;
    }
    if (subtitle.length > 0) {
        associateReport.subtitle = subtitle;
    }
    if (toast.length > 0) {
        associateReport.toast = toast;
    }
    if (btnTitle.length > 0) {
        associateReport.btnTitle = btnTitle;
    }
    associateReport.houseType = self.houseType;
    associateReport.houseId = self.houseId;
    associateReport.topViewController = self.belongsVC;
    associateReport.reportParams = reportParamsDict;
    associateReport.associateInfo = associateInfoDict;
    associateReport.chooseAgencyList = self.chooseAgencyList;
    
    NSMutableDictionary *extraInfo = @{}.mutableCopy;
    extraInfo[@"biz_trace"] = self.houseInfoBizTrace.length ? self.houseInfoBizTrace : @"be_null";
    extraInfo[@"origin_from"] = reportParamsDict[@"origin_from"] ?: @"be_null";
    associateReport.extraInfo = extraInfo.copy;
    
    [FHHouseFillFormHelper fillFormActionWithAssociateReportModel:associateReport completion:nil];
}

- (void)imAction {
    NSMutableDictionary *extraDic = @{@"realtor_position":@"detail_button",
                                      @"position":@"button"}.mutableCopy;
    if (self.contactPhone.unregistered && self.contactPhone.imLabel.length > 0) {
        extraDic[@"position"] = @"online";
        extraDic[@"realtor_position"] = @"online";
    }
    
    // ------------- 房源详情页 --------------------//
    if([self.belongsVC isKindOfClass:FHHouseDetailViewController.class] ||
       [self.belongsVC isKindOfClass:FHNewHouseDetailViewController.class] ||
       [self.belongsVC isKindOfClass:FHNeighborhoodDetailViewController.class]) {
        FHHouseDetailViewController *houseDetailVC = (FHHouseDetailViewController *)self.belongsVC;
        NSObject *detailData  = houseDetailVC.viewModel.detailData;
        switch(houseDetailVC.viewModel.houseType) {
            case FHHouseTypeNewHouse:
            {
                // 新房详情页
                if([detailData isKindOfClass:FHDetailNewModel.class]) {
                    FHDetailNewModel *detailNewModel = (FHDetailNewModel *)detailData;
                    if(detailNewModel.data.highlightedRealtorAssociateInfo) {
                        extraDic[kFHAssociateInfo] = detailNewModel.data.highlightedRealtorAssociateInfo;
                    }
                }
            }
                break;
            case FHHouseTypeSecondHandHouse:
            {
                // 二手房详情页
                if([detailData isKindOfClass:FHDetailOldModel.class]) {
                    FHDetailOldModel *detailOldModel = (FHDetailOldModel *)detailData;
                    if(detailOldModel.data.highlightedRealtorAssociateInfo) {
                        extraDic[kFHAssociateInfo] = detailOldModel.data.highlightedRealtorAssociateInfo;
                    }
                }
            }
                break;
            case FHHouseTypeRentHouse:
            {
                // 租房详情页
                if([detailData isKindOfClass:FHRentDetailResponseModel.class]) {
                    FHRentDetailResponseModel *detailRentalModel = (FHRentDetailResponseModel *)detailData;
                    if(detailRentalModel.data.highlightedRealtorAssociateInfo) {
                        extraDic[kFHAssociateInfo] = detailRentalModel.data.highlightedRealtorAssociateInfo;
                    }
                }
            }
                break;
            case FHHouseTypeNeighborhood:
            {
                // 小区详情页
                if([detailData isKindOfClass:FHDetailNeighborhoodModel.class]) {
                    FHDetailNeighborhoodModel *detailNeighborhoodModel = (FHDetailNeighborhoodModel *)detailData;
                    if(detailNeighborhoodModel.data.highlightedRealtorAssociateInfo) {
                        extraDic[kFHAssociateInfo] = detailNeighborhoodModel.data.highlightedRealtorAssociateInfo;
                    }
                }
            }
                break;
            default:
                break;
        }
    }
    
    // ------------- 房源详情页子页面 ---------------//
    
    if([self.belongsVC isKindOfClass:FHHouseDetailSubPageViewController.class]) {
        FHHouseDetailSubPageViewController *detailSubPageVC = (FHHouseDetailSubPageViewController *)self.belongsVC;
        NSObject *detailSubData = detailSubPageVC.viewModel.detailData;
        //新房详情页楼盘信息子页面
        if([detailSubData isKindOfClass:FHDetailNewCoreDetailModel.class]) {
            FHDetailNewCoreDetailModel *detailNewCoreDetailModel = (FHDetailNewCoreDetailModel *)detailSubData;
            if(detailNewCoreDetailModel.data.highlightedRealtorAssociateInfo) {
                extraDic[kFHAssociateInfo] = detailNewCoreDetailModel.data.highlightedRealtorAssociateInfo;
            }
        }
        // 新房详情页户型列表页子页面
        if([detailSubData isKindOfClass:FHDetailFloorPanListResponseModel.class]) {
            FHDetailFloorPanListResponseModel *detailFloorPanListModel = (FHDetailFloorPanListResponseModel *)detailSubData;
            if(detailFloorPanListModel.data.highlightedRealtorAssociateInfo) {
                extraDic[kFHAssociateInfo] = detailFloorPanListModel.data.highlightedRealtorAssociateInfo;
            }
        }
    }
    
    [self onlineActionWithExtraDict:extraDic];
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
        NSString *title = [NSString stringWithFormat:@"%@(%ld)",self.socialInfo.socialGroupInfo.socialGroupName, (unsigned long)self.socialInfo.socialGroupInfo.chatStatus.currentConversationCount];
        dict[@"chat_title"] = title;
    } else {
        NSInteger count = [[IMManager shareInstance].chatService sdkConversationWithIdentifier:convId].participantsCount;
        NSString *title = [NSString stringWithFormat:@"%@(%ld)", self.socialInfo.socialGroupInfo.socialGroupName, (long)count];
        dict[@"chat_title"] = title;
        dict[@"in_conversation"] = @"1";
        dict[@"conversation_id"] = self.socialInfo.socialGroupInfo.chatStatus.conversationId;
        dict[@"short_conversation_id"] = [[NSNumber numberWithLongLong:self.socialInfo.socialGroupInfo.chatStatus.conversationShortId] stringValue];
    }
    dict[@"member_role"] = [NSString stringWithFormat: @"%ld",(unsigned long)self.socialInfo.socialGroupInfo.userAuth];
    dict[@"is_admin"] = @(self.socialInfo.socialGroupInfo.userAuth > UserAuthTypeNormal);
    dict[@"report_params"] = [reportDic btd_jsonStringEncoded];
    
//    WeakSelf;
    dict[@"group_chat_page_exit_block"] = ^(void) {
//        StrongSelf;
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
    tracerDic[@"biz_trace"] = contactPhone.bizTrace;
    [tracerDic setValue:_contactPhone.enablePhone? @"1" : @"0" forKey:@"phone_show"];
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
    tracerDic[@"is_call"] = contactPhone.enablePhone ? @"1" : @"0";
    tracerDic[@"is_report"] = contactPhone.isFormReport ? @"1" : @"0";
    tracerDic[@"is_online"] = _contactPhone.unregistered?@"1":@"0";
    tracerDic[@"biz_trace"] = contactPhone.bizTrace?:@"be_null";
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
        if (self.houseInfoBizTrace) {
            activity.extraInfo = @{@"biz_trace":self.houseInfoBizTrace};
        }
        [TTShareManager addUserDefinedActivity:activity];
        [self.shareManager updateBizTraceExtraInfo:activity.extraInfo  activity:activity];
    }
    return _shareManager;
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
