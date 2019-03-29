//
//  FHPriceValuationHistoryViewModel.h
//  FHHouseTrend
//
//  Created by 谢思铭 on 2019/3/22.
//

#import <Foundation/Foundation.h>
#import "FHPriceValuationHistoryController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHPriceValuationHistoryViewModel : NSObject

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHPriceValuationHistoryController *)viewController;

- (void)requestData;

@end

NS_ASSUME_NONNULL_END
