//
//  FHHomeConfigManager.m
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import "FHHomeConfigManager.h"
#import <TTRoute.h>
#import <TTArticleCategoryManager.h>
#import "FHEnvContext.h"
#import <TTNetworkManager.h>

#define kFHHomeHouseMixedCategoryID   @"f_house_news" // 推荐频道

@interface FHHomeConfigManager()

@property(nonatomic , strong) id fhHomeBridge;

@end

@implementation FHHomeConfigManager

+(instancetype)sharedInstance
{
    static FHHomeConfigManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FHHomeConfigManager alloc] init];
        [FHEnvContext sharedInstance].homeConfigCallBack = ^(FHConfigDataModel * _Nonnull configModel) {
            [manager acceptConfigDataModel:configModel];
        };
    });
    return manager;
}

//to do 去掉找房频道之后，单独请求
- (void)currentNeedRequestConfig:(NSString *)cityId cityGeoCode:(NSString *)cityCode lat:(double)latValue lon:(double)lonValue cityName:(NSString *)cityName
{
    NSInteger cityIdNumber = 0;
    if (cityId&&[cityId isKindOfClass:[NSString class]]) {
        cityIdNumber = [cityId integerValue];
    }
    [FHMainApi getConfig:cityIdNumber gaodeLocation:CLLocationCoordinate2DMake(latValue, lonValue) gaodeCityId:cityCode gaodeCityName:cityName completion:^(FHConfigModel * _Nullable model, NSError * _Nullable error) {
        self.currentDataModel = model.data;
        self.currentDictionary = model.data.toDictionary;
//        [self.configDataReplay sendNext:model.data];
    }];
}

- (void)acceptConfigDictionary:(NSDictionary *)configDict
{
    if (configDict && [configDict isKindOfClass:[NSDictionary class]]) {
        if (![configDict isEqualToDictionary:self.currentDictionary]) {
            FHConfigDataModel *dataModel = [[FHConfigDataModel alloc] initWithDictionary:configDict error:nil];
            self.currentDataModel = dataModel;
            self.currentDictionary = configDict;
//            [self.configDataReplay sendNext:dataModel];
//            [self.searchConfigDataReplay sendNext:[[FHEnvContext sharedInstance] getSearchConfigFromCache]];
        }
    }
}

- (void)acceptConfigDataModel:(FHConfigDataModel *)configModel
{
    if (configModel && [configModel isKindOfClass:[FHConfigDataModel class]]) {
        if (![configModel.toDictionary isEqualToDictionary:self.currentDictionary]) {
            self.currentDataModel = configModel;
            self.currentDictionary = configModel.toDictionary;
//            [self.configDataReplay sendNext:configModel];
//            [self.searchConfigDataReplay sendNext:[[FHEnvContext sharedInstance] getSearchConfigFromCache]];
        }
    }
}

- (void)openCategoryFeedStart
{

    NSString * categoryStartName = nil;

    if ([[[FHHomeConfigManager sharedInstance] fhHomeBridgeInstance] respondsToSelector:@selector(feedStartCategoryName)]) {
        categoryStartName = [[self fhHomeBridgeInstance] feedStartCategoryName];
    }
    if ([categoryStartName isEqualToString:@"f_find_house"] && [[[TTArticleCategoryManager sharedManager] allCategories] containsObject:[TTArticleCategoryManager categoryModelByCategoryID:@"f_find_house"]]) {
        if ([[[FHHomeConfigManager sharedInstance] fhHomeBridgeInstance] respondsToSelector:@selector(currentSelectCategoryName)]) {
            self.isNeedTriggerPullDownUpdateFowFindHouse = YES;
        }
    }else
    {
        if ([categoryStartName isEqualToString:[TTArticleCategoryManager currentSelectedCategoryID]]) {
            self.isNeedTriggerPullDownUpdate = NO;
        }else
        {
            self.isNeedTriggerPullDownUpdate = YES;
        }
    }
    
    if (categoryStartName == nil) {
        BOOL isHasFindHouseCategory = [[[TTArticleCategoryManager sharedManager] allCategories] containsObject:[TTArticleCategoryManager categoryModelByCategoryID:kNIHFindHouseCategoryID]];
        if (isHasFindHouseCategory) {
            categoryStartName = kNIHFindHouseCategoryID;
        }else
        {
            categoryStartName = kNIHFeedHouseMixedCategoryID;
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *openUrl = [NSString stringWithFormat:@"snssdk1370://category_feed?category=%@",categoryStartName];
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:openUrl] userInfo:nil];
        });
    });
}

- (void)updateConfigDataFromCache
{
    
}

- (id<FHHomeBridgeProtocol>)fhHomeBridgeInstance
{
    if (!_fhHomeBridge) {
        Class classBridge = NSClassFromString(@"FHHomeBridgeImp");
        if (classBridge) {
            _fhHomeBridge = [[classBridge alloc] init];
        }
    }
    return _fhHomeBridge;
}



@end
