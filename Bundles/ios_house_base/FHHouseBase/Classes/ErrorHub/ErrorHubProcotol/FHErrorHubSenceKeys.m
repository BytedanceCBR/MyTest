//
//  FHErrorHubSenceKeys.m
//  FHHouseBase
//
//  Created by liuyu on 2020/5/9.
//

#import "FHErrorHubSenceKeys.h"

@implementation FHErrorHubSenceKeys
+ (NSArray *)returnSenceNameArrFromEventName:(NSString *)eventName {
    if ([eventName isEqualToString:@"request"] || [eventName isEqualToString:@"buryingPoint"] || [eventName isEqualToString:@"config&&settings"]) {
        return @[@"config",@"settings"];
    }
    return @[];
}
@end
