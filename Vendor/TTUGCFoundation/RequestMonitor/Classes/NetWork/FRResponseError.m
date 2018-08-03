//
//  FRResponseError.m
//  Article
//
//  Created by ranny_90 on 2017/10/17.
//

#import "FRResponseError.h"
#import "TTNetworkDefine.h"
#import "NSDictionary+TTAdditions.h"
#import "TTBaseMacro.h"
#import "JSONModelError.h"

@implementation FRResponseError

+ (NSError *)mapResponseError:(NSError *)responseError{
    
    if (!responseError) {
        return nil;
    }
    
    if ([responseError.domain isEqualToString:kTTNetworkErrorDomain]) {
        
        if (!SSIsEmptyDictionary(responseError.userInfo)) {
            
            //数据 json格式 解析错误
            if ([responseError.userInfo tt_objectForKey:@"TTNetworkErrorOriginalDataKey"]
                && responseError.code == -99) {

                 responseError = [NSError errorWithDomain:kTTNetworkServerErrorDomain code:responseError.code userInfo:responseError.userInfo];
            }
            
            //后端业务错误，新的model逻辑，errorcode为后端透传
            else if ([responseError.userInfo tt_intValueForKey:@"server_error_code"] != 0){
                
                responseError = [NSError errorWithDomain:kTTNetworkServerDataFormatErrorDomain code:responseError.code userInfo:responseError.userInfo];
            }
            
            //后端业务错误，老的逻辑，errorcode为message或自定义
            else if ([responseError.userInfo tt_objectForKey:@"server_old_error_code"]){
                
                responseError = [NSError errorWithDomain:kTTNetworkServerDataFormatErrorDomain code:responseError.code userInfo:responseError.userInfo];
            }
            
        }
    }
    
    //其他为网络库的错误
    
    
    return responseError;
}

+ (kTTNetworkErrorDomainType)responseErrorDomain:(NSError *)responseError{
    if (!responseError) {
        return kTTNetworkErrorNetWorkDomainNone;
    }
    
    if ([responseError.domain isEqualToString:kTTNetworkErrorDomain]) {
        return kTTNetworkErrorNetWorkDomainType;
    }
    else if ([responseError.domain isEqualToString:kTTNetworkServerErrorDomain]){
        return kTTNetworkErrorSeverJsonDomainType;
    }
    else if ([responseError.domain isEqualToString:kTTNetworkServerDataFormatErrorDomain]){
        
        return kTTNetworkErrorSeverDataDomainType;
    }
    else if ([responseError.domain isEqualToString:JSONModelErrorDomain]){
        return kTTNetWorkErrorJsonModelParseType;
    }
    else {
        return kTTNetworkErrorOtherDomainType;
    }
}

@end
