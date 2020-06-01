//
//  FHErorHubConfigSence.m
//  FHHouseBase
//
//  Created by liuyu on 2020/5/9.
//

#import "FHErorHubConfigSence.h"
#import "FHHouseErrorHubManager.h"
#import "FHEnvContext.h"
#import "FHErrorHubDataReadWrite.h"

@implementation FHErorHubConfigSence

+ (void)load {
    [[FHHouseErrorHubManager sharedInstance] registerFHErrorHubProcotolClass:self];
}

- (NSDictionary *)returunAbnormalReportData {
    FHConfigDataModel *configDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    NSDictionary *configDic = [FHErrorHubDataReadWrite  removeNillValue:[configDataModel toDictionary]];
    return @{@"config_data":configDic?configDic:@{}};
}

- (NSString *)associatedKey {
    return @"config";
}
@end
