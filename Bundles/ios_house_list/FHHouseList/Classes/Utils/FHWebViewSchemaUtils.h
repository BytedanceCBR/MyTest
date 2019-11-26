//
//  FHWebViewSchemaUtils.h
//  BDAccountSessionSDK-SessionCheck
//
//  Created by zhulijun on 2019/10/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHWebViewSchemaUtils : UICollectionViewCell

/**
 * 判断一个schema是否为webview schema
 */
+(BOOL)isWebViewSchema:(NSString*)urlStr;
+(BOOL)isWebViewSchemaURL:(NSURL*)url;

/**
 * url schema为webview的URL
 * name 为key值
 * params 需要添加的param
 *
 * 如果schema的url value中已经存在key值为name的param，则覆盖
 *
 */
+(NSURL*)webViewSchemaAddOrReplaceParamStr:(NSString*)urlStr name:(NSString*)name param:(NSString*)param;
+(NSURL*)webViewSchemaURLAddOrReplaceParamStr:(NSURL*)url name:(NSString*)name param:(NSString*)param;

/**
 * url schema为webview的URL
 * reportParams 需要添加的report_params
 *
 * 如果schema的url value中已经存在report_params，则合并，合并规则已经存在的key值覆盖，不存在的key值添加,如果存在的值是string，则覆盖
 *
 */
+(NSURL*)webViewSchemaAddReportParamDic:(NSString*)urlStr reportParams:(NSDictionary*)reportParams;
+(NSURL*)webViewSchemaURLAddReportParamDic:(NSURL*)url reportParams:(NSDictionary*)reportParams;

/**
 * url schema为webview的URL
 * name 为key值
 * params 需要添加的params
 *
 * 如果schema的url value中已经存在params，则合并，合并规则已经存在的key值覆盖，不能存在的key值添加 如果存在的值是string，则覆盖
 *
 */
+(NSURL*)webViewSchemaAddOrReplaceParamDic:(NSString*)urlStr name:(NSString*)name params:(NSDictionary*)params;
+(NSURL*)webViewSchemaURLAddOrReplaceParamDic:(NSURL*)url name:(NSString*)name params:(NSDictionary*)params;
@end

NS_ASSUME_NONNULL_END
