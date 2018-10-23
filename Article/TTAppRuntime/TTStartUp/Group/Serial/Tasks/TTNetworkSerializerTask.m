//
//  TTNetworkSerializerTask.m
//  Article
//
//  Created by fengyadong on 17/1/17.
//
//

#import "TTNetworkSerializerTask.h"
#import "TTNetworkManager.h"
#import "TTDefaultHTTPRequestSerializer.h"
#import "BDTDefaultHTTPRequestSerializer.h"
#import "TTDefaultJSONResponseSerializer.h"
#import "TTDefaultBinaryResponseSerializer.h"
#import "TTDefaultResponseModelResponseSerializer.h"
#import "TTDefaultResponsePreprocessor.h"

#import "TTNetworkUtilities.h"
#import "TTPostDataHttpRequestSerializer.h"
#import "TTRouteSelectionServerConfig.h"
#import "TTHttpsControlManager.h"
#import "TTLocationManager.h"  //add by songlu
#import "TTFingerprintManager.h"
#import "IESAntiSpam.h"
#import <CommonCrypto/CommonCrypto.h>
#import "SSCookieManager.h"
#import "AKTaskSettingHelper.h"
#import "Bubble-Swift.h"

@implementation TTNetworkSerializerTask

- (NSString *)taskIdentifier {
    return @"NetworkSerializer";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    [TTSandBoxHelper setAppDidLaunchThisTime];
    [[self class] settingNetworkSerializerClass];
}

+ (void)settingNetworkSerializerClass {
    //add by songlu
    Monitorblock block = ^(NSDictionary* data, NSString* logType) {
        LOGD(@"%s logType %@", __FUNCTION__, logType);
        [[TTMonitor shareManager] trackData:data logTypeStr:logType];
    };
    [TTNetworkManager setMonitorBlock:block];
    
    GetDomainblock GetDomainblock = ^(NSData* data) {
        NSError *jsonError = nil;
        LOGD(@"%s GetDomainblock is %@", __FUNCTION__, data);
        id jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if ([SSCommonLogic isRefactorGetDomainsEnabled]) {
            [[CommonURLSetting sharedInstance] refactorHandleResult:(NSDictionary *)jsonDict error:jsonError];
        } else {
            [[CommonURLSetting sharedInstance] handleResult_:(NSDictionary *)jsonDict error:jsonError];
        }
    };
//    [TTNetworkManager setGetDomainBlock:GetDomainblock];

    NSString *city = [TTLocationManager sharedManager].city;
    [TTNetworkManager setCityName: city];
    //end by songlu
    
    BOOL isHttpDnsEnabled = [TTRouteSelectionServerConfig sharedTTRouteSelectionServerConfig].isHttpDnsEnabled;
//    isHttpDnsEnabled = YES;//TODO: hard code
    [TTNetworkManager setHttpDnsEnabled:isHttpDnsEnabled];
    
    BOOL isChromiumEnabled = [TTRouteSelectionServerConfig sharedTTRouteSelectionServerConfig].isChromiumEnabled;
    isChromiumEnabled = YES;//TODO: hard code
    if (isChromiumEnabled) {
        [TTNetworkManager setLibraryImpl:TTNetworkManagerImplTypeLibChromium];
    }
//    } else {
//        [TTNetworkManager setLibraryImpl:TTNetworkManagerImplTypeAFNetworking];
//    }

    IESAntiSpamConfig *config = [IESAntiSpamConfig configWithAppID:@"13"
                                                            spname:@"toutiao"
                                                         secretKey:@"2a35c29661d45a80fdf0e73ba5015be19f919081b023e952c7928006fa7a11b3"];
    NSString *(^IESAntiSpamDeviceIDBlock)(void) = ^(void) {
        return [[TTInstallIDManager sharedInstance] deviceID];;
    };
    [[IESAntiSpam sharedInstance] setIESAntiSpamDeviceIDBlock:IESAntiSpamDeviceIDBlock];
//    [IESAntiSpam setSessionBlock:^NSString * {
//        NSString *sessionId = [[TTInstallIDManager sharedInstance] deviceID];
//        return sessionId;
//    }];
    [[IESAntiSpam sharedInstance] startWithConfig:config];
    
    TTURLHashBlock hash = ^(NSURL *url, NSDictionary *formData) {
        return [[IESAntiSpam sharedInstance] encryptURLWithURL:url formData:formData];
    };
    [[TTNetworkManager shareInstance] setUrlHashBlock:hash];

    // 网络库default serializer初始化
    [[TTNetworkManager shareInstance] setDefaultRequestSerializerClass:[BDTDefaultHTTPRequestSerializer class]];
    [[TTNetworkManager shareInstance] setDefaultJSONResponseSerializerClass:[TTDefaultJSONResponseSerializer class]];
    [[TTNetworkManager shareInstance] setDefaultBinaryResponseSerializerClass:[TTDefaultBinaryResponseSerializer class]];
    [[TTNetworkManager shareInstance] setDefaultResponseModelResponseSerializerClass:[TTDefaultResponseModelResponseSerializer class]];
    //添加preprocess class
    [[TTNetworkManager shareInstance] setDefaultResponseRreprocessorClass:[TTDefaultResponsePreprocessor class]];
    [[TTNetworkManager shareInstance] setUrlTransformBlock:^(NSURL * url){
        NSString *urlStr = [url.absoluteString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSURL *urlObj = [NSURL URLWithString:urlStr];
        
        if (!urlObj) {
            urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            urlObj = [NSURL URLWithString:urlStr];
        }
        
        urlObj = [[TTHttpsControlManager sharedInstance_tt] transferedURLFrom:urlObj];
        urlStr = urlObj.absoluteString;
        
        BOOL isHttps = [urlStr hasPrefix:@"https://"];
        NSURL *convertUrl = urlObj;
        
        if (!isHttps) {
            convertUrl = [urlObj tt_URLByReplacingDomainName];
        }
        
        return convertUrl;
        
    }];

    //改为动态的
    [[TTNetworkManager shareInstance] setCommonParamsblock:^(void) {
        NSMutableDictionary *tmpParams = [NSMutableDictionary dictionaryWithDictionary:[TTNetworkUtilities commonURLParameters]];
        NSString *curVersion = [TTSandBoxHelper versionName];
        NSArray<NSString *> *strArray = [curVersion componentsSeparatedByString:@"."];
        NSInteger version = 0;
        for (NSInteger i = 0; i < strArray.count; i += 1) {
            NSString *tmp = strArray[i];
            version = version * 10 + tmp.integerValue;
        }
        version += 600;
        NSMutableArray *newStrArray = [NSMutableArray arrayWithCapacity:3];
        for (NSInteger i = 0; i < 2; i += 1) {
            NSInteger num = version % 10;
            version /= 10;
            NSString *tmp = [NSString stringWithFormat:@"%ld", num];
            [newStrArray addObject:tmp];
        }
        NSString *tmp = [NSString stringWithFormat:@"%ld",version];
        [newStrArray addObject:tmp];
        NSString *newVersion = [[newStrArray reverseObjectEnumerator].allObjects componentsJoinedByString:@"."];
        [tmpParams setValue:newVersion forKey:@"version_code"];
        [tmpParams setValue:[TTSandBoxHelper buildVerion] forKey:@"update_version_code"];
        if (/*[TTRouteSelectionServerConfig sharedTTRouteSelectionServerConfig].figerprintEnabled &&*/ !isEmptyString([TTFingerprintManager sharedInstance].fingerprint)) {
            [tmpParams addEntriesFromDictionary:@{@"fp":[TTFingerprintManager sharedInstance].fingerprint}];
        }
        [tmpParams setValue:@([[AKTaskSettingHelper shareInstance] appIsReviewing]) forKey:@"review_flag"];

        NSDictionary* fParams = [[EnvContext shared] client].commonParamsProvider();
        [fParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [tmpParams setValue:obj forKey:key];
        }];
        NSDictionary *commonParams = [tmpParams copy];
        return commonParams;
    }];
    [[TTNetworkManager shareInstance] creatAppInfo];
    //头条stream有 数据混淆 即对json 的data做位运算，所以这里要处理一下 返回data然后根据情况处理后 再当做JSON解析
    [TTNetworkManager shareInstance].pureChannelForJSONResponseSerializer = YES;
    
    [TTNetworkManager shareInstance].isEncryptQueryInHeader = [TTRouteSelectionServerConfig sharedTTRouteSelectionServerConfig].isEncryptQueryInHeader;
    [TTNetworkManager shareInstance].isEncryptQuery = [TTRouteSelectionServerConfig sharedTTRouteSelectionServerConfig].isEncryptQuery;
    [TTNetworkManager shareInstance].isKeepPlainQuery = [TTRouteSelectionServerConfig sharedTTRouteSelectionServerConfig].isKeepPlainQuery;
    
//    [TTNetworkManager shareInstance].isEncryptQueryInHeader = YES;
//    [TTNetworkManager shareInstance].isEncryptQuery = NO;
//    [TTNetworkManager shareInstance].isKeepPlainQuery = YES;
    
//    [[TTNetworkManager shareInstance] enableVerboseLog];//TODO comment out this line
    LOGI(@"isEncryptQueryInHeader = %d, isEncryptQuery = %d, isKeepPlainQuery = %d", [TTNetworkManager shareInstance].isEncryptQueryInHeader, [TTNetworkManager shareInstance].isEncryptQuery, [TTNetworkManager shareInstance].isKeepPlainQuery);
}


@end
