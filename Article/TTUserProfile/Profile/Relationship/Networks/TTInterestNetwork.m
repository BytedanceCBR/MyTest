//
//  TTInterestNetwork.m
//  Article
//
//  Created by liuzuopeng on 8/30/16.
//
//

#import "TTInterestNetwork.h"
#import "TTNetworkManager.h"


@implementation TTInterestNetwork
+ (void)getInterestListWithUserID:(NSString *)uid Offset:(NSNumber *)offset completion:(void (^)(TTInterestResponseModel *aModel, NSError *error))completion {
    TTInterestRequestModel *requestModel = [TTInterestRequestModel new];
    requestModel.user_id = !isEmptyString(uid) ? uid : @"0";
    requestModel.offset = offset;

    [[TTNetworkManager shareInstance] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        TTInterestResponseModel *interestModel = (TTInterestResponseModel *)responseModel;
        if (completion) {
            completion(interestModel, error);
        }
    }];
}
@end
