//
//  SSHTTPProcesser.h
//  Article
//
//  Created by SunJiangting on 14-10-24.
//
//

#import <Foundation/Foundation.h>

@protocol SSHTTPResponseProtocol <NSObject>
/// 如果headerFields Content-Type 为ss-formated-data, 则会修改responseData为反混淆过的。使用者应该使用修改过的responseData
@property(nonatomic, strong) NSData *responseData;

@optional
- (NSDictionary *)allHeaderFields;

@end

@interface SSHTTPProcesser : NSObject

+ (instancetype)sharedProcesser;

// 处理response 之前的预处理, 处理反混淆， 实时下架文章等。
// @param total 增加当前网络请求总时延参数
// @param url   请求urlString
- (void)preprocessHTTPResponse:(id<SSHTTPResponseProtocol>)HTTPResponse
      requestTotalTimeInterval:(int64_t)total
                    requestURL:(NSURL *)url;

@end


@interface SSHTTPProcesser (SSProcessHeaderFields)

/// 处理response 之前的预处理，比如文章时时下架这种命令形式的
- (void)processHTTPHeaderFields:(NSDictionary *)headerFields requestTotalTimeInterval:(int64_t)total requestURL:(NSURL *)url;

@end


@interface SSHTTPResponseProtocolItem : NSObject <SSHTTPResponseProtocol>

@property(nonatomic, strong) NSDictionary *allHeaderFields;

@end
