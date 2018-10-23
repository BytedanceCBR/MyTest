//
//  TTVCommodityEntity.m
//  Article
//
//  Created by panxiang on 2017/8/8.
//
//

#import "TTVCommodityEntity.h"

@implementation TTVCommodityEntity
- (NSString *)charge_url
{
   return [_charge_url stringByRemovingPercentEncoding];
}

+ (TTVCommodityEntity *)entityWithDictionary:(NSDictionary *)dic
{
    TTVCommodityEntity *entity = [[TTVCommodityEntity alloc] init];
    entity.image_url = [dic stringValueForKey:@"image_url" defaultValue:nil];
    entity.source = [dic stringValueForKey:@"source" defaultValue:nil];
    entity.source_type = [dic integerValueForKey:@"source_type" defaultValue:0];
    entity.charge_url = [dic stringValueForKey:@"charge_url" defaultValue:nil];
    entity.commodity_id = [dic stringValueForKey:@"commodity_id" defaultValue:nil];
    entity.title = [dic stringValueForKey:@"title" defaultValue:nil];
    entity.insert_time = [dic floatValueForKey:@"insert_time" defaultValue:0];
    entity.price = [dic integerValueForKey:@"price" defaultValue:0];
    entity.display_duration = [dic floatValueForKey:@"display_duration" defaultValue:0];
    entity.coupon_type = [dic integerValueForKey:@"coupon_type" defaultValue:0];
    entity.coupon_num = [dic floatValueForKey:@"coupon_after_price" defaultValue:0];
    return entity;
}
@end
