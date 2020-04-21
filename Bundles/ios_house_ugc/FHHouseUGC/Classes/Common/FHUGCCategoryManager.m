//
//  FHUGCCategoryManager.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/4/20.
//

#import "FHUGCCategoryManager.h"
#import "TTLocationManager.h"
#import "TTArticleCategoryManager.h"
#import "TTBaseMacro.h"
#import "TTNetworkManager.h"
#import "TTURLDomainHelper.h"
#import "NSDictionary+TTAdditions.h"
#import "FHMainApi.h"
#import "TTSandBoxHelper.h"

@implementation FHUGCCategoryManager

+ (FHUGCCategoryManager *)sharedManager
{
    static FHUGCCategoryManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FHUGCCategoryManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.allCategories = [NSMutableArray array];
    }
    return self;
}


+ (FHCommunityCollectionCellType)convertCategoryToType:(NSString *)category {
    FHCommunityCollectionCellType type = FHCommunityCollectionCellTypeNone;
    if([category isEqualToString:@"f_ugc_follow"]){
        type = FHCommunityCollectionCellTypeMyJoin;
    }else if([category isEqualToString:@"f_ugc_neighbor"]){
        type = FHCommunityCollectionCellTypeNearby;
    }else{
        type = FHCommunityCollectionCellTypeCustom;
    }
    return type;
}

- (void)startGetCategory
{
    [self startGetCategory:NO];
}

- (void)startGetCategory:(BOOL)userChanged
{
    Class cls = NSClassFromString(@"FHUGCCategoryModel");
    NSDate *startDate = [NSDate date];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:5];
    
    TTCategory *newsLocalCategory = [TTArticleCategoryManager newsLocalCategory];
    //用户选择过城市，发送给服务端
    if (newsLocalCategory && [TTArticleCategoryManager isUserSelectedLocalCity]) {
        [params setValue:newsLocalCategory.name forKey:@"user_city"];
    }
    
    CLLocationCoordinate2D coord = [TTLocationManager sharedManager].placemarkItem.coordinate;
    double lon = coord.longitude;
    double lat = coord.latitude;
    if (lon * lat > 0) {
        [params setValue:@(lat) forKey:@"latitude"];
        [params setValue:@(lon) forKey:@"longitude"];
    }
    
    //gps 城市
    NSString *city = [TTLocationManager sharedManager].city;
    if(city.length > 0){
        [params setValue:city forKey:@"city"];
    }
    
    //服务端返回的城市
    [params setValue:[[self class] latestServerLocalCity] forKey:@"server_city"];
    
    //version
    [params setValue:[[self class] fetchGetCategoryVersion] forKey:@"version"];
    
    //categories
//    NSString * categorysStr = [self fetchGetCategoryCategoryIDs];
//    [params setValue:categorysStr forKey:@"categories"];

//    NSString * preFixedCategoryIDStr = [self fetchGetPrefixedCategoryCategoryIDs];
//    [params setValue:preFixedCategoryIDStr forKey:@"pre_categories"];
    
//    if ([categorysStr isEqualToString:@"[\n\n]"]) {
//        [params setValue: @"0" forKey:@"version"];
//    }
    
    //是否用户主动修改
    [params setValue:@(userChanged) forKey:@"user_modify"];
    
    [[TTNetworkManager shareInstance] requestForBinaryWithResponse:[self subscribedCategoryURLString] params:params method:@"GET" needCommonParams:YES callback:^(NSError *error, id obj, TTHttpResponse *response) {
        __block NSError *backError = error;
        NSDate *backDate = [NSDate date];
        NSDate *serDate = [NSDate date];
        FHNetworkMonitorType resultType = FHNetworkMonitorTypeSuccess;
        NSInteger code = 0;
        NSString *errMsg = nil;
        NSMutableDictionary *extraDict = nil;
        NSDictionary *exceptionDict = nil;
        id <FHBaseModelProtocol> model = nil;
        NSInteger responseCode = -1;
        if (response.statusCode) {
            responseCode = response.statusCode;
        }

        if (backError && !obj) {
            code = backError.code;
            resultType = FHNetworkMonitorTypeNetFailed;
            
            if (self.completionRequest) {
                self.completionRequest(NO);
            }
        } else {
            model = (id <FHBaseModelProtocol>) [FHMainApi generateModel:obj class:cls error:&backError];
            if([model isKindOfClass:[FHUGCCategoryModel class]]){
                FHUGCCategoryModel *categoryModel = (FHUGCCategoryModel *)model;
                
                [[self class] setHasGotRemoteData];

                NSString * remoteVersion = categoryModel.data.version;
                [[self class] setGetCategoryVersion:remoteVersion];
                
                [self.allCategories removeAllObjects];
                [self.allCategories addObjectsFromArray:categoryModel.data.data];

                if (self.completionRequest) {
                    self.completionRequest(YES);
                }
            }else{
                if (self.completionRequest) {
                    self.completionRequest(NO);
                }
            }
            
            serDate = [NSDate date];
            if (!model) {
                // model 为nil
                code = 1;
                resultType = FHNetworkMonitorTypeBizFailed + 1;
            } else {
                // model 不为nil
                if ([model respondsToSelector:@selector(status)]) {
                    NSString *status = [model performSelector:@selector(status)];
                    if (status.integerValue != 0 || backError != nil) {
                        code = [status integerValue];
                        errMsg = backError.domain;
                        resultType = FHNetworkMonitorTypeBizFailed+code;
                    }
                }
            }
        }
        [FHMainApi addRequestLog:[self subscribedCategoryURLString] startDate:startDate backDate:backDate serializeDate:serDate resultType:resultType errorCode:code errorMsg:errMsg extra:extraDict exceptionDict:exceptionDict responseCode:responseCode];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAritlceCategoryGotFinishedNotification object:nil];
    }];

}

- (void)startGetCategoryWithCompleticon:(void(^)(BOOL isSuccess))completion
{
    self.completionRequest = completion;
    [self startGetCategory];
}

#pragma mark -- get category version
/**
 *  返回get_category API发送是携带的version信息
 *
 *  @return version信息
 */
+ (NSString *)fetchGetCategoryVersion
{
    NSString *result = nil;
    if ([TTArticleCategoryManager hasGotRemoteData]) {//从远端获取到过频道信息， 用频道数据库的信息
        result = [[NSUserDefaults standardUserDefaults] objectForKey:kArticleCategoryManagerVersionKey];
    }
    else {//未从远端获取到过频道信息
        //特殊情况下的客户端段上报：上报内置频道列表时version为2，旧版升级新版时上报版本为1
        result = @"2";
    }
    
    if (isEmptyString(result)) {
        return @"0";
    }
    return result;
}

+ (void)setGetCategoryVersion:(NSString *)version
{
    if (isEmptyString(version)) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kArticleCategoryManagerVersionKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:version forKey:kArticleCategoryManagerVersionKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//#pragma mark -- get category categoryIDs
///**
// *  返回get_category API发送是携带的category信息
// *
// *  @return category ID的array 转换为Json的array
// */
//- (NSString *)fetchGetCategoryCategoryIDs
//{
//    NSArray *categoryIDs = [self subscribedCategoryIDs];
//    NSMutableArray *fixCategoryIDs = [NSMutableArray arrayWithArray:categoryIDs];
//    if ([fixCategoryIDs containsObject:kTTMainCategoryID]) {
//        [fixCategoryIDs removeObject:kTTMainCategoryID];
//    }
//    NSString *result = [fixCategoryIDs tt_JSONRepresentation];
//    return result;
//}
//
//- (NSString *)fetchGetPrefixedCategoryCategoryIDs {
//
//    NSArray *preFixedCategoryIDs = [self prefixedCategoryIDs];
//    NSMutableArray *fixCategoryIDs = [NSMutableArray arrayWithArray:preFixedCategoryIDs];
//
//    if ([fixCategoryIDs containsObject:kTTMainCategoryID]) {
//        [fixCategoryIDs removeObject:kTTMainCategoryID];
//    }
//
//    NSString *result = [fixCategoryIDs tt_JSONRepresentation];
//    return result;
//
//}

+ (void)setServerLocalCityName:(NSString *)name
{
    if (name == nil) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kArticleCategoryManagerServerLocalCityNameKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setValue:name forKey:kArticleCategoryManagerServerLocalCityNameKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)latestServerLocalCity
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kArticleCategoryManagerServerLocalCityNameKey];
}

- (NSString *)subscribedCategoryURLString
{
    NSString *domain = [[TTURLDomainHelper shareInstance] domainFromType:TTURLDomainTypeNormal];
    return [NSString stringWithFormat:@"%@/category/get_light/1/", domain];
}

/**
 *  设置当前版本获取到过远端的频道数据
 */
+ (void)setHasGotRemoteData
{
    NSString * keyStr = [NSString stringWithFormat:@"ArticleCategoryManagerGotRemoteData%@", [TTSandBoxHelper versionName]];
    [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:keyStr];
}

+ (void)clearHasGotRemoteData {
    NSString * keyStr = [NSString stringWithFormat:@"ArticleCategoryManagerGotRemoteData%@", [TTSandBoxHelper versionName]];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:keyStr];
}

@end
