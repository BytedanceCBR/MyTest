//
//  FHConfigAPI.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/20.
//

#import "FHConfigAPI.h"
#import "FHURLSettings.h"
#import "FHMainApi.h"

#define GET @"GET"
#define POST @"POST"
#define DEFULT_ERROR @"请求错误"
#define API_ERROR_CODE  10000
#define API_NO_DATA     10001
#define API_WRONG_DATA  10002

@implementation FHConfigAPI

+ (TTHttpTask *_Nullable )requestGeneralConfig:(NSInteger )cityId gaodeLocation:(CLLocationCoordinate2D)location gaodeCityId:(NSString *)gCityId gaodeCityName:(NSString *)gCityName completion:(void(^)(FHConfigModel* _Nullable model , NSError *_Nullable  error))completion
{
   return  [FHMainApi getConfig:cityId gaodeLocation:location gaodeCityId:gCityId gaodeCityName:gCityName completion:^(FHConfigModel * _Nullable model, NSError * _Nullable error) {
       completion(model,error);
    }];
}

@end
