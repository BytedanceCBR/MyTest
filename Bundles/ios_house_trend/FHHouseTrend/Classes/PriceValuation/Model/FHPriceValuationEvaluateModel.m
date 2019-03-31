//GENERATED CODE , DON'T EDIT
#import "FHPriceValuationEvaluateModel.h"
@implementation FHPriceValuationEvaluateModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

@implementation FHPriceValuationEvaluateDataModel
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"estimateId": @"estimate_id",
    @"estimatePrice": @"estimate_price",
    @"estimatePricingPersqm": @"estimate_pricing_persqm",
    @"estimatePriceRateStr": @"estimate_price_rate_str",
    @"estimatePricingPersqmStr": @"estimate_pricing_persqm_str",
    @"houseInfoDict": @"house_info_dict",
  };
  return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
     return dict[keyName]?:keyName;
  }];
}
+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}
@end

