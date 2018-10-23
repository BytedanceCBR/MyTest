//
//  HTSBaseHTTPRequestSerializer.m
//  Pods
//
//  Created by 权泉 on 2017/5/11.
//
//

#import "HTSBaseHTTPRequestSerializer.h"

@implementation HTSBaseHTTPRequestSerializer

+ (NSObject<TTHTTPRequestSerializerProtocol> *)serializer
{
    HTSBaseHTTPRequestSerializer *serializer = [[HTSBaseHTTPRequestSerializer alloc] init];
    return serializer;
}

- (TTHttpRequest *)URLRequestWithRequestModel:(TTRequestModel *)requestModel
                                 commonParams:(NSDictionary *)commonParam;
{
    TTHttpRequest *request = [super URLRequestWithRequestModel:requestModel commonParams:commonParam];
    return [self preprocessRequest:request parameters:nil];
}

- (TTHttpRequest *)URLRequestWithURL:(NSString *)URL
                              params:(id)params
                              method:(NSString *)method
               constructingBodyBlock:(TTConstructingBodyBlock)bodyBlock
                        commonParams:(NSDictionary *)commonParam;
{
    TTHttpRequest *request = [super URLRequestWithURL:URL
                                               params:params
                                               method:method
                                constructingBodyBlock:bodyBlock
                                         commonParams:commonParam];
    return [self preprocessRequest:request parameters:params];
}

- (TTHttpRequest *)URLRequestWithURL:(NSString *)URL
                         headerField:(NSDictionary *)headField
                              params:(NSDictionary *)params
                              method:(NSString *)method
               constructingBodyBlock:(TTConstructingBodyBlock)bodyBlock
                        commonParams:(NSDictionary *)commonParam;
{
    TTHttpRequest *request = [super URLRequestWithURL:URL headerField:headField params:params method:method constructingBodyBlock:bodyBlock commonParams:commonParam];
    return [self preprocessRequest:request parameters:params];
}

#pragma mark -- Private Method
- (TTHttpRequest *)preprocessRequest:(TTHttpRequest *)request parameters:(id)parameters
{
    return request;
}

@end
