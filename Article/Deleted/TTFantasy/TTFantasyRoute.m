//
//  TTFantasyRoute.m
//  Article
//
//  Created by panxiang on 2018/1/5.
//

#import "TTFantasyRoute.h"
#import "TTRoute.h"
#import "TTVFantasy.h"
#import "TTFantasyWindowManager.h"
#import "SSCommonLogic.h"
#import "TTFFantasyTracker.h"

extern NSString * const kTTFEnterFromTypeKey;
@implementation TTFantasyRoute
+ (void)load
{
    [TTRoute registerRouteEntry:@"fantasy" withObjClass:[self class]];
}

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj
{
    if (self = [super init]) {
    }
    return self;
}

- (void)customOpenTargetWithParamObj:(nullable TTRouteParamObj *)paramObj
{
//    [TTVFantasy ttf_enterFantasyFromViewController:[TTUIResponderHelper topmostViewController] trackerDescriptor:paramObj.queryParams];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:paramObj.queryParams];
    if (!isEmptyString([TTFFantasyTracker sharedInstance].lastGid)) {
        NSMutableDictionary *last = [NSMutableDictionary dictionary];
        [last setValue:[TTFFantasyTracker sharedInstance].lastGid forKey:@"from_gid"];
        [last setValue:@(ceil([[TTFFantasyTracker sharedInstance].lastDate timeIntervalSince1970])) forKey:@"last_gid_time"];
        [dic setValue:last forKey:kTTFLastHistoryInfoKey];
    }
    
    if ([SSCommonLogic fantasyWindowResizeable]) {
        [TTFantasyWindowManager sharedManager].trackerDescriptor = dic;
        [[TTFantasyWindowManager sharedManager] show];
    } else {
        [TTVFantasy ttf_enterFantasyFromViewController:[TTUIResponderHelper topmostViewController] trackerDescriptor:paramObj.queryParams];
    }
   
}
@end
