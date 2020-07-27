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
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"origin_from"] = self.tracerModel.originFrom?: @"be_null";
    dict[@"enter_from"] = self.tracerModel.enterFrom?: @"be_null";
    dict[@"page_type"] = [extraDic.allKeys containsObject:@"page_type"]?extraDic[@"page_type"]:@"be_null";
    dict[@"group_id"] = itemData.groupId;
    dict[@"realtor_id"] = itemData.realtor.realtorId?:@"be_null";
    dict[@"element_type"] = @"realtor_evaluate";
    dict[@"rank"] = [extraDic.allKeys containsObject:@"rank"]?extraDic[@"rank"]:@"be_null";
    dict[@"from_gid"] = [extraDic.allKeys containsObject:@"from_gid"]?extraDic[@"from_gid"]:@"be_null";
    dict[@"log_pb"] = itemData.logPb;
    
    id logPb = dict[@"log_pb"];
    NSDictionary *logPbDic = nil;
    if([logPb isKindOfClass:[NSDictionary class]]){
        logPbDic = logPb;
    }else if([logPb isKindOfClass:[NSString class]]){
        logPbDic = [FHUtils dictionaryWithJsonString:logPb];
    }
    
    if(logPbDic[@"impr_id"]){
        dict[@"impr_id"] = logPbDic[@"impr_id"];
    }
    
    if(logPbDic[@"group_source"]){
        dict[@"group_source"] = logPbDic[@"group_source"];
    }
    
    TRACK_EVENT(@"feed_client_show", dict);
}

@end
