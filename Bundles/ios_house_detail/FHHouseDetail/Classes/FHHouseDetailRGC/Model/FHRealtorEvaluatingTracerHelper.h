//
//  FHRealtorEvaluatingTracerHelper.h
//  FHHouseDetail
//
//  Created by liuyu on 2020/6/19.
//

#import <Foundation/Foundation.h>
#import "FHTracerModel.h"
#import "FHFeedUGCCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHRealtorEvaluatingTracerHelper : NSObject
@property(nonatomic, strong) FHTracerModel *tracerModel;
///feed_client_show
- (void)trackFeedClientShow:(FHFeedUGCCellModel *)itemData withExtraDic:(NSDictionary *)extraDic;
@end

NS_ASSUME_NONNULL_END
