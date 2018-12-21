//
//  FHConfigAPI.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/20.
//

#import <Foundation/Foundation.h>
#import "FHConfigModel.h"
#import "FHSearchConfigModel.h"
#import <TTNetworkManager/TTNetworkManager.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHConfigAPI : NSObject

/*
 *  请求筛选器c配置
 *  @param: param 请求参数
 *  @param: completion 请求回调
 */
+(TTHttpTask *_Nullable)requestSearchConfig:(NSDictionary *)param completion:(void(^)(FHSearchConfigModel *_Nullable model , NSError *_Nullable error))completion;


/*
 *  请求通用城市配置
 *  @param: param 请求参数
 *  @param: completion 请求回调
 */
+ (TTHttpTask *_Nullable )requestGeneralConfig:(NSInteger )cityId gaodeLocation:(CLLocationCoordinate2D)location gaodeCityId:(NSString *)gCityId gaodeCityName:(NSString *)gCityName completion:(void(^)(FHConfigModel* _Nullable model , NSError *_Nullable  error))completion;

@end

NS_ASSUME_NONNULL_END
