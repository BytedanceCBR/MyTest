//
//  FHBaseMainListViewModel+Rent.h
//  FHHouseList
//
//  Created by 春晖 on 2019/3/12.
//

#import "FHBaseMainListViewModel.h"

NS_ASSUME_NONNULL_BEGIN
@class FHHouseRentModel;
@interface FHBaseMainListViewModel (Rent)

-(void)requestRentData:(BOOL)isHead query:(NSString *_Nullable)query completion:(void(^)(FHHouseRentModel *_Nullable model , NSError *_Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
