//
//  FHRentDetailAPI.m
//  Pods
//
//  Created by leo on 2018/11/25.
//

#import "FHRentDetailAPI.h"
#import <TTNetworkManager.h>
#import "FHURLSettings.h"

#define GET @"GET"
#define POST @"POST"
#define DEFULT_ERROR @"请求错误"
#define API_ERROR_CODE  1000



@implementation FHRentDetailAPI
+(TTHttpTask*)requestRentDetail:(NSString*)rentCode
                     completion:(void(^)(FHRentDetailResponseModel *model , NSError *error))completion {
    
    NSString * host = [FHURLSettings baseURL] ?: @"https://i.haoduofangs.com";
    NSString* url = [host stringByAppendingString:@"/f100/api/rental/info"];
    return [[TTNetworkManager shareInstance] requestForBinaryWithURL:url
                                                              params:@{@"rental_f_code": rentCode}
                                                              method:@"GET"
                                                    needCommonParams:YES
                                                            callback:^(NSError *error, id obj) {
        FHRentDetailResponseModel *model = nil;
        if (!error) {
            model = [[FHRentDetailResponseModel alloc] initWithData:obj error:&error];
        }

        if (![model.status isEqualToString:@"0"]) {
            error = [NSError errorWithDomain:model.message?:DEFULT_ERROR code:API_ERROR_CODE userInfo:nil];
        }

        if (completion) {
            completion(model,error);
        }
    }];
}
@end
