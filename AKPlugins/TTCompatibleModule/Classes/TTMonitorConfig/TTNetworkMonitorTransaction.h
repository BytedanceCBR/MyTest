//
//  TTNetworkMonitorTransaction.h
//  TTMonitor
//
//  Created by ZhangLeonardo on 16/3/9.
//  Copyright © 2016年 ZhangLeonardo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "TTNetworkManager.h"

@interface TTNetworkMonitorTransaction : NSObject

@property (nonatomic, copy) NSString *requestID;

@property (nonatomic, strong) TTHttpRequest *request;
@property (nonatomic, strong) TTHttpResponse *response;
@property (nonatomic, strong) NSError *error;

@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSInteger hasTriedTimes;
@property (nonatomic, copy) NSString * requestUrl;



/**
 定义见： https://wiki.bytedance.com/pages/viewpage.action?pageId=524425#id-基础服务-基础服务-cdn图片监控API
 1 ~ 99为自定义:
 1：未知错误
 2: 连接超时 (ConnectTimeoutException)
 3: 网络超时 (SocketTimeoutException)
 4: IO错误 (IOException)
 5: SocketException (若能细分，按下面的具体类型)
 6. reset by peer
 7: BindException
 8: ConnectException (若能区分，尽量具体到12 ~ 17的错误)
 9: NoRouteToHostException
 10: PortUnreachableException
 11: UnknownHostException
 12: ECONNRESET
 13: ECONNREFUSED
 14: EHOSTUNREACH
 15: ENETUNREACH
 16: EADDRNOTAVAIL
 17: EADDRINUSE
 18: 无http响应 (NoHttpResponseExcetion)
 19: 协议错误 (ClientProtocolException)
 20: content length超过限制
 21: too many redirects
 
 31: 客户端未知错误
 32: 客户端存储空间不足
 33: ENOENT 打开或写入文件失败：文件不存在
 34: EDQUOT 占用存储超出配额
 35: EROFS 文件系统只读
 36: EACCES 无权限
 37: EIO
 
 >= 100为服务端响应状态码, 如
 200: 下载成功
 502: 网关错误
 */
@property (nonatomic, assign) NSInteger status;


+ (NSInteger)statusCodeForNSUnderlyingError:(NSError *)error;

/**
 *  读取HTTP的状态码
 *
 *  @param response HTTP的response
 *
 *  @return 如果找到，返回NSNotFond
 */
+ (NSInteger)statusCodeForResponse:(TTHttpResponse *)response;


@end
