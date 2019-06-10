//
//  FHJSONHTTPRequestSerializer.m
//  FHHouseBase
//
//  Created by 春晖 on 2019/3/20.
//

#import "FHJSONHTTPRequestSerializer.h"

@implementation FHJSONHTTPRequestSerializer

+ (NSObject<TTHTTPRequestSerializerProtocol> *)serializer
{
    return [FHJSONHTTPRequestSerializer new];
    
}

- (TTHttpRequest *)URLRequestWithURL:(NSString *)URL
                              params:(NSDictionary *)params
                              method:(NSString *)method
               constructingBodyBlock:(TTConstructingBodyBlock)bodyBlock
                        commonParams:(NSDictionary *)commonParam
{
    TTHttpRequest *request = [super URLRequestWithURL:URL params:params method:method constructingBodyBlock:bodyBlock commonParams:commonParam];
    
    [request setValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    if ([@"POST" isEqualToString: method] && [params isKindOfClass:[NSDictionary class]]) {
        
        NSMutableDictionary *mparams = [NSMutableDictionary new];
        [mparams addEntriesFromDictionary:params];
        NSURLComponents *components = [[NSURLComponents alloc] initWithString:URL];
        for (NSURLQueryItem *item in components.queryItems) {
            mparams[item.name] = item.value;
        }
        
        NSData *data = [NSJSONSerialization dataWithJSONObject:mparams options:kNilOptions error:nil];
        if (data) {
            request.HTTPBody = data;
        }
    }
    
    return request;
}

@end
