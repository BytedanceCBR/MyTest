//
//  TTModifyCertificationResponseModel.m
//  Article
//
//  Created by wangdi on 2017/5/23.
//
//

#import "TTModifyCertificationResponseModel.h"

@implementation TTModifyCertificationRequestModel

//- (instancetype)init
//{
//    if(self = [super init]) {
//        self._host = [CommonURLSetting baseURL];
//        self._uri = @"/user/profile/auth/modify_auth_info/";
//        self._method = @"POST";
//        self._response = NSStringFromClass([TTModifyCertificationResponseModel class]);
//    }
//    return self;
//}


@end

@implementation TTModifyCertificationDataResponseModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end

@implementation TTModifyCertificationResponseModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end
