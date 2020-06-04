//
//  FHErrorHubSettingsHub.m
//  FHHouseBase
//
//  Created by liuyu on 2020/5/9.
//

#import "FHErrorHubSettingsHub.h"
#import "FHHouseErrorHubManager.h"
#import "FHErrorHubDataReadWrite.h"
@implementation FHErrorHubSettingsHub

+ (void)load {
    [[FHHouseErrorHubManager sharedInstance] registerFHErrorHubProcotolClass:self];
}

- (NSDictionary *)returunAbnormalReportData {
     NSDictionary *dictSetting  = [self fhSettings];
    dictSetting = [FHErrorHubDataReadWrite  removeNillValue:dictSetting];
    return @{@"settings_data":dictSetting?dictSetting:@{}};
}

- (NSDictionary *)fhSettings {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"kFHSettingsKey"]){
        return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kFHSettingsKey"];
    } else {
        return nil;
    }
}

- (NSString *)associatedKey {
    return @"settings";
}

@end
