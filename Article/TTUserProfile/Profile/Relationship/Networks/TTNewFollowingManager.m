//
//  TTNewFollowingManager.m
//  Article
//
//  Created by lizhuoli on 17/1/8.
//
//

#import "TTNewFollowingManager.h"
#import "TTNetworkManager.h"
#import <TTAccountBusiness.h>

@implementation TTNewFollowingManager

+ (instancetype)sharedInstance
{
    static TTNewFollowingManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [TTNewFollowingManager new];
    });
    
    return manager;
}

- (void)fetchFollowingListWithUserID:(NSString *)userID cursor:(NSString *)cursor completion:(TTNewFollowingResponseBlock)completion
{
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:2];
    param[@"user_id"] = !isEmptyString(userID) ? userID : @"0";
    if (cursor && cursor.intValue != 0) {
        param[@"cursor"] = cursor;
    }
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting newFollowingURLString] params:param method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (!error && jsonObj && [jsonObj isKindOfClass:[NSDictionary class]]) {
            NSError *err;
            TTNewFollowingResponseModel *model = [[TTNewFollowingResponseModel alloc] initWithDictionary:jsonObj error:&err];
            if (model) {
                if (completion) {
                    completion(nil, model);
                }
            } else {
                if (completion) {
                    completion(err, nil);
                }
            }
        } else {
            if (!error) {
                error = [NSError errorWithDomain:kTTNewFollowingErrorDomain code:1 userInfo:nil];
            }
            if (completion) {
                completion(error, nil);
            }
        }
    }];
}

@end
