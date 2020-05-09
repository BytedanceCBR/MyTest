//
//  FHHouseErrorHubManager.m
//  FHHouseBase
//
//  Created by liuyu on 2020/4/8.
//

#import "FHHouseErrorHubManager.h"
#import "FHHouseErrorHubView.h"
#import "FHErrorHubMonitor.h"
#import "TTSandBoxHelper.h"
#import "FHErrorHubProcotol.h"
#import "FHErrorHubSenceKeys.h"
@interface FHHouseErrorHubManager()
@property (strong, nonatomic) NSMutableArray *procotalClassArr;
@end
@implementation FHHouseErrorHubManager

+ (instancetype)sharedInstance
{
    static FHHouseErrorHubManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FHHouseErrorHubManager alloc]init];
    });
    return manager;
}

- (NSMutableArray *)procotalClassArr {
    if (!_procotalClassArr) {
        NSMutableArray *procotalClassArr = [[NSMutableArray alloc]init];
        _procotalClassArr = procotalClassArr;
    }
    return _procotalClassArr;
}

- (void)registerFHErrorHubProcotolClass:(Class)cls {
    [self.procotalClassArr addObject:cls];
}

- (void)checkRequestResponseWithHost:(NSString *)host requestParams:(NSDictionary *)params responseStatus:(TTHttpResponse *)responseStatus response:(id)response analysisError:(NSError *)analysisError changeModelType:(FHNetworkMonitorType )type errorHubType:(FHErrorHubType)errorHubType {
    if (![[self getChannel] isEqualToString:@"local_test"] || ![self errorHubSwitch]) {
        return;
    }
    NSInteger status = -1;
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:response
                                                                       options:NSJSONReadingAllowFragments
                                                                         error:nil];
    if ([responseDictionary.allKeys containsObject:@"status"]) {
        status = [NSString stringWithFormat:@"%@",responseDictionary[@"status"]].integerValue;
    }
    if ( type !=FHNetworkMonitorTypeSuccess || status != 0) {
        NSDictionary *responseStatusDic = [[NSDictionary alloc]initWithDictionary:responseStatus.allHeaderFields];
        NSMutableDictionary *outputDic = [[NSMutableDictionary alloc]init];
        [outputDic setValue:host forKey:@"name"];
        [outputDic setValue:[self removeNillValue:responseDictionary] forKey:@"response"];
        [outputDic setValue:[self removeNillValue:params] forKey:@"params"];
        [outputDic setValue:[self removeNillValue:params] forKey:@"params"];
        [outputDic setValue:[self removeNillValue:responseStatusDic] forKey:@"httpStatus"];
        [outputDic setValue:[NSString stringWithFormat:@"%@",@(type)] forKey:@"error_info"];
        if (analysisError) {
            [outputDic setValue:@{@"error_code":@(analysisError.code),
                                  @"error_domain":analysisError.domain,
                                  @"error_info":analysisError.userInfo}  forKey:@"analysisError"];
        }else {
            [outputDic setValue:@"-1" forKey:@"analysisError"];
        }
        [outputDic addEntriesFromDictionary:[self returnSenceDicWithSenceArr:[FHErrorHubSenceKeys returnSenceNameArrFromEventName:@"request"]]];
        [outputDic setValue:[self getCurrentTimes] forKey:@"currentTime"];
        [FHErrorHubDataReadWrite addLogWithData:outputDic logType:errorHubType];
        dispatch_async(dispatch_get_main_queue(), ^{
            [FHHouseErrorHubView showErrorHubViewWithTitle:@"核心接口异常" content:[NSString stringWithFormat:@"HOST:%@",host]];
        });
        //添加请求监控
        NSMutableDictionary *extra = @{}.mutableCopy;
        [extra setValue:@"request" forKey:@"errorHubType"];
        [extra setValue:host forKey:@"eventName"];
        [extra setValue:@(type) forKey:@"errorHubType"];
        [extra setValue:[self getCurrentTimes] forKey:@"currentTime"];
        [extra setValue:[[self removeNillValue:responseStatusDic]objectForKey:@"x-tt-logid"] forKey:@"logID"];
        [FHErrorHubMonitor errorErrorReportingMessage:@"接口错误" extr:extra];
    }
}

- (void)checkBuryingPointWithEvent:(NSString *)eventName Params:(NSDictionary* )eventParams errorHubType:(FHErrorHubType)errorHubType {
    if (![[self getChannel] isEqualToString:@"local_test"] || ![self errorHubSwitch]) {
        return;
    }        dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *eventArr = [self localCheckBuryingPointData];
        NSMutableDictionary *errorSaveDic = [[NSMutableDictionary alloc]init];
        [errorSaveDic setValue:eventParams forKey:@"parmas"];
        [errorSaveDic setValue:eventName forKey:@"name"];
        [eventArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *dic = obj;
            if ([[dic objectForKey:@"event"] isEqualToString:eventName]) {
                NSArray *params = dic[@"params"];
                [params enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSDictionary *paramItem = obj;
                    NSString *checkValue = @"";
                    NSString *checkKey = paramItem[@"param_name"]?:@"";
                    if ([eventParams.allKeys containsObject:checkKey]) {
                        checkValue =  [NSString stringWithFormat:@"%@",eventParams[checkKey]?:@""];
                    }
                    NSArray *rangeArr = paramItem[@"range"]?:@[];
                    NSString *level = paramItem[@"error_level"]?:@"";
                    if ([paramItem[@"type"] isEqualToString:@"mandatory"]) {
                        if (checkValue.length<1) {
                            [errorSaveDic setValue:[NSString stringWithFormat:@"埋点关键字段%@为空",checkKey] forKey:@"error_info"];
                        }else {
                            if (![rangeArr containsObject:checkValue]) {
                                [errorSaveDic setValue:[NSString stringWithFormat:@"埋点关键字段%@取值范围错误",checkKey] forKey:@"error_info"];
                            }
                        }
                    }else {
                        if (![rangeArr containsObject:checkValue]) {
                            [errorSaveDic setValue:[NSString stringWithFormat:@"埋点关键字段%@取值范围错误",checkKey] forKey:@"error_info"];
                        }
                    }
                    NSString *errStr = errorSaveDic[@"error_info"] ;
                    if (errStr.length>0) {
                        if ([level isEqualToString:@"critical"]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [FHHouseErrorHubView showErrorHubViewWithTitle:@"埋点异常" content:[NSString stringWithFormat:@"event_name:%@ error:%@",eventName,errStr]];
                            });
                        }
                        [errorSaveDic addEntriesFromDictionary:[self returnSenceDicWithSenceArr:[FHErrorHubSenceKeys returnSenceNameArrFromEventName:@"buryingPoint"]]];
                        [errorSaveDic setValue:[self getCurrentTimes] forKey:@"currentTime"];
                        [FHErrorHubDataReadWrite addLogWithData:errorSaveDic logType:errorHubType];
                        //添加埋点监控
                        NSMutableDictionary *extra = @{}.mutableCopy;
                        [extra setValue:@"buryingPoint" forKey:@"errorHubType"];
                        [extra setValue:eventName forKey:@"eventName"];
                        [extra setValue:errorSaveDic[@"error_info"] forKey:@"error_info"];
                        [extra setValue:[self getCurrentTimes] forKey:@"currentTime"];
                        [FHErrorHubMonitor errorErrorReportingMessage:@"埋点错误" extr:extra];
                    }
                }];
            }
        }];
    });
}

- (NSArray *)localCheckBuryingPointData {
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"buryingPointCheck" ofType:@"json"];
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:path];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    return array;
}

- (NSDictionary *)fhSettings {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kFHSettingsKey"]){
        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kFHSettingsKey"];
    } else {
        return nil;
    }
}

- (NSString*)getCurrentTimes{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    NSLog(@"currentTimeString =  %@",currentTimeString);
    return currentTimeString;
}

- (NSDictionary *)removeNillValue:(NSDictionary *)inputDic {
    NSArray *allKeys = inputDic.allKeys;
    NSMutableDictionary *mutabInputDic = inputDic.mutableCopy;
    [allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = obj;
        id dicItem  = mutabInputDic[key];
        if (!dicItem) {
            [mutabInputDic removeObjectForKey:key];
        };
        if ([dicItem isKindOfClass:[NSDictionary class]]) {
            [mutabInputDic setValue:[self removeNillValue:dicItem] forKey:key];
        };
        if ([dicItem isKindOfClass:[NSArray class]]) {
            NSMutableArray *dicItems = [(NSArray *)dicItem mutableCopy];
            [dicItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    [dicItems replaceObjectAtIndex:idx withObject:[self removeNillValue:obj]];
                }
            }];
            [mutabInputDic setValue:dicItems forKey:key];
        }
    }];
    return mutabInputDic;
}

- (void)saveConfigAndSettingsSence {
    if (![[self getChannel] isEqualToString:@"local_test"] || ![self errorHubSwitch]) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *outputDic = [[NSMutableDictionary alloc]init];
        [outputDic addEntriesFromDictionary:[self returnSenceDicWithSenceArr:[FHErrorHubSenceKeys returnSenceNameArrFromEventName:@"config&&settings"]]];
        [FHErrorHubDataReadWrite addLogWithData:outputDic logType:FHErrorHubTypeConfig];
    });
    
}

-(NSString*)getChannel {
    return [TTSandBoxHelper getCurrentChannel];
}

- (NSDictionary *)returnSenceDicWithSenceArr:(NSArray *)senceArr {
    NSMutableDictionary *outputDic = [[NSMutableDictionary alloc]init];
    [_procotalClassArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id <FHeErrorHubProtocol> associatedSence = [[obj alloc]init];
        if ([associatedSence respondsToSelector:@selector(returunAbnormalReportData)]) {
            if ([associatedSence respondsToSelector:@selector(associatedKey)]) {
                NSString *associatedKey = [associatedSence associatedKey];
                if ([senceArr containsObject:associatedKey]) {
                    NSDictionary *dic = [associatedSence returunAbnormalReportData];
                    [outputDic addEntriesFromDictionary:dic];
                }
            }
        }
    }];
    return outputDic;
}
- (void)saveCustomerData:(id)data WithEventName:(NSString *)eventName errorMessage:(nonnull NSString *)errorInfo extr:(nonnull NSDictionary *)extr {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *outputDic = [[NSMutableDictionary alloc]init];
        [outputDic addEntriesFromDictionary:[self returnSenceDicWithSenceArr:[FHErrorHubSenceKeys returnSenceNameArrFromEventName:eventName]]];    [outputDic addEntriesFromDictionary:data];
        [FHErrorHubDataReadWrite addLogWithData:outputDic logType:FHErrorHubTypeCustom];
        [FHErrorHubMonitor errorErrorReportingMessage:errorInfo extr:extr];
    });
}

- (BOOL)errorHubSwitch {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"_errorHubSwitch"];
}

@end
