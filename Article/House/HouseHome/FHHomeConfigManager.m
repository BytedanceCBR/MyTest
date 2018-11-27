//
//  FHHomeConfigManager.m
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import "FHHomeConfigManager.h"
#import <TTRoute.h>
#import <TTArticleCategoryManager.h>

@interface FHHomeConfigManager()

@property (nonatomic,assign)BOOL isNeedTriggerPullDownUpdate;

@end

@implementation FHHomeConfigManager

+(instancetype)sharedInstance
{
    static FHHomeConfigManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FHHomeConfigManager alloc] init];
        manager.configDataReplay = [RACReplaySubject subject];
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
        
    }];
}

- (void)acceptConfigDictionary:(NSDictionary *)configDict
{
    if (configDict && [configDict isKindOfClass:[NSDictionary class]]) {
        if (![configDict isEqualToDictionary:self.currentDictionary]) {
            FHConfigDataModel *dataModel = [[FHConfigDataModel alloc] initWithDictionary:configDict error:nil];
            self.currentDataModel = dataModel;
            self.currentDictionary = configDict;
            [self.configDataReplay sendNext:dataModel];
        }
    }
}

- (void)openCategoryFeedStart
{
    NSString * categoryStartName = [SSCommonLogic feedStartCategory];
    
    if ([categoryStartName isEqualToString:[TTArticleCategoryManager currentSelectedCategoryID]]) {
        self.isNeedTriggerPullDownUpdate = NO;
    }else
    {
        self.isNeedTriggerPullDownUpdate = YES;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *openUrl = [NSString stringWithFormat:@"snssdk1370://category_feed?category=%@",categoryStartName];
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:openUrl] userInfo:nil];                });
    });
}

- (void)updateConfigDataFromCache
{
    
    
    
}

@end
