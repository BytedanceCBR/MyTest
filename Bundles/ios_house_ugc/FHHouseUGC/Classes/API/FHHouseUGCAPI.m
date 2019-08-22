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

+ (TTHttpTask *)requestCommunityDetail:(NSString *)communityId class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion {
    NSString *queryPath = @"/f100/ugc/social_group_basic_info";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"social_group_id"] = communityId ?: @"";
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

+ (TTHttpTask *)requestFeedListWithCategory:(NSString *)category behotTime:(double)behotTime loadMore:(BOOL)loadMore listCount:(NSInteger)listCount completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion {

    NSString *queryPath = [ArticleURLSetting encrpytionStreamUrlString];
    
    //test
//    NSString *queryPath = @"http://10.224.5.205:8765/api/news/feed/v96/";

    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"category"] = category;
    paramDic[@"count"] = @(10);
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
    
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    NSString *fCityId = [FHEnvContext getCurrentSelectCityIdFromLocal];
    if(fCityId){
        [extraDic setObject:fCityId forKey:@"f_city_id"];
    }
    
    paramDic[@"client_extra_params"] = [extraDic tt_JSONRepresentation];

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

+ (TTHttpTask *)postDelete:(NSString *)groupId socialGroupId:(NSString *)socialGroupId enterFrom:(NSString *)enterFrom pageType:(NSString *)pageType completion:(void(^)(bool success , NSError *error))completion {
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
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}


+ (TTHttpTask *)refreshFeedTips:(NSString *)category beHotTime:(NSString *)beHotTime completion:(void(^)(bool hasNew , NSError *error))completion {
    NSString *queryPath = @"/ugc/v:version/refresh_tips";
    NSString *url = QURL(queryPath);
    
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if(category){
        paramDic[@"category"] = category;
    }
    if(beHotTime){
        paramDic[@"be_hot_time"] = beHotTime;
    }
    
    return [[TTNetworkManager shareInstance] requestForBinaryWithURL:url params:paramDic method:@"GET" needCommonParams:YES callback:^(NSError *error, id obj) {
        
        BOOL success = NO;
        BOOL hasNew = NO;
        if (!error) {
            @try{
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:obj options:kNilOptions error:&error];
                success = ([json[@"status"] integerValue] == 0);
                if (!success) {
                    NSString *msg = json[@"message"];
                    error = [NSError errorWithDomain:msg?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
                }else{
                    hasNew = [json[@"data"][@"has_new_content"] boolValue];
                }
            }
            @catch(NSException *e){
                error = [NSError errorWithDomain:e.reason code:API_ERROR_CODE userInfo:e.userInfo];
            }
        }
        if (completion) {
            completion(hasNew,error);
        }
    }];
}
@end
