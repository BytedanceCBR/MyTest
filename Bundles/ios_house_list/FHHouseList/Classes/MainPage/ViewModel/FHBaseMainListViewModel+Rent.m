//
//  FHBaseMainListViewModel+Rent.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/12.
//

#import "FHBaseMainListViewModel+Rent.h"
#import "FHBaseMainListViewModel+Internal.h"
#import <FHHouseBase/FHMainApi.h>


@implementation FHBaseMainListViewModel (Rent)

-(void)requestRentData:(BOOL)isHead query:(NSString *_Nullable)query completion:(void(_Nonnull^)(FHHouseRentModel *_Nullable model , NSError *_Nullable error))completion
{
    NSInteger offset = 0;
    if (!isHead) {
        offset = self.houseList.count;
    }
    
    self.requestTask =  [FHMainApi searchRent:query params:nil offset:offset searchId:self.searchId sugParam:nil completion:^(FHHouseRentModel * _Nonnull model, NSError * _Nonnull error) {
        if (completion) {
            completion(model,error);
        }
    }];
}

@end
