//
//  FHUGCencyclopediaTracerHelper.m
//  FHHouseUGC
//
//  Created by liuyu on 2020/5/26.
//

#import "FHUGCencyclopediaTracerHelper.h"
#import "FHUserTracker.h"

@implementation FHUGCencyclopediaTracerHelper
- (void)trackCategoryRefresh {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"origin_from"] = self.tracerModel.originFrom?: @"be_null";
    dict[@"enter_from"] = self.tracerModel.enterFrom?: @"be_null";
    dict[@"category_name"] = self.tracerModel.categoryName?:@"be_null";
    dict[@"page_type"] = [self getPageType]?:@"be_null";
    dict[@"event_type"] = [self eventType];
    dict[@"refresh_type"] = @"pull";
    dict[@"enter_type"] = @"click";
    TRACK_EVENT(@"category_refresh", dict);
}

- (void)trackClientShow:(NSDictionary *)itemData {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"origin_from"] = self.tracerModel.originFrom?: @"be_null";
    dict[@"enter_from"] = self.tracerModel.enterFrom?: @"be_null";
    dict[@"category_name"] = self.tracerModel.categoryName?:@"be_null";
    dict[@"page_type"] = [self getPageType]?:@"be_null";
    dict[@"event_type"] = [self eventType];
    dict[@"enter_type"] = @"click";
    dict[@"impr_id"] = [itemData.allKeys containsObject:@"impr_id"]?itemData[@"impr_id"]:@"be_null";
    dict[@"item_id"] = [itemData.allKeys containsObject:@"item_id"]?itemData[@"item_id"]:@"be_null";
    dict[@"from_gid"] = [itemData.allKeys containsObject:@"group_id"]?itemData[@"group_id"]:@"group_id";
    dict[@"group_id"] = [itemData.allKeys containsObject:@"group_id"]?itemData[@"group_id"]:@"group_id";

    TRACK_EVENT(@"client_show", dict);
}

- (void)trackHeaderSegmentClickOptions:(NSInteger )index {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"origin_from"] = self.tracerModel.originFrom?: @"be_null";
    dict[@"enter_from"] = self.tracerModel.enterFrom?: @"be_null";
    dict[@"category_name"] = self.tracerModel.categoryName?:@"be_null";
    dict[@"page_type"] = [self getPageType]?:@"be_null";
    dict[@"click_position"] = @(index);
    dict[@"element_from"] = self.tracerModel.elementFrom?:@"be_null";
    TRACK_EVENT(@"click_options", dict);
}

- (void)trackHeaderSegmentClickOptionsWithString:(NSString *)name {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"origin_from"] = self.tracerModel.originFrom?: @"be_null";
    dict[@"enter_from"] = self.tracerModel.enterFrom?: @"be_null";
    dict[@"category_name"] = self.tracerModel.categoryName?:@"be_null";
    dict[@"page_type"] = [self getPageType]?:@"be_null";
    dict[@"click_position"] = name;
    dict[@"element_from"] = self.tracerModel.elementFrom?:@"be_null";
    TRACK_EVENT(@"click_options", dict);
}

- (NSString *)getPageType {
    return @"f_house_encyclopedia";
}

- (NSString *)eventType {
    return @"house_app2c_v2";
}
@end
