//
//  SSADFetchInfoManager.m
//  Article
//
//  Created by Zhang Leonardo on 12-11-13.
//
//

#import "CommonURLSetting.h"
#import "SSADFetchInfoManager.h"
#import "SSADManager.h"
#import "SSADModel.h"
#import <TTAdModule/TTAdMonitorManager.h>
#import <TTBaseLib/NetworkUtilities.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTNetworkManager/TTNetworkManager.h>
#import <TTMonitor/TTExtensions.h>
#import "TTSettingsManager.h"

#if 0
#define DLog(...) NSLog(__VA_ARGS__)
#else
#define DLog(...)
#endif

@implementation SSADFetchInfoManager

+ (instancetype)shareInstance {
    static SSADFetchInfoManager * infoManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        infoManager = [[SSADFetchInfoManager alloc] init];
    });
    return infoManager;
}

- (void)startFetchADInfoWithExtraParameters:(NSDictionary *)extra {
    if (!TTNetworkConnected()) {
        return;
    }
     
    NSString * url = [CommonURLSetting appADURLString];
    NSMutableDictionary *parameterDict = [NSMutableDictionary dictionary];
    [parameterDict addEntriesFromDictionary:extra];
    NSString *carrierName = [TTExtensions carrierName];
    [parameterDict setValue:carrierName forKey:@"carrier"];
    
    __weak typeof(self) weakSelf = self;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:parameterDict method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        __strong typeof(weakSelf) self = weakSelf;
        
        if ([[[TTSettingsManager sharedManager] settingForKey:@"tt_optimize_start_enabled" defaultValue:@1 freeze:YES] boolValue]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self process:jsonObj error:error];
            });
        }else{
            [self process:jsonObj error:error];
        }
  
    }];
}

- (void)process:(NSDictionary*)result error:(NSError*)error {
    if (error == nil) {
        //LOGD(@">>>拿到广告接口数据\n %@", tt_dictionaryValueForKey:@"data"]);
        NSDictionary *data = [result tt_dictionaryValueForKey:@"data"];
        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
            
        void(^adjustModel)(SSADModel*, NSTimeInterval) = ^(SSADModel *model, NSTimeInterval currentTimestamp) {
            model.adModelType = SSADModelTypeSplash;
            model.requestTimeInterval = currentTimestamp;
            model.displayTime = model.displayTime / 1000;
            model.maxDisplayTime = model.maxDisplayTime / 1000;
            model.maxDisplayTime = MAX(model.maxDisplayTime, model.displayTime);
            if (SSIsEmptyArray(model.splashTrackURLStrings)) {
                if (!isEmptyString(model.splashTrackURLStr)) {
                    model.splashTrackURLStrings = @[model.splashTrackURLStr];
                }
            }
                
            if (SSIsEmptyArray(model.splashClickTrackURLStrings)) {
                if (!isEmptyString(model.splashClickTrackURLString)) {
                    model.splashClickTrackURLStrings = @[model.splashClickTrackURLString];
                }
            }
                
            if (!model.predownload) {
                model.predownload = @(TTNetworkFlagWifi);
            }
                
            if (!model.displaySkipButton) {
                model.displaySkipButton = @(YES);
            }
                
            if (!model.displayViewButton) {
                model.displayViewButton = @(1);
            }
            model.videoMute = !model.videoMute; // "voice_switch": false 表示静音。
        };
        
        NSArray *splashInfos = [data tt_arrayValueForKey:@"splash"];
        NSMutableArray * splashModels = [NSMutableArray arrayWithCapacity:splashInfos.count];
            
            for (int i = 0; i < splashInfos.count; i ++) {
            NSDictionary * dict = splashInfos[i];
            NSError *error;
            SSADModel * model = [[SSADModel  alloc] initWithDictionary:dict error:&error];
            if (error || !model) {
                DLog(error.localizedDescription);
                [self moniter_trackService:2 error:error];
            } else {
                if (model.intervalCreatives) {
                    [model.intervalCreatives enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj isKindOfClass:[SSADModel class]]) {
                            adjustModel(obj, currentTime);
                        } else {
                            LOGE(@"解析出错");
                            [self moniter_trackService:3 error:error];
                        }
                    }];
                }
                adjustModel(model, currentTime);
                [splashModels addObject:model];
            }
        }
        [[SSADManager shareInstance] updateADControlInfoForSplashModels:splashModels];
        DLog(@"AD>>>>> fetch models : %zd", splashModels.count);
    } else {
        [self moniter_trackService:0 error:error];
    }
}

- (void)moniter_trackService:(NSInteger)status error:(NSError *)error {
    [TTAdMonitorManager trackService:@"ad_splash_error" status:status extra:error.userInfo];
}

@end
