//
//  TTPostDataHttpRequestSerializer.m
//  Article
//
//  Created by yuxin on 10/13/15.
//
//

#import "AWEPostDataHttpRequestSerializer.h"
//#import "SSCommon+JSON.h"

@implementation AWEPostDataHttpRequestSerializer

+ (NSObject<TTHTTPRequestSerializerProtocol> *)serializer
{
    return [AWEPostDataHttpRequestSerializer new];
    
}

- (TTHttpRequest *)URLRequestWithURL:(NSString *)URL
                             params:(NSDictionary *)parameters
                             method:(NSString *)method
              constructingBodyBlock:(TTConstructingBodyBlock)bodyBlock
                       commonParams:(NSDictionary *)commonParam
{
    TTHttpRequest * request = [super URLRequestWithURL:URL params:parameters method:method constructingBodyBlock:bodyBlock commonParams:commonParam];
    
    [request setValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSData * postDate = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
    [request setHTTPBody:postDate];
    
    return request;

}
@end
