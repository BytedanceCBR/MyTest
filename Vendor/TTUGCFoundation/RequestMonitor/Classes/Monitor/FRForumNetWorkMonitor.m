//
//  FRForumNetWorkMonitor.m
//  Pods
//
//  Created by ranny_90 on 2017/10/19.
//

#import "FRForumNetWorkMonitor.h"
#import "FRResponseError.h"
#import "FRForumMonitorModel.h"
#import "TTBaseMacro.h"

static NSMutableDictionary<NSString *, id> *_FRForumNetWorkMonitorDictionary;

void ConfigureNetWorkMonitor(NSString *monitorService, id className){
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _FRForumNetWorkMonitorDictionary = [NSMutableDictionary new];
    });
    
    if (!className || !monitorService) {
        return;
    }
    
    NSString *classFullName = NSStringFromClass(className);
    
    if (isEmptyString(classFullName)) {
        return;
    }
    if([_FRForumNetWorkMonitorDictionary objectForKey:classFullName]){
        return;
    }
    
    [_FRForumNetWorkMonitorDictionary setValue:monitorService forKey:classFullName];
}

@interface FRForumNetWorkMonitor()

@end

@implementation FRForumNetWorkMonitor

+ (instancetype)sharedInstance {
    static FRForumNetWorkMonitor* s_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[FRForumNetWorkMonitor alloc] init];
    });
    return s_instance;
}

- (NSString *)getMonitorServiceForClassName:(NSString *)className{
    
    if (!_FRForumNetWorkMonitorDictionary || !className) {
        return nil;
    }
    
    NSString *monitorService = [_FRForumNetWorkMonitorDictionary objectForKey:className];
        
    return monitorService;
}

- (FRForumMonitorModel *)monitorNetWorkErrorWithRequestModel:(TTRequestModel *)requestModel WithError:(NSError *)error{
    
    if (!requestModel) {
        return nil;
    }
    
    NSString *requstClassName = NSStringFromClass([requestModel class]);
    NSString *monitorService  = [self getMonitorServiceForClassName:requstClassName];
    
    FRForumMonitorModel *monitorModel = [[FRForumMonitorModel alloc] init];
    monitorModel.monitorStatus = [self monitorStatusWithNetError:error];
    monitorModel.monitorService = monitorService;
    
    return monitorModel;
}

- (NSUInteger)monitorStatusWithNetError:(NSError *)error{
    
    NSInteger monitorStatus = kTTNetworkMonitorStatusNone;
    
    if (error) {
        kTTNetworkErrorDomainType domainType = [FRResponseError responseErrorDomain:error];
        
        if (domainType == kTTNetworkErrorNetWorkDomainType) {
            monitorStatus = kTTNetworkMonitorStatusCronetError;
        }
        else if (domainType == kTTNetworkErrorSeverJsonDomainType){
            monitorStatus = kTTNetworkMonitorStatusServerJsonError;
        }
        else if (domainType == kTTNetworkErrorSeverDataDomainType){
            monitorStatus = kTTNetworkMonitorStatusSeverDataError;
        }
        else if (domainType == kTTNetWorkErrorJsonModelParseType){
            monitorStatus = kTTNetworkMonitorStatusJsonModelParseError;
        }
        else if (domainType == kTTNetworkErrorOtherDomainType){
            monitorStatus = kTTNetworkMonitorStatusOtherError;
        }
    }
    else {
        monitorStatus = kTTNetworkMonitorStatusSucess;
    }
    return monitorStatus;
}

@end
