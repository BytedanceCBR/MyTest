//
//  FHShortVideoTracerUtil.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/9/25.
//

#import "FHShortVideoTracerUtil.h"
#import "FHUserTracker.h"
@interface FHShortVideoTracerUtil ()

@property (nonatomic, copy, nullable) NSDate *stayPageStartTime;

@end
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
    [dic setObject:@"110841" forKey:@"event_tracking_id"];
    [dic setObject:model.tracerDic[@"origin_from"]?:@"be_null" forKey:@"origin_from"];
    [dic setObject:model.tracerDic[@"enter_from"]?:@"be_null" forKey:@"enter_from"];
    [FHUserTracker writeEvent:@"feed_client_show" params:dic];
}

+ (void)videoPlayOrPauseWithName:(NSString *)event eventModel:(FHFeedUGCCellModel *)model eventIndex:(NSInteger)index {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        NSDictionary *logPb = [model.logPb copy];
        [dic setObject:model.groupId?:@"" forKey:@"group_id"];
        [dic setObject:[FHShortVideoTracerUtil pageType] forKey:@"page_type"];
        [dic setObject:[FHShortVideoTracerUtil categoryName] forKey:@"category_name"];
        [dic setObject:index?@(index):@(0) forKey:@"rank"];
        [dic setObject:logPb[@"group_source"]?:@"" forKey:@"group_source"];
        [dic setObject:logPb?:@"" forKey:@"log_pb"];
        [dic setObject:model.tracerDic[@"origin_from"]?:@"be_null" forKey:@"origin_from"];
        [dic setObject:model.tracerDic[@"enter_from"]?:@"be_null" forKey:@"enter_from"];
    if ([event isEqualToString:@"video_play"]) {
        [dic setObject:@"110842" forKey:@"event_tracking_id"];
    }else {
         [dic setObject:@"110844" forKey:@"event_tracking_id"];
    }
        [FHUserTracker writeEvent:event params:dic];
}

+ (void)videoOverWithModel:(FHFeedUGCCellModel *)model eventIndex:(NSInteger)index forStayTime:(NSString *)stayTime {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    NSDictionary *logPb = [model.logPb copy];
    [dic setObject:model.groupId?:@"" forKey:@"group_id"];
    [dic setObject:[FHShortVideoTracerUtil pageType] forKey:@"page_type"];
    [dic setObject:@"110843" forKey:@"event_tracking_id"];
    [dic setObject:[FHShortVideoTracerUtil categoryName] forKey:@"category_name"];
    [dic setObject:index?@(index):@(0) forKey:@"rank"];
    [dic setObject:logPb[@"group_source"]?:@"" forKey:@"group_source"];
    [dic setObject:stayTime forKey:@"stay_time"];
    [dic setObject:logPb?:@"" forKey:@"log_pb"];
    [dic setObject:model.tracerDic[@"origin_from"]?:@"be_null" forKey:@"origin_from"];
    [dic setObject:model.tracerDic[@"enter_from"]?:@"be_null" forKey:@"enter_from"];
    [FHUserTracker writeEvent:@"video_over" params:dic];
}

+ (void)goDetailWithModel:(FHFeedUGCCellModel *)model eventIndex:(NSInteger)index {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    NSDictionary *logPb = [model.logPb copy];
    [dic setObject:model.groupId?:@"" forKey:@"group_id"];
    [dic setObject:[FHShortVideoTracerUtil pageType] forKey:@"page_type"];
    [dic setObject:[FHShortVideoTracerUtil categoryName] forKey:@"category_name"];
    [dic setObject:index?@(index):@(0) forKey:@"rank"];
    [dic setObject:logPb[@"group_source"]?:@"" forKey:@"group_source"];
    [dic setObject:logPb?:@"" forKey:@"log_pb"];
    [dic setObject:@"110845" forKey:@"event_tracking_id"];
    [dic setObject:logPb[@"impr_id"]?:@"be_null" forKey:@"impr_id"];
    [dic setObject:model.tracerDic[@"origin_from"]?:@"be_null" forKey:@"origin_from"];
    [dic setObject:model.tracerDic[@"enter_from"]?:@"be_null" forKey:@"enter_from"];
    [FHUserTracker writeEvent:@"go_detail" params:dic];
}

+ (void)stayPageWithModel:(FHFeedUGCCellModel *)model eventIndex:(NSInteger)index forStayTime:(NSString *)stayTime {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    NSDictionary *logPb = [model.logPb copy];
    [dic setObject:model.groupId?:@"" forKey:@"group_id"];
    [dic setObject:[FHShortVideoTracerUtil pageType] forKey:@"page_type"];
    [dic setObject:[FHShortVideoTracerUtil categoryName] forKey:@"category_name"];
    [dic setObject:index?@(index):@(0) forKey:@"rank"];
    [dic setObject:logPb[@"group_source"]?:@"" forKey:@"group_source"];
    [dic setObject:logPb?:@"" forKey:@"log_pb"];
    [dic setObject:@"110846" forKey:@"event_tracking_id"];
    [dic setObject:logPb[@"impr_id"]?:@"be_null" forKey:@"impr_id"];
    [dic setObject:model.tracerDic[@"origin_from"]?:@"be_null" forKey:@"origin_from"];
    [dic setObject:model.tracerDic[@"enter_from"]?:@"be_null" forKey:@"enter_from"];
    [dic setObject:stayTime forKey:@"stay_time"];
    [FHUserTracker writeEvent:@"stay_page" params:dic];
}

+ (void)clickLikeOrdisLikeWithWithName:(NSString *)event eventPosition:(NSString *)position eventModel:(FHFeedUGCCellModel *)model eventIndex:(NSInteger)index commentId:(NSString *)commentId {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    NSDictionary *logPb = [model.logPb copy];
    [dic setObject:model.groupId?:@"" forKey:@"group_id"];
    [dic setObject:[FHShortVideoTracerUtil pageType] forKey:@"page_type"];
    [dic setObject:[FHShortVideoTracerUtil categoryName] forKey:@"category_name"];
    [dic setObject:index?@(index):@(0) forKey:@"rank"];
    [dic setObject:logPb[@"group_source"]?:@"" forKey:@"group_source"];
    [dic setObject:logPb?:@"" forKey:@"log_pb"];
    [dic setObject:position forKey:@"click_positon"];
    [dic setObject:logPb[@"impr_id"]?:@"be_null" forKey:@"impr_id"];
    [dic setObject:model.tracerDic[@"origin_from"]?:@"be_null" forKey:@"origin_from"];
    [dic setObject:model.tracerDic[@"enter_from"]?:@"be_null" forKey:@"enter_from"];
     [dic setObject:commentId?:@"" forKey:@"comment_id"];
    if ([event isEqualToString:@"click_like"]) {
        [dic setObject:@"110847" forKey:@"event_tracking_id"];
    }else {
         [dic setObject:@"110848" forKey:@"event_tracking_id"];
    }
    
    [FHUserTracker writeEvent:event params:dic];
}

+ (void)clickCommentWithModel:(FHFeedUGCCellModel *)model eventIndex:(NSInteger)index eventPosition:(NSString *)position {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    NSDictionary *logPb = [model.logPb copy];
    [dic setObject:model.groupId?:@"" forKey:@"group_id"];
    [dic setObject:[FHShortVideoTracerUtil pageType] forKey:@"page_type"];
    [dic setObject:[FHShortVideoTracerUtil categoryName] forKey:@"category_name"];
    [dic setObject:index?@(index):@(0) forKey:@"rank"];
    [dic setObject:logPb[@"group_source"]?:@"" forKey:@"group_source"];
    [dic setObject:logPb?:@"" forKey:@"log_pb"];
    [dic setObject:position forKey:@"click_position"];
    [dic setObject:@"110849" forKey:@"event_tracking_id"];
    [dic setObject:logPb[@"impr_id"]?:@"be_null" forKey:@"impr_id"];
    [dic setObject:model.tracerDic[@"origin_from"]?:@"be_null" forKey:@"origin_from"];
    [dic setObject:model.tracerDic[@"enter_from"]?:@"be_null" forKey:@"enter_from"];
    [FHUserTracker writeEvent:@"click_comment" params:dic];
}

+ (void)clickCommentSubmitWithModel:(FHFeedUGCCellModel *)model eventIndex:(NSInteger)index {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    NSDictionary *logPb = [model.logPb copy];
    [dic setObject:model.groupId?:@"" forKey:@"group_id"];
    [dic setObject:[FHShortVideoTracerUtil pageType] forKey:@"page_type"];
    [dic setObject:[FHShortVideoTracerUtil categoryName] forKey:@"category_name"];
    [dic setObject:index?@(index):@(0) forKey:@"rank"];
    [dic setObject:logPb[@"group_source"]?:@"" forKey:@"group_source"];
    [dic setObject:logPb?:@"" forKey:@"log_pb"];
    [dic setObject:@"110850" forKey:@"event_tracking_id"];
    [dic setObject:logPb[@"impr_id"]?:@"be_null" forKey:@"impr_id"];
    [dic setObject:model.tracerDic[@"origin_from"]?:@"be_null" forKey:@"origin_from"];
    [dic setObject:model.tracerDic[@"enter_from"]?:@"be_null" forKey:@"enter_from"];
    [FHUserTracker writeEvent:@"click_submit_comment" params:dic];
}
+ (void)clickshareBtn:(FHFeedUGCCellModel *)model {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    NSDictionary *logPb = [model.logPb copy];
    [dic setObject:model.groupId?:@"" forKey:@"group_id"];
    [dic setObject:[FHShortVideoTracerUtil pageType] forKey:@"page_type"];
    [dic setObject:[FHShortVideoTracerUtil categoryName] forKey:@"category_name"];
    [dic setObject:logPb[@"group_source"]?:@"" forKey:@"group_source"];
    [dic setObject:@"110851" forKey:@"event_tracking_id"];
    [dic setObject:logPb[@"impr_id"]?:@"be_null" forKey:@"impr_id"];
    [dic setObject:model.tracerDic[@"origin_from"]?:@"be_null" forKey:@"origin_from"];
    [dic setObject:model.tracerDic[@"enter_from"]?:@"be_null" forKey:@"enter_from"];
    [FHUserTracker writeEvent:@"click_share" params:dic];
}

+ (void)clicksharePlatForm:(FHFeedUGCCellModel *)model eventPlantFrom:(NSString *)platFrom {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    NSDictionary *logPb = [model.logPb copy];
    [dic setObject:model.groupId?:@"" forKey:@"group_id"];
    [dic setObject:[FHShortVideoTracerUtil pageType] forKey:@"page_type"];
    [dic setObject:[FHShortVideoTracerUtil categoryName] forKey:@"category_name"];
    [dic setObject:logPb[@"group_source"]?:@"" forKey:@"group_source"];
    [dic setObject:@"110852" forKey:@"event_tracking_id"];
    [dic setObject:logPb[@"impr_id"]?:@"be_null" forKey:@"impr_id"];
    [dic setObject:model.tracerDic[@"origin_from"]?:@"be_null" forKey:@"origin_from"];
    [dic setObject:model.tracerDic[@"enter_from"]?:@"be_null" forKey:@"enter_from"];
    [dic setObject:platFrom forKey:@"platform"];
    [FHUserTracker writeEvent:@"share_platfrom" params:dic];
}

+ (NSString *)categoryName {
    return @"f_house_smallvideo_flow";
}

+ (NSString *)pageType {
    return @"small_video_detail";
}

- (void)flushStayPageTime
{
    self.stayPageStartTime = [NSDate date];
}

- (NSTimeInterval)timeIntervalForStayPage
{
    return [[NSDate date] timeIntervalSinceDate:self.stayPageStartTime];
}
@end
