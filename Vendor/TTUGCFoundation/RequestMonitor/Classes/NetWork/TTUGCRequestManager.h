//
//  TTUGCRequestManager.h
//  Article
//
//  Created by SongChai on 2017/8/9.
//

#import "TTNetworkManager.h"
#import "TTUGCResponseError.h"
#import "TTUGCRequestMonitorModel.h"

typedef void (^TTUGCMonitorNetworkModelFinishBlock)(NSError *error, id<TTResponseModelProtocol> responseModel, TTUGCRequestMonitorModel *monitorModel);

typedef void (^TTMonitorNetworkJSONFinishBlock)(NSError *error, id jsonObj, TTUGCRequestMonitorModel *monitorModel);

@interface TTUGCRequestManager : NSObject

///**
// *  通过requestModel请求，简单封装TTNetworkManager，增加业务错误返回的domain，否则上层不能获取err_no和err_tips
// *  网络库的请求抽象处理，可以定制化需求
// *
// *  @param model    请求model
// *  @param callback 结果回调，可打端监控
// *
// *  @return TTHttpTask
// */
//
+ (TTHttpTask *)requestModel:(TTRequestModel *)model
         callBackWithMonitor:(TTUGCMonitorNetworkModelFinishBlock)callBack;

///**
// *  通过requestModel请求，简单封装TTNetworkManager，增加业务错误返回的domain，否则上层不能获取err_no和err_tips
// *  网络库的请求抽象处理，可以定制化需求
// *
// *  @param URL    请求URL
// *  @param params 请求参数
// *  @param method 请求类型
// *  @param commonParams 是否需要公共参数
// *  @param callback 结果回调，可打端监控
// *
// *  @return TTHttpTask
// */
//
+ (TTHttpTask *)requestForJSONWithURL:(NSString *)URL
                               params:(id)params
                               method:(NSString *)method
                     needCommonParams:(BOOL)commonParams
                  callBackWithMonitor:(TTNetworkJSONFinishBlockWithResponse)callback;

@end
