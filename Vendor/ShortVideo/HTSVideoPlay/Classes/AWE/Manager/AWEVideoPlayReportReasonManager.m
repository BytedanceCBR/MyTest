//
//  AWEVideoPlayReportReasonManager.m
//  Pods
//
//  Created by 01 on 17/5/7.
//
//

#import "AWEVideoPlayReportReasonManager.h"
#import "AWEVideoPlayNetworkManager.h"

@implementation AWEVideoPlayReportReasonManager

- (void)requestReportReasonWithReportTypeString:(NSString *)typeString withComplection:(AWEReportReasonManagerCompletionBlock)block
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:typeString forKey:@"report_type"];
    
    NSString *urlString = @"https://aweme.snssdk.com/aweme/v1/aweme/feedback/reasons/";
    [[AWEVideoPlayNetworkManager sharedInstance] requestJSONFromURL:urlString params:parameters method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (!error && [jsonObj isKindOfClass:[NSDictionary class]] && [jsonObj[@"data"] isKindOfClass:[NSArray class]] && [jsonObj[@"data"] count] > 0) {
            block(jsonObj[@"data"], nil);
        } else {
            NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"AWEReportReason" ofType:@"plist"];
            NSDictionary *reportReasonList = [NSDictionary dictionaryWithContentsOfFile:plistPath];
            NSArray *reportDefaultArray = [reportReasonList objectForKey:typeString];
            block(reportDefaultArray, error);
        }
    }];
}

- (void)requestReportWithReportParams:(NSDictionary *)reportParams completion:(void (^)(NSError *error, id jsonObj))completion {
    
    NSString *urlString = @"https://aweme.snssdk.com/aweme/v1/aweme/feedback/";
    
    [[AWEVideoPlayNetworkManager sharedInstance] requestJSONFromURL:urlString params:reportParams method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        if (completion) {
            completion(error, jsonObj);
        }
    }];
}


@end
