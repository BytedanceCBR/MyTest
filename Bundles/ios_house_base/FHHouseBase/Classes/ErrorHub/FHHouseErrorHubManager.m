//
//  FHHouseErrorHubManager.m
//  FHHouseBase
//
//  Created by liuyu on 2020/4/8.
//

#import "FHHouseErrorHubManager.h"
#import "FHHouseErrorHubView.h"

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

- (void)checkRequestResponseWithHost:(NSString *)host requestParams:(id)params responseStatus:(TTHttpResponse *)responseStatus response:(id)response analysisError:(NSError *)analysisError changeModelType:(FHNetworkMonitorType )type errorHubType:(FHErrorHubType)errorHubType {
    NSInteger responseCode = -1;
    if (responseStatus.statusCode) {
        responseCode = responseStatus.statusCode;
    }
    NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:response
                                                                       options:NSJSONReadingAllowFragments
                                                                         error:nil];
    NSDictionary *responseStatusDic = [[NSDictionary alloc]initWithDictionary:responseStatus.allHeaderFields];
    if ( type !=FHNetworkMonitorTypeSuccess) {
        NSMutableDictionary *outputDic = [[NSMutableDictionary alloc]init];
        [outputDic setValue:host forKey:@"HOST"];
        [outputDic setValue:responseDictionary forKey:@"response"];
        [outputDic setValue:params forKey:@"params"];
        [outputDic setValue:responseStatusDic forKey:@"httpStatus"];
        [outputDic setValue:analysisError forKey:@"analysisError"];
        [self addLogWithData:outputDic logType:errorHubType];
        dispatch_async(dispatch_get_main_queue(), ^{
            [FHHouseErrorHubView showErrorHubViewWithTitle:@"核心接口异常" content:[NSString stringWithFormat:@"HOST:%@",host]];
        });
    }
}
//保存数据
- (void)addLogWithData:(id)Data logType:(FHErrorHubType)errorHubType {
    NSMutableArray *dataArr;
    if ([self loadDataFromLocalDataWithType:errorHubType].count>0) {
        dataArr = [[self loadDataFromLocalDataWithType:errorHubType] mutableCopy];
    }else {
        dataArr = [[NSMutableArray alloc]init];
    }
    if (dataArr.count>9) {
        [dataArr replaceObjectAtIndex:0 withObject:Data];
    }else {
        [dataArr addObject:Data];
    }
    NSDictionary *hostError = @{@"host_error":dataArr};
    [hostError writeToFile:[self localDataPathWithType:errorHubType] atomically:YES];
}

- (NSArray *)loadDataFromLocalDataWithType:(FHErrorHubType)errorHubType {
    NSDictionary *data = [[NSDictionary alloc]initWithContentsOfFile:[self localDataPathWithType:errorHubType]];
    NSArray *readArr = [data objectForKey:[[data allKeys] firstObject]];
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
    [errorSaveDic setValue:eventName forKey:@"event"];
    [eventArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = obj;
        if ([[dic objectForKey:@"event"] isEqualToString:eventName]) {
            NSArray *params = dic[@"params"];
            [params enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *paramItem = obj;
                if ([paramItem[@"type"] isEqualToString:@"mandatory"]) {
                    NSString *checkKey = paramItem[@"param_name"];
                    NSString *checkValue = eventParams[checkKey];
                    NSArray *rangeArr = paramItem[@"rang"];
                    NSString *level = paramItem[@"error_level"];
                    if (checkValue.length<1) {
                        [errorSaveDic setValue:[NSString stringWithFormat:@"埋点关键字段%@为空",checkKey] forKey:@"error"];
                    }else {
                        if (![rangeArr containsObject:checkValue]) {
                            [errorSaveDic setValue:[NSString stringWithFormat:@"埋点关键字段%@取值范围错误",checkKey] forKey:@"error"];
                        }
                    }
                    NSString *errStr = errorSaveDic[@"error"] ;
                    if (errStr.length>0) {
                        if ([level isEqualToString:@"critical"]) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [FHHouseErrorHubView showErrorHubViewWithTitle:@"埋点异常" content:[NSString stringWithFormat:@"event_name:%@",eventName]];
                            });
                        }
                        [self addLogWithData:errorSaveDic logType:errorHubType];
                    }
                }
            }];
        }
    }];
    NSLog(@"%@",eventArr);
    
}

- (NSArray *)localCheckBuryingPointData {
    NSError *error;
    NSDictionary *dataDict = [NSDictionary dictionaryWithContentsOfURL:[[NSBundle mainBundle] pathForResource:@"buryingPointCheck"ofType:@"plist"] error:&error];
    return dataDict[@"data"];
}
@end
