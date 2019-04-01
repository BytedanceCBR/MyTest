//
//  FHMainApi+HouseFind.h
//  FHHouseFind
//
//  Created by 春晖 on 2019/2/13.
//

#import <FHHouseBase/FHMainApi.h>
#import "FHHFHistoryModel.h"
#import "FHFHClearHistoryModel.h"
#import "FHHouseFindRecommendModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMainApi (HouseFind)

+ (TTHttpTask *)requestHFHistoryByHouseType:(NSString *)houseType completion:(void(^_Nullable)(FHHFHistoryModel * model , NSError *error))completion;

+ (TTHttpTask *)clearHFHistoryByHouseType:(NSString *)houseType completion:(void(^_Nullable)(FHFHClearHistoryModel * model , NSError *error))completion;

+ (TTHttpTask *)requestHFHelpUsedByHouseType:(NSString *)houseType completion:(void(^_Nullable)(FHHouseFindRecommendModel * model , NSError *error))completion;

+ (TTHttpTask *)saveHFHelpFindByHouseType:(NSString *)houseType query:(NSString *)query phoneNum:(NSString *)phoneNum completion:(void(^_Nullable)(FHHouseFindRecommendModel * model , NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
