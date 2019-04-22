//
//  TTDefaultResponseModelResponseSerializer.m
//  Article
//
//  Created by Huaqing Luo on 11/9/15.
//
//

#import "TTDefaultResponseModelResponseSerializer.h"
#import "JSONModelError.h"

@implementation TTDefaultResponseModelResponseSerializer

- (NSObject<TTResponseModelProtocol> *)responseObjectForResponse:(TTHttpResponse *)response
                                                         jsonObj:(id)jsonObj
                                                    requestModel:(TTRequestModel *)requestModel
                                                   responseError:(NSError *)responseError
                                                     resultError:(NSError *__autoreleasing *)resultError
{
    __autoreleasing NSError * jsonError = nil;
    id responseObject = [self responseObjectForResponse:response jsonObj:jsonObj responseError:responseError resultError:&jsonError];
    
    if (jsonError) {
        if (resultError) {
            *resultError = jsonError;
        }
        return nil;
    }
    
    if (![responseObject isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSAssert(requestModel._response, @"requestModel必须包含response信息");
    
    Class class = NSClassFromString(requestModel._response);
    if (!class) {
        return nil;
    }
    id result = [[class alloc] initWithDictionary:responseObject error:resultError];
    
    if (*resultError) {
        [self error:resultError addHTTPStatusCodeWithResponse:response];
    }
    return result;
}

+ (NSObject<TTJSONResponseSerializerProtocol> *)serializer
{
    return [[[self class] alloc] init];
}

@end
