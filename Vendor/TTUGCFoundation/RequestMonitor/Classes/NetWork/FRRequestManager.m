//
//  FRRequestManager.m
//  Article
//
//  Created by SongChai on 2017/8/9.
//

#import "FRRequestManager.h"
#import "TTMonitorConfiguration.h"
#import "FRForumNetWorkMonitor.h"
#import "TTBaseMacro.h"


@implementation FRRequestManager

+ (TTHttpTask *)requestModel:(TTRequestModel *)model
                    callback:(TTNetworkResponseModelFinishBlock)callback {
    FRMonitorNetworkModelFinishBlock callbackWrap;
    if (callback) {
        callbackWrap = ^(NSError *error, id<TTResponseModelProtocol> responseModel, FRForumMonitorModel *monitorModel){
            callback(error,responseModel);
        };
    }
    
    return [self requestModel:model callBackWithMonitor:callbackWrap];
}

+ (TTHttpTask *)requestModel:(TTRequestModel *)model callBackWithMonitor:(FRMonitorNetworkModelFinishBlock)callback {
    
    TTNetworkResponseModelFinishBlock callbackWrap = ^(NSError *error, NSObject<TTResponseModelProtocol> * responseModel){
        //第一步，将网路库的错误映射成新错误，主要用户细化识别业务错误和json model错误
        error = [FRResponseError mapResponseError:error];
        //第二步，根据预先配置的需要自动化监控的配置表，生成自动化监控值。如果没有配置，monitorService返回nil
        FRForumMonitorModel *monitorModel = [[FRForumNetWorkMonitor sharedInstance] monitorNetWorkErrorWithRequestModel:model WithError:error];
        //第三步，将monitorModel抛回给业务方，业务方可以根据情况进行修改和自定义
        if (callback) {
            callback(error,responseModel,monitorModel);
        }
        //上报
        if (!isEmptyString(monitorModel.monitorService)) {
            [[TTMonitor shareManager] trackService:monitorModel.monitorService status:monitorModel.monitorStatus extra:monitorModel.monitorExtra];
        }
    };
    
    return [[TTNetworkManager shareInstance] requestModel:model callback:callbackWrap];
}

+ (TTHttpTask *)requestForJSONWithURL:(NSString *)URL params:(id)params method:(NSString *)method needCommonParams:(BOOL)commonParams callback:(TTNetworkJSONFinishBlock)callback {
    TTNetworkJSONFinishBlock callbackWrap;
    if (callback) {
        callbackWrap = ^(NSError *error, id jsonObj){
            error = [FRResponseError mapResponseError:error];
            callback(error, jsonObj);
        };
    }
    return [[TTNetworkManager shareInstance] requestForJSONWithURL:URL params:params method:method needCommonParams:commonParams callback:callbackWrap];
}


@end
