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
    [dataArr writeToFile:[self localDataPathWithType:errorHubType] atomically:YES];
}

- (NSArray *)loadDataFromLocalDataWithType:(FHErrorHubType)errorHubType {
    NSArray *readArr=[[NSArray alloc]initWithContentsOfFile:[self localDataPathWithType:errorHubType]];
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
            
        default:
            break;
    }
    
    ;
    return strFinalPath;
}




@end
