//
//  StockData.h
//  
//
//  Created by 王双华 on 16/5/5.
//
//

#import <Foundation/Foundation.h>
#import "ExploreOriginalData.h"

NS_ASSUME_NONNULL_BEGIN

@interface StockData : ExploreOriginalData

@property (nullable, nonatomic, retain) NSString *changeAmount;
@property (nullable, nonatomic, retain) NSString *changeScale;
@property (nullable, nonatomic, retain) NSNumber *lastUpdateTime;
@property (nullable, nonatomic, retain) NSNumber *refreshInterval;
@property (nullable, nonatomic, retain) NSString *refreshUrl;
@property (nullable, nonatomic, retain) NSString *schemaUrl;
@property (nullable, nonatomic, retain) NSString *stockID;
@property (nullable, nonatomic, retain) NSString *stockName;
@property (nullable, nonatomic, retain) NSString *stockPrice;
@property (nullable, nonatomic, retain) NSNumber *stockStatus;
@property (nullable, nonatomic, retain) NSString *tradingStatus;

//时间过了，永久停止刷新数据
@property (nonatomic, assign) BOOL shouldStopUpdate;
//标记是否第一次从feed推出数据
@property (nonatomic, assign) BOOL shouldReloadCell;

- (void)updateWithDataContentObj:(NSDictionary *)content;

@end

NS_ASSUME_NONNULL_END

