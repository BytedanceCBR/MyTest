//
//  FHErrorHubDataReadWrite.m
//  FHHouseBase
//
//  Created by liuyu on 2020/5/9.
//

#import "FHErrorHubDataReadWrite.h"

@implementation FHErrorHubDataReadWrite

+ (NSDictionary *)removeNillValue:(NSDictionary *)inputDic {
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

//保存数据
+ (void)addLogWithData:(id)Data logType:(FHErrorHubType)errorHubType {
    NSMutableArray *dataArr = [self loadDataFromLocalDataWithType:errorHubType].mutableCopy;
    switch (errorHubType) {
        case FHErrorHubTypeRequest:
            if (dataArr.count>9) {
                [dataArr removeObjectAtIndex:0];
                [dataArr addObject:Data];
            }else {
                [dataArr addObject:Data];
            }
            break;
        case FHErrorHubTypeBuryingPoint:
            [dataArr addObject:Data];
            break;
        case FHErrorHubTypeConfig:
            [dataArr addObject:Data];
            break;
        case FHErrorHubTypeShare:
            [dataArr removeAllObjects];
            [dataArr addObject:Data];
            break;
        case FHErrorHubTypeCustom:
            [dataArr addObject:Data];
            break;
            break;
    }
    NSDictionary *errorInfo = @{@"error_hub":dataArr};
    NSData *errordata = [NSJSONSerialization dataWithJSONObject:errorInfo options:0 error:NULL];
    [errordata writeToFile:[self localDataPathWithType:errorHubType] atomically:YES];
}

//通过类型读取数据
+ (NSArray *)loadDataFromLocalDataWithType:(FHErrorHubType)errorHubType {
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

+ (NSString *)localDataPathWithType:(FHErrorHubType)errorHubType {
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
        case FHErrorHubTypeCustom:
            strFinalPath = [NSString stringWithFormat:@"%@/errorCustom.plist",strPath];
            break;
        default:
            break;
    }
    ;
    return strFinalPath;
}

+ (NSArray *)getLocalErrorDataWithType:(FHErrorHubType)errorHubType {
    return  [self loadDataFromLocalDataWithType:errorHubType];
}

+ (void)removeLogWithData:(NSDictionary *)data logType:(FHErrorHubType)errorHubType {
    NSMutableArray  *dataArr = [self loadDataFromLocalDataWithType:errorHubType].mutableCopy;
    [dataArr removeObject:data];
    NSDictionary *errorInfo = @{@"error_hub":dataArr};
    NSData *errordata = [NSJSONSerialization dataWithJSONObject:errorInfo options:0 error:NULL];
    [errordata writeToFile:[self localDataPathWithType:errorHubType] atomically:YES];
}

@end
