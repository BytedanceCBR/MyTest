//
//  FHHouseUGCAPI.m
//

#import "FHHouseUGCAPI.h"
#import "ArticleURLSetting.h"
#import "TTLocationManager.h"
#import "TTDeviceHelper.h"
#import "NSStringAdditions.h"
#import "FHUGCModel.h"
#import "FHUGCConfig.h"
#import "FHEnvContext.h"
#import "JSONAdditions.h"
#import "FHTopicHeaderModel.h"
#import "FHURLSettings.h"
#import "FHTopicFeedListModel.h"
#import "FHFeedOperationResultModel.h"
#import "FHUGCNoticeModel.h"
#import "FHUGCVoteModel.h"
#import "FHUGCVoteResponseModel.h"

#define DEFULT_ERROR @"请求错误"
#define API_ERROR_CODE  10000
#define QURL(QPATH) [[self host] stringByAppendingString:QPATH]

@implementation FHHouseUGCAPI

+ (NSString *)host {
    return [FHURLSettings baseURL];
}

+ (void)loadUgcConfigEntrance {
    [[FHUGCConfig sharedInstance] loadConfigData];
}

+ (TTHttpTask *)requestTopicList:(NSString *)communityId class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion {
    NSString *queryPath = @"/f100/api/community/topics";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"community_id"] = communityId ?: @"";
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (TTHttpTask *)requestAllForumWithClass:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion {
    NSString *queryPath = @"/f100/ugc/all_forum";
    return [FHMainApi queryData:queryPath params:nil class:cls completion:completion];
}

+ (TTHttpTask *)requestCommunityDetail:(NSString *)communityId class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion {
    NSString *queryPath = @"/f100/ugc/social_group_basic_info";
    NSString *url = QURL(queryPath);
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"social_group_id"] = communityId ?: @"";
    
    return [[TTNetworkManager shareInstance] requestForBinaryWithURL:url params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id obj) {
        __block NSError *backError = error;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            id<FHBaseModelProtocol> model = (id<FHBaseModelProtocol>)[FHMainApi generateModel:obj class:cls error:&backError];
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(model,backError);
                });
            }
        });
        
    }];
//    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (TTHttpTask *)requestFeedListWithCategory:(NSString *)category behotTime:(double)behotTime loadMore:(BOOL)loadMore listCount:(NSInteger)listCount extraDic:(NSDictionary *)extraDic completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion {

    NSString *queryPath = [ArticleURLSetting encrpytionStreamUrlString];

    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"category"] = category;
    paramDic[@"count"] = @(20);
//    paramDic[@"detail"] = @(1);
//    paramDic[@"image"] = @(1);
//    paramDic[@"LBS_status"] = [TTLocationManager currentLBSStatus];
    paramDic[@"city"] = [TTLocationManager sharedManager].city;
    paramDic[@"loc_mode"] = @([TTLocationManager isLocationServiceEnabled]);

    TTPlacemarkItem *placemarkItem = [TTLocationManager sharedManager].placemarkItem;
    if (placemarkItem.coordinate.longitude > 0) {
        paramDic[@"latitude"] = @(placemarkItem.coordinate.latitude);
        paramDic[@"longitude"] = @(placemarkItem.coordinate.longitude);
        paramDic[@"loc_time"] = @((long long) placemarkItem.timestamp);
    }

    paramDic[@"language"] = [TTDeviceHelper currentLanguage];
    paramDic[@"refer"] = @(1);
    if (behotTime) {
        paramDic[@"refer"] = @(1);
    }

    if (loadMore && behotTime) {
        NSNumber *maxBehotTimeNumber = @(behotTime);
        if (!maxBehotTimeNumber) maxBehotTimeNumber = [NSNumber numberWithInt:0];
        paramDic[@"max_behot_time"] = maxBehotTimeNumber;
    } else {
        NSNumber *minBeHotTimeNumber = [NSNumber numberWithInt:0];
        if (behotTime) {
            minBeHotTimeNumber = @(behotTime);
        }
        paramDic[@"min_behot_time"] = minBeHotTimeNumber;
    }

    paramDic[@"strict"] = @(0);
    paramDic[@"list_count"] = @(listCount);
    paramDic[@"concern_id"] = @"";
//    paramDic[@"cp"] = [self encreptTime:[[NSDate date] timeIntervalSince1970]];

    if (!loadMore) {
        paramDic[@"refresh_reason"] = @(0);
    }
    
    if(extraDic){
        paramDic[@"client_extra_params"] = [extraDic tt_JSONRepresentation];
    }

    Class cls = NSClassFromString(@"FHFeedListModel");

    return [[TTNetworkManager shareInstance] requestForBinaryWithURL:queryPath params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id obj) {
        __block NSError *backError = error;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            id <FHBaseModelProtocol> model = (id <FHBaseModelProtocol>) [FHMainApi generateModel:obj class:cls error:&backError];
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(model, backError);
                });
            }
        });

    }];

//    return [FHMainApi queryData:queryPath params:paramDic class:nil completion:completion];
}

+ (NSString *)encreptTime:(double)time {
    if (time <= 0) {
        return nil;
    }
    NSMutableString *returnStr;
    NSString *str = [NSString stringWithFormat:@"%.0f", time];
    NSString *hexedString = [NSString stringWithFormat:@"%lX", [str integerValue]];
    NSString *md5Str = [str MD5HashString];
    if (!hexedString || hexedString.length != 8) {
        return @"7E0AC8874BB0985";//(MD5('suspicious')后15位)，之后将通过日志分析找出相应的可疑 IP 进一步筛查。
    }
    if (hexedString.length == 8 && md5Str && md5Str.length > 5) {
        returnStr = [[NSMutableString alloc] init];
        for (int i = 0; i < 5; i++) {
            [returnStr appendFormat:@"%c", [hexedString characterAtIndex:i]];
            [returnStr appendFormat:@"%c", [md5Str characterAtIndex:i]];
        }
        [returnStr appendString:[hexedString substringFromIndex:5]];
        [returnStr appendString:@"q1"];
    }
    return returnStr;
}

+ (TTHttpTask *)requestFollowListByType:(NSInteger)type class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion {
    NSString *queryPath = @"/f100/ugc/user_follows";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"type"] = @(type);
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (TTHttpTask *)requestFollow:(NSString *)group_id action:(NSInteger)action completion:(void (^ _Nullable)(id<FHBaseModelProtocol> model, NSError *error))completion {
    NSString *queryPath = @"/f100/ugc/follow";
    Class jsonCls = [FHCommonModel class];
    if (action == 0) {
        // 取消关注
        queryPath = @"/f100/ugc/unfollow";
        jsonCls = [FHCommonModel class];
    } else if (action == 1) {
        // 关注
        queryPath = @"/f100/ugc/follow";
        jsonCls = [FHUGCFollowModel class];
    }
        
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (group_id.length > 0 ) {
        paramDic[@"social_group_id"] = group_id;
    }
    NSString *query = [NSString stringWithFormat:@"social_group_id=%@",group_id];
    return [FHMainApi postRequest:queryPath query:query params:paramDic jsonClass:jsonCls completion:^(JSONModel * _Nullable model, NSError * _Nullable error) {
        if (completion) {
            completion(model,error);
        }
    }];
}

+ (TTHttpTask *)requestSocialSearchByText:(NSString *)text class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion {
    NSString *queryPath = @"/f100/ugc/social_group_suggestion";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (text.length > 0) {
        paramDic[@"query"] = text;
    }
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (TTHttpTask *)requestRecommendSocialGroupsWithSource:(NSString *)source latitude:(CGFloat)latitude longitude:(CGFloat)longitude class:(Class)cls completion:(void (^)(id <FHBaseModelProtocol> model, NSError *error))completion {
    NSString *queryPath = @"/f100/ugc/recommend_social_groups";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    
    if(source){
        paramDic[@"source_from"] = source;
    }
    if(latitude != 0){
        paramDic[@"latitude"] = @(latitude);
    }
    
    if(longitude != 0){
        paramDic[@"longitude"] = @(longitude);
    }

    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (TTHttpTask *)requestUGCConfig:(Class)cls completion:(void (^)(id<FHBaseModelProtocol> _Nonnull, NSError * _Nonnull))completion {
    NSString *queryPath = @"/f100/ugc/config";
    return [FHMainApi queryData:queryPath params:nil class:cls completion:completion];
}

+ (TTHttpTask *)requestForumFeedListWithForumId:(NSString *)forumId offset:(NSInteger)offset loadMore:(BOOL)loadMore completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion {
    NSString *queryPath = @"/f100/ugc/feed/v1/forum_feeds";
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"forum_id"] = forumId;
    paramDic[@"count"] = @(20);
    paramDic[@"offset"] = @(offset);
    
    TTPlacemarkItem *placemarkItem = [TTLocationManager sharedManager].placemarkItem;
    if (placemarkItem.coordinate.longitude > 0) {
        paramDic[@"latitude"] = @(placemarkItem.coordinate.latitude);
        paramDic[@"longitude"] = @(placemarkItem.coordinate.longitude);
    }
    
    paramDic[@"load_more"] = @(loadMore);
    
    Class cls = NSClassFromString(@"FHFeedListModel");
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (TTHttpTask *)requestFeedListWithCategory:(NSString *)categoryId offset:(NSInteger)offset loadMore:(BOOL)loadMore completion:(void (^)(id<FHBaseModelProtocol> _Nonnull, NSError * _Nonnull))completion {
    NSString *queryPath = @"/f100/ugc/feed/v1/recommend_feeds";
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"channel_id"] = categoryId;
    paramDic[@"count"] = @(20);
    paramDic[@"offset"] = @(offset);
    
    TTPlacemarkItem *placemarkItem = [TTLocationManager sharedManager].placemarkItem;
    if (placemarkItem.coordinate.longitude > 0) {
        paramDic[@"latitude"] = @(placemarkItem.coordinate.latitude);
        paramDic[@"longitude"] = @(placemarkItem.coordinate.longitude);
    }
    
    paramDic[@"load_more"] = @(loadMore);
    
    Class cls = NSClassFromString(@"FHFeedListModel");
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (TTHttpTask *)postDelete:(NSString *)groupId cellType:(NSInteger)cellType socialGroupId:(NSString *)socialGroupId enterFrom:(NSString *)enterFrom pageType:(NSString *)pageType completion:(void(^)(bool success , NSError *error))completion {
    NSString *queryPath = @"/f100/ugc/delete_post";
    NSString *url = QURL(queryPath);
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if(groupId){
        paramDic[@"group_id"] = groupId;
    }
    if(socialGroupId){
        paramDic[@"social_group_id"] = socialGroupId;
    }
    if(enterFrom){
        paramDic[@"enter_from"] = enterFrom;
    }
    if(pageType){
        paramDic[@"page_type"] = pageType;
    }
    paramDic[@"cell_type"] = @(cellType);
    
    return [[TTNetworkManager shareInstance] requestForBinaryWithURL:url params:paramDic method:@"POST" needCommonParams:YES callback:^(NSError *error, id obj) {
        
        BOOL success = NO;
        if (!error) {
            @try{
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
                success = ([json[@"status"] integerValue] == 0);
                if (!success) {
                    NSString *msg = json[@"message"];
                    error = [NSError errorWithDomain:msg?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
                }
            }
            @catch(NSException *e){
                error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo ];
            }
        }
        if (completion) {
            completion(success,error);
        }
    }];
}

+ (TTHttpTask *)postOperation:(NSString *)groupId cellType:(NSInteger)cellType socialGroupId:(NSString *)socialGroupId operationCode:(NSString *)operationCode enterFrom:(NSString *)enterFrom pageType:(NSString *)pageType completion:(void (^ _Nonnull)(id<FHBaseModelProtocol> model, NSError *error))completion {
    NSString *queryPath = @"/f100/ugc/stick_operate";
    NSString *url = QURL(queryPath);
    //暂时为了测试写死开发机地址
//    url = @"http://10.224.10.118:6789/f100/ugc/stick_operate";
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if(groupId){
        paramDic[@"group_id"] = groupId;
    }
    if(socialGroupId){
        paramDic[@"social_group_id"] = socialGroupId;
    }
    if(enterFrom){
        paramDic[@"enter_from"] = enterFrom;
    }
    if(pageType){
        paramDic[@"page_type"] = pageType;
    }
    if(operationCode){
        paramDic[@"operate_code"] = operationCode;
    }
    
    paramDic[@"cell_type"] = @(cellType);
    
    Class jsonCls = [FHFeedOperationResultModel class];
    
    return [[TTNetworkManager shareInstance] requestForBinaryWithURL:url params:paramDic method:@"POST" needCommonParams:YES callback:^(NSError *error, id obj) {
        __block NSError *backError = error;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            id<FHBaseModelProtocol> model = (id<FHBaseModelProtocol>)[FHMainApi generateModel:obj class:jsonCls error:&backError];
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(model,backError);
                });
            }
        });
    }];
}

+ (TTHttpTask *)requestCommentDetailDataWithCommentId:(NSString *)comment_id socialGroupId:(NSString *)socialGroupId class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion {
    NSString *queryPath = @"/f100/ugc/material/v0/comment_detail";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (comment_id.length > 0) {
        paramDic[@"comment_id"] = comment_id;
    }
    if (socialGroupId.length > 0) {
        paramDic[@"social_group_id"] = socialGroupId;
    }
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (TTHttpTask *)requestReplyListWithCommentId:(NSString *)comment_id offset:(NSInteger)offset class:(Class)cls completion:(void (^)(id<FHBaseModelProtocol> _Nonnull, NSError * _Nonnull))completion {
    NSString *queryPath = @"/2/comment/v1/reply_list/";
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"id"] = comment_id ?: @"";
    paramDic[@"count"] = @(20);
    paramDic[@"offset"] = @(offset);
    paramDic[@"is_repost"] = @(0);// 不知道干嘛的
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (TTHttpTask *)requestCommunityList:(NSInteger)districtId source:(NSString *)source latitude:(CGFloat)latitude longitude:(CGFloat)longitude class:(Class)cls completion:(void (^)(id <FHBaseModelProtocol> model, NSError *error))completion;{
    NSString *queryPath = @"/f100/ugc/social_group_district";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];

    paramDic[@"district_id"] = @(districtId);
    if(latitude != 0){
        paramDic[@"latitude"] = @(latitude);
    }

    if(longitude != 0){
        paramDic[@"longitude"] = @(longitude);
    }
    
    if(source){
        paramDic[@"source_from"] = source;
    }
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}


+ (TTHttpTask *)refreshFeedTips:(NSString *)category beHotTime:(double)beHotTime completion:(void(^)(bool hasNew ,NSTimeInterval interval,NSTimeInterval cacheDuration, NSError *error))completion {
    NSString *queryPath = @"/f100/ugc/v1/refresh_tips";
    NSString *url = QURL(queryPath);
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if(category){
        paramDic[@"category"] = category;
    }
    if(beHotTime){
        paramDic[@"be_hot_time"] = @(beHotTime);
    }
    
    return [[TTNetworkManager shareInstance] requestForBinaryWithURL:url params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id obj) {
        
        BOOL success = NO;
        BOOL hasNew = NO;
        NSTimeInterval interval = 0;
        NSTimeInterval cacheDuration = 0;
        if (!error) {
            @try{
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
                success = ([json[@"status"] integerValue] == 0);
                if (!success) {
                    NSString *msg = json[@"message"];
                    error = [NSError errorWithDomain:msg?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
                }else{
                    hasNew = [json[@"data"][@"has_new_content"] boolValue];
                    interval = [json[@"data"][@"refresh_duration"] doubleValue];
                    cacheDuration = [json[@"data"][@"client_cache_duration"] doubleValue];
                }
            }
            @catch(NSException *e){
                error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo];
            }
        }
        if (completion) {
            completion(hasNew,interval,cacheDuration,error);
        }
    }];
}

+ (TTHttpTask *)requestTopicHeader:(NSString *)forum_id completion:(void (^ _Nullable)(id<FHBaseModelProtocol> model, NSError *error))completion {
    NSString *queryPath = @"/forum/home/v1/info/?";
    NSString *url = QURL(queryPath); // 1640650037191725 1642474912698382
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if(forum_id){
        paramDic[@"forum_id"] = forum_id;
        paramDic[@"is_preview"] = @(0);
    }
    
    return [[TTNetworkManager shareInstance] requestForBinaryWithURL:url params:paramDic method:@"POST" needCommonParams:YES callback:^(NSError *error, id obj) {
        
        BOOL success = NO;
        FHTopicHeaderModel *headerModel = nil;
        if (!error) {
            @try{
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
                success = ([json[@"err_no"] integerValue] == 0);
                if (!success) {
                    NSString *msg = json[@"err_tips"];
                    error = [NSError errorWithDomain:msg?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
                }else{
                    headerModel = [[FHTopicHeaderModel alloc] initWithDictionary:json error:&error];
                }
            }
            @catch(NSException *e) {
                error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo];
            }
        }
        if (completion) {
            completion(headerModel,error);
        }
    }];
}

+ (TTHttpTask *)requestTopicList:(NSString *)query_id tab_id:(NSString *)tab_id categoryName:(NSString *)category offset:(NSInteger)offset count:(NSInteger)count appExtraParams:(NSString *)appExtraParams completion:(void (^ _Nullable)(id<FHBaseModelProtocol> model, NSError *error))completion {
    NSString *queryPath = @"/api/feed/forum_all/v1/?";
    NSString *url = QURL(queryPath);
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (query_id) {
        paramDic[@"query_id"] = query_id;
    }
    if (category.length > 0) {
       paramDic[@"category"] = category;
    }
    if (tab_id.length > 0) {
        paramDic[@"tab_id"] = tab_id;
    }
    if (appExtraParams.length > 0) {
        paramDic[@"app_extra_params"] = appExtraParams;
    }
    paramDic[@"count"] = @(count);
    paramDic[@"offset"] = @(offset);
    paramDic[@"stream_api_version"] = [FHURLSettings streamAPIVersionString];
    
    return [[TTNetworkManager shareInstance] requestForBinaryWithURL:url params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id obj) {
        
        FHTopicFeedListModel *listModel = nil;
        if (!error) {
            @try{
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
                if (error) {
                    if ([json isKindOfClass:[NSDictionary class]]) {
                        NSString *msg = json[@"message"];
                        error = [NSError errorWithDomain:msg?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
                    }
                }else{
                    listModel = [[FHTopicFeedListModel alloc] initWithDictionary:json error:&error];
                }
            }
            @catch(NSException *e){
                error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo];
            }
        }
        if (completion) {
            completion(listModel, error);
        }
    }];
}

+ (TTHttpTask *)requestUpdateUGCNoticeWithParam:(NSDictionary *)params completion:(void (^)(FHUGCNoticeModel *model, NSError *error))completion {
    
    NSString *queryPath = @"/f100/ugc/social_group/announcement";
    NSString *url = QURL(queryPath);
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    [paramDic addEntriesFromDictionary:params];
    
    return [[TTNetworkManager shareInstance] requestForBinaryWithURL:url params:paramDic method:@"POST" needCommonParams:YES callback:^(NSError *error, id obj) {
        
        BOOL success = NO;
        FHUGCNoticeModel *ugcNoticeModel = nil;
        if (!error) {
            @try{
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
                success = ([json[@"status"] integerValue] == 0);
                if (!success) {
                    NSString *msg = json[@"message"];
                    error = [NSError errorWithDomain:msg?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
                }
                else
                {
                    ugcNoticeModel = [[FHUGCNoticeModel alloc] initWithDictionary:json error:&error];
                }
            }
            @catch(NSException *e){
                error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo];
            }
        }
        
        if (completion) {
            completion(ugcNoticeModel,error);
        }
    }];
}

+ (TTHttpTask *)requestMyCommentListWithUserId:(NSString *)userId offset:(NSInteger)offset completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion {
    NSString *queryPath = @"/api/feed/my_comments/v1/?";
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"count"] = @(20);
    paramDic[@"offset"] = @(offset);
    paramDic[@"category"] = @"my_comments";
    
    Class cls = NSClassFromString(@"FHUGCCommentListModel");
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (TTHttpTask *)requestHomePageInfoWithUserId:(NSString *)userId completion:(void (^)(id<FHBaseModelProtocol> _Nonnull, NSError * _Nonnull))completion {
    NSString *queryPath = @"/user/profile/homepage/v7/?";
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if(userId){
        paramDic[@"user_id"] = userId;
    }
    
    paramDic[@"refer"] = @"all";
    
    Class cls = NSClassFromString(@"FHPersonalHomePageModel");
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (TTHttpTask *)requestHomePageFeedListWithUserId:(NSString *)userId offset:(NSInteger)offset count:(NSInteger)count completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion {
    NSString *queryPath = @"/api/feed/profile/v1/?";
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if(userId){
        paramDic[@"visited_uid"] = userId;
    }
    paramDic[@"category"] = @"profile_all";
    paramDic[@"count"] = @(count);
    paramDic[@"offset"] = @(offset);
    paramDic[@"stream_api_version"] = [FHURLSettings streamAPIVersionString];
    
    Class cls = NSClassFromString(@"FHFeedListModel");
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (TTHttpTask *)requestFocusListWithUserId:(NSString *)userId completion:(void (^)(id<FHBaseModelProtocol> _Nonnull, NSError * _Nonnull))completion {
    NSString *queryPath = @"/f100/ugc/follow_sg_list";
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if(userId){
        paramDic[@"user_id"] = userId;
    }
    
    Class cls = NSClassFromString(@"FHUGCModel");
    
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}
    
+ (TTHttpTask *)requestFollowUserListBySocialGroupId:(NSString *)socialGroupId offset:(NSInteger)offset class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion {
    NSString *queryPath = @"/f100/ugc/follow_list";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (socialGroupId.length > 0) {
        paramDic[@"social_group_id"] = socialGroupId;
    }
    paramDic[@"offset"] = @(offset);
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (TTHttpTask *)requestFollowSugSearchByText:(NSString *)text socialGroupId:(NSString *)socialGroupId offset:(NSInteger)offset class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion {
    NSString *queryPath = @"/f100/ugc/follow_suggest_list";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (text.length > 0) {
        paramDic[@"query_key"] = text;
    }
    if (socialGroupId.length > 0) {
        paramDic[@"social_group_id"] = socialGroupId;
    }
    paramDic[@"offset"] = @(offset);
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}
+ (TTHttpTask *)requestVotePublishWithParam:(NSDictionary *)params completion:(void (^)(id<FHBaseModelProtocol> _Nonnull, NSError * _Nonnull))completion {
    
    NSString *queryPath = @"/f100/ugc/vote/publish";
    NSString *url = QURL(queryPath);
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    [paramDic addEntriesFromDictionary:params];
    
    return [[TTNetworkManager shareInstance] requestForBinaryWithURL:url params:paramDic method:@"POST" needCommonParams:YES requestSerializer:[FHVoteHTTPRequestSerializer class] responseSerializer:[[TTNetworkManager shareInstance]defaultBinaryResponseSerializerClass] autoResume:YES callback:^(NSError *error, id obj) {
        
        BOOL success = NO;
        FHUGCVoteModel *ugcVoteModel = nil;
        if (!error) {
            @try{
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
                success = ([json[@"status"] integerValue] == 0);
                if (!success) {
                    NSString *msg = json[@"message"];
                    error = [NSError errorWithDomain:msg?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
                }
                else
                {
                    ugcVoteModel = [[FHUGCVoteModel alloc] initWithDictionary:json error:&error];
                }
            }
            @catch(NSException *e){
                error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo];
            }
        }
        
        if (completion) {
            completion(ugcVoteModel,error);
        }
    }];
}

// 提交投票
+ (TTHttpTask *)requestVoteSubmit:(NSString *)voteId optionIDs:(NSArray *)optionIds optionNum:(NSNumber *)optionNum completion:(void(^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion {
    NSString *queryPath = @"/f100/ugc/vote/submit";
    NSString *url = QURL(queryPath);
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if(voteId.length > 0) {
        paramDic[@"vote_id"] = [NSNumber numberWithInteger:[voteId integerValue]];
    }
    if(optionIds.count > 0) {
        paramDic[@"option_ids"] = optionIds;
    }
    if(optionNum > 0) {
        paramDic[@"option_num"] = optionNum;
    }
    
    return [[TTNetworkManager shareInstance] requestForBinaryWithURL:url params:paramDic method:@"POST" needCommonParams:YES requestSerializer:[FHVoteHTTPRequestSerializer class] responseSerializer:[[TTNetworkManager shareInstance]defaultBinaryResponseSerializerClass] autoResume:YES callback:^(NSError *error, id obj) {
        
        BOOL success = NO;
        id model = nil;
        if (!error) {
            @try{
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
                success = ([json[@"status"] integerValue] == 0);
                if (!success) {
                    NSString *msg = json[@"message"];
                    error = [NSError errorWithDomain:msg?:@"投票失败" code:API_ERROR_CODE userInfo:nil];
                } else {
                    model = [[FHUGCVoteResponseModel alloc] initWithDictionary:json error:&error];
                }
            }
            @catch(NSException *e){
                error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo ];
            }
        }
        if (completion) {
            completion(model,error);
        }
    }];
}
// 取消投票
+ (TTHttpTask *)requestVoteCancel:(NSString *)voteId optionNum:(NSNumber *)optionNum completion:(void(^)(BOOL success , NSError *error))completion {
    NSString *queryPath = @"/f100/ugc/vote/cancel";
    NSString *url = QURL(queryPath);
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if(voteId.length > 0) {
        paramDic[@"vote_id"] = [NSNumber numberWithInteger:[voteId integerValue]];
    }
    if(optionNum > 0) {
        paramDic[@"option_num"] = optionNum;
    }
    
    return [[TTNetworkManager shareInstance] requestForBinaryWithURL:url params:paramDic method:@"POST" needCommonParams:YES requestSerializer:[FHVoteHTTPRequestSerializer class] responseSerializer:[[TTNetworkManager shareInstance]defaultBinaryResponseSerializerClass] autoResume:YES callback:^(NSError *error, id obj) {
        
        BOOL success = NO;
        if (!error) {
            @try{
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
                success = ([json[@"status"] integerValue] == 0);
                if (!success) {
                    NSString *msg = json[@"message"];
                    error = [NSError errorWithDomain:msg?:@"取消投票失败" code:API_ERROR_CODE userInfo:nil];
                }
            }
            @catch(NSException *e){
                error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo ];
            }
        }
        if (completion) {
            completion(success,error);
        }
    }];
}

@end

@implementation FHVoteHTTPRequestSerializer

+ (NSObject<TTHTTPRequestSerializerProtocol> *)serializer
{
    return [FHVoteHTTPRequestSerializer new];
    
}

- (TTHttpRequest *)URLRequestWithURL:(NSString *)URL
                              params:(NSDictionary *)parameters
                              method:(NSString *)method
               constructingBodyBlock:(TTConstructingBodyBlock)bodyBlock
                        commonParams:(NSDictionary *)commonParam
{
    TTHttpRequest * request = [super URLRequestWithURL:URL params:parameters method:method constructingBodyBlock:bodyBlock commonParams:commonParam];
    
    [request setValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    if ([@"POST" isEqualToString: method] && [parameters isKindOfClass:[NSDictionary class]]) {
        NSData * postDate = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
        [request setHTTPBody:postDate];
    }
    
    
    return request;
    
}
@end
