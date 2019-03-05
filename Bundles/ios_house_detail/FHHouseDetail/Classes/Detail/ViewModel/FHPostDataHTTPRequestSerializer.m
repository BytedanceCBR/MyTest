//
//  FHPostDataHTTPRequestSerializer.m
//  Pods
//
//  Created by 张静 on 2019/2/17.
//

#import "FHPostDataHTTPRequestSerializer.h"

@implementation FHPostDataHTTPRequestSerializer

+ (NSObject<TTHTTPRequestSerializerProtocol> *)serializer
{
    return [FHPostDataHTTPRequestSerializer new];
    
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
    
    if ([@"POST" isEqualToString: method] && [parameters isKindOfClass:[NSDictionary class]]) {
        NSData * postDate = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
        [request setHTTPBody:postDate];
    }

    
    return request;
    
}
@end
