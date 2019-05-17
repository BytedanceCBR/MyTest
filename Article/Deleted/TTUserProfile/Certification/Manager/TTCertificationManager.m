//
//  TTCertificationManager.m
//  Article
//
//  Created by wangdi on 2017/5/16.
//
//

#import "TTCertificationManager.h"
#import "TTNetworkManager.h"

@implementation TTCertificationManager

static id _instance;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (void)getCertificationInfoWithCompletion:(void (^)(NSError *error, TTGetCertificationResponseModel *))completion
{
    TTGetCertificationRequestModel *request = [[TTGetCertificationRequestModel alloc] init];
    [[TTNetworkManager shareInstance] requestModel:request callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        TTGetCertificationResponseModel *model = (TTGetCertificationResponseModel *)responseModel;
        if(completion) {
            completion(error,model);
        }
    }];
}

- (void)postCertificationWithRequestModel:(TTPostCertificationRequestModel *)requestModel completion:(void (^)(NSError *error,NSDictionary *result))completion
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:requestModel.real_name forKey:@"real_name"];
    [param setValue:requestModel.id_number forKey:@"id_number"];
    [param setValue:requestModel.auth_class_2 forKey:@"auth_class_2"];
    [param setValue:requestModel.company forKey:@"company"];
    [param setValue:requestModel.profession forKey:@"profession"];
    [param setValue:requestModel.additional forKey:@"additional"];
    [[TTNetworkManager shareInstance] uploadWithURL:[CommonURLSetting uploadCertificationURLString] parameters:param constructingBodyWithBlock:^(id<TTMultipartFormData> formData) {
        NSDictionary<NSString *,UIImage *> *images = requestModel.images;
        [images enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIImage * _Nonnull obj, BOOL * _Nonnull stop) {
            NSData *data = UIImageJPEGRepresentation(obj, 0.8);
            [formData appendPartWithFileData:data name:key fileName:@"image.jpg" mimeType:@"image/jpeg"];
        }];
    } progress:nil needcommonParams:YES callback:^(NSError *error, id jsonObj) {
        if(completion) {
            completion(error,jsonObj);
        }
        
    }];
}

- (void)postModofyCertificationWithRequestModel:(TTModifyCertificationRequestModel *)requestModel completion:(void (^)(NSError *error, NSDictionary *result))completion
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setValue:requestModel.company forKey:@"company"];
    [param setValue:requestModel.profession forKey:@"profession"];
    [param setValue:requestModel.apply_vtag forKey:@"apply_vtag"];
    [param setValue:requestModel.additional forKey:@"additional"];
    [[TTNetworkManager shareInstance] uploadWithURL:[CommonURLSetting uploadModifyCertificationURLString] parameters:param constructingBodyWithBlock:^(id<TTMultipartFormData> formData) {
        NSData *data = UIImageJPEGRepresentation(requestModel.image, 0.8);
        [formData appendPartWithFileData:data name:@"verified_material1" fileName:@"image.jpg" mimeType:@"image/jpeg"];

    } progress:nil needcommonParams:YES callback:^(NSError *error, id jsonObj) {
        if(completion) {
            completion(error,jsonObj);
        }
        
    }];
    
}

- (void)cancelCertificationWithCompletion:(void (^)(NSError *error, TTCancelCertificationResponseModel *responseModel))completion
{
    TTCancelCertificationRequestModel *requestModel = [[TTCancelCertificationRequestModel alloc] init];
    [[TTNetworkManager shareInstance] requestModel:requestModel callback:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel) {
        TTCancelCertificationResponseModel *model = (TTCancelCertificationResponseModel *)responseModel;
        if(completion) {
            completion(error,model);
        }
    }];
}

@end
