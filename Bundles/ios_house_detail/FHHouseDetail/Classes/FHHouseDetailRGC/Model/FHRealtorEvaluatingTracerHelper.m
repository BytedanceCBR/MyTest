//
//  FHRealtorEvaluatingTracerHelper.m
//  FHHouseDetail
//
//  Created by liuyu on 2020/6/19.
//

#import "FHRealtorEvaluatingTracerHelper.h"
#import "FHUserTracker.h"
@implementation FHRealtorEvaluatingTracerHelper
- (void)trackFeedClientShow:(FHFeedUGCCellModel *)itemData withExtraDic:(NSDictionary *)extraDic{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"origin_from"] = self.tracerModel.originFrom?: @"be_null";
    dict[@"enter_from"] = self.tracerModel.enterFrom?: @"be_null";
    dict[@"page_type"] = [extraDic.allKeys containsObject:@"page_type"]?extraDic[@"page_type"]:@"be_null";
    dict[@"event_type"] = [self eventType];
//    dict[@"group_id"] = itemData.groupId?:@"be_null";
    dict[@"group_id"] = [extraDic.allKeys containsObject:@"group_id"]?extraDic[@"group_id"]:@"be_null";
    dict[@"group_source"] = itemData.logPb[@"group_source"]?:@"be_null";
    dict[@"realtor_id"] = itemData.realtor.realtorId?:@"be_null";
    dict[@"realtor_id"] = itemData.realtor.realtorId?:@"be_null";
    dict[@"element_type"] = @"realtor_evaluate";
    dict[@"rank"] = [extraDic.allKeys containsObject:@"rank"]?extraDic[@"rank"]:@"be_null";
    dict[@"from_gid"] = [extraDic.allKeys containsObject:@"from_gid"]?extraDic[@"from_gid"]:@"be_null";
    dict[@"log_pb"] = self.tracerModel.logPb?: [extraDic.allKeys containsObject:@"log_pb"]?extraDic[@"log_pb"]:@"be_null";
    TRACK_EVENT(@"feed_client_show", dict);
}

- (NSString *)eventType {
    return @"house_app2c_v2";
}
@end
