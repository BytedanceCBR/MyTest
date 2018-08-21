//
//  TTLocationDelegate.h
//  Pods
//
//  Created by 王双华 on 17/3/7.
//
//


#import <Foundation/Foundation.h>

@protocol TTLocationDelegate <NSObject>

/**
 处理请求定位接口返回的命令
 
 */
- (void)processLocationCommandIfNeededFromNetWork:(BOOL)fromNetwork;

/**
 先请求授权，成功后，请求定位服务
 
 @param completionHandler 请求服务后的回调
 */
- (void)regeocodeWithCompletionHandler:(void (^)(NSArray *))completionHandler;

/**
 发送埋点
 
 @param event 事件 label 标签
 */
- (void)event:(NSString*)event label:(NSString*)label;

@end
