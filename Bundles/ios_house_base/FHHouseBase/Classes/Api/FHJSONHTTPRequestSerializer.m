//
//  FHJSONHTTPRequestSerializer.m
//  FHHouseBase
//
//  Created by 春晖 on 2019/3/20.
//

//#import "FHJSONHTTPRequestSerializer.h"
//
//@implementation FHJSONHTTPRequestSerializer
//
//- (TTHttpRequest *)URLRequestWithURL:(NSString *)URL
//                              params:(NSDictionary *)params
//                              method:(NSString *)method
//               constructingBodyBlock:(TTConstructingBodyBlock)bodyBlock
//                        commonParams:(NSDictionary *)commonParam
//{
//    TTHttpRequest *request = [super URLRequestWithURL:URL params:params method:method constructingBodyBlock:bodyBlock commonParams:commonParam];
//    
//    [request setValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    
//    if ([@"POST" isEqualToString: method] && [params isKindOfClass:[NSDictionary class]]) {
//        
//        NSData *data = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:nil];
//        if (data) {
//            request.HTTPBody = data;
//        }
//    }
//    
//    
//    return request;
//}
//
//@end
