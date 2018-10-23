//
//  TTPostCertificationResponseModel.h
//  Article
//
//  Created by wangdi on 2017/5/16.
//
//

#import "TTResponseModel.h"

@interface TTPostCertificationRequestModel  : TTRequestModel

@property (nonatomic, copy) NSString *real_name;
@property (nonatomic, copy) NSString *id_number;
@property (nonatomic, copy) NSString *auth_class_2;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *profession;
@property (nonatomic, copy) NSString *additional;
@property (nonatomic, strong) NSDictionary<NSString *,UIImage *> *images;

@end

@interface TTPostCertificationDataResponseModel : TTResponseModel

@property (nonatomic, copy) NSString *auth_show_info;

@end

@interface TTPostCertificationResponseModel : TTResponseModel

@end
