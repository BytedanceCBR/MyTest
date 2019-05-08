//
//  TTMessageCenterRouter.h
//  Article
//
//  Created by zuopengliu on 29/11/2017.
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN


@protocol TTMessageRouteProtocol;
@interface TTMessageCenterRouter : NSObject

/**
 注册路由业务方
 
 @param router 路由业务方，被强持有
 */
+ (void)registerRouter:(id<TTMessageRouteProtocol> _Nonnull)router;

/**
 取消|移除注册路由业务方
 
 @param router 路由业务方
 */
+ (void)unregisterRouter:(id<TTMessageRouteProtocol> _Nonnull)router;

/**
 判断是否能处理当前的URL对象

 @param url URL对象
 @return 能处理返回YES，否则返回NO
 */
+ (BOOL)canHandleOpenURL:(NSURL * _Nonnull)url;


/**
 处理当前的URL对象，若不能处理直接返回NO

 @param url URL对象
 @return 能处理返回YES并执行具体操作，否则返回NO
 */
+ (BOOL)handleOpenURL:(NSURL * _Nonnull)url;

@end



@protocol TTMessageRouteProtocol
@required
/**
 判断是否能打开具体的URL对象
 
 @param url URL对象
 @return 能打开返回YES，否则返回NO
 */
+ (BOOL)canHandleOpenURL:(NSURL * _Nonnull)url;

/**
 打开具体的URL对象

 @param url URL对象
 @return 能打开返回YES并执行具体操作，否则返回NO
 */
+ (BOOL)handleOpenURL:(NSURL * _Nonnull)url;

@end


NS_ASSUME_NONNULL_END
