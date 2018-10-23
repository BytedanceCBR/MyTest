//
//  FRShareMessageManager.m
//  Article
//
//  Created by 王霖 on 15/9/9.
//
//

#import "FRShareMessageManager.h"
#import "TTNetworkManager.h"
#import "FRApiModel.h"
#import <TTBaseLib/NSDictionary+TTAdditions.h>

@implementation FRShareMessageManager

- (void)shareMessageFromPlatform:(TTSharePlatformType)platformType condition:(NSDictionary *)condition withCompletion:(TTPlatformShareMessageCompletion)completion {
    FRTtdiscussV1ShareRequestModel *request = [[FRTtdiscussV1ShareRequestModel alloc] init];
    request.forward_to = [condition objectForKey:@"forward_to"];
    request.forward_type = [condition objectForKey:@"forward_type"];
    request.forward_id = [condition objectForKey:@"forward_id"];
    request.forward_content = [condition objectForKey:@"forward_content"];
    
    [[TTNetworkManager shareInstance] requestModel:request callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        completion(responseModel, error);
    }];
}

@end
