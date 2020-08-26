//
//  FHHouseDetailPhoneCallViewModel.m
//  Pods
//
//  Created by 张静 on 2019/2/14.
//

#import "FHHouseDetailPhoneCallViewModel.h"
#import "FHHouseType.h"
#import "FHHouseDetailAPI.h"
#import "TTRoute.h"
#import "YYCache.h"
#import <FHCommonUI/ToastManager.h>
#import "TTReachability.h"
#import <TTPhotoScrollVC/TTPhotoScrollViewController.h>
#import "FHDetailBottomBarView.h"
#import "TTAccount.h"
#import <BDTrackerProtocol/BDTrackerProtocol.h>

#import <FHHouseBase/FHUserTracker.h>
#import <FHHouseBase/FHGeneralBizConfig.h>
#import <FHHouseBase/FHEnvContext.h>
#import "IMManager.h"
#import "HMDTTMonitor.h"
#import "FHUtils.h"
#import "NSDictionary+TTAdditions.h"
#import "FHIESGeckoManager.h"
#import <TTSettingsManager/TTSettingsManager.h>
#import "FHHouseIMClueHelper.h"

#define IM_OPEN_URL @"im_open_url"

extern NSString *const kFHToastCountKey;
extern NSString *const kFHPhoneNumberCacheKey;
extern NSString *const kFHPLoginhoneNumberCacheKey;

@interface FHHouseDetailPhoneCallViewModel ()

@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, copy) NSString *houseId;
@property (nonatomic, strong) NSMutableDictionary *imParams; //用于IM跟前端交互的字段

@end

@implementation FHHouseDetailPhoneCallViewModel

- (instancetype)initWithHouseType:(FHHouseType)houseType houseId:(NSString *)houseId
{
    self = [super init];
    if (self) {
        _houseType = houseType;
        _houseId = houseId;
        _rnIsUnAvalable = NO;
    }
    return self;
}

// extra:realtor_position element_from item_id
- (void)imchatActionWithPhone:(FHDetailContactModel *)contactPhone realtorRank:(NSString *)rank extraDic:(NSDictionary *)extra {
    
    // IM 透传数据模型
    FHAssociateIMModel *associateIMModel = [FHAssociateIMModel new];
    associateIMModel.houseId = self.houseId;
    associateIMModel.houseType = self.houseType;
    associateIMModel.associateInfo = extra[kFHAssociateInfo];
    BOOL isUseContactBizTrace = [extra[@"realtor_position"] isEqualToString:@"detail_button"] || [extra[@"realtor_position"] isEqualToString:@"detail_related"] || [extra[@"realtor_position"] isEqualToString:@"actually_survey"];
    if (contactPhone.bizTrace && [extra isKindOfClass:[NSDictionary class]] && isUseContactBizTrace) {
        if(extra[@"source_from"] && [extra[@"source_from"] isEqualToString:@"education_type"]){
            associateIMModel.extraInfo = @{@"biz_trace":self.houseInfoBizTrace};
        }else{
            associateIMModel.extraInfo = @{@"biz_trace":contactPhone.bizTrace};
        }
    }else{
        if (self.houseInfoBizTrace) {
            associateIMModel.extraInfo = @{@"biz_trace":self.houseInfoBizTrace};
        }
    }
    
    NSMutableDictionary *tempExtra = extra.mutableCopy;
    tempExtra[kFHAssociateInfo] = nil;
    extra = tempExtra.copy;
    
    // IM 相关埋点上报参数
    FHAssociateReportParams *reportParams = [FHAssociateReportParams new];
    reportParams.enterFrom = self.tracerDict[@"enter_from"] ? : @"be_null";
    reportParams.houseType = self.tracerDict[@"house_type"] ? : @"be_null";
    reportParams.elementFrom = self.tracerDict[@"element_from"] ? : @"be_null";
    reportParams.originFrom = self.tracerDict[@"origin_from"] ? : @"be_null";
    reportParams.logPb = self.tracerDict[@"log_pb"];
    reportParams.originSearchId = self.tracerDict[@"origin_search_id"] ? : @"be_null";
    reportParams.rank = self.tracerDict[@"rank"] ? : @"be_null";
    reportParams.cardType = self.tracerDict[@"card_type"] ? : @"be_null";
    reportParams.pageType = self.tracerDict[@"page_type"] ?: @"be_null";
    reportParams.realtorId = contactPhone.realtorId;
    reportParams.realtorRank = rank ? @(rank.integerValue): @(0);
    reportParams.realtorLogpb = contactPhone.realtorLogpb;
    reportParams.conversationId = @"be_null";
    reportParams.extra = extra;
    reportParams.realtorPosition = extra[@"realtor_position"];
    reportParams.searchId = self.tracerDict[@"search_id"] ? : @"be_null";
    reportParams.fromGid = self.tracerDict[@"from_gid"] ? : @"be_null";
    
    if(self.tracerDict[@"group_id"]) {
        reportParams.groupId = self.tracerDict[@"group_id"];
    } else if([self.tracerDict[@"log_pb"] isKindOfClass:NSDictionary.class]) {
        reportParams.groupId = (self.tracerDict[@"log_pb"][@"group_id"] ? : @"be_null");
    } else {
        reportParams.groupId = @"be_null";
    }
    
    associateIMModel.reportParams = reportParams;
    
    // IM跳转链接
    associateIMModel.imOpenUrl = extra[IM_OPEN_URL]?:contactPhone.imOpenUrl;
    
    // 配置静默关注回调
    WeakSelf;
    associateIMModel.slientFollowCallbackBlock = ^(BOOL isSuccess) {
        if (isSuccess) {
            wself.isEnterIM = YES;
        }
    };
    // 跳转IM
    [FHHouseIMClueHelper jump2SessionPageWithAssociateIM:associateIMModel];
}

- (void)silentFollow:(NSDictionary *)extraDict
{
    NSMutableDictionary *params = @{}.mutableCopy;
    if (self.tracerDict) {
        [params addEntriesFromDictionary:self.tracerDict];
    }
    if (extraDict) {
        [params addEntriesFromDictionary:extraDict];
    }
    FHHouseFollowUpConfigModel *configModel = [[FHHouseFollowUpConfigModel alloc]initWithDictionary:params error:nil];
    configModel.houseType = self.houseType;
    configModel.followId = self.houseId;
    configModel.actionType = self.houseType;
    configModel.hideToast = YES;
    // 静默关注功能
    __weak typeof(self)wself = self;
    [FHHouseFollowUpHelper silentFollowHouseWithConfigModel:configModel completionBlock:^(BOOL isSuccess) {
        if (isSuccess) {
            wself.isEnterIM = YES;
        }
    }];
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


- (void)jump2RealtorDetailWithPhone:(FHDetailContactModel *)contactPhone isPreLoad:(BOOL)isPre extra:(NSDictionary*)extra
{
    TTRouteObject *routeObj = [self creatJump2RealtorDetailWithPhone:contactPhone isPreLoad:NO andIsOpen:YES extra:extra];
          if ([routeObj.instance isKindOfClass:[UIViewController class]] && [self.belongsVC isKindOfClass:[UIViewController class]]) {
              [self.belongsVC.navigationController pushViewController:(UIViewController *)routeObj.instance animated:YES];
          }
//        [self creatJump2RealtorDetailWithPhone:contactPhone isPreLoad:NO andIsOpen:YES extra:extra];
}

- (TTRouteObject *)creatJump2RealtorDetailWithPhone:(FHDetailContactModel *)contactPhone isPreLoad:(BOOL)isPre andIsOpen:(BOOL)isOpen extra:(NSDictionary*)extra
{
    if (contactPhone.realtorId.length < 1) {
        return nil;
    }
    NSDictionary *settings = [self fhSettings];
    BOOL openNewRealtor = [settings btd_boolValueForKey:@"f_new_realtor_detail"];
    if (openNewRealtor) {
            NSURL *openUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://new_realtor_detail"]];
        NSMutableDictionary *info = @{}.mutableCopy;
        info[@"title"] = @"经纪人主页";
        info[@"realtor_id"] = contactPhone.realtorId;
        NSMutableDictionary *tracerDic = self.tracerDict.mutableCopy;
        tracerDic[@"element_from"] = extra[@"element_from"] ? : [self elementTypeStringByHouseType:self.houseType];
        info[@"tracer"] = tracerDic;
        info[@"house_id"] = _houseId;
        info[@"house_type"] = @(_houseType);
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:info];
        TTRouteObject *routeObj = [[TTRoute sharedRoute] routeObjWithOpenURL:openUrl userInfo:userInfo];
        return routeObj;
    }else {
            NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
            //    NSString *host = @"http://10.1.15.29:8889";
            NSURL *openUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://realtor_detail?realtor_id=%@",contactPhone.realtorId]];
        
            NSMutableDictionary *dict = @{}.mutableCopy;
            if (extra[@"enter_from"]) {
                dict[@"enter_from"] = extra[@"enter_from"];
            }else {
                dict[@"enter_from"] = self.tracerDict[@"page_type"] ? : @"be_null";
            }
            dict[@"element_from"] = extra[@"element_from"] ? : [self elementTypeStringByHouseType:self.houseType];
            dict[@"origin_from"] = self.tracerDict[@"origin_from"] ? : @"be_null";
            id logPb = self.tracerDict[@"log_pb"];
            if ([logPb isKindOfClass:[NSDictionary class]]) {
                dict[@"log_pb"] = logPb;
            }else if ([logPb isKindOfClass:[NSString class]]){
                NSString * logPbStr = (NSString *)logPb;
                logPbStr = [logPbStr stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
                NSData *logPbData = [logPbStr dataUsingEncoding:NSUTF8StringEncoding];
                if (logPbData) {
                    NSDictionary *logPbDict = [NSJSONSerialization JSONObjectWithData:logPbData options:kNilOptions error:nil];
                    dict[@"log_pb"] = logPbDict;
                }
        
            }
            dict[@"search_id"] = self.tracerDict[@"search_id"] ? : @"be_null";
            dict[@"origin_search_id"] = self.tracerDict[@"origin_search_id"] ? : @"be_null";
            dict[@"group_id"] = self.houseId ? : @"be_null";
            dict[@"rank"] = self.tracerDict[@"rank"] ? : @"be_null";
            dict[@"card_type"] = self.tracerDict[@"card_type"] ? : @"be_null";
            if ([self.tracerDict[@"log_pb"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *logPbDict = self.tracerDict[@"log_pb"];
                dict[@"impr_id"] = logPbDict[@"impr_id"] ? : @"be_null";
                dict[@"search_id"] = logPbDict[@"search_id"] ? : @"be_null";
        //        dict[@"group_id"] = logPbDict[@"group_id"] ? : @"be_null";
            }
            dict[@"realtor_rank"] = @"be_null";
            dict[@"realtor_position"] = @"be_null";
            dict[@"is_login"] = [[TTAccount sharedAccount] isLogin] ? @"1" : @"0";
            dict[@"from"] = @"app_realtor_mainpage";
            dict[@"realtor_logpb"] = contactPhone.realtorLogpb;
            if (extra[@"enter_from"]) {
                dict[@"enter_from"] = extra[@"enter_from"];
            }
        
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
            imdic[@"source"] = @"app_realtor_mainpage";
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
            }
        return nil;
    }
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
            
        default:
            break;
    }
    return @"be_null";
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

// 回调方法
- (void)vc_viewDidAppear:(BOOL)animated
{
    if (self.isEnterIM) {
        [FHHouseFollowUpHelper showFollowToast];
        self.isEnterIM = NO;
    }
}

- (void)vc_viewDidDisappear:(BOOL)animated
{
    
}


+ (NSDictionary *)fhSettings {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kFHSettingsKey"]){
        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kFHSettingsKey"];
    } else {
        return nil;
    }
}

- (NSDictionary *)fhSettings {
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
