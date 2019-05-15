//
//  TTCancelCertificationResponseModel.m
//  Article
//
//  Created by wangdi on 2017/5/23.
//
//

#import "TTCancelCertificationResponseModel.h"

@implementation TTCancelCertificationRequestModel

- (instancetype)init
{
    if(self = [super init]) {
        self._host = [CommonURLSetting baseURL];
        self._uri = @"/user/profile/auth/cancel/";
        self._method = @"GET";
        self._response = NSStringFromClass([TTCancelCertificationResponseModel class]);
    }
    return self;
}

@end

@implementation TTCancelCertificationDataResponseModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}


@end

@implementation TTCancelCertificationResponseModel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

@end
