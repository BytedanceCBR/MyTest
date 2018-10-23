//
//  FRRequestManager.h
//  Article
//
//  Created by SongChai on 2017/8/9.
//

#import "TTNetworkManager.h"
#import "FRResponseError.h"
#import "FRForumMonitorModel.h"

 typedef void (^FRMonitorNetworkModelFinishBlock)(NSError *error, id<TTResponseModelProtocol> responseModel, FRForumMonitorModel *monitorModel);

@interface FRRequestManager : NSObject

/**
 *  通过requestModel请求，简单封装TTNetworkManager，增加业务错误返回的domain，否则上层不能获取err_no和err_tips
 *  网络库的请求抽象处理，可以定制化需求
 *
 *  @param model    请求model
 *  @param callback 结果回调
 *
 *  @return TTHttpTask
 */

 + (TTHttpTask *)requestModel:(TTRequestModel *)model callback:(TTNetworkResponseModelFinishBlock)callback; __deprecated_msg("请使用requestModel:callBackWithMonitor: 多打端监控");

+ (TTHttpTask *)requestModel:(TTRequestModel *)model
         callBackWithMonitor:(FRMonitorNetworkModelFinishBlock)callBack;

+ (TTHttpTask *)requestForJSONWithURL:(NSString *)URL
                               params:(id)params
                               method:(NSString *)method
                            needCommonParams:(BOOL)commonParams
                             callback:(TTNetworkJSONFinishBlock)callback; __deprecated_msg("请使用新版API");

@end
