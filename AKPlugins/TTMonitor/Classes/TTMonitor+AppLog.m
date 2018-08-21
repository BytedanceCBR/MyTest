//
//  TTMonitor+AppLog.m
//  Article
//
//  Created by 苏瑞强 on 16/9/6.
//
//

#import "TTMonitor+AppLog.h"

@implementation TTMonitor (AppLog)

-(void)trackAppLogWithTag:(NSString *)tag label:(NSString *)label{
    [self trackAppLogWithTag:tag label:label extraValue:nil];
}

-(void)trackAppLogWithTag:(NSString *)tag label:(NSString *)label extraValue:(NSDictionary *)extra
{
    if (!tag || !label) {
        return;
    }
    NSString * value = [NSString stringWithFormat:@"%@_%@", tag, label];
    [[TTMonitor shareManager] trackService:@"applog" value:value extra:extra];
}

@end
