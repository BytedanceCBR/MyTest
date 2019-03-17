//
//  FHBaseMainListViewModel+Rent.m
//  FHHouseList
//
//  Created by 春晖 on 2019/3/12.
//

#import "FHBaseMainListViewModel+Rent.h"
#import "FHBaseMainListViewModel+Internal.h"
#import <FHHouseBase/FHMainApi.h>
#import <FHHouseBase/FHHouseRentModel.h>

@implementation FHBaseMainListViewModel (Rent)

-(TTHttpTask *)requestRentData:(BOOL)isHead query:(NSString *_Nullable)query completion:(void(^_Nullable)(FHHouseRentModel *_Nullable model , NSError *_Nullable error))completion
{
    NSInteger offset = 0;
    if (!isHead) {
        offset = self.houseList.count;
    }
    
    return   [FHMainApi searchRent:query params:nil offset:offset searchId:self.searchId sugParam:nil completion:^(FHHouseRentModel * _Nonnull model, NSError * _Nonnull error) {
        if (completion) {
            completion(model,error);
        }
    }];
}

-(NSString *)originFromWithFilterType:(FHHouseRentFilterType)filterType
{
    switch (filterType) {
            case FHHouseRentFilterTypeWhole:
            return  @"renting_fully";
            case FHHouseRentFilterTypeApart:
            return  @"renting_apartment";
            case FHHouseRentFilterTypeShare:
            return  @"renting_joint";
            case FHHouseRentFilterTypeMap:
            return @"renting_mapfind";
        default:
            return nil;
    }
    return nil;
}

-(FHHouseRentFilterType)rentFilterType:(NSString *)openUrl
{
    NSURL *url = [NSURL URLWithString:openUrl];
    if (!url) {
        return FHHouseRentFilterTypeNone;
    }
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:YES];
    if ([components.host isEqualToString:@"mapfind_rent"]) {
        return FHHouseRentFilterTypeMap;
    }
    
    if ([components.host isEqualToString:@"house_list"]) {
        for (NSURLQueryItem *queryItem in components.queryItems) {
            if ([queryItem.name isEqualToString:@"rental_type[]"]) {
                if ([queryItem.value isEqualToString:@"1"]) {
                    //整租
                    return FHHouseRentFilterTypeWhole;
                }else if ([queryItem.value isEqualToString:@"2"]){
                    //合租
                    return FHHouseRentFilterTypeShare;
                }
            }else if ([queryItem.name isEqualToString:@"rental_contract_type[]"]){
                if ([queryItem.value isEqualToString:@"2"]) {
                    //公寓
                    return FHHouseRentFilterTypeApart;
                }
                
            }
        }
    }
    return FHHouseRentFilterTypeNone;
}

@end
