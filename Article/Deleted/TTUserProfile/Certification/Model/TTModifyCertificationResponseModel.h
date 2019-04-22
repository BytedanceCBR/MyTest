//
//  TTModifyCertificationResponseModel.h
//  Article
//
//  Created by wangdi on 2017/5/23.
//
//

#import "TTRequestModel.h"
#import "TTResponseModel.h"

@interface TTModifyCertificationRequestModel : TTRequestModel

@property (nonatomic, copy) NSString *company;
@property (nonatomic, copy) NSString *profession;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *apply_vtag;
@property (nonatomic, copy) NSString *additional;

@end

@interface TTModifyCertificationDataResponseModel : TTResponseModel

@end

@interface TTModifyCertificationResponseModel : TTResponseModel

@end
