//
//  FHHouseSearcher.h
//  Article
//
//  Created by 谷春晖 on 2018/10/26.
//

#import <Foundation/Foundation.h>
#import "FHSearchHouseModel.h"
#import <TTNetworkManager/TTHttpTask.h>
#import "FHMapSearchTypes.h"
#import "FHMapSearchModel.h"
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString const * EXCLUDE_ID_KEY ;
extern NSString const * NEIGHBORHOOD_ID_KEY;
extern NSString const *HOUSE_TYPE_KEY ;
extern NSString const *SUGGESTION_PARAMS_KEY;

@interface FHHouseSearcher : NSObject

/**
 * 请求房子信息  /f100/api/search
 * query need:
 *   exclude_id[]
 *   exclude_id[]
 *   neighborhood_id[]
 *   neighborhood_id[]
 * param need:
 *   house_type
 */
+(TTHttpTask *_Nullable)houseSearchWithQuery:(NSString *_Nullable)query param:(NSDictionary * _Nonnull)queryParam offset:(NSInteger)offset needCommonParams:(BOOL)needCommonParams callback:(void(^_Nullable )(NSError *_Nullable error , FHSearchHouseDataModel *_Nullable model))callback;

/**
 * 地图找房 api
 
 */
+(TTHttpTask *_Nullable)mapSearch:(FHMapSearchType)houseType searchId:(NSString *_Nullable)searchId query:(NSString *_Nullable)query maxLocation:(CLLocationCoordinate2D)maxLocation minLocation:(CLLocationCoordinate2D)minLocation resizeLevel:(CGFloat)reizeLevel suggestionParams:(NSString *_Nullable)suggestionParams callback:(void(^_Nullable)(NSError *_Nullable error , FHMapSearchDataModel *_Nullable model))callback;

@end

NS_ASSUME_NONNULL_END