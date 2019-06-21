//
//  FHHouseUGCAPI.m
//

#import "FHHouseUGCAPI.h"
#import "ArticleURLSetting.h"
#import "TTLocationManager.h"
#import "TTDeviceHelper.h"
#import "NSStringAdditions.h"


@implementation FHHouseUGCAPI

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
//    NSString *queryPath = @"/f100/api/v2/msg/system_list";

    NSString *queryPath = [ArticleURLSetting encrpytionStreamUrlString];

    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    paramDic[@"category"] = category;
    paramDic[@"count"] = @(20);
    paramDic[@"detail"] = @(1);
    paramDic[@"image"] = @(1);
    paramDic[@"LBS_status"] = [TTLocationManager currentLBSStatus];
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
    paramDic[@"cp"] = [self encreptTime:[[NSDate date] timeIntervalSince1970]];

    if (!loadMore) {
        paramDic[@"refresh_reason"] = @(0);
    }
//    "last_refresh_sub_entrance_interval" = 4459;
//    "session_refresh_idx" = 5;
//    "tt_from" = pull;

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
    if (action == 0) {
        // 取消关注
        queryPath = @"/f100/ugc/unfollow";
    } else if (action == 1) {
        // 取消关注
        queryPath = @"/f100/ugc/follow";
    }
        
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (group_id.length > 0 ) {
        paramDic[@"social_group_id"] = group_id;
    }
    NSString *query = [NSString stringWithFormat:@"social_group_id=%@",group_id];
    return [FHMainApi postRequest:queryPath query:query params:paramDic jsonClass:[FHCommonModel class] completion:^(JSONModel * _Nullable model, NSError * _Nullable error) {
        if (completion) {
            completion(model,error);
        }
    }];
}

+ (TTHttpTask *)requestSocialSearchByText:(NSString *)text class:(Class)cls completion:(void (^ _Nullable)(id <FHBaseModelProtocol> model, NSError *error))completion {
    NSString *queryPath = @"/f100/ugc/search";
    NSMutableDictionary *paramDic = [NSMutableDictionary new];
    if (text.length > 0) {
        paramDic[@"text"] = text;
    }
    return [FHMainApi queryData:queryPath params:paramDic class:cls completion:completion];
}

@end
