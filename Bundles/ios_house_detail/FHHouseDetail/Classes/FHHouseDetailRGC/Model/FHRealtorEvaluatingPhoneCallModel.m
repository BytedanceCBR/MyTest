//
//  FHRealtorEvaluatingPhoneCallModel.m
//  FHHouseDetail
//
//  Created by liuyu on 2020/6/17.
//

#import "FHRealtorEvaluatingPhoneCallModel.h"
#import "FHAssociateIMModel.h"
#import "FHHouseIMClueHelper.h"
#import "FHHousePhoneCallUtils.h"
#import "FHIESGeckoManager.h"
#import "FHEnvContext.h"
#import "FHRNHelper.h"
#import "FHURLSettings.h"
#import "IMManager.h"
#import "TTAccount.h"
#import "FHUtils.h"
#import "NSDictionary+TTAdditions.h"
#define IM_OPEN_URL @"im_open_url"
@interface FHRealtorEvaluatingPhoneCallModel ()
@property (nonatomic, assign) FHHouseType houseType; // 房源类型
@property (nonatomic, copy) NSString *houseId;
@property (nonatomic, strong) NSMutableDictionary *imParams; //用于IM跟前端交互的字段
@property (nonatomic, assign) BOOL rnIsUnAvalable;
@end
@implementation FHRealtorEvaluatingPhoneCallModel
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
- (void)imchatActionWithPhone:(FHFeedUGCCellRealtorModel *)realtorModel realtorRank:(NSString *)rank extraDic:(NSDictionary *)extra {
    
    // IM 透传数据模型
    FHAssociateIMModel *associateIMModel = [FHAssociateIMModel new];
    associateIMModel.houseId = self.houseId;
    associateIMModel.houseType = self.houseType;
    associateIMModel.associateInfo = realtorModel.associateInfo;
    NSMutableDictionary *tempExtra = extra.mutableCopy;
    tempExtra[kFHAssociateInfo] = nil;
    extra = tempExtra.copy;
    
    // IM 相关埋点上报参数
    FHAssociateReportParams *reportParams = [FHAssociateReportParams new];
    reportParams.enterFrom = self.tracerDict[@"enter_from"] ? : @"be_null";
    reportParams.elementFrom = self.tracerDict[@"element_from"] ? : @"be_null";
    reportParams.originFrom = self.tracerDict[@"origin_from"] ? : @"be_null";
    reportParams.logPb = self.tracerDict[@"log_pb"];
    reportParams.fromGid = extra[@"from_gid"]?:@"be_null";
    reportParams.originSearchId = self.tracerDict[@"origin_search_id"] ? : @"be_null";
    reportParams.rank = (rank.length > 0) ? rank : (self.tracerDict[@"rank"] ? : @"be_null");
    reportParams.cardType = self.tracerDict[@"card_type"] ? : @"be_null";
    reportParams.pageType = self.tracerDict[@"page_type"] ?: @"be_null";
    reportParams.realtorId = realtorModel.realtorId;
    reportParams.realtorRank = rank ?[NSNumber numberWithInt:rank.intValue]: 0;
    reportParams.realtorLogpb = realtorModel.realtorLogpb;
    reportParams.conversationId = @"be_null";
    reportParams.extra = extra;
    reportParams.realtorPosition = extra[@"realtor_position"];
    reportParams.searchId = self.tracerDict[@"search_id"] ? : @"be_null";
    
    if(self.tracerDict[@"group_id"]) {
        reportParams.groupId = self.tracerDict[@"group_id"];
    } else if([self.tracerDict[@"log_pb"] isKindOfClass:NSDictionary.class]) {
        reportParams.groupId = (self.tracerDict[@"log_pb"][@"group_id"] ? : @"be_null");
    } else {
        reportParams.groupId = @"be_null";
    }
    
    associateIMModel.reportParams = reportParams;
    
    // IM跳转链接
    associateIMModel.imOpenUrl = extra[IM_OPEN_URL]?:realtorModel.chatOpenurl;
    
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

- (void)phoneChatActionWithAssociateModel:(FHAssociatePhoneModel *)associatePhoneModel {
    [FHHousePhoneCallUtils callWithAssociatePhoneModel:associatePhoneModel completion:^(BOOL success, NSError * _Nonnull error, FHDetailVirtualNumModel * _Nonnull virtualPhoneNumberModel) {
    }];
}

- (void)jump2RealtorDetailWithPhone:(FHFeedUGCCellRealtorModel *)contactPhone isPreLoad:(BOOL)isPre extra:(NSDictionary*)extra
{
    //如果没有资源，走H5
    if (![FHIESGeckoManager isHasCacheForChannel:@"f_realtor_detail"] || self.rnIsUnAvalable) {
        [self creatJump2RealtorDetailWithPhone:contactPhone isPreLoad:NO andIsOpen:YES extra:extra];
        return;
    }
    
    if ([FHRealtorEvaluatingPhoneCallModel isEnableCurrentChannel]) {
        if (isPre && [FHEnvContext isNetworkConnected]) {
            TTRouteObject *routeAgentObj = [[FHRNHelper sharedInstance] getRNCacheForCacheKey:self.hash];
            if ([routeAgentObj.instance isKindOfClass:[UIViewController class]] && [self.belongsVC isKindOfClass:[UIViewController class]]) {
                [self.belongsVC.navigationController pushViewController:routeAgentObj.instance animated:YES];
            }else
            {
                TTRouteObject *routeObj = [self creatJump2RealtorDetailWithPhone:contactPhone isPreLoad:NO andIsOpen:NO extra:extra];
                if ([routeObj.instance isKindOfClass:[UIViewController class]] && [self.belongsVC isKindOfClass:[UIViewController class]]) {
                    [self.belongsVC.navigationController pushViewController:routeObj.instance animated:YES];
                }else
                {
                    [self creatJump2RealtorDetailWithPhone:contactPhone isPreLoad:NO andIsOpen:YES extra:extra];
                }
            }
        }else
        {
            TTRouteObject *routeObj = [self creatJump2RealtorDetailWithPhone:contactPhone isPreLoad:NO andIsOpen:NO extra:extra];
            if ([routeObj.instance isKindOfClass:[UIViewController class]] && [self.belongsVC isKindOfClass:[UIViewController class]]) {
                    [self.belongsVC.navigationController pushViewController:routeObj.instance animated:YES];
            }else
            {
                [self creatJump2RealtorDetailWithPhone:contactPhone isPreLoad:NO andIsOpen:YES extra:extra];
            }
        }
    }else
    {
        [self creatJump2RealtorDetailWithPhone:contactPhone isPreLoad:NO andIsOpen:YES extra:extra];
    }
}

- (TTRouteObject *)creatJump2RealtorDetailWithPhone:(FHFeedUGCCellRealtorModel *)contactPhone isPreLoad:(BOOL)isPre andIsOpen:(BOOL)isOpen extra:(NSDictionary*)extra
{
    if (contactPhone.realtorId.length < 1) {
        return nil;
    }
    
    if (![FHIESGeckoManager isHasCacheForChannel:@"f_realtor_detail"] && !isOpen) {
        return nil;
    }
    
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
//    imdic[kFHCluePage] = @(FHClueIMPageTypeCExpertDetail);// todo zjing
//    imdic[kFHClueEndpoint] = @(FHClueEndPointTypeC);
//    NSURL *url = [NSURL URLWithString:contactPhone.realtorDetailUrl];
//    if (url) {
//        NSURLComponents* components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
//        NSMutableArray<NSURLQueryItem *> *queryItems = [components.queryItems mutableCopy];
//        NSURLQueryItem *imQueryItem;
//        for(NSURLQueryItem *queryItem in components.queryItems){
//            if([queryItem.name isEqualToString:@"im_params"]){
//                imQueryItem = queryItem;
//                break;
//            }
//        }
//        if (imQueryItem.value.length > 0) {
//            NSError *err;
//            NSString *imParamStr = [imQueryItem.value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            NSData *jsondata = [imParamStr dataUsingEncoding:NSUTF8StringEncoding];
//            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsondata options:NSJSONReadingMutableContainers error:&err];
//            if (!err && dic) {
//                [imdic addEntriesFromDictionary:dic];
//            }
//        }
//    }
    NSString *imParams = nil;
    NSError *imParseError = nil;
    NSData *imJsonData = [NSJSONSerialization dataWithJSONObject:imdic options:0 error:&imParseError];
    if (!imParseError) {
        imParams = [[NSString alloc] initWithData:imJsonData encoding:NSUTF8StringEncoding];
    }
    NSString *realtorDeUrl = contactPhone.mainPageInfo;
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
    info[@"title"] = @"经纪人主页";
    info[@"realtor_id"] = contactPhone.realtorId;
    info[@"delegate"] = self;
    info[@"trace"] = self.tracerDict;
    info[@"house_id"] = _houseId;
    info[@"house_type"] = @(_houseType);

    if (isOpen) {
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc]initWithInfo:info];
        [[TTRoute sharedRoute]openURLByViewController:openUrl userInfo:userInfo];
        return nil;
    }else
    {
        dict[@"page_type"] = @"realtor_detail";
        BOOL islogin = [[TTAccount sharedAccount] isLogin];
        [imdic setValue:islogin ? @"1" : @"0" forKey:@"is_login"];
        
        NSString *openUrlRnStr = [NSString stringWithFormat:@"sslocal://react?module_name=FHRNAgentDetailModule_home&realtorId=%@&can_multi_preload=%ld&channelName=f_realtor_detail&debug=0&report_params=%@&im_params=%@&bundle_name=%@&is_login=%@",contactPhone.realtorId,isPre ? 1 : 0,[FHUtils getJsonStrFrom:dict],[FHUtils getJsonStrFrom:imdic],@"agent_detail.bundle",islogin ? @"1" : @"0"];
        
        NSURL *openUrlRn = [NSURL URLWithString:openUrlRnStr];
        
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:info];
        TTRouteObject *routeObj = [[TTRoute sharedRoute] routeObjWithOpenURL:openUrlRn userInfo:userInfo];
        if (isPre) {
            [[FHRNHelper sharedInstance] addCacheViewOpenUrl:openUrlRnStr andUserInfo:userInfo andCacheKey:self.hash];
            return nil;
        }else
        {
            return routeObj;
        }
    }
}

+ (BOOL)isEnableCurrentChannel
{
    if([FHRealtorEvaluatingPhoneCallModel fhRNEnableChannels].count > 0 && [[FHRealtorEvaluatingPhoneCallModel fhRNEnableChannels] containsObject:@"f_realtor_detail"])
    {
        return YES;
    }else
    {
        return NO;
    }
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

+ (NSDictionary *)fhSettings {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kFHSettingsKey"]){
        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kFHSettingsKey"];
    } else {
        return nil;
    }
}
@end
