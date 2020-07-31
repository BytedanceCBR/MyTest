//
//  FHRealtorEvaluatingTracerHelper.m
//  FHHouseDetail
//
//  Created by liuyu on 2020/6/19.
//

#import "FHRealtorEvaluatingTracerHelper.h"
#import "FHUserTracker.h"
#import "FHUtils.h"

@implementation FHRealtorEvaluatingTracerHelper
- (void)trackFeedClientShow:(FHFeedUGCCellModel *)itemData withExtraDic:(NSDictionary *)extraDic{
    NSMutableDictionary *dict = [itemData.tracerDic mutableCopy];
    dict[@"realtor_id"] = itemData.realtor.realtorId?:@"be_null";
    TRACK_EVENT(@"feed_client_show", dict);
}

@end
