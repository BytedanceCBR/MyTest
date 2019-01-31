//
//  FHHouseDetailAPI.h
//  FHHouseDetailAPI
//
//  Created by 张元科 on 2019/1/30.
//

#import <Foundation/Foundation.h>
#import <TTNetworkManager.h>
#import "FHURLSettings.h"
#import "FHHouseType.h"
#import "FHMainApi.h"

@class TTHttpTask,FHDetailNewModel,FHDetailNeighborhoodModel,FHDetailOldModel;

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseDetailAPI : NSObject

+(TTHttpTask*)requestNewDetail:(NSString*)houseId
                     completion:(void(^)(FHDetailNewModel * _Nullable model , NSError * _Nullable error))completion;

+(TTHttpTask*)requestOldDetail:(NSString*)houseId
                    completion:(void(^)(FHDetailOldModel * _Nullable model , NSError * _Nullable error))completion;

+(TTHttpTask*)requestNeighborhoodDetail:(NSString*)houseId
                    completion:(void(^)(FHDetailNeighborhoodModel * _Nullable model , NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
