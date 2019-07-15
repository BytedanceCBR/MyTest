//
//  TTUGCNetworkMonitor.m
//  Pods
//
//  Created by ranny_90 on 2017/10/19.
//

#import "TTUGCNetworkMonitor.h"
#import "TTUGCResponseError.h"
#import "TTUGCRequestMonitorModel.h"
#import "TTBaseMacro.h"

static NSMutableDictionary<NSString *, id> *_TTUGCNetworkMonitorDictionary;

void ConfigureNetWorkMonitor(NSString *monitorService, id className){
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _TTUGCNetworkMonitorDictionary = [NSMutableDictionary new];
    });
    
    if (!className || !monitorService) {
        return;
    }
    
    NSString *classFullName = NSStringFromClass(className);
    
    if (isEmptyString(classFullName)) {
        return;
    }
    if([_TTUGCNetworkMonitorDictionary objectForKey:classFullName]){
        return;
    }
    
    [_TTUGCNetworkMonitorDictionary setValue:monitorService forKey:classFullName];
}

@interface TTUGCNetworkMonitor()

@end

@implementation TTUGCNetworkMonitor

+ (instancetype)sharedInstance {
    static TTUGCNetworkMonitor* s_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[TTUGCNetworkMonitor alloc] init];
    });
    return s_instance;
}

- (NSString *)getMonitorServiceForClassName:(NSString *)className{
    
    if (!_TTUGCNetworkMonitorDictionary || !className) {
        return nil;
    }
    
    NSString *monitorService = [_TTUGCNetworkMonitorDictionary objectForKey:className];
        
    return monitorService;
}


- (NSString *)getMonitorServiceForURL:(NSString *)urlStr {
    if (isEmptyString(urlStr)) {
        return nil;
    }

    NSURL *url = [NSURL URLWithString:urlStr];
    NSString *path = [url path];

    if (!isEmptyString(path)) {
        NSString *serviceName = [path stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        if ([serviceName hasPrefix:@"_"] && serviceName.length > 0) {
            serviceName = [serviceName substringFromIndex:1];
        }

        return serviceName;
    }

    return nil;
}

- (TTUGCRequestMonitorModel *)monitorNetWorkErrorWithRequestModel:(TTRequestModel *)requestModel WithError:(NSError *)error{
    
    if (!requestModel) {
        return nil;
    }
    
    NSString *requstClassName = NSStringFromClass([requestModel class]);
    NSString *monitorService  = [self getMonitorServiceForClassName:requstClassName];
    
    TTUGCRequestMonitorModel *monitorModel = [[TTUGCRequestMonitorModel alloc] init];
    monitorModel.monitorStatus = [self monitorStatusWithNetError:error];
    monitorModel.monitorService = monitorService;
    if (isEmptyString(monitorService)) {
        monitorService = [self getMonitorServiceForURL:requestModel._requestURL.absoluteString];
        monitorModel.enableMonitor = NO;
    } else {
        monitorModel.enableMonitor = YES;
    }
    monitorModel.enableMonitor = monitorService;
    
    return monitorModel;
}

- (TTUGCRequestMonitorModel *)monitorNetWorkErrorWithURL:(NSString *)url WithError:(NSError *)error {
    if (isEmptyString(url)) {
        return nil;
    }

    NSString *monitorService  = [self getMonitorServiceForURL:url];

    TTUGCRequestMonitorModel *monitorModel = [[TTUGCRequestMonitorModel alloc] init];
    monitorModel.monitorStatus = [self monitorStatusWithNetError:error];
    monitorModel.monitorService = monitorService;

    return monitorModel;
}

- (NSUInteger)monitorStatusWithNetError:(NSError *)error{
    
    NSInteger monitorStatus = kTTNetworkMonitorStatusNone;
    
    if (error) {
        kTTNetworkErrorDomainType domainType = [TTUGCResponseError responseErrorDomain:error];
        
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
