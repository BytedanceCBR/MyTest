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
#import "JSONAdditions.h"

@interface FHUGCCategoryManager ()

@property(nonatomic, strong) NSMutableArray *defaultCategories;

@end

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
        _allCategories = [NSMutableArray array];
        _defaultCategories = [self generatDefaultCategories];
    }
    return self;
}

- (NSInteger)getCategoryIndex:(NSString *)category {
    NSInteger index = -1;
    for (NSInteger i = 0; i < _allCategories.count; i++) {
        FHUGCCategoryDataDataModel *model = _allCategories[i];
        if([model.category isEqualToString:category]){
            return i;
            break;
        }
    }
    return index;
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
    
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    extraDic[@"tab_name"] = @"ugc";
    params[@"client_extra_params"] = [extraDic tt_JSONRepresentation];
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

                NSString * remoteVersion = categoryModel.data.version;
                [[self class] setGetCategoryVersion:remoteVersion];
                
                if(categoryModel.data.data.count > 0){
                    [_allCategories removeAllObjects];
                    [_allCategories addObjectsFromArray:categoryModel.data.data];
                }

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
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kUGCCategoryGotFinishedNotification object:nil];
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
        result = [[NSUserDefaults standardUserDefaults] objectForKey:kUGCCategoryManagerVersionKey];
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
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUGCCategoryManagerVersionKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setObject:version forKey:kUGCCategoryManagerVersionKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)setServerLocalCityName:(NSString *)name
{
    if (name == nil) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUGCCategoryManagerServerLocalCityNameKey];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setValue:name forKey:kUGCCategoryManagerServerLocalCityNameKey];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)latestServerLocalCity
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kUGCCategoryManagerServerLocalCityNameKey];
}

- (NSString *)subscribedCategoryURLString
{
    NSString *domain = [[TTURLDomainHelper shareInstance] domainFromType:TTURLDomainTypeNormal];
    return [NSString stringWithFormat:@"%@/category/get_light/1/", domain];
}

- (NSMutableArray *)allCategories {
    if(_allCategories.count <= 0){
        return _defaultCategories;
    }
    
    return _allCategories;
}

//当接口失败时的兜底频道
- (NSMutableArray *)generatDefaultCategories {
    NSMutableArray *categories = [NSMutableArray array];
    [categories addObject:[self generateCategoryDataModel:@"f_news_recommend" name:@"推荐"]];
    [categories addObject:[self generateCategoryDataModel:@"f_ugc_neighbor" name:@"圈子"]];
    [categories addObject:[self generateCategoryDataModel:@"f_house_qa" name:@"问答百科"]];
    [categories addObject:[self generateCategoryDataModel:@"f_house_concerns" name:@"楼市关注"]];
    [categories addObject:[self generateCategoryDataModel:@"f_house_transaction" name:@"购房交易"]];
    [categories addObject:[self generateCategoryDataModel:@"f_ugc_follow" name:@"关注"]];
    
    return categories;
}

- (FHUGCCategoryDataDataModel *)generateCategoryDataModel:(NSString *)category name:(NSString *)name {
    FHUGCCategoryDataDataModel *dataModel = [[FHUGCCategoryDataDataModel alloc] init];
    dataModel.category = category;
    dataModel.name = name;
    return dataModel;
}



@end
