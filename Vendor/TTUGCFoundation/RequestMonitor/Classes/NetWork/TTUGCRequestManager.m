//
//  TTUGCRequestManager.m
//  Article
//
//  Created by SongChai on 2017/8/9.
//

#import "TTUGCRequestManager.h"
#import "TTUGCNetworkMonitor.h"
#import "TTBaseMacro.h"
#import <Heimdallr/HMDTTMonitor.h>

@implementation TTUGCRequestManager

+ (TTHttpTask *)requestModel:(TTRequestModel *)model
                    callback:(TTNetworkResponseModelFinishBlock)callback {
    TTUGCMonitorNetworkModelFinishBlock callbackWrap;
    if (callback) {
        callbackWrap = ^(NSError *error, id<TTResponseModelProtocol> responseModel, TTUGCRequestMonitorModel *monitorModel){
            callback(error,responseModel);
        };
    }
    
    return [self requestModel:model callBackWithMonitor:callbackWrap];
}

+ (TTHttpTask *)requestModel:(TTRequestModel *)model callBackWithMonitor:(TTUGCMonitorNetworkModelFinishBlock)callback {

    NSTimeInterval start = CFAbsoluteTimeGetCurrent();
    TTNetworkResponseModelFinishBlock callbackWrap = ^(NSError *error, NSObject<TTResponseModelProtocol> * responseModel){
        NSTimeInterval cost = (CFAbsoluteTimeGetCurrent() - start) * 1000;
        //第一步，将网路库的错误映射成新错误，主要用户细化识别业务错误和json model错误
        error = [TTUGCResponseError mapResponseError:error];
        //第二步，根据预先配置的需要自动化监控的配置表，生成自动化监控值。如果没有配置，monitorService返回nil
        TTUGCRequestMonitorModel *monitorModel = [[TTUGCNetworkMonitor sharedInstance] monitorNetWorkErrorWithRequestModel:model WithError:error];
        //第三步，将monitorModel抛回给业务方，业务方可以根据情况进行修改和自定义
        if (callback) {
            callback(error,responseModel,monitorModel);
        }
        //上报
        if (!isEmptyString(monitorModel.monitorService) && monitorModel.enableMonitor) {
            monitorModel.cost = cost;
            [[HMDTTMonitor defaultManager] hmdTrackService:monitorModel.monitorService
                                                    metric:monitorModel.metric
                                                  category:[monitorModel categoryContainsMonitorStatus]
                                                     extra:monitorModel.monitorExtra];
        }
    };
    
    return [[TTNetworkManager shareInstance] requestModel:model callback:callbackWrap];
}

+ (TTHttpTask *)requestForJSONWithURL:(NSString *)URL params:(id)params method:(NSString *)method needCommonParams:(BOOL)commonParams callback:(TTNetworkJSONFinishBlockWithResponse)callback {
    TTNetworkJSONFinishBlockWithResponse callbackWrap;
    if (callback) {
        callbackWrap = ^(NSError *error, id jsonObj,TTHttpResponse *response){
            callback(error, jsonObj,response);
        };
    }

    return [self requestForJSONWithURL:URL params:params method:method needCommonParams:commonParams callBackWithMonitor:callbackWrap];
}

+ (TTHttpTask *)requestForJSONWithURL:(NSString *)URL params:(id)params method:(NSString *)method needCommonParams:(BOOL)commonParams callBackWithMonitor:(TTNetworkJSONFinishBlockWithResponse)callback {
    NSTimeInterval start = CFAbsoluteTimeGetCurrent();
    TTNetworkJSONFinishBlockWithResponse callbackWrap = ^(NSError *error, id jsonObj,TTHttpResponse *response){
        NSTimeInterval cost = (CFAbsoluteTimeGetCurrent() - start) * 1000;
        error = [TTUGCResponseError mapResponseError:error];
        TTUGCRequestMonitorModel *monitorModel = [[TTUGCNetworkMonitor sharedInstance] monitorNetWorkErrorWithURL:URL WithError:error];
        if (callback) {
            callback(error, jsonObj, response);
        }
        if (!isEmptyString(monitorModel.monitorService) && monitorModel.enableMonitor) {
            monitorModel.cost = cost;
            [[HMDTTMonitor defaultManager] hmdTrackService:monitorModel.monitorService
                                                    metric:monitorModel.metric
                                                  category:[monitorModel categoryContainsMonitorStatus]
                                                     extra:monitorModel.monitorExtra];
        }
    };

    return [[TTNetworkManager shareInstance] requestForJSONWithResponse:URL params:params method:method needCommonParams:commonParams callback:callbackWrap];
}

@end
