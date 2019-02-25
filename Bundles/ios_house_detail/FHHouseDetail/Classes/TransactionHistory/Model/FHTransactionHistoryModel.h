//已编辑过
#import <JSONModel.h>
#import "FHDetailNeighborhoodModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol FHTransactionHistoryDataListModel<NSObject>
@end

@interface FHTransactionHistoryModel : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHDetailNeighborhoodDataTotalSalesModel *data ;
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
