//
//  FHHouseSearcher.m
//  Article
//
//  Created by 谷春晖 on 2018/10/26.
//

#import "FHHouseSearcher.h"
#import <TTNetworkManager/TTNetworkManager.h>
#import <FHHouseBase/FHURLSettings.h>
#import <FHHouseBase/FHCommonDefines.h>
#import "FHMainApi.h"

@implementation FHHouseSearcher

+(TTHttpTask *_Nullable)houseSearchWithQuery:(NSString *_Nullable)query param:(NSDictionary * _Nonnull)queryParam offset:(NSInteger)offset class:(Class)cls  needCommonParams:(BOOL)needCommonParams callback:(void(^_Nullable )(NSError *_Nullable error , id<FHBaseModelProtocol> _Nullable model ))callback
{
    NSString *path = @"/f100/api/search";
    if (query.length > 0) {
        query = [query stringByAppendingFormat:@"&offset=%ld",offset];
    }else{
        query = [NSString stringWithFormat:@"&offset=%ld",offset];
    }    
 
    if (![query containsString:@"search_id"] && queryParam[@"search_id"]) {
        query = [query stringByAppendingFormat:@"&search_id=%@",queryParam[@"search_id"]];
    }
    
    return [FHMainApi postRequest:path uploadLog:YES query:query params:queryParam jsonClass:cls completion:^(JSONModel * _Nullable model, NSError * _Nullable error) {
        callback(error ,model);
    }];
}


+(TTHttpTask *_Nullable)mapSearch:(FHMapSearchType)houseType searchId:(NSString *_Nullable)searchId query:(NSString *_Nullable)query maxLocation:(CLLocationCoordinate2D)maxLocation minLocation:(CLLocationCoordinate2D)minLocation resizeLevel:(CGFloat)reizeLevel targetType:(NSString *_Nullable)targetType  suggestionParams:(NSString *_Nullable)suggestionParams extraParams:(NSDictionary *_Nullable)extraParams callback:(void(^_Nullable)(NSError *_Nullable error , FHMapSearchDataModel *_Nullable model))callback
{
    NSString *host = [[FHURLSettings baseURL] stringByAppendingString:@"/f100/api/map_search?"];
    NSMutableDictionary *param = [NSMutableDictionary new];
    
    if (![query containsString:@"house_type"]) {
        param[@"house_type"] = @(houseType);
    }
    if (![query containsString:@"max_latitude"]) {
        param[@"max_latitude"] = @(maxLocation.latitude);
    }
    if (![query containsString:@"max_longitude"]) {
        param[@"max_longitude"] = @(maxLocation.longitude);
    }
    if (![query containsString:@"min_latitude"]) {
        param[@"min_latitude"] = @(minLocation.latitude);
    }
    if (![query containsString:@"min_longitude"]) {
        param[@"min_longitude"] = @(minLocation.longitude);
    }
        
    if (searchId) {
        param[@"search_id"] = searchId;
    }
    if (suggestionParams) {
        param[@"suggestion_params"] = suggestionParams;
    }
    if (query.length > 0) {
        host = [host stringByAppendingString:query];
    }
    
    if (![query containsString:@"resize_level"]) {
        param[@"resize_level"] = @(reizeLevel);
    }
    
    if (!IS_EMPTY_STRING(targetType)) {
        param[@"target_type"] = targetType;
    }
    if (extraParams) {
        [param addEntriesFromDictionary:extraParams];
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
