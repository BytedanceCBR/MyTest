//
//  FHShortVideoTracerUtil.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/9/25.
//

#import "FHShortVideoTracerUtil.h"
#import "FHUserTracker.h"
@implementation FHShortVideoTracerUtil
+ (void)feedClientShowWithmodel:(FHFeedUGCCellModel *)model eventIndex:(NSInteger)index {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    NSDictionary *logPb = [model.logPb copy];
    [dic setObject:model.groupId?:@"" forKey:@"group_id"];
    [dic setObject:[FHShortVideoTracerUtil pageType] forKey:@"page_type"];
    [dic setObject:[FHShortVideoTracerUtil categoryName] forKey:@"category_name"];
    [dic setObject:index?@(index):@(0) forKey:@"rank"];
    [dic setObject:logPb[@"group_source"]?:@"" forKey:@"group_source"];
    [dic setObject:logPb?:@"" forKey:@"log_pb"];
    [dic setObject:model.tracerDic[@"origin_from"]?:@"be_null" forKey:@"origin_from"];
    [FHUserTracker writeEvent:@"feed_client_show" params:dic];
}

+ (NSString *)categoryName {
    return @"f_house_smallvideo_flow";
}

+ (NSString *)pageType {
    return @"f_house_smallvideo_flow";
}
@end
