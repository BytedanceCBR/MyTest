//
//  TTVFantasy.m
//  Article
//
//  Created by panxiang on 2018/1/12.
//

#import "TTVFantasy.h"
#import "TTFFantasyTracker.h"
@implementation TTVFantasy
+ (void)ttf_enterFantasyFromViewController:(UIViewController *)vc
                         trackerDescriptor:(nullable NSDictionary *)descriptor
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:descriptor];
    if (!isEmptyString([TTFFantasyTracker sharedInstance].lastGid)) {
        NSMutableDictionary *last = [NSMutableDictionary dictionary];
        [last setValue:[TTFFantasyTracker sharedInstance].lastGid forKey:@"from_gid"];
        [last setValue:@(ceil([[TTFFantasyTracker sharedInstance].lastDate timeIntervalSince1970])) forKey:@"last_gid_time"];
        [dic setValue:last forKey:kTTFLastHistoryInfoKey];
    }
    [TTFantasy ttf_enterFantasyFromViewController:vc trackerDescriptor:dic];
}
@end
