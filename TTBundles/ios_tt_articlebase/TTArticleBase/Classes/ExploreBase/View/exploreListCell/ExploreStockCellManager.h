//
//  ExploreStockCellManager.h
//  Article
//
//  Created by 王双华 on 16/4/22.
//
//

#import <Foundation/Foundation.h>
#import "StockData.h"

@interface ExploreStockCellManager : NSObject

+ (instancetype)sharedManager;

- (void)startGetDataFromStockData:(StockData *)stockData completion:(void(^)(StockData *stockData, NSDictionary *data, NSError *error))completion;

@end
