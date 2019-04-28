//
//  TTCertificationManager.h
//  Article
//
//  Created by wangdi on 2017/5/16.
//
//

#import <Foundation/Foundation.h>
#import "TTGetCertificationResponseModel.h"
#import "TTPostCertificationResponseModel.h"
#import "TTCancelCertificationResponseModel.h"
#import "TTModifyCertificationResponseModel.h"

@interface TTCertificationManager : NSObject

+ (instancetype)sharedInstance;

- (void)getCertificationInfoWithCompletion:(void (^)(NSError *error,TTGetCertificationResponseModel *responseModel))completion;

- (void)postCertificationWithRequestModel:(TTPostCertificationRequestModel *)requestModel completion:(void (^)(NSError *error,NSDictionary *result))completion;

- (void)postModofyCertificationWithRequestModel:(TTModifyCertificationRequestModel *)requestModel completion:(void (^)(NSError *error,NSDictionary *result))completion;

- (void)cancelCertificationWithCompletion:(void (^)(NSError *error,TTCancelCertificationResponseModel *responseModel))completion;

@end
