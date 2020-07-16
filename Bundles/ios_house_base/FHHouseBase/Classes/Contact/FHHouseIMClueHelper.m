//
//  FHHouseIMClueHelper.m
//  FHHouseBase
//
//  Created by 张静 on 2020/3/26.
//

#import "FHHouseIMClueHelper.h"
#import "FHHouseFollowUpHelper.h"
#import "FHUserTracker.h"
#import <TTAccountSDK/TTAccount.h>
#import <TTRoute/TTRoute.h>

@implementation FHHouseIMClueHelper

+ (void)jump2SessionPageWithConfigModel:(FHHouseIMClueConfigModel *)configModel
{
    NSMutableDictionary *dict = @{}.mutableCopy;
    dict[@"enter_from"] = configModel.enterFrom ? : @"be_null";
    dict[@"element_from"] = configModel.elementFrom ? : @"be_null";
    dict[@"origin_from"] = configModel.originFrom ? : @"be_null";
    dict[@"log_pb"] = configModel.logPb ? : @"be_null";
    dict[@"origin_search_id"] = configModel.originSearchId ? : @"be_null";
    dict[@"rank"] = configModel.rank ? : @"be_null";
//    dict[@"card_type"] = configModel.cardType ? : @"be_null";
    dict[@"page_type"] = configModel.pageType ?: @"be_null";
    dict[@"is_login"] = [[TTAccount sharedAccount] isLogin] ? @"1" : @"0";
    dict[@"realtor_id"] = configModel.realtorId ? : @"be_null";;
    dict[@"realtor_rank"] = configModel.realtorRank ?: @"0";
    dict[@"conversation_id"] = configModel.conversationId ? : @"be_null";
    dict[@"realtor_logpb"] = configModel.realtorLogpb ? : @"be_null";
//    dict[@"source"] = configModel.source; // ? : @"be_null";
    dict[@"from"] = configModel.from;
    dict[@"source_from"] = configModel.sourceFrom;
    dict[@"search_id"] = configModel.searchId ? : @"be_null";
    dict[@"realtor_position"] = configModel.realtorPosition ? : @"be_null";
    dict[@"growth_deepevent"] = @(1);
    
    // 线索相关字段
    dict[@"clue_page"] = configModel.cluePage;
    dict[@"clue_endpoint"] = configModel.clueEndpoint;

    NSString *urlStr = configModel.imOpenUrl;
    if (urlStr.length > 0) {
        NSURL *openUrl = [NSURL URLWithString:urlStr];
        NSMutableDictionary *userInfoDict = @{}.mutableCopy;
        if (dict) {
            userInfoDict[@"tracer"] = dict;
        }
        userInfoDict[@"from"] = configModel.from;
        if (configModel.extraInfo) {
            [dict addEntriesFromDictionary:configModel.extraInfo];
        }
        [FHUserTracker writeEvent:@"click_im" params:dict];

        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
        [self silentFollowHouse:configModel];
    }
}

+ (void)silentFollowHouse:(FHHouseIMClueConfigModel *)imConfig
{
    FHHouseFollowUpConfigModel *configModel = [[FHHouseFollowUpConfigModel alloc]init];
    configModel.houseType = imConfig.houseType;
    configModel.followId = imConfig.houseId;
    configModel.actionType = imConfig.houseType;
    configModel.hideToast = YES;
    // 静默关注功能
    [FHHouseFollowUpHelper silentFollowHouseWithConfigModel:configModel completionBlock:^(BOOL isSuccess) {
    }];
}

+ (void)jump2SessionPageWithConfig:(NSDictionary *)configDict
{
    FHHouseIMClueConfigModel *configModel = [[FHHouseIMClueConfigModel alloc]initWithDictionary:configDict error:nil];
    if (configModel) {
        [self jump2SessionPageWithConfigModel:configModel];
    }
}

+ (void)jump2SessionPageWithAssociateDict:(NSDictionary *)associateDict
{
    FHAssociateIMModel *configModel = [[FHAssociateIMModel alloc]initWithDictionary:associateDict error:nil];
    if (configModel) {
        [self jump2SessionPageWithAssociateIM:configModel];
    }
}

+ (void)jump2SessionPageWithAssociateIM:(FHAssociateIMModel *)associateIM
{
    NSString *urlStr = associateIM.imOpenUrl;
    if (urlStr.length > 0) {
        
        if(!associateIM.isIgnoreReportClickIM) {
            // 上报IM点击埋点
            [self addClickIMLog:associateIM];
        }
        // 执行跳转
        NSURL *openUrl = [NSURL URLWithString:urlStr];
        NSMutableDictionary *userInfoDict = @{}.mutableCopy;
        NSMutableDictionary *report_params = [associateIM.reportParams.toDictionary mutableCopy];
        report_params[UT_ENTER_FROM] = report_params[UT_PAGE_TYPE];
        userInfoDict[@"report_params"] = report_params;
        userInfoDict[@"associate_info"] = associateIM.associateInfo.imInfo?:@{}; // 只传入im_info即可
        userInfoDict[@"extra_info"] = associateIM.extraInfo;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
        
        NSNumber *loginSchema = associateIM.reportParams.extra[kFHIMLoginSchema];
        if(loginSchema) {
            switch (loginSchema.integerValue) {
                case 1:
                {
                    if(![TTAccount sharedAccount].isLogin) {
                        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo pushHandler:^(UINavigationController *nav, TTRouteObject *routeObj) {
                            [nav pushViewController:routeObj.instance animated:NO];
                        }];
                        NSURL *URL = [NSURL URLWithString:@"sslocal://flogin"];
                        NSMutableDictionary *params = [NSMutableDictionary dictionary];
                        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:params];
                        [[TTRoute sharedRoute] openURLByPushViewController:URL userInfo:userInfo];
                    }
                    else {
                        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
                    }
                }
                    break;
                default:
                {
                    [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:userInfo];
                }
                    break;
            }
        }
        
        // 静默关注处理
        [self silentFollowHouseWithAssociateIM:associateIM];
    }
}

+ (void)silentFollowHouseWithAssociateIM:(FHAssociateIMModel *)associateIM
{
    NSMutableDictionary *params = @{}.mutableCopy;
    
    if(associateIM.reportParams.toDictionary) {
        [params addEntriesFromDictionary:associateIM.reportParams.toDictionary];
    }
    
    if(associateIM.reportParams.extra) {
        [params addEntriesFromDictionary:associateIM.reportParams.extra];
    }

    FHHouseFollowUpConfigModel *configModel = [[FHHouseFollowUpConfigModel alloc] initWithDictionary:params error:nil];
    
    configModel.houseType = associateIM.houseType;
    configModel.followId = associateIM.houseId;
    configModel.actionType = associateIM.houseType;
    configModel.hideToast = YES;
    
    if (configModel.followId && configModel.followId.length > 0) {
        // 静默关注功能
        [FHHouseFollowUpHelper silentFollowHouseWithConfigModel:configModel completionBlock:^(BOOL isSuccess) {
            if(associateIM.slientFollowCallbackBlock) {
                associateIM.slientFollowCallbackBlock(isSuccess);
            }
        }];
    }
}

+ (void)addClickIMLog:(FHAssociateIMModel *)associateIM
{
    NSMutableDictionary *dict = @{}.mutableCopy;
    FHAssociateReportParams *reportParams = associateIM.reportParams;
    
    dict[@"enter_from"] = reportParams.enterFrom ? : @"be_null";
    dict[@"element_from"] = reportParams.elementFrom ? : @"be_null";
    dict[@"origin_from"] = reportParams.originFrom ? : @"be_null";
    dict[@"log_pb"] = reportParams.logPb ? : @"be_null";
    dict[@"origin_search_id"] = reportParams.originSearchId ? : @"be_null";
    dict[@"rank"] = reportParams.rank ? : @"be_null";
    dict[@"card_type"] = reportParams.cardType ? : @"be_null";
    dict[@"page_type"] = reportParams.pageType ?: @"be_null";
    dict[@"is_login"] = [[TTAccount sharedAccount] isLogin] ? @"1" : @"0";
    dict[@"realtor_id"] = reportParams.realtorId ? : @"be_null";
    dict[@"realtor_rank"] = reportParams.realtorRank ?: @"0";
    dict[@"conversation_id"] = reportParams.conversationId ? : @"be_null";
    dict[@"realtor_position"] = reportParams.realtorPosition ? : @"be_null";
    dict[@"realtor_logpb"] = reportParams.realtorLogpb;
    dict[@"growth_deepevent"] = @(1);
    dict[@"biz_trace"] = associateIM.extraInfo[@"biz_trace"] ? : @"be_null";
    dict[@"source_from"] = reportParams.sourceFrom;
    dict[@"associate_info"] = associateIM.associateInfo.imInfo?:@{}; // 只传im_info即可
    dict[@"group_id"] = reportParams.groupId ? : @"be_null";
    dict[@"house_type"] = reportParams.houseType ? : @"be_null";
    dict[@"from_gid"] = reportParams.fromGid ? : @"be_null";
    
    if(reportParams.extra) {
        [dict addEntriesFromDictionary:reportParams.extra];
        dict[@"im_open_url"] = nil;
    }

    [FHUserTracker writeEvent:@"click_im" params:dict];
}

@end

@implementation FHHouseIMClueConfigModel



+(JSONKeyMapper *)keyMapper
{
    return [JSONKeyMapper mapperForSnakeCase];
}

//+(BOOL)propertyIsIgnored:(NSString *)propertyName
//{
//    return NO;
//}

+(BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setTraceParams:(NSDictionary *)params
{
    _pageType = params[@"page_type"];
    _cardType = params[@"card_type"];
    _enterFrom = params[@"enter_from"];
    _elementFrom = params[@"element_from"];
    _rank = params[@"rank"];
    _originFrom = params[@"origin_from"];
    _originSearchId = params[@"origin_search_id"];
    _logPb = params[@"log_pb"];
    _searchId = params[@"search_id"];
    _imprId = params[@"impr_id"];
    _position = params[@"position"];
    _realtorPosition = params[@"realtor_position"];
    _itemId = params[@"item_id"];
    if (params[@"from"]) {
        _from = params[@"from"];
    }
    _cluePage = params[kFHCluePage];
    _clueEndpoint = params[kFHClueEndpoint];
    _realtorRank = params[@"realtor_rank"];
    _source = params[@"source"];
    _realtorLogpb = params[@"realtor_logpb"];
    _imOpenUrl = params[@"im_open_url"];
    _sourceFrom = params[@"source_from"];

    _targetId = params[@"target_id"];
    _targetType = params[@"target_type"];
    _extraInfo = params[@"extra_info"];
}

- (void)setLogPbWithNSString:(NSString *)logpb
{
    if ([@"be_null" isEqualToString:logpb]) {
        self.logPb = nil;
    }else if ([logpb isKindOfClass:[NSString class]]) {
        @try {
            NSData *data = [logpb dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            self.logPb = dict;
        } @catch (NSException *exception) {
#if DEBUG
            NSLog(@"exception is: %@",exception);
#endif
        }
    }
}

@end
