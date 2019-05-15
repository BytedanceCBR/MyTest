//
//  TTGetCertificationResponseModel.h
//  Article
//
//  Created by wangdi on 2017/5/16.
//
//

#import "TTResponseModel.h"
#import "TTRequestModel.h"

@interface TTGetCertificationRequestModel : TTRequestModel

@end

@interface TTGetCertificationDataIndustryResponseModel : TTResponseModel

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSArray *content;

@end

@protocol TTGetCertificationDataIndustryResponseModel <NSObject>

@end

@interface TTGetCertificationDataExtraResponseModel : TTResponseModel

@property (nonatomic, copy) NSString *reason;
@property (nonatomic, copy) NSString *additional;

@end

@interface TTGetCertificationDataUserInfoResponseModel : TTResponseModel

@property (nonatomic, strong) NSNumber *status;
@property (nonatomic, copy) NSString *auth_class_2;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *id_number;
@property (nonatomic, copy) NSString *verify_type;
@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *profession;
@property (nonatomic, copy) NSString *real_name;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, strong) TTGetCertificationDataExtraResponseModel *extra;

@end

@interface TTGetCertificationDataUserAuditInfoResponseModel : TTResponseModel

@property (nonatomic, strong) NSNumber *is_auditing;
@property (nonatomic, strong) NSNumber *can_modify_auth_info;

@end

@interface TTGetCertificationDataResponseModel : TTResponseModel

@property (nonatomic, strong) NSArray<TTGetCertificationDataIndustryResponseModel> *industry;
@property (nonatomic, strong) TTGetCertificationDataUserInfoResponseModel *user_auth_data;
@property (nonatomic, strong) TTGetCertificationDataUserAuditInfoResponseModel *audit_info;
@property (nonatomic, strong) NSNumber *is_pgc;
@property (nonatomic, copy) NSString *auditing_show_info;
@property (nonatomic, copy) NSString *audit_not_pass_info;
@property (nonatomic, strong) NSNumber *fans_count;
@property (nonatomic, strong) NSNumber *need_fans;
@property (nonatomic, copy) NSString *agreement_url;
@property (nonatomic, copy) NSString *faq_url;
@property (nonatomic, copy) NSString *upgrade_vtag;
@property (nonatomic, strong) NSNumber *has_post_ugc;
@end


@interface TTGetCertificationResponseModel : TTResponseModel

@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) TTGetCertificationDataResponseModel *data;

@end
