//
//  FHHouseErrorHubManager.m
//  FHHouseBase
//
//  Created by liuyu on 2020/4/8.
//

#import "FHHouseErrorHubManager.h"
#import "FHHouseErrorHubView.h"
#import "FHEnvContext.h"
#import "HMDTTMonitor.h"



@implementation FHHouseErrorHubManager
+(instancetype)sharedInstance
{
    static FHHouseErrorHubManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FHHouseErrorHubManager alloc]init];
    });
    return manager;
}

- (void)checkRequestResponseWithHost:(NSString *)host requestParams:(NSDictionary *)params responseStatus:(TTHttpResponse *)responseStatus response:(id)response analysisError:(NSError *)analysisError changeModelType:(FHNetworkMonitorType )type errorHubType:(FHErrorHubType)errorHubType {
    //    NSInteger responseCode = -1;
    //    if (responseStatus.statusCode) {
    //        responseCode = responseStatus.statusCode;
    //    }
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:response
                                                                       options:NSJSONReadingAllowFragments
                                                                         error:nil];
    NSDictionary *responseStatusDic = [[NSDictionary alloc]initWithDictionary:responseStatus.allHeaderFields];
    if ( type !=FHNetworkMonitorTypeSuccess) {
        NSMutableDictionary *outputDic = [[NSMutableDictionary alloc]init];
        [outputDic setValue:host forKey:@"name"];
        [outputDic setValue:[self removeNillValue:responseDictionary] forKey:@"response"];
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
        [outputDic setValue:[self getCurrentTimes] forKey:@"currentTime"];
        FHConfigDataModel *configDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
        NSDictionary *dictSetting  = [self fhSettings];
        [outputDic setValue: [self removeNillValue:[configDataModel toDictionary]] forKey:@"config_data"];
        [outputDic setValue:[self removeNillValue:dictSetting] forKey:@"settings_data"];
        [self addLogWithData:outputDic logType:errorHubType];
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
            [[HMDTTMonitor defaultManager] hmdTrackService:@"slardar_local_test_err" metric:nil category:@{@"status" : @(1)} extra:extra];
    }
    
}
//保存数据
- (void)addLogWithData:(id)Data logType:(FHErrorHubType)errorHubType {
    NSMutableArray *dataArr = [self loadDataFromLocalDataWithType:errorHubType].mutableCopy;
    NSString *keyStr;
    switch (errorHubType) {
        case FHErrorHubTypeRequest:
            if (dataArr.count>9) {
                [dataArr removeObjectAtIndex:0];
                [dataArr addObject:Data];
            }else {
                [dataArr addObject:Data];
            }
            keyStr = @"host_error";
            break;
        case FHErrorHubTypeBuryingPoint:
            [dataArr addObject:Data];
            keyStr = @"buryingpoint_error";
            break;
        case FHErrorHubTypeConfig:
            [dataArr addObject:Data];
            keyStr = @"coonfig_settings";
            break;
        case FHErrorHubTypeShare:
            [dataArr removeAllObjects];
            [dataArr addObject:Data];
            keyStr = @"error_share";
            break;
            
        default:
            break;
    }
    NSDictionary *errorInfo = @{keyStr:dataArr};
    NSData *errordata = [NSJSONSerialization dataWithJSONObject:errorInfo options:0 error:NULL];
    [errordata writeToFile:[self localDataPathWithType:errorHubType] atomically:YES];
}

- (NSArray *)loadDataFromLocalDataWithType:(FHErrorHubType)errorHubType {
    NSData *data = [NSData dataWithContentsOfFile:[self localDataPathWithType:errorHubType]];
    if (!data) {
        return @[];
    }
    NSDictionary *dictFromData = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:NULL];
    NSArray *readArr = dictFromData[[dictFromData allKeys].firstObject];
    return readArr;
}

- (NSString *)localDataPathWithType:(FHErrorHubType)errorHubType {
    NSArray *pathArr=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *strPath=[pathArr lastObject];
    NSString *strFinalPath;
    switch (errorHubType) {
        case FHErrorHubTypeRequest:
            strFinalPath = [NSString stringWithFormat:@"%@/requestErrorHub.plist",strPath];
            break;
        case FHErrorHubTypeBuryingPoint:
            strFinalPath = [NSString stringWithFormat:@"%@/buryingPointError.plist",strPath];
            break;
        case FHErrorHubTypeConfig:
            strFinalPath = [NSString stringWithFormat:@"%@/configSettingsError.plist",strPath];
            break;
        case FHErrorHubTypeShare:
            strFinalPath = [NSString stringWithFormat:@"%@/errorShare.plist",strPath];
            break;
        default:
            break;
    }
    ;
    return strFinalPath;
}

- (void)checkBuryingPointWithEvent:(NSString *)eventName Params:(NSDictionary* )eventParams errorHubType:(FHErrorHubType)errorHubType {
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
                if ([paramItem[@"type"] isEqualToString:@"mandatory"]) {
                    NSString *checkKey = paramItem[@"param_name"]?:@"";
                    NSString *checkValue = [NSString stringWithFormat:@"%@",eventParams[checkKey]?:@""];
                    NSArray *rangeArr = paramItem[@"range"]?:@[];
                    NSString *level = paramItem[@"error_level"]?:@"";
                    if (checkValue.length<1) {
                        [errorSaveDic setValue:[NSString stringWithFormat:@"埋点关键字段%@为空",checkKey] forKey:@"error_info"];
                    }else {
                        if (![rangeArr containsObject:checkValue]) {
                            [errorSaveDic setValue:[NSString stringWithFormat:@"埋点关键字段%@取值范围错误",checkKey] forKey:@"error_info"];
                        }
                    }
                    NSString *errStr = errorSaveDic[@"error"] ;
                    if (errStr.length>0) {
                        if ([level isEqualToString:@"critical"]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [FHHouseErrorHubView showErrorHubViewWithTitle:@"埋点异常" content:[NSString stringWithFormat:@"event_name:%@",eventName]];
                            });
                        }
                        FHConfigDataModel *configDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
                        NSDictionary *dictSetting  = [self fhSettings];
                        [errorSaveDic setValue:[configDataModel toDictionary] forKey:@"config_data"];
                        [errorSaveDic setValue:dictSetting forKey:@"settings_data"];
                        [errorSaveDic setValue:[self getCurrentTimes] forKey:@"currentTime"];
                        [self addLogWithData:errorSaveDic logType:errorHubType];
                        //添加埋点监控
                        NSMutableDictionary *extra = @{}.mutableCopy;
                        [extra setValue:@"buryingPoint" forKey:@"errorHubType"];
                        [extra setValue:eventName forKey:@"eventName"];
                        [extra setValue:errorSaveDic[@"error_info"] forKey:@"error_info"];
                        [extra setValue:[self getCurrentTimes] forKey:@"currentTime"];
                        [[HMDTTMonitor defaultManager] hmdTrackService:@"slardar_local_test_err" metric:nil category:@{@"status" : @(0)} extra:extra];
                    }
                }
            }];
        }
    }];
    NSLog(@"%@",eventArr);
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

- (NSArray *)getLocalErrorDataWithType:(FHErrorHubType)errorHubType {
    return  [self loadDataFromLocalDataWithType:errorHubType];
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

- (void)saveConfigAndSettings {
    NSMutableDictionary *outputDic = [[NSMutableDictionary alloc]init];
    FHConfigDataModel *configDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    NSDictionary *dictSetting  = [self fhSettings];
    [outputDic setValue: [self removeNillValue:[configDataModel toDictionary]] forKey:@"config_data"];
    [outputDic setValue:[self removeNillValue:dictSetting] forKey:@"settings_data"];
    [self addLogWithData:outputDic logType:FHErrorHubTypeConfig];
}
@end
