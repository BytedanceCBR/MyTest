//
//  TTAPNsRouting.h
//  Article
//
//  Created by zuopengliu on 21/12/2017.
//

#import <Foundation/Foundation.h>
#import "SSAPNsAlertManager.h"



NS_ASSUME_NONNULL_BEGIN

/**
 回调中参数Key如下
 
 #define kSSAPNsAlertManagerTitleKey         @"kSSAPNsAlertManagerTitleKey"
 #define kSSAPNsAlertManagerSchemaKey        @"kSSAPNsAlertManagerSchemaKey"
 #define kSSAPNsAlertManagerOldApnsTypeIDKey @"kSSAPNsAlertManagerOldApnsTypeIDKey"  // 老的推送方式， 如果有id，则是推送到详情页
 #define kSSAPNsAlertManagerRidKey           @"kSSAPNsAlertManagerRidKey"
 #define kSSAPNsAlertManagerImportanceKey    @"kSSAPNsAlertManagerImportanceKey"     // 紧急程度
 #define kSSAPNsAlertManagerAttachmentKey    @"kSSAPNsAlertManagerAttachmentKey"     // 附件
 
 Usage:
 1. Register
 [TTAPNsRouting registerHost:@"host" matchBlock:^BOOL(NSDictionary * _Nonnull params) {
     return YES;
 }];
 
 [TTAPNsRouting registerHostPattern:@"host*" matchBlock:^BOOL(NSDictionary * _Nonnull params) {
     return YES;
 }];
 
 2. Unregister
 [TTAPNsRouting unregisterHost:@"host"];
 
 [TTAPNsRouting unregisterHostPattern:@"host*"];
 */
@interface TTAPNsRouting : NSObject

/**
 注册推送消息路由；同一个host注册多次会回调多次
 
 @param host 添加的host，不支持正则表达式
 @param handler 匹配时的回调 {handler能处理返回YES，否则返回NO}
 */
+ (void)registerHost:(NSString *)host
          matchBlock:(BOOL (^)(NSDictionary *params))handler;

+ (void)registerHostPattern:(NSString *)hostPattern /** 支持正则表达式匹配 */
                 matchBlock:(BOOL (^)(NSDictionary *params))handler;

/**
 移除推送消息host注册的所有回调
 
 @param host 移除的host
 */
+ (void)unregisterHost:(NSString *)host;

+ (void)unregisterHostPattern:(NSString *)hostPattern;

@end



@interface TTAPNsRouting (HandlePushMessage)

/**
 处理推送消息路由
 
 @param params 推送消息
 @return 能处理返回YES，否则返回NO
 */
+ (BOOL)handlePushMsg:(NSDictionary *)params;

@end



@interface NSDictionary (APNsPushSchemeURL)

/**
 从推送信息中获取下发的Scheme URL

 @return 返回scheme URL
 */
- (NSURL *)apns_schemeURL;

@end

NS_ASSUME_NONNULL_END
