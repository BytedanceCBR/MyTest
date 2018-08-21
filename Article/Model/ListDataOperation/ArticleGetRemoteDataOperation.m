//
//  ArticleGetRemoteDataOperation.m
//  Article
//
//  Created by Dianwei on 12-11-18.
//
//

#import "ArticleGetRemoteDataOperation.h"
#import "ArticleURLSetting.h"
#import "NewsUserSettingManager.h"

#import "TTArticleCategoryManager.h"
#import <TTBaseLib/JSONAdditions.h>
#import "ExploreFetchListDefines.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTArticleCategoryManager.h"
#import "TTSubEntranceManager.h"
#import "NSDataAdditions.h"

#import "TTNetworkDefine.h"
#import "TTNetworkManager.h"
#import "TTNetworkUtilities.h"
#import "TTNetworkTouTiaoDefine.h"
#import "NetworkUtilities.h"

#import "TTLocationManager.h"
#import "NSStringAdditions.h"
#import "ListDataHeader.h"
#import "NSObject+TTAdditions.h"
#import "NewsListLogicManager.h"
#import "TTExploreMainViewController.h"
#import <TTAccountBusiness.h>
//#import "TTNetworkManagerAFNetworking.h"
//#import "TTCommonwealManager.h"
#import "ExploreListHelper.h"
#import "TTRNBundleManager.h"
#import "TTCategoryBadgeNumberManager.h"
#import "ExploreFetchListManager.h"

@interface ArticleGetRemoteDataOperation ()
@property(nonatomic, strong)TTHttpTask *httpTask;
@end

@implementation ArticleGetRemoteDataOperation

- (void)dealloc
{
    [_httpTask cancel];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.shouldExecuteBlock = ^(id dataContext){
            BOOL fromRemote = [[dataContext objectForKey:kExploreFetchListFromRemoteKey] boolValue];
            BOOL isDisplayView = [[dataContext objectForKey:kExploreFetchListIsDisplayViewKey] boolValue];
            NSArray *sortedList = [dataContext objectForKey:kExploreFetchListItemsKey];
            BOOL result = fromRemote || (isDisplayView && [sortedList count] == 0);

            // 由于自动清理，只取到了一个LastRead时也应该发起数据请求
            if (!result && isDisplayView && [sortedList count] == 1) {
                ExploreOrderedData *orderedData = sortedList.firstObject;
                if ([orderedData isKindOfClass:[ExploreOrderedData class]] && orderedData.cellType == ExploreOrderedDataCellTypeLastRead) {
                    result = YES;
                }
            }
            
            if (result) {
                BOOL getMore = [[dataContext objectForKey:kExploreFetchListGetMoreKey] boolValue];
                if (!getMore) {
                    NSDictionary *condition = [dataContext objectForKey:kExploreFetchListConditionKey];                    
                    NSString *categoryID = [condition objectForKey:kExploreFetchListConditionListUnitIDKey];
                    NSString *concernID = [condition objectForKey:kExploreFetchListConditionListConcernIDKey];
                    
                    NSString *primaryKey = categoryID ?: concernID;
                    if (!isEmptyString(primaryKey)) {
                        [[NewsListLogicManager shareManager] saveHasReloadForCategoryID:primaryKey];
                    }
                }
            }
            
            return result;
        };
    }
    
    return self;
}

- (void)cancel
{
//    [operation cancelAndClearDelegate];
    [_httpTask cancel];
}

- (void)execute:(id)operationContext
{
    self.hasFinished = NO;
    if(!self.shouldExecuteBlock(operationContext))
    {
        self.hasFinished = YES;
        if (self.opDelegate && [self.opDelegate respondsToSelector:@selector(dataOperationStartExecute:)]) {
            [self.opDelegate dataOperationInterruptExecute:self];
        }
        return;
    }

    
    NSArray * allItems = [operationContext objectForKey:kExploreFetchListItemsKey];
    BOOL getMore = [[operationContext objectForKey:kExploreFetchListGetMoreKey] boolValue];
    NSMutableDictionary *condition = [operationContext objectForKey:kExploreFetchListConditionKey];
    NSMutableDictionary * exploreMixedListConsumeTimeStamps = [condition objectForKey:kExploreFetchListRefreshOrLoadMoreConsumeTimeStampsKey];
    [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime]) forKey:kExploreFetchListGetRemoteDataOperationBeginTimeStampKey];
    
    if([allItems count] > 0)
    {
        if(getMore)
        {
            ExploreOrderedData *lastObject = [allItems lastObject];
            if ([lastObject isKindOfClass:[ExploreOrderedData class]] && lastObject.cellType != ExploreOrderedDataCellTypeLastRead) {
                NSNumber * oIndex = @([lastObject behotTime]);
                if (oIndex) {
                    [condition setObject:oIndex forKey:kListDataConditionRankKey];
                }
            }
        }
        else
        {
            ExploreOrderedData *firstObject = [allItems firstObject];
            if ([firstObject isKindOfClass:[ExploreOrderedData class]] && firstObject.cellType != ExploreOrderedDataCellTypeLastRead) {
                NSNumber * oIndex = @([firstObject behotTime]);
                if (oIndex) {
                    [condition setObject:oIndex forKey:kListDataConditionRankKey];
                }
            }
        }
    }
    [operationContext setValue:@(allItems.count) forKey:kExploreCurrentCategoryListItemCountKey];
    NSDictionary *requestInfo = [ArticleGetRemoteDataOperation requestInfoForOperationContext:operationContext];

    NSString     *completeURLStr    = [requestInfo objectForKey:@"urlString"];
    NSDictionary *getParameter      = [requestInfo objectForKey:@"parameter"];
    NSDictionary *postParameter     = [requestInfo objectForKey:@"postParameter"];
    NSString     *method            = nil;
    NSDictionary *parameters        = nil;

    if (postParameter) {
        method = @"POST";
        parameters = postParameter;
        if (getParameter) {
            completeURLStr = [[NSURL tt_URLWithString:completeURLStr parameters:getParameter] absoluteString];
        }
    } else {
        method = @"GET";
        parameters = getParameter;
    }
    
    [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime]) forKey:kExploreFetchListRemoteRequestBeginTimeStampKey];
    
    [self.httpTask cancel];
    
    WeakSelf;
    self.httpTask = [[TTNetworkManager shareInstance] requestForJSONWithURL:completeURLStr
                                                                     params:parameters
                                                                     method:method
                                                           needCommonParams:YES
                                                                   callback:^(NSError *error, id jsonObj) {
                                                                       StrongSelf;
                                                                       self.httpTask = nil;
                                                                       
                                                                       if (jsonObj) {
                                                                           jsonObj = @{@"result":jsonObj};
                                                                       }
                                                                       if (error && error.code != NSURLErrorCancelled) {
                                                                           NSMutableDictionary * monitorParams = [[NSMutableDictionary alloc] init];
                                                                           [monitorParams setValue:completeURLStr forKey:@"request_url"];
                                                                           [monitorParams setValue:error.description forKey:@"error"];
                                                                           [monitorParams addEntriesFromDictionary:getParameter];
                                                                           [monitorParams setValue:@(error.code) forKey:@"error_code"];
//                                                                           if ([[TTNetworkManager shareInstance] isKindOfClass:[TTNetworkManagerAFNetworking class]]) {
//                                                                               [monitorParams setValue:@0 forKey:@"status"];
//                                                                           }else{
                                                                               [monitorParams setValue:@1 forKey:@"status"];
//                                                                           }
                                                                           if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
                                                                               [monitorParams setValue:@2 forKey:@"status"];
                                                                           }
                                                                           
                                                                           NSNumber *resonseCode = [error.userInfo valueForKey:@"response_code"];
                                                                           //服务端业务错误
                                                                           if (resonseCode) {
                                                                               [monitorParams setValue:resonseCode forKey:@"error_code"];
                                                                               //用作查询纯服务端触发的错误
                                                                               [monitorParams setValue:resonseCode forKey:@"response_error_code"];
                                                                           }
                                                                         
                                                                           NSString *status = [[jsonObj tt_dictionaryValueForKey:@"result"] tt_stringValueForKey:@"message"];
                                                                           if (status && ![status isEqualToString:@"success"]) {
                                                                               [monitorParams setValue:status forKey:@"message_info"];
                                                                           }
                                                                           [[TTMonitor shareManager] trackService:@"feed_load_status" attributes:monitorParams];
                                                                       }
                                                                       
                                                                       NSError *logicError = [SSCommonLogic handleError:error responseResult:jsonObj exceptionInfo:NULL treatExceptionAsError:YES requestURL:completeURLStr];
                                                                       [self result:jsonObj error:logicError userInfo:operationContext];
                                                                   }];
}

+ (NSDictionary*)requestInfoForOperationContext:(id)context
{
    NSMutableString * urlString = [[NSMutableString alloc] initWithCapacity:30];
    BOOL loadMore = [[context objectForKey:kExploreFetchListGetMoreKey] boolValue];
    NSDictionary *condition = [context objectForKey:kExploreFetchListConditionKey];
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:5];
    NSMutableDictionary *postParam = [NSMutableDictionary dictionaryWithCapacity:5];
    NSInteger count = kExploreFetchListRemoteLoadCount;
    
    if ([context objectForKey:kExploreFetchListConditionKey][kExploreFetchListSilentFetchFromRemoteKey]) {
        // 快速插入，refresh_type设置值为4
        [param setObject:@(4) forKey:@"refresh_type"];
    }
    
    ExploreOrderedDataListType listType = [[context objectForKey:kExploreFetchListListTypeKey] intValue];
    ListDataOperationReloadFromType reloadFromType = [[condition objectForKey:kExploreFetchListConditionReloadFromTypeKey] intValue];
    NSString * categoryID = [condition objectForKey:kExploreFetchListConditionListUnitIDKey];
    
    // refresh增加session参数
    NSInteger feedLoadLocalStrategy = [SSCommonLogic feedLoadLocalStrategy];
    if (categoryID && !loadMore && feedLoadLocalStrategy == 0) {
        [[ExploreFetchListRefreshSessionManager sharedInstance] updateSessionCountForCategoryID:categoryID];
        NSInteger sessionCount = [[ExploreFetchListRefreshSessionManager sharedInstance] sessionCountForCategoryID:categoryID];
        [param setObject:@(sessionCount) forKey:@"session_refresh_idx"];
    }
    
    if (listType == ExploreOrderedDataListTypeCategory)
    {
//        [urlString appendString:[ArticleURLSetting recentURLString]];
        
        if (!loadMore) {
            NSNumber *refreshType = [condition objectForKey:kExploreFetchListRefreshTypeKey];
            if (!refreshType) {
                refreshType = [NSNumber numberWithInt:0];
            }
            [param setObject:refreshType forKey:@"refresh_reason"];
        }
        
        if(loadMore && [condition objectForKey:kExploreFetchListConditionBeHotTimeKey])
        {
            NSNumber *maxBehotTimeNumber = [condition objectForKey:kExploreFetchListConditionBeHotTimeKey];
            if(!maxBehotTimeNumber) maxBehotTimeNumber = [NSNumber numberWithInt:0];
            [param setObject:maxBehotTimeNumber forKey:@"max_behot_time"];
        }
        else
        {
            NSNumber * minBeHotTimeNumber = [NSNumber numberWithInt:0];
            if ([condition objectForKey:kExploreFetchListConditionBeHotTimeKey])
            {
                minBeHotTimeNumber = [condition objectForKey:kExploreFetchListConditionBeHotTimeKey];
            }
            [param setObject:minBeHotTimeNumber forKey:@"min_behot_time"];
        }
        if (listType == ExploreOrderedDataListTypeCategory) {
            ExploreFetchListApiType apiType = [[condition objectForKey:kExploreFetchListConditionApiType] unsignedIntegerValue];
            NSString * concernID = [condition objectForKey:kExploreFetchListConditionListConcernIDKey];
            NSString * movieCommentVideoID = [condition objectForKey:kExploreFetchListConditionListMovieCommentVideoIDKey];
            NSString *movieCommentEntireID = [condition objectForKey:kExploreFetchListConditionListMovieCommentEntireIDKey];
            
            if ([categoryID isEqualToString:kTTMainCategoryID]) {
                //推荐频道不传categoryID
                //v5.5.x:和曾怀东确定了，推荐频道上传concernID
                [param setValue:concernID forKey:@"concern_id"];
                if (![ExploreLogicSetting isUpgradeUser]) {//新用户在推荐频道出兴趣选择cell
                    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
                    NSNumber *newUserActionValue = [userDefaults objectForKey:kUserDefaultNewUserActionKey];
                    if ([newUserActionValue intValue] < 3) {//不存在或者为1/2时返回new_user_action:1/2/3
                        NSDictionary *interestWordsDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:kRNCellNewUserActionInterestWordsDictionary];
                        if (interestWordsDictionary.count > 0) {
                            [param setValue:@(3) forKey:@"new_user_action"];
                            NSString *interestWordsJSON = [interestWordsDictionary tt_JSONRepresentation];
                            [postParam setValue:interestWordsJSON forKey:@"interest_words"];
                            [context setValue:@(YES) forKey:kExploreFetchListHasPostNewUserActionKey];
                        }
                        else{
                            if([newUserActionValue intValue] < 2) {
                                [param setValue:@([newUserActionValue intValue] + 1) forKey:@"new_user_action"];
                            }
                            [context setValue:@(NO) forKey:kExploreFetchListHasPostNewUserActionKey];
                        }
                    }
                }

            }
            else {
                [param setValue:categoryID forKey:@"category"];
                [param setValue:concernID forKey:@"concern_id"];
                [param setValue:movieCommentVideoID forKey:@"mov_id"];
                [param setValue:movieCommentEntireID forKey:@"movie_id"];
            }
            
            [param setValue:@(0) forKey:@"strict"];
            if (movieCommentVideoID) {
                NSNumber *offset = [condition objectForKey:kExploreFetchListConditionListMovieCommentVideoAPIOffsetKey];
                [param setValue:offset forKey:@"offset"];
                [urlString appendString:[ArticleURLSetting movieCommentVideoTabURLString]];

            } else if (movieCommentEntireID) {
                [urlString appendString:[ArticleURLSetting movieCommentEntireTabURLString]];
            } else {
                switch (apiType) { 
                    case ExploreFetchListApiTypeVerticalVideo: {
                        NSNumber * offset = [condition objectForKey:kExploreFetchListConditionVerticalVideoAPIOffsetKey];
                        [param setValue:offset forKey:@"offset"];
                        [urlString appendString:[ArticleURLSetting verticalVideoURLString]];
                    }
                        break;
                    default: {
                        [urlString appendString:[ArticleURLSetting encrpytionStreamUrlString]];
                    }
                        break;
                }
            }
            //请求来自：1.频道 2.关心主页
            NSUInteger refer = [[condition objectForKey:kExploreFetchListConditionListReferKey] unsignedIntegerValue];
            if (refer != 1 && refer != 2) {
                refer = 1;
            }
            [param setValue:@(refer) forKey:@"refer"];
            
            // 访问来源
            NSString *from = [condition objectForKey:kExploreFetchListConditionFromKey];
            if (!isEmptyString(from)) {
                [param setValue:from forKey:@"from"];
            }
            
            // 是否视频tab
            TTCategoryModelTopType topType = [condition[kExploreFetchListConditionListFromTabKey] unsignedIntegerValue];
            if (topType == TTCategoryModelTopTypeVideo) {
                [param setValue:@"main_tab" forKey:@"list_entrance"];
            } else {
                [param setValue:[condition objectForKey:kExploreFetchListConditionListShortVideoListEntranceKey] forKey:@"list_entrance"];
            }

            // 本地支持的widget React Native bundle
            if (![[TTRNBundleManager sharedManager] localBundleDirtyForModuleName:TTRNWidgetBundleName]) {
                NSString *supportRNBundle = [[TTRNBundleManager sharedManager] bitMaskStringForModuleName:TTRNWidgetBundleName];
                if (!isEmptyString(supportRNBundle)) {
                    [param setValue:supportRNBundle forKey:@"support_rn"];
                }
            }
            
            // extra
            NSString *extra = [condition objectForKey:kExploreFetchListConditionExtraKey];
            if (!isEmptyString(extra)) {
                [param setValue:extra forKey:@"extra"];
            }
            
            //stream API 返回子频道，客户端需传入last_refresh_sub_entrance_interval，表示服务端上次返回子频道离现在的时间间隔，以s为单位。
            NSTimeInterval lastRefreshInterval = [TTSubEntranceManager subEntranceLastRefreshTimeIntervalForCategory:categoryID concernID:concernID];

            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
            [param setValue:@((long long)(now - lastRefreshInterval)) forKey:@"last_refresh_sub_entrance_interval"];
//            //公益项目新加字段
//            if([SSCommonLogic commonwealEntranceEnable]) {
//                [param setValue:[NSString stringWithFormat:@"%.0lf",[[TTCommonwealManager sharedInstance] todayUsingTime]] forKey:@"st_time"];
//            }
        }
        else {
            [param setValue:[condition objectForKey:kExploreFetchListConditionListUnitIDKey] forKey:@"entry_id"];
        }
        
        [param setObject:@(count) forKey:@"count"];
    }
    else {
        NSLog(@"*****warning not support list type*******");
    }
    
    //关注频道刷新的时候是否有红点
    if ([condition objectForKey:kExploreFollowCategoryHasRedPointKey]) {
        [param setValue:[[condition objectForKey:kExploreFollowCategoryHasRedPointKey] boolValue]?@(1):@(0) forKey:@"top_tips"];
    }
    
    //当前频道列表的显示数量
    [param setValue:[context objectForKey:kExploreCurrentCategoryListItemCountKey] forKey:@"list_count"];
    [param setValue:[NSNumber numberWithBool:YES] forKey:@"detail"];
    [param setValue:[NSNumber numberWithBool:YES] forKey:@"image"];
    [param setValue:[TTLocationManager currentLBSStatus] forKey:@"LBS_status"];
    TTPlacemarkItem *placemarkItem = [TTLocationManager sharedManager].placemarkItem;
    if(placemarkItem.coordinate.longitude > 0) {
        [param setValue:@(placemarkItem.coordinate.latitude) forKey:@"latitude"];
        [param setValue:@(placemarkItem.coordinate.longitude) forKey:@"longitude"];
        [param setValue:@((long long)placemarkItem.timestamp) forKey:@"loc_time"];
    }
    NSString *city = [TTLocationManager sharedManager].city;
    [param setValue:city forKey:@"city"];
    
    [param setValue:[self encreptTime:[[NSDate date] timeIntervalSince1970]] forKey:@"cp"];

    if (!loadMore) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        // 用户只有在推荐频道上传通讯录逻辑失败，加 sfl 参数，第一刷显示好友正在读标签
        if ([userDefaults boolForKey:kExploreFetchListShowFriendLabelKey]) {
            [param setValue:@1 forKey:@"sfl"];
            [userDefaults setObject:nil forKey:kExploreFetchListShowFriendLabelKey];
            [userDefaults synchronize];
        }
    }


    // loc_mode(定位服务状态)
    BOOL bLocEnabled = [TTLocationManager isLocationServiceEnabled];
    [param setValue:@(bLocEnabled) forKey:@"loc_mode"];
    
    [param setValue:[ExploreListHelper refreshTypeStrForReloadFromType:reloadFromType] forKey:@"tt_from"];
    
    TTArticleCategoryManager *manager = [TTArticleCategoryManager sharedManager];
    
    if (![manager.localCategory.name isEqualToString:kTTNewsLocalCategoryNoCityName]) {
        //用户选择过城市，发送给服务端
        TTCategory *newsLocalCategory = [TTArticleCategoryManager newsLocalCategory];
        if (newsLocalCategory && [TTArticleCategoryManager isUserSelectedLocalCity]) {
            [param setValue:newsLocalCategory.name forKey:@"user_city"];
        }
    }
    
    [param setValue:[TTDeviceHelper currentLanguage] forKey:@"language"];
    
    /**额外的Get请求参数**/
    NSDictionary *extraParams = [condition tt_dictionaryValueForKey:kExploreFetchListExtraGetParametersKey];
    if (extraParams) {
         [param addEntriesFromDictionary:extraParams];
    }
   
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:3];
    [result setValue:urlString forKey:@"urlString"];
    [result setValue:param forKey:@"parameter"];
    if (postParam.count > 0) {
        [result setValue:postParam forKey:@"postParameter"];
    }
    return result;
}

- (void)result:(NSDictionary*)result error:(NSError*)tError userInfo:(id)userInfo
{
    NSMutableDictionary * exploreMixedListConsumeTimeStamps = [userInfo objectForKey:kExploreFetchListConditionKey][kExploreFetchListRefreshOrLoadMoreConsumeTimeStampsKey];
    [exploreMixedListConsumeTimeStamps setValue:@([NSObject currentUnixTime]) forKey:kExploreFetchListGetRemoteDataOperationEndTimeStampKey];
    
    //标记这个数据是 远端数据还是 本地数据
    [userInfo setValue:@(YES) forKey:kExploreFetchListIsResponseFromRemoteKey];
    
    if(tError) {
        [userInfo setObject:[NSNumber numberWithBool:NO] forKey:kExploreFetchListResponseHasMoreKey];
        [userInfo setObject:[NSNumber numberWithBool:YES] forKey:kExploreFetchListResponseFinishedkey];
        [self notifyWithData:nil error:tError userInfo:userInfo];
        self.hasFinished = YES;
        
        NSData *responseData = tError.userInfo[@"TTNetworkErrorOriginalDataKey"];
        if ([responseData isKindOfClass:[NSData class]] && (tError.code == kTTNetworkManagerJsonResultNotDictionaryErrorCode)) {
            /// 发送失败的事件
            //            api_error
            NSMutableDictionary *events = [@{@"category":@"umeng", @"label":@"json", @"tag":@"api_error"} mutableCopy];
            NSData *subdata = [responseData subdataWithRange:NSMakeRange(0, MIN(16, responseData.length))];
            [events setValue:[subdata hexadecimalString] forKey:@"data"];
            [TTTrackerWrapper eventData:events];
        }
    }
    else {
        NSNumber *hasPostInterestWords = [userInfo objectForKey:kExploreFetchListHasPostNewUserActionKey];
        if (result.count > 0) {
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            NSNumber *newUserActionValue = [userDefaults objectForKey:kUserDefaultNewUserActionKey];
            if ([hasPostInterestWords boolValue]){
                NSDictionary *interestWordsDictionary = [userDefaults objectForKey:kRNCellNewUserActionInterestWordsDictionary];
                if (interestWordsDictionary.count > 0 && [newUserActionValue intValue] < 3) {
                    [userDefaults removeObjectForKey: kRNCellNewUserActionInterestWordsDictionary];
                    [userDefaults setValue:@(3) forKey:kUserDefaultNewUserActionKey];
                }
                [userInfo setValue:@(NO) forKey:kExploreFetchListHasPostNewUserActionKey];
                [userDefaults synchronize];
            }
            else if([newUserActionValue intValue] < 3){
                [userDefaults setValue:@([newUserActionValue intValue] + 1) forKey:kUserDefaultNewUserActionKey];
                [userDefaults synchronize];
            }
        }
        [userInfo setValue:result forKey:kExploreFetchListResponseRemoteDataKey];
        [self executeNext:userInfo];
    }
}


+ (NSString *)encreptTime:(double)time{
    if (time<=0) {
        return nil;
    }
    NSMutableString * returnStr;
    NSString * str = [NSString stringWithFormat:@"%.0f",time];
    NSString *hexedString = [NSString stringWithFormat:@"%lX",[str integerValue]];
    NSString * md5Str = [str MD5HashString];
    if (!hexedString || hexedString.length!=8) {
        return @"7E0AC8874BB0985";//(MD5('suspicious')后15位)，之后将通过日志分析找出相应的可疑 IP 进一步筛查。
    }
    if (hexedString.length==8 && md5Str && md5Str.length>5) {
        returnStr = [[NSMutableString alloc] init];
        for(int i=0; i<5; i++){
            [returnStr appendFormat:@"%c",[hexedString characterAtIndex:i]];
            [returnStr appendFormat:@"%c",[md5Str characterAtIndex:i]];
        }
        [returnStr appendString:[hexedString substringFromIndex:5]];
        [returnStr appendString:@"q1"];
    }
    return returnStr;
}
@end
