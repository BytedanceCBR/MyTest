//
//  TTVPlayerTokenManager.m
//  Article
//
//  Created by 戚宽 on 2018/8/7.
//

#import "TTVPlayerTokenManager.h"
#import <TTNetworkManager/TTNetworkManager.h>
#import "NSDictionary+TTAdditions.h"

@implementation TTVPlayerTokenManager

+ (void)requestPlayTokenWithVideoID:(NSString *)videoID completion:(void (^)(NSError *error, NSString *authToken, NSString *bizToken))completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:2];
    params[@"format"] = @"json";
    params[@"video_id"] = videoID;
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[self urlStr] params:params method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        NSString *authToken;
        NSString *bizToken;
        if (!error) {
            if ([jsonObj isKindOfClass:[NSDictionary class]]) {
                authToken = [jsonObj tt_stringValueForKey:@"auth_token"];
                bizToken = [jsonObj tt_stringValueForKey:@"biz_token"];
            }
        }
        
        if (completion) {
            completion(error, authToken, bizToken);
        }
    }];
}

+ (NSString *)urlStr {
    return [NSString stringWithFormat:@"%@/vapp/api/playtoken/v1/", @"http://is.snssdk.com"];
}

@end
