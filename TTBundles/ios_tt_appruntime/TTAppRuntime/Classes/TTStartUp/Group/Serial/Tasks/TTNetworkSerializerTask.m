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
#import <TTNetBusiness/TTNetworkUtilities.h>
#import "TTPostDataHttpRequestSerializer.h"
#import <TTNetBusiness/TTRouteSelectionServerConfig.h>
#import "TTLocationManager.h"  //add by songlu
#import <CommonCrypto/CommonCrypto.h>
#import "SSCookieManager.h"
#import "AKTaskSettingHelper.h"
#import <SecGuard/SGMSafeGuardManager.h>
//#import "AKSafeGuardHelper.h"
#import "FHEnvContext.h"
#import <TTBaseLib/TTSandBoxHelper.h>
#import <TTMonitor/TTMonitor.h>
#import "SSCommonLogic.h"
#import "CommonURLSetting.h"
#import "TTLaunchDefine.h"
#import <FHHouseBase/TTSandBoxHelper+House.h>
#import <TTBaseLib/TTNetworkHelper.h>
#import <FHHouseBase/TTSandBoxHelper+House.h>
#import <TTAccountSDK/TTAccount+SessionToken.h>

DEC_TASK("TTNetworkSerializerTask",FHTaskTypeSerial,TASK_PRIORITY_HIGH+6);

@implementation TTNetworkSerializerTask

- (NSString *)taskIdentifier {
    return @"NetworkSerializer";
}

- (void)startWithApplication:(UIApplication *)application options:(NSDictionary *)launchOptions {
    [super startWithApplication:application options:launchOptions];
    [TTSandBoxHelper setAppDidLaunchThisTime];
    [[self class] settingNetworkSerializerClass];
}

+(BOOL)isArm64
{
    NSInteger i = 0;
    return sizeof(i) >= 8;
}


+ (void)settingNetworkSerializerClass {
    //add by songlu
    Monitorblock block = ^(NSDictionary* data, NSString* logType) {
        LOGD(@"%s logType %@", __FUNCTION__, logType);
        [[TTMonitor shareManager] trackData:data logTypeStr:logType];
    };
    [TTNetworkManager setMonitorBlock:block];

//    GetDomainblock GetDomainblock = ^(NSData* data) {
//        NSError *jsonError = nil;
//        LOGD(@"%s GetDomainblock is %@", __FUNCTION__, data);
//        id jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
//
//        if ([SSCommonLogic isRefactorGetDomainsEnabled]) {
//            [[CommonURLSetting sharedInstance] refactorHandleResult:(NSDictionary *)jsonDict error:jsonError];
//        } else {
//            [[CommonURLSetting sharedInstance] handleResult_:(NSDictionary *)jsonDict error:jsonError];
//        }
//    };
//    [TTNetworkManager setGetDomainBlock:GetDomainblock];

    NSString *city = [TTLocationManager sharedManager].city;
    [TTNetworkManager setCityName: city];
    //end by songlu

    BOOL isHttpDnsEnabled = [TTRouteSelectionServerConfig sharedTTRouteSelectionServerConfig].isHttpDnsEnabled;
    //    isHttpDnsEnabled = YES;//TODO: hard code
    [TTNetworkManager setHttpDnsEnabled:isHttpDnsEnabled];

    BOOL isChromiumEnabled = [TTRouteSelectionServerConfig sharedTTRouteSelectionServerConfig].isChromiumEnabled;
//    isChromiumEnabled = NO;//TODO: hard code
    isChromiumEnabled = [self isArm64];
    if (isChromiumEnabled) {
        [TTNetworkManager setLibraryImpl:TTNetworkManagerImplTypeLibChromium];
    } else {
        [TTNetworkManager setLibraryImpl:TTNetworkManagerImplTypeAFNetworking];
    }

//    // 初始化SafeGuard配置
//    [[AKSafeGuardHelper sharedInstance] initSafeGuard];
//
//    // 启动自动防护
//    [[SGMSafeGuardManager sharedManager] sgm_scheduleSafeGuard];

    // 请求验证
    TTURLHashBlock hash = ^(NSURL *url, NSDictionary *formData) {
        return [[SGMSafeGuardManager sharedManager] sgm_encryptURLWithURL:url formData:formData];
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
        NSMutableDictionary *commonParams = [NSMutableDictionary dictionaryWithDictionary:[TTNetworkUtilities commonURLParameters]];
    
        //因为fparams里会有未处理的version_code ，需要后面的把这个冲掉 @xiefei
        NSDictionary* fParams = [[FHEnvContext sharedInstance] getRequestCommonParams];
        
        [fParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [commonParams setValue:obj forKey:key];
        }];
        
        /*
         * 因为feed流要求版本与头条一致，当前为0.x.x 待后面正式后要注意更改对应关系
         */
        [commonParams setValue:[TTSandBoxHelper fhVersionCode] forKey:@"version_code"];
        [commonParams setValue:[TTSandBoxHelper buildVerion] forKey:@"update_version_code"];
        
        NSString *cityName = [FHEnvContext getCurrentUserDeaultCityNameFromLocal];
        if (cityName.length > 0) {
            [commonParams setValue:cityName forKey:@"f_city_name"];
        }
        
        NSString *cityId = [FHEnvContext getCurrentSelectCityIdFromLocal];
        if (cityId.length > 0) {
            [commonParams setValue:cityId forKey:@"f_city_id"];
            [commonParams setValue:cityId forKey:@"city_id"];
        }

//        if (/*[TTRouteSelectionServerConfig sharedTTRouteSelectionServerConfig].figerprintEnabled &&*/ !isEmptyString([TTFingerprintManager sharedInstance].fingerprint)) {
//            [commonParams addEntriesFromDictionary:@{@"fp":[TTFingerprintManager sharedInstance].fingerprint}];
//        }

//      NSDictionary* fParams = [[EnvContext shared] client].commonParamsProvider();

//        [commonParams setValue:@([[AKTaskSettingHelper shareInstance] appIsReviewing]) forKey:@"review_flag"];
        NSDictionary* result = [commonParams copy];
        return result;
    }];
    [[TTNetworkManager shareInstance] creatAppInfo];
    //头条stream有 数据混淆 即对json 的data做位运算，所以这里要处理一下 返回data然后根据情况处理后 再当做JSON解析
    [TTNetworkManager shareInstance].pureChannelForJSONResponseSerializer = YES;

    [TTNetworkManager shareInstance].isEncryptQueryInHeader = [TTRouteSelectionServerConfig sharedTTRouteSelectionServerConfig].isEncryptQueryInHeader;
    [TTNetworkManager shareInstance].isEncryptQuery = [TTRouteSelectionServerConfig sharedTTRouteSelectionServerConfig].isEncryptQuery;
    [TTNetworkManager shareInstance].isKeepPlainQuery = [TTRouteSelectionServerConfig sharedTTRouteSelectionServerConfig].isKeepPlainQuery;

    [TTNetworkManager shareInstance].ServerConfigHostFirst = @"tnc3-bjlgy.snssdk.com";
    [TTNetworkManager shareInstance].ServerConfigHostSecond = @"tnc3-alisc1.snssdk.com";
    [TTNetworkManager shareInstance].ServerConfigHostThird = @"tnc3-aliec2.snssdk.com";

    [[TTNetworkManager shareInstance] setDomainBase:@"i.haoduofangs.com"];
    [[TTNetworkManager shareInstance] setDomainLog:@"log.haoduofangs.com"];
    [[TTNetworkManager shareInstance] setDomainMon:@"mon.haoduofangs.com"];
    [[TTNetworkManager shareInstance] setDomainSec:@"security.haoduofangs.com"];
    [[TTNetworkManager shareInstance] setDomainChannel:@"ichannel.haoduofangs.com"];
    [[TTNetworkManager shareInstance] setDomainISub:@"isub.haoduofangs.com"];

    [TTNetworkManager shareInstance].TokenHost = @"security.haoduofangs.com";

    //    [TTNetworkManager shareInstance].isEncryptQueryInHeader = YES;
    //    [TTNetworkManager shareInstance].isEncryptQuery = NO;
    //    [TTNetworkManager shareInstance].isKeepPlainQuery = YES;

    //    [[TTNetworkManager shareInstance] enableVerboseLog];//TODO comment out this line
    //    [BDAccountSessionTokenManager setCommonParamsBlock:^(void) {
    //        NSDictionary *commonParams = [TTNetworkUtilities commonURLParameters];
    //        if ([TTRouteSelectionServerConfig sharedTTRouteSelectionServerConfig].figerprintEnabled && !isEmptyString([TTFingerprintManager sharedInstance].fingerprint)) {
    //            commonParams = [TTNetworkUtilities commonURLParametersAppendKeyAndValues:@{@"fp":[TTFingerprintManager sharedInstance].fingerprint}];
    //        }
    //        return commonParams;
    //    }];
    //    [TTNetworkManager shareInstance].requestFilterBlock = ^(TTHttpRequest *request){
    //        if ([BDAccountSessionXTTToken shared].sessionSDKIsActive) {
    //            NSArray *domainWhiteList = @[@".snssdk.com", @".toutiao.com", @".wukong.com"];
    //            for (NSString *domain in domainWhiteList) {
    //                if ([request.URL.host hasSuffix:domain]) {
    //                    [BDAccountSessionXTTToken addXTokenToRequest:request];
    //                }
    //            }
    //        }
    //    };
    
    //在[[TTNetworkManager shareInstance] start];之前加以下代码
    //通过TTNet 的 requestFilterBlock在header 中添加token
    [TTNetworkManager shareInstance].requestFilterBlock = ^(TTHttpRequest *request){
        [TTAccount addTokenToRequest:request];
        
        // 设置BOE请求头
        BOOL isBOE = [TTSandBoxHelper isInHouseApp] && [[NSUserDefaults standardUserDefaults] boolForKey:@"BOE_OPEN_KEY"];
        if(isBOE) {
            [TTNetworkManager shareInstance].requestFilterBlock = ^(TTHttpRequest *request) {
                NSMutableDictionary *headers = [NSMutableDictionary dictionary];
                if(request.allHTTPHeaderFields.count) {
                    [headers addEntriesFromDictionary:request.allHTTPHeaderFields];
                }
                [headers setObject:@"prod" forKey:@"X-Tt-Env"];
                [headers setObject:@"1" forKey:@"X-Use-Boe"];
                request.allHTTPHeaderFields = headers;
            };
        }
    };
    
    //更新token及过期设置:过期判断取决于业务方业务，如果业务方没有踢人操作的话，只需要根据下面进行设置
    [TTNetworkManager shareInstance].responseFilterBlock = ^(TTHttpRequest *request, TTHttpResponse *response, id data, NSError *responseError) {
        BOOL sessionExpired = NO;
        if ([data isKindOfClass:[NSData class]]) {
//            if ([(NSData *)data length] > 300) {
//                //长度大于 300 不会出现 session_expired
//                return;
//            }
            NSError *serializationError = nil;
            id tmpdata = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&serializationError];
            if (!serializationError && [tmpdata isKindOfClass:[NSDictionary class]]) {
                NSDictionary *resultData = [tmpdata objectForKey:@"data"];
                if ([resultData isKindOfClass:[NSDictionary class]] && [resultData.allKeys containsObject:@"name"]) {
                    if ([@"session_expired" isEqualToString:resultData[@"name"]]) {
                        // 说明每个app判断票据过期的逻辑可能会不一样，按照自己的来
                        sessionExpired = YES;
                    }
                }
            }
        }
        if (sessionExpired) {
            [[TTMonitor shareManager] trackService:@"session_expired" status:1 extra:response.allHeaderFields];
        }
        [TTAccount setXTokenWithResponse:response responseError:responseError sessionHasExpired:sessionExpired];
        //[BDAccountSessionXTTToken setXTokenWithResponse:response responseError:responseError sessionHasExpired:sessionExpired];
    };
    
    if ([TTSandBoxHelper isInHouseApp] && [[NSUserDefaults standardUserDefaults]boolForKey:@"BOE_OPEN_KEY"]) {
        //设置BOE环境和白名单 https://wiki.bytedance.net/pages/viewpage.action?pageId=336579929
        [[TTNetworkManager shareInstance] setBoeProxyEnabled:YES];
        [[TTNetworkManager shareInstance] setBypassBoeJSON:@"{\"bypass_boe_host_list\": [\"mon.haoduofangs.com\", \"mon.snssdk.com\", \"soulkiller.bytedance.net\",\"p1.pstatp.com\",\"p3.pstatp.com\",\"p6.pstatp.com\",\"p9.pstatp.com\",\"p11.pstatp.com\",\"p9-tt.bytecdn.cn\",\"sf1-ttcdn-tos.pstatp.com\",\"sf6-ttcdn-tos.pstatp.com\",\"sf3-ttcdn-tos.pstatp.com\"]}"];
    }
    [[TTNetworkManager shareInstance] start];
    
    LOGI(@"isEncryptQueryInHeader = %d, isEncryptQuery = %d, isKeepPlainQuery = %d", [TTNetworkManager shareInstance].isEncryptQueryInHeader, [TTNetworkManager shareInstance].isEncryptQuery, [TTNetworkManager shareInstance].isKeepPlainQuery);
}


@end
