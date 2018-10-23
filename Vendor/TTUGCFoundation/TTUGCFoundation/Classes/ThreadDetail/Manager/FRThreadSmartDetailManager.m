//
//  FRThreadSmartDetailManager.m
//  Article
//
//  Created by 王霖 on 4/22/16.
//
//

#import "FRThreadSmartDetailManager.h"
#import <TTNetworkManager.h>
//#import "TTLocationManager.h"
#import <TTVersionHelper.h>
#import <YYCache/YYCache.h>
#import "TTKitchenHeader.h"
#import "FRApiModel.h"

@interface FRThreadSmartDetailManager ()

@end

@implementation FRThreadSmartDetailManager

+ (void)requestDetailInfoWithThreadID:(int64_t)threadID userID:(int64_t)userID callback:(void(^ _Nullable)(NSError * _Nullable error, NSObject<TTResponseModelProtocol> * _Nullable responseModel ,FRForumMonitorModel *_Nullable monitorModel))callback
{
    [[self sharedManager] requestDetailInfoWithThreadID:threadID userID:userID callback:callback];
}

+ (instancetype)sharedManager
{
    static FRThreadSmartDetailManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FRThreadSmartDetailManager alloc] init];
    });
    return manager;
}

- (void)requestDetailInfoWithThreadID:(int64_t)threadID userID:(int64_t)userID callback:(void(^)(NSError * _Nullable error, NSObject<TTResponseModelProtocol> * _Nullable responseModel ,FRForumMonitorModel *_Nullable monitorModel))callback {
    FRUgcThreadDetailV2InfoRequestModel * threadInfoRequst = [[FRUgcThreadDetailV2InfoRequestModel alloc] init];
    threadInfoRequst.thread_id = @(threadID);
    
    TTHttpTask *task = [FRRequestManager requestModel:threadInfoRequst callBackWithMonitor:^(NSError *error, NSObject<TTResponseModelProtocol> *responseModel, FRForumMonitorModel *monitorModel) {
        if (callback) {
            callback(error, responseModel,monitorModel);
        }
    }];
    [task setPriority:0.75];
}

@end
