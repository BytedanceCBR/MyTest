//
//  FHBaseMainListViewModel+Rent.h
//  FHHouseList
//
//  Created by 春晖 on 2019/3/12.
//

#import "FHBaseMainListViewModel.h"
#import "FHHouseRentFilterType.h"
#import "FHCommuteConfigDelegate.h"

NS_ASSUME_NONNULL_BEGIN
@class FHHouseRentModel,FHListSearchHouseModel;
@class TTHttpTask;
@interface FHBaseMainListViewModel (Rent)<FHCommuteConfigDelegate>

-(TTHttpTask *)requestRentData:(BOOL)isHead query:(NSString *_Nullable)query completion:(void(^_Nullable)(FHListSearchHouseModel *_Nullable model , NSError *_Nullable error))completion;

-(NSString *)originFromWithFilterType:(FHHouseRentFilterType)filterType;

-(FHHouseRentFilterType)rentFilterType:(NSString *)openUrl;

-(void)showCommuteConfigPage;

-(void)tryAddCommuteShowLog;

@end

NS_ASSUME_NONNULL_END
