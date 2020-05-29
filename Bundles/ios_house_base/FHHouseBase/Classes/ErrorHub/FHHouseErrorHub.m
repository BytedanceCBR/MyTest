//
//  FHHouseErrorHub.m
//  FHHouseBase
//
//  Created by liuyu on 2020/5/11.
//

#import "FHHouseErrorHub.h"

@implementation FHHouseErrorHub
+ (FHHouseErrorHub *)initFHHouseErrorHubWithEventname:(NSString *)eventName errorInfo:(NSString *)errorInfo saveDic:(NSDictionary *)saveDic senceArr:(NSArray *)senceArr extra:(NSDictionary *)extra type:(FHErrorHubType)type {
    FHHouseErrorHub *errHub = [[FHHouseErrorHub alloc]init];
    errHub.eventName = eventName;
    errHub.errorInfo = errorInfo;
    errHub.saveDic = saveDic;
    errHub.senceArr = senceArr;
    errHub.extra = extra;
    errHub.type = type;
    return errHub;
}
@end
