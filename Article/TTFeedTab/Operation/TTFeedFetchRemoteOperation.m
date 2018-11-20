//
//  TTFeedFetchRemoteOperation.m
//  Article
//
//  Created by fengyadong on 16/11/14.
//
//

#import "TTFeedFetchRemoteOperation.h"
#import "TTFeedContainerViewModel.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTNetworkManager.h"
#import "TTNetworkUtilities.h"
#import "TTLocationManager.h"
#import "TTArticleCategoryManager.h"
#import "NSStringAdditions.h"
#import "TTNetworkTouTiaoDefine.h"
#import "ExploreFetchListDefines.h"
#import "ExploreListHelper.h"
#import "TTFeedValidator.h"
#import <TTBaseLib/JSONAdditions.h>
#import "Card+CoreDataClass.h"
#import <SDWebImage/SDWebImageCompat.h>
#import "TTHistoryEntryGroup.h"

@interface TTFeedFetchRemoteOperation ()

@property (nonatomic, assign) uint64_t startTime;
@property (nonatomic, assign) uint64_t endTime;
@property (nonatomic, strong) NSNumber *rankKey;
@property (nonatomic, strong) NSDictionary *remoteDict;
@property (nonatomic, strong) NSArray *flattenList;
@property (nonatomic, assign) BOOL hasPostInterestWords;
@property (nonatomic, strong) NSError *error;

@end

@implementation TTFeedFetchRemoteOperation

@synthesize startTime = _startTime;
@synthesize endTime = _endTime;

static TTFeedValidator *_feedValidator;
+ (TTFeedValidator *)feedValidator {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _feedValidator = [[TTFeedValidator alloc] init];
    });
    return _feedValidator;
}

- (instancetype)initWithViewModel:(TTFeedContainerViewModel *)viewModel {
    if (self = [super initWithViewModel:viewModel]) {
        if ([self.viewModel respondsToSelector:@selector(hasPostInterestWords)]) {
            _hasPostInterestWords = [self.viewModel.delegate hasPostInterestWords];
        }
    }
    return self;
}

- (void)asyncOperation {
    
    if (!self.viewModel.delegate) {
        [self didFinishCurrentOperation];
        return;
    }

    self.startTime = [NSObject currentUnixTime];
    
    dispatch_main_sync_safe(^{
        [self.targetVC tt_startUpdate];
    });
    
    NSArray<ExploreOrderedData *> *allItems = self.viewModel.allItems;
    
    if([allItems count] > 0)
    {
        if(self.viewModel.loadMore)
        {
            NSNumber * oIndex = nil;
            
            id lastObject = [allItems lastObject];
            if ([lastObject isKindOfClass:[ExploreOrderedData class]]) {
                oIndex = @([((ExploreOrderedData *)lastObject) behotTime]);
            } else if ([lastObject isKindOfClass:[TTHistoryEntryGroup class]]) {
                oIndex = @([((TTHistoryEntryGroup *)lastObject).orderedDataList.lastObject behotTime]);
            }
            
            if (oIndex) {
                self.rankKey = oIndex;
            }
        }
        else
        {
            NSNumber * oIndex = nil;
            
            id fistObject = [allItems firstObject];
            if ([fistObject isKindOfClass:[ExploreOrderedData class]]) {
                oIndex = @([((ExploreOrderedData *)fistObject) behotTime]);
            } else if ([fistObject isKindOfClass:[TTHistoryEntryGroup class]]) {
                oIndex = @([((TTHistoryEntryGroup *)fistObject).orderedDataList.firstObject behotTime]);
            }
            
            if (oIndex) {
                self.rankKey = oIndex;
            }

        }
    }
    
    NSMutableDictionary *getParams = [NSMutableDictionary dictionaryWithDictionary:[self generateCommonGetParams]];
    
    if ([self.viewModel.delegate respondsToSelector:@selector(getParamsForHTTPRequest)]) {
        [getParams setValuesForKeysWithDictionary:[self.viewModel.delegate getParamsForHTTPRequest]];
    }
    
    NSDictionary *postParams = nil;
    if ([self.viewModel.delegate respondsToSelector:@selector(postParamsForHTTPRequest)]) {
        postParams = [self.viewModel.delegate postParamsForHTTPRequest];
    }
    
    NSString *URLString = nil;
    if ([self.viewModel.delegate respondsToSelector:@selector(URLStringForHTTPRequst)]) {
        URLString = [self.viewModel.delegate URLStringForHTTPRequst];
    }

    NSString *methodName = @"GET";
    if ([self.viewModel.delegate respondsToSelector:@selector(methodForHTTPRequst)]) {
        methodName = [self.viewModel.delegate methodForHTTPRequst];
    }

    if(isEmptyString(URLString)) {
        [self didFinishCurrentOperation];
        return;
    }

    [[TTNetworkManager shareInstance] requestForJSONWithURL:[[NSURL tt_URLWithString:URLString parameters:getParams] absoluteString] params:postParams method:methodName needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        self.error = error;
        if(error) {
            self.endTime = [NSObject currentUnixTime];
            
            NSData *responseData = error.userInfo[@"TTNetworkErrorOriginalDataKey"];
            if ([responseData isKindOfClass:[NSData class]] && (error.code == kTTNetworkManagerJsonResultNotDictionaryErrorCode)) {
                /// 发送失败的事件
                //            api_error
                NSMutableDictionary *events = [@{@"category":@"umeng", @"label":@"json", @"tag":@"api_error"} mutableCopy];
                NSData *subdata = [responseData subdataWithRange:NSMakeRange(0, MIN(16, responseData.length))];
                [events setValue:[subdata hexadecimalString] forKey:@"data"];
                [TTTrackerWrapper eventData:events];
            }
            
            [self didFinishCurrentOperation];
        }
        else {
            if (((NSDictionary *)jsonObj).count > 0) {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                NSNumber *newUserActionValue = [userDefaults objectForKey:kUserDefaultNewUserActionKey];
                if (self.hasPostInterestWords){
                    NSDictionary *interestWordsDictionary = [userDefaults objectForKey:kRNCellNewUserActionInterestWordsDictionary];
                    if (interestWordsDictionary.count > 0 && [newUserActionValue intValue] < 3) {
                        [userDefaults removeObjectForKey: kRNCellNewUserActionInterestWordsDictionary];
                        [userDefaults setValue:@(3) forKey:kUserDefaultNewUserActionKey];
                    }
                    self.hasPostInterestWords = NO;
                    [userDefaults synchronize];
                }
                else if([newUserActionValue intValue] < 3){
                    [userDefaults setValue:@([newUserActionValue intValue] + 1) forKey:kUserDefaultNewUserActionKey];
                    [userDefaults synchronize];
                }
                
                [self parseRemoteDict:(NSDictionary *)jsonObj];
            }
        }
    }];
}

- (NSDictionary*)generateCommonGetParams
{
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:5];
    
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
    
    if ([TTLocationManager sharedManager].baiduPlacemarkItem) {
        TTPlacemarkItem *placemarkItem = [TTLocationManager sharedManager].baiduPlacemarkItem;
        if (placemarkItem.coordinate.longitude > 0) {
            [param setValue:@(placemarkItem.coordinate.latitude) forKey:@"bd_latitude"];
            [param setValue:@(placemarkItem.coordinate.longitude) forKey:@"bd_longitude"];
        }
        NSString *city = placemarkItem.city;
        if (!isEmptyString(city)) {
            [param setValue:city forKey:@"bd_city"];
        }
        long long locTime = (long long)placemarkItem.timestamp;
        [param setValue:@(locTime) forKey:@"bd_loc_time"];
    }
    
    [param setValue:[[self class] encreptTime:[[NSDate date] timeIntervalSince1970]] forKey:@"cp"];
    
    // loc_mode(定位服务状态)
    BOOL bLocEnabled = [TTLocationManager isLocationServiceEnabled];
    [param setValue:@(bLocEnabled) forKey:@"loc_mode"];

    [param setValue:[[ExploreListHelper class] refreshTypeStrForReloadFromType:self.reloadType]forKey:@"tt_from"];
    
    TTArticleCategoryManager *manager = [TTArticleCategoryManager sharedManager];
    
    if (![manager.localCategory.name isEqualToString:kTTNewsLocalCategoryNoCityName]) {
        //用户选择过城市，发送给服务端
        TTCategory *newsLocalCategory = [TTArticleCategoryManager newsLocalCategory];
        if (newsLocalCategory && [TTArticleCategoryManager isUserSelectedLocalCity]) {
            [param setValue:newsLocalCategory.name forKey:@"user_city"];
        }
    }
    
    [param setValue:[TTDeviceHelper currentLanguage] forKey:@"language"];
   
    return param;
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

- (void)parseRemoteDict:(NSDictionary *)remoteDict {
    self.remoteDict = remoteDict;
    self.flattenList = [self parsedPersistentsForDict:remoteDict];
    self.endTime = [NSObject currentUnixTime];
    [self didFinishCurrentOperation];
}

- (NSArray *)parsedPersistentsForDict:(NSDictionary *)remoteDict {
    NSArray *remoteList = [remoteDict objectForKey:@"data"];
    
    NSMutableArray *persistents = [NSMutableArray arrayWithCapacity:10];       //保存非内嵌型数据(原始数据)
    //    NSMutableArray * cardArticles = [NSMutableArray arrayWithCapacity:10];      // card里的article
    //
    //    NSMutableArray * cardStockDatas = [NSMutableArray arrayWithCapacity:10];        //card里的自选股cell
    //    NSMutableArray * cardBookDatas = [NSMutableArray arrayWithCapacity:10];         //card里推荐多本小说
    
    NSUInteger searchStartOrderIndex = 0;//用于搜索
    if (self.loadMoreCount) {
        searchStartOrderIndex = (self.loadMoreCount + 1) * kExploreFetchListSearchRemoteLoadCount;
    }
    
    //存储文章，段子的group id， 用于一次返回的列表内消重
    NSMutableSet * infoGIDSet = [NSMutableSet setWithCapacity:20];
    NSMutableSet *infoIIDs = [NSMutableSet setWithCapacity:5];
    
    NSMutableArray *incorrectRecords = [NSMutableArray arrayWithCapacity:2];
    for(NSDictionary *originDict in remoteList)
    {
        if (![originDict isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSDictionary * dict;
        if ([originDict.allKeys containsObject:@"code"] && [originDict count]<=2) {
            NSString* content  = [originDict valueForKey:@"content"];
            NSData * contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
            dict = [NSJSONSerialization JSONObjectWithData:contentData options:NSJSONReadingMutableContainers error:nil];
        }else{
            dict = originDict;
        }
        if (!dict) {
            continue;
        }
    
        //此处处理不支持的类型
        ExploreOrderedDataCellType cellType = [[dict objectForKey:@"cell_type"] intValue];
        BOOL supportCellType = [ExploreListHelper supportForCellType:cellType];
        if (!supportCellType) {
            continue;
        }
        if (![[[self class] feedValidator] isValidObject:dict]) {
            [incorrectRecords addObject:dict];
            continue;
        }
        
        NSMutableDictionary * mutDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        
        if (!isEmptyString(self.categoryID)) {
            [mutDict setValue:self.categoryID forKey:@"categoryID"];
        } else {
            [mutDict setValue:@"" forKey:@"categoryID"];
        }
        
        if (!isEmptyString(self.concernID)) {
            [mutDict setValue:self.concernID forKey:@"concernID"];
        } else {
            [mutDict setValue:@"" forKey:@"concernID"];
        }
        
        [mutDict setValue:@(self.listType) forKey:@"listType"];
        [mutDict setValue:@(self.listLocation) forKey:@"listLocation"];
        
        if (self.listType == ExploreOrderedDataListTypeFavorite) {
            if (![[dict allKeys] containsObject:@"user_repin_time"]) {
                //没有user_repin_time的数据用behot_time
                if ([[dict allKeys] containsObject:kExploreOrderedDataCursorKey]) {
                    [mutDict setValue:[dict objectForKey:kExploreOrderedDataCursorKey] forKey:@"orderIndex"];
                }
                else if ([[dict allKeys] containsObject:@"behot_time"]) {
                    NSNumber *behotTime = [dict objectForKey:@"behot_time"];
                    [mutDict setValue:@([behotTime longLongValue] * 1000) forKey:@"orderIndex"];
                }
                else {
                    //没有user_repin_time和behot_time、cursor的数据过滤
                    continue;
                }
                
            }
            else {
                //补充order Index
                NSNumber *repinTime = [dict objectForKey:@"user_repin_time"];
                [mutDict setValue:@([repinTime longLongValue] * 1000) forKey:@"orderIndex"];
            }
            
            [mutDict setValue:@(YES) forKey:@"user_repin"];
        } else if (self.listType == ExploreOrderedDataListTypeReadHistory || self.listType == ExploreOrderedDataListTypePushHistory) {
            if ([mutDict valueForKey:@"date"]) {
                [mutDict setValue:[self parsedPersistentsForDict:mutDict] forKey:@"data"];
                [persistents addObject:mutDict];
            }
        } else {
            if ([[dict allKeys] containsObject:kExploreOrderedDataCursorKey]) {
                [mutDict setValue:[dict objectForKey:kExploreOrderedDataCursorKey] forKey:@"orderIndex"];
            }
            else if ([[dict allKeys] containsObject:@"behot_time"]) {
                NSNumber *behotTime = [dict objectForKey:@"behot_time"];
                [mutDict setValue:@([behotTime longLongValue] * 1000) forKey:@"orderIndex"];
            }
            else {
                //没有behot_time、cursor的数据， 全部过滤
                continue;
            }
        }
        
        NSString *itemID = nil;
        if (dict[@"item_id"]) {
            itemID = [NSString stringWithFormat:@"%@", dict[@"item_id"]];
        }
        [mutDict setValue:itemID forKey:@"itemID"];
        
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
        [mutDict setValue:@(now) forKey:@"requestTime"];
                
        if (cellType == ExploreOrderedDataCellTypeArticle ||
            cellType == ExploreOrderedDataCellTypeEssay) {
            
            if (![[dict allKeys] containsObject:@"group_id"]) {
                //判断，如果没有gid，则废弃这条数据
                continue;
            }
            NSString * gid = [NSString stringWithFormat:@"%@", [dict objectForKey:@"group_id"]];
            if ([infoGIDSet containsObject:gid] || (itemID && [infoIIDs containsObject:itemID])) {
                //如果本次返回的数据，已经有包含这个gid/itemid 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:gid];
            if (itemID) {
                [infoIIDs addObject:itemID];
            }
            [mutDict setValue:@([gid longLongValue]) forKey:@"uniqueID"];
            
            /// 新增了文章类型的广告，实际是文章，但是 广告的属性都包含在 ad_data里面，为了避免新建很多字段进行存储，就直接dump成string存储
            if ([dict valueForKey:@"ad_data"]) {
                NSDictionary *adData = [dict valueForKey:@"ad_data"];
                if ([adData isKindOfClass:[NSDictionary class]]) {
                    NSString *adPromoter = [adData tt_JSONRepresentation];
                    [mutDict setValue:adPromoter forKey:@"ad_data"];
                }
            }
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeThread) {
            if (![[dict allKeys] containsObject:@"thread_id"]) {
                //判断，如果没有thread_id，就废弃这条数据
                continue;
            }
            NSString *tid = [NSString stringWithFormat:@"%@", [dict objectForKey:@"thread_id"]];
            
            if ([infoGIDSet containsObject:tid]) {
                //如果本次返回的数据，已经有包含这个adID 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:tid];
            
            [mutDict setValue:@([tid longLongValue]) forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if (cellType == ExploreOrderedDataCellTypeAppDownload) {
            if (![[dict allKeys] containsObject:@"ad_id"]) {
                //判断，如果没有adid，则废弃这条数据
                continue;
            }
            NSString * adID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"ad_id"]];
            
            if ([infoGIDSet containsObject:adID]) {
                //如果本次返回的数据，已经有包含这个adID 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:adID];
            
            [mutDict setValue:@([adID longLongValue]) forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        }
        else if(cellType == ExploreOrderedDataCellTypeCard)
        {
            if (![[dict allKeys] containsObject:@"id"]) {
                //判断，如果没有group id，则废弃这条数据
                LOGD(@"ExploreOrderedDataCellTypeCard has NO id");
                continue;
            }
            
            NSString * gID = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
            [mutDict setValue:@([gID longLongValue]) forKey:@"uniqueID"];
            
            if ([infoGIDSet containsObject:gID]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            
            [infoGIDSet addObject:gID];
            [mutDict setValue:@([gID longLongValue]) forKey:@"uniqueID"];
            [persistents addObject:mutDict];
            LOGD(@"card uniqueID: %@", gID);
            // 处理card里的article
            for (NSDictionary *data in [mutDict tt_arrayValueForKey:@"data"])
            {
                ExploreOrderedDataCellType cellType = [data tt_intValueForKey:@"cell_type"];
                if (cellType == ExploreOrderedDataCellTypeArticle)
                {
                    if (![[data allKeys] containsObject:@"group_id"]) {
                        //判断，如果没有gid，则废弃这条数据
                        LOGD(@"ExploreOrderedDataCellTypeCard has NO group_id");
                        continue;
                    }
                    
                    NSString *gid = [NSString stringWithFormat:@"%@", [data objectForKey:@"group_id"]];
                    
                    NSMutableDictionary *articleData = [NSMutableDictionary dictionaryWithDictionary:data];
                    [articleData setValue:@([gid longLongValue]) forKey:@"uniqueID"];
                    [articleData setValue:self.categoryID forKey:@"categoryID"];
                    [articleData setValue:self.concernID forKey:@"concernID"];
                    [articleData setValue:@(ExploreOrderedDataListTypeCategory) forKey:@"listType"];
                    [articleData setValue:@(ExploreOrderedDataListLocationCard) forKey:@"listLocation"];
                    [persistents addObject:articleData];
                }
                else if (cellType == ExploreOrderedDataCellTypeStock){
                    if (![[data allKeys] containsObject:@"id"]) {
                        //判断，如果没有gid，则废弃这条数据
                        continue;
                    }
                    
                    NSString *gid = [NSString stringWithFormat:@"%@", [data objectForKey:@"id"]];
                    
                    NSMutableDictionary *stockData = [NSMutableDictionary dictionaryWithDictionary:data];
                    [stockData setValue:@([gid longLongValue]) forKey:@"uniqueID"];
                    [stockData setValue:self.categoryID forKey:@"categoryID"];
                    [stockData setValue:self.concernID forKey:@"concernID"];
                    [stockData setValue:@(ExploreOrderedDataListTypeCategory) forKey:@"listType"];
                    [stockData setValue:@(ExploreOrderedDataListLocationCard) forKey:@"listLocation"];
                    [persistents addObject:stockData];
                }
                else if (cellType == ExploreOrderedDataCellTypeBook) {
                    if (![[data allKeys] containsObject:@"id"]) {
                        //判断，如果没有gid，则废弃这条数据
                        continue;
                    }
                    
                    NSString *gid = [NSString stringWithFormat:@"%@", [data objectForKey:@"id"]];
                    
                    NSMutableDictionary *bookData = [NSMutableDictionary dictionaryWithDictionary:data];
                    [bookData setValue:@([gid longLongValue]) forKey:@"uniqueID"];
                    [bookData setValue:self.categoryID forKey:@"categoryID"];
                    [bookData setValue:self.concernID forKey:@"concernID"];
                    [bookData setValue:@(ExploreOrderedDataListTypeCategory) forKey:@"listType"];
                    [bookData setValue:@(ExploreOrderedDataListLocationCard) forKey:@"listLocation"];
                    [persistents addObject:bookData];
                }
            }
        }
        else if (cellType == ExploreOrderedDataCellTypeWeb ||
                 cellType == ExploreOrderedDataCellTypeRN ||
                 cellType == ExploreOrderedDataCellTypeInterestGuide ||
                 cellType == ExploreOrderedDataCellTypeDynamicRN) {
            if (![[dict allKeys] containsObject:@"id"]) {
                //判断，如果没有group id，则废弃这条数据
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@", [dict objectForKey:@"id"]];
            
            // 如果is_deleted=YES，清理db以及缓存，列表不再出现
            //            if ([[dict objectForKey:@"is_deleted"] boolValue]) {
            //
            //                continue;
            //            }
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:gid];
            [mutDict setValue:@([gid longLongValue]) forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        } else if (cellType == ExploreOrderedDataCellTypeLive) {
            if (![[dict allKeys] containsObject:@"id"]) {
                //判断，如果没有group id，则废弃这条数据
                continue;
            }
            
            NSString *gid = [NSString stringWithFormat:@"%@", [dict objectForKey:@"live_id"]];
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            
            [infoGIDSet addObject:gid];
            [mutDict setValue:@([gid longLongValue]) forKey:@"uniqueID"];
            [mutDict setValue:@([gid longLongValue]) forKey:@"live_id"];
            [persistents addObject:mutDict];
        } else if (cellType == ExploreOrderedDataCellTypeHuoShan) {
            
            if (![[dict allKeys] containsObject:@"live_id"]) {
                //判断，如果没有live id，则废弃这条数据
                continue;
            }
            NSString *liveId = [NSString stringWithFormat:@"%@", [dict objectForKey:@"live_id"]];
            if ([infoGIDSet containsObject:liveId]) {
                //如果本次返回的数据，已经有包含这个liveId 的数据， 则消重
                continue;
            }
            
            [infoGIDSet addObject:liveId];
            [mutDict setValue:@([liveId longLongValue]) forKey:@"uniqueID"];
            [mutDict setValue:@([liveId longLongValue]) forKey:@"live_id"];
            [persistents addObject:mutDict];
        } else if(cellType == ExploreOrderedDataCellTypeLianZai){
            if(![[dict allKeys] containsObject:@"id"]){
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            
            [infoGIDSet addObject:gid];
            [mutDict setValue:@([gid longLongValue]) forKey:@"uniqueID"];
            //            [mutDict setValue:@([gid longLongValue]) forKey:@"live_id"];
            [persistents addObject:mutDict];
        } else if (cellType == ExploreOrderedDataCellTypeBook) {
            if (![[dict allKeys] containsObject:@"id"]) {
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            
            [infoGIDSet addObject:gid];
            [mutDict setValue:@([gid longLongValue]) forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        } else if (cellType == ExploreOrderedWenDaInviteCellType) {
            if(![[dict allKeys] containsObject:@"id"]){
                continue;
            }
            NSString *gid = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:gid]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            
            [infoGIDSet addObject:gid];
            [mutDict setValue:@([gid longLongValue]) forKey:@"uniqueID"];
            [persistents addObject:mutDict];
        } else if (cellType == ExploreOrderedDataCellTypeShortVideo ||
                   cellType == ExploreOrderedDataCellTypeShortVideo_AD){
            if (![[dict allKeys] containsObject:@"id"]) {
                continue;
            }
            NSString *uniqueID = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:uniqueID]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:uniqueID];
            [mutDict setValue:@([uniqueID longLongValue]) forKey:@"uniqueID"];
            //没有下发item_id，客户端自己加一个
            [mutDict setValue:@([uniqueID longLongValue]) forKey:@"itemID"];
            [persistents addObject:mutDict];
            
        } else if (cellType == ExploreOrderedDataCellTypeFHHouse){
            if (![[dict allKeys] containsObject:@"id"]) {
                continue;
            }
            NSString *uniqueID = [NSString stringWithFormat:@"%@",[dict objectForKey:@"id"]];
            if ([infoGIDSet containsObject:uniqueID]) {
                //如果本次返回的数据，已经有包含这个gid 的数据， 则消重
                continue;
            }
            [infoGIDSet addObject:uniqueID];
            [mutDict setValue:@([uniqueID longLongValue]) forKey:@"uniqueID"];
            //没有下发item_id，客户端自己加一个
            [mutDict setValue:@([uniqueID longLongValue]) forKey:@"itemID"];
            [persistents addObject:mutDict];
        }
        
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (incorrectRecords.count > 0) {
            /// 发送出错的记录给服务器
            [self _handleIncorrectRecords:incorrectRecords];
        }
    });
    
    return [persistents copy];
}

- (void)_handleIncorrectRecords:(NSArray *)records {
    if (SSIsEmptyArray(records)) {
        return;
    }
    // 发送几条数据出错了
    NSDictionary * events = @{@"category":@"umeng", @"tag":@"embeded_ad", @"label":@"invalidate", @"value":@(records.count)};
    [TTTrackerWrapper eventData:events];
}

@end
