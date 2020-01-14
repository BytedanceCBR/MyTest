//
//  TTBaseSystemMonitorRecorder.m
//  Article
//
//  Created by 苏瑞强 on 16/7/18.
//
//

#import "TTBaseSystemMonitorRecorder.h"
#define kLatestKey @"latest"

@implementation TTBaseSystemMonitorRecorder

- (NSString *)type{
    return @"";
}

- (NSString *)label{
    return @"";
}

- (double)monitorInterval{
    return 60*60;
}

- (BOOL)isEnabled{
    return NO;
}

+ (nullable NSString *)latestActionKey:(NSString *)type{
    return [NSString stringWithFormat:@"%@_%@", kLatestKey, type];
}

- (void)recordIfNeeded:(BOOL)isTermite {}

- (void)handleAppEnterBackground{
    
}

- (void)handleAppEnterForground{
    
}

@end
