//
//  FHHouseSearcher.m
//  Article
//
//  Created by 谷春晖 on 2018/10/26.
//

#import "FHHouseSearcher.h"
#import <TTNetworkManager/TTNetworkManager.h>
#import "Bubble-Swift.h"

@implementation FHHouseSearcher

+(TTHttpTask *_Nullable)houseSearchWithQuery:(NSString *_Nullable)query param:(NSDictionary * _Nonnull)queryParam offset:(NSInteger)offset needCommonParams:(BOOL)needCommonParams callback:(void(^_Nullable )(NSError *_Nullable error , FHSearchHouseDataModel *_Nullable model))callback
{
    NSString *host = [[[EnvContext networkConfig] host] stringByAppendingString:@"/f100/api/search?"];
    if (query.length > 0) {
        host = [host stringByAppendingString:query];
    }
    NSMutableDictionary *param = [NSMutableDictionary new];
    param[@"offset"] = @(offset);
    
    [param addEntriesFromDictionary:queryParam];
    
    return [[TTNetworkManager shareInstance] requestForBinaryWithResponse:host params:param method:@"GET" needCommonParams:needCommonParams callback:^(NSError *error, id obj, TTHttpResponse *response) {
        if (!callback) {
            return ;
        }
        if (!error) {
            if ([(NSData *)obj length] > 0 ) {
                NSError *jsonError = nil;
                FHSearchHouseModel *houseModel = [[FHSearchHouseModel alloc] initWithData:obj error:&jsonError];
                if (jsonError) {
                    error = jsonError;
                }else if (houseModel && [houseModel.message isEqualToString:@"success"]) {
                    callback(nil,houseModel.data);
                    return;
                }else{
                    error = [NSError errorWithDomain:houseModel.status?:@"请求失败" code:-10000 userInfo:nil];
                }
            }else{
               error = [NSError errorWithDomain:@"请求失败" code:-10000 userInfo:nil];
            }
        }
        callback(error ,nil);
    }];
}


+(TTHttpTask *_Nullable)mapSearch:(FHMapSearchType)houseType searchId:(NSString *_Nullable)searchId query:(NSString *_Nullable)query maxLocation:(CLLocationCoordinate2D)maxLocation minLocation:(CLLocationCoordinate2D)minLocation resizeLevel:(CGFloat)reizeLevel suggestionParams:(NSString *_Nullable)suggestionParams callback:(void(^_Nullable)(NSError *_Nullable error , FHMapSearchDataModel *_Nullable model))callback
{
    NSString *host = [EnvContext.networkConfig.host stringByAppendingString:@"/f100/api/map_search?"];
    NSMutableDictionary *param = [@{@"house_type":@(houseType),
                                    @"max_latitude":@(maxLocation.latitude),
                                    @"max_longitude":@(maxLocation.longitude),
                                    @"min_latitude":@(minLocation.latitude),
                                    @"min_longitude":@(minLocation.longitude),
                                    @"resize_level":@(reizeLevel)
                                    } mutableCopy];
    if (searchId) {
        param[@"search_id"] = searchId;
    }
    if (suggestionParams) {
        param[@"suggestion_params"] = suggestionParams;
    }
    if (query.length > 0) {
        host = [host stringByAppendingString:query];
    }
    
    return [[TTNetworkManager shareInstance]requestForBinaryWithURL:host params:param method:@"GET" needCommonParams:YES callback:^(NSError *error, id obj) {
        if (!callback) {
            return ;
        }
        if (!error && obj) {
            FHMapSearchModel *model = [[FHMapSearchModel alloc] initWithData:obj error:&error];
            if (!error && [model.message isEqualToString:@"success"]) {
                callback(nil,model.data);
                return ;
            }else if (!error){
                error = [NSError errorWithDomain:model.message code:-1000 userInfo:nil];
            }
            callback(error,nil);
        }
    }];
    
}


@end

NSString const * EXCLUDE_ID_KEY = @"exclude_id";
NSString const * NEIGHBORHOOD_ID_KEY = @"neighborhood_id";
NSString const *HOUSE_TYPE_KEY = @"house_type";
NSString const *SUGGESTION_PARAMS_KEY = @"suggestion_params";

