//
//  TTPostCheckBindPhoneViewModel.m
//  Article
//
//  Created by ranny_90 on 2017/8/8.
//
//

#import "TTPostCheckBindPhoneViewModel.h"
#import "TTNetworkManager.h"

@implementation TTPostCheckBindPhoneViewModel

+ (void)checkPostNeedBindPhoneOrNotWithCompletion:(void(^ _Nullable)(FRPostBindCheckType checkType))completion{
    
    FRUgcPublishPostV1CheckRequestModel *checkBindModel = [[FRUgcPublishPostV1CheckRequestModel alloc] init];
    
    [[TTNetworkManager shareInstance] requestModel:checkBindModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        if (error) {
            if (completion) {
                completion(FRPostBindCheckTypePostBindCheckTypeNone);
            }
        }
        else if ([responseModel isKindOfClass:[FRUgcPublishPostV1CheckResponseModel class]]) {
            FRUgcPublishPostV1CheckResponseModel *checkResponse = (FRUgcPublishPostV1CheckResponseModel *)responseModel;
            if (completion) {
                completion(checkResponse.bind_mobile);
            }
            
        }
        else {
            if (completion) {
                completion(FRPostBindCheckTypePostBindCheckTypeNone);
            }
        }
    }];
}

@end
