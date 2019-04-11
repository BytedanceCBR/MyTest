//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
#import "FHPriceValuationHistoryModel.h"
NS_ASSUME_NONNULL_BEGIN
@interface FHPriceValuationEvaluateDataModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *estimateId;
@property (nonatomic, copy , nullable) NSString *estimatePrice;
@property (nonatomic, copy , nullable) NSString *estimatePricingPersqm;
@property (nonatomic, copy , nullable) NSString *estimatePriceRateStr;
@property (nonatomic, copy , nullable) NSString *estimatePricingPersqmStr;
@property (nonatomic, strong , nullable) FHPriceValuationHistoryDataHistoryHouseListHouseInfoHouseInfoDictModel *houseInfoDict ;
@end

@interface FHPriceValuationEvaluateModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHPriceValuationEvaluateDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
