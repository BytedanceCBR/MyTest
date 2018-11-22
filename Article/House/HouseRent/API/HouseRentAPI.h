//
//  HouseRentAPI.h
//  Article
//
//  Created by leo on 2018/11/22.
//

#import <Foundation/Foundation.h>
@class FHHouseRentRelatedResponseModel;
@class FHRentSameNeighborhoodResponseModel;
NS_ASSUME_NONNULL_BEGIN
@class TTHttpTask;
@interface HouseRentAPI : NSObject


+ (TTHttpTask*)requestHouseRentRelated:(NSString*)rentId
                            completion:(void(^)(FHHouseRentRelatedResponseModel* model , NSError *error))completion;

+ (TTHttpTask*)requestHouseRentSameNeighborhood:(NSString*)rentId
                             withNeighborhoodId:(NSString*)neighborhoodId
                                     completion:(void(^)(FHRentSameNeighborhoodResponseModel* model , NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
