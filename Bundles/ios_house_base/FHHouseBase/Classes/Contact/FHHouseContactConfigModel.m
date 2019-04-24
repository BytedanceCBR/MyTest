//
//  FHHouseContactConfigModel.m
//  FHHouseDetail
//
//  Created by 张静 on 2019/4/22.
//

#import "FHHouseContactConfigModel.h"

@implementation FHHouseContactConfigModel

+(JSONKeyMapper *)keyMapper
{
    return [JSONKeyMapper mapperForSnakeCase];
}

+(BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

- (void)setTraceParams:(NSDictionary *)params
{
    _pageType = params[@"page_type"];
    _cardType = params[@"card_type"];
    _enterFrom = params[@"enter_from"];
    _elementFrom = params[@"element_from"];
    _rank = params[@"rank"];
    _originFrom = params[@"origin_from"];
    _originSearchId = params[@"origin_search_id"];
    _logPb = params[@"log_pb"];
    _searchId = params[@"search_id"];
    _imprId = params[@"impr_id"];

}
@end
