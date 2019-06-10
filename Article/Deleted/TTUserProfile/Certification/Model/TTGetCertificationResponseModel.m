//
//  TTGetCertificationResponseModel.m
//  Article
//
//  Created by wangdi on 2017/5/16.
//
//

#import "TTGetCertificationResponseModel.h"

@implementation TTGetCertificationRequestModel

- (instancetype)init
{
    if(self = [super init]) {
        self._host = [CommonURLSetting baseURL];
        self._uri = @"/user/profile/auth/apply/v2/";
        self._method = @"GET";
        self._response = NSStringFromClass([TTGetCertificationResponseModel class]);
    }
    return self;
}

@end

@implementation TTGetCertificationDataResponseModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}


@end

@implementation TTGetCertificationDataIndustryResponseModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}


@end

@implementation TTGetCertificationDataExtraResponseModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end


@implementation TTGetCertificationDataUserInfoResponseModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end

@implementation TTGetCertificationDataUserAuditInfoResponseModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end

@implementation TTGetCertificationResponseModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}


@end
