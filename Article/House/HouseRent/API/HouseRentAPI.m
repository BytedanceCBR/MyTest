//
//  HouseRentAPI.m
//  Article
//
//  Created by leo on 2018/11/22.
//

#import "HouseRentAPI.h"
#import <TTNetworkManager.h>
#import "FHHouseRentRelatedResponse.h"
#import "FHRentSameNeighborhoodResponse.h"
#define DEFULT_ERROR @"请求错误"
#define API_ERROR_CODE  1000
@implementation HouseRentAPI
+ (TTHttpTask*)requestHouseRentRelated:(NSString*)rentId
                            completion:(void(^)(FHHouseRentRelatedResponseModel* model , NSError *error))completion {
    NSString* url = @"https://i.haoduofangs.com/f100/api/related_rent";
    return [[TTNetworkManager shareInstance]
            requestForBinaryWithURL:url
            params:@{@"house_id": rentId}
            method:@"GET"
            needCommonParams:YES
            callback:^(NSError *error, id obj) {
                FHHouseRentRelatedResponseModel* model = nil;
                if (!error) {
                    model = [[FHHouseRentRelatedResponseModel alloc] initWithData:obj error:&error];
                }
                if (![model.status isEqualToString:@"0"]) {
                    error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
                }

                if (completion) {
                    completion(model,error);
                }
            }];
}

+ (TTHttpTask*)requestHouseRentSameNeighborhood:(NSString*)rentId
                             withNeighborhoodId:(NSString*)neighborhoodId
                                     completion:(void(^)(FHRentSameNeighborhoodResponseModel* model , NSError *error))completion {
    NSString* url = @"https://i.haoduofangs.com/f100/api/same_neighborhood_rent";
    return [[TTNetworkManager shareInstance]
            requestForBinaryWithURL:url
            params:@{@"house_id": rentId,
//                     @"neighborhood_id": neighborhoodId,
                     }
            method:@"GET"
            needCommonParams:YES
            callback:^(NSError *error, id obj) {
                FHRentSameNeighborhoodResponseModel* model = nil;
                if (!error) {
                    model = [[FHRentSameNeighborhoodResponseModel alloc] initWithData:obj error:&error];
                }
                if (![model.status isEqualToString:@"0"]) {
                    error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
                }

                if (completion) {
                    completion(model,error);
                }
            }];
}
@end
