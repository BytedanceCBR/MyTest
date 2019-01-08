//
//  CommonLogicSetting.h
//  Gallery
//
//  Created by Hu Dianwei on 6/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommonURLSetting.h"
#import "TTNetworkUtilities.h"
#import "TTNetworkUtil.h"
#import "ExploreExtenstionDataHelper.h"
#import "DNSManager.h"

#import "TTLocationManager.h"
 
#import "SSCommonLogic.h"
#import "TTBaseMacro.h"
#import "TTHttpsControlManager.h"

#import "TTLCSServerConfig.h"
#import "TTRouteSelectionServerConfig.h"
#import "TTRouteSelectionManager.h"
#import "TTGetDomainsResponseModel.h"


#define NormalBaseURLDomain  @"i.haoduofangs.com"
#define SNSBaseURLDomain     @"isub.haoduofangs.com"
#define LogBaseURLDomain     @"log.haoduofangs.com"
#define ChannelBaseURLDomain @"ichannel.haoduofangs.com"
#define AppMonitorDomain     @"mon.snssdk.com"
#define SecurityBaseURLDomain    @"security.haoduofangs.com"
#define kibYangGuangURLDomain  @"ib.365yg.com"
#define kiYangGuangURLDomain  @"i.365yg.com"

#define kBaseURLDomainsUserDefaultKey @"kBaseURLDomainsUserDefaultKey"
#define kBaseURLMappingUserDefaultKey @"kBaseURLMappingUserDefaultKey"

#define kNormalBaseURLDomainKey  @"i"
#define kSecurityBaseURLDomainKey  @"si"
#define kSNSBaseURLDomainKey     @"isub"
#define kLogBaseURLDomainKey     @"log"
#define kChannelBaseURLDomainKey @"ichannel"
#define kAppMonitorBaseURLDomainKey @"mon"



// domain dictionary
static inline void setBaseURLDomains(NSDictionary *domains) {
    [[NSUserDefaults standardUserDefaults] setObject:domains forKey:kBaseURLDomainsUserDefaultKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

static inline NSDictionary *baseURLDomains() {
    NSDictionary *domains = [[NSUserDefaults standardUserDefaults] objectForKey:kBaseURLDomainsUserDefaultKey];
    if (!domains || !domains[kSecurityBaseURLDomainKey]) {
        domains = @{kNormalBaseURLDomainKey : NormalBaseURLDomain,
                    kSNSBaseURLDomainKey : SNSBaseURLDomain,
                    kSecurityBaseURLDomainKey : SecurityBaseURLDomain,
                    kLogBaseURLDomainKey : LogBaseURLDomain,
                    kChannelBaseURLDomainKey : ChannelBaseURLDomain,
                    kAppMonitorBaseURLDomainKey: AppMonitorDomain};
        [[NSUserDefaults standardUserDefaults] setObject:domains forKey:kBaseURLDomainsUserDefaultKey];
    }
    return domains;
}

static inline void setBaseURLDomainMapping(NSArray *mapping) 
{
    if ([mapping isKindOfClass:[NSArray class]]) 
    {
        [[NSUserDefaults standardUserDefaults] setObject:mapping forKey:kBaseURLMappingUserDefaultKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if (!mapping)
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kBaseURLMappingUserDefaultKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

static inline NSArray *baseURLMapping() 
{
    NSArray *mapping = [[NSUserDefaults standardUserDefaults] objectForKey:kBaseURLMappingUserDefaultKey];
    if ([mapping isKindOfClass:[NSArray class]] && mapping.count > 0) {
        return mapping;
    }
    return nil;
}

// 为兼容2.5版本内测时动态域名api更换的key，添加这个方法
static NSString* restoreURLDomainForKey(NSString *key) {
    NSDictionary *domains = baseURLDomains();
    if (![domains.allKeys containsObject:key]) {
        NSMutableDictionary *mutDomains = [domains mutableCopy];
        if ([key isEqualToString:kNormalBaseURLDomainKey]) {
            [mutDomains setObject:NormalBaseURLDomain forKey:key];
        }
        else if ([key isEqualToString:kSNSBaseURLDomainKey]) {
            [mutDomains setObject:SNSBaseURLDomain forKey:key];
        }
        else if ([key isEqualToString:kLogBaseURLDomainKey]) {
            [mutDomains setObject:LogBaseURLDomain forKey:key];
        }
        else if ([key isEqualToString:kChannelBaseURLDomainKey]) {
            [mutDomains setObject:ChannelBaseURLDomain forKey:key];
        }
        else if([key isEqualToString:kAppMonitorBaseURLDomainKey])
        {
            [mutDomains setObject:AppMonitorDomain forKey:key];
        }
        
        setBaseURLDomains([mutDomains copy]);
    }
    
    domains = baseURLDomains();
    return [domains objectForKey:key];
}

static inline NSString* baseURLDomainForKey(NSString *key) {
    NSDictionary *domains = baseURLDomains();
    NSString *domain = [domains objectForKey:key];
    if (isEmptyString(domain)) {
        domain = restoreURLDomainForKey(key);
    }
    return domain;
}

// urls
static inline NSString* baseURLForKey(NSString *key) {
    NSString *domain = baseURLDomainForKey(key);
    
    //FIXME: 因为返回了is.snssdk.com 会使某些api 404 故先注释掉该部分
//    if ([key isEqualToString:kNormalBaseURLDomainKey] || [domain isEqualToString:NormalBaseURLDomain]) {
//        if ([TTRouteSelectionServerConfig sharedTTRouteSelectionServerConfig].isEnabled) {
//
//            NSString *bestHost = [[TTRouteSelectionManager sharedTTRouteSelectionManager] bestHost];
//            if (bestHost) {
//                //LOGD(@"%s use route selection result host: %@", __FUNCTION__, bestHost);
//                return bestHost;
//            }
//        }
//    }
    
#if DEBUG

    return [NSString stringWithFormat:@"https://%@", domain];

#else
    
    return [NSString stringWithFormat:@"https://%@", domain];
    
#endif
    
}


@interface CommonURLSetting() {
    int _repeatCount;
}

@property (nonatomic, strong) NSURLSessionTask *task;

@end


@implementation CommonURLSetting

- (void)dealloc
{
    
}

static CommonURLSetting *_sharedInstance = nil;
+ (CommonURLSetting *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

+ (id)alloc
{
    NSAssert(_sharedInstance == nil, @"Attempt alloc another instance for a singleton.");
    return [super alloc];
}

#pragma mark - request domains

+ (NSArray *)urlMapping
{
    NSArray *mapping = baseURLMapping();
    return mapping;
}

- (void)requestURLDomains
{
    
//    NSArray *requestDomainURLs = @[@"https://dm.toutiao.com/get_domains/v4/", @"https://dm.bytedance.com/get_domains/v4/", @"https://dm.pstatp.com/get_domains/v4/"];
    NSArray *requestDomainURLs = @[@"https://dm.haoduofangs.com/get_domains/v4/"];

    if (_repeatCount < [requestDomainURLs count]) {
        NSString *tURL = [requestDomainURLs objectAtIndex:_repeatCount];
        
        NSDictionary *commonParam = [TTNetworkUtilities commonURLParameters];
        
        NSMutableDictionary *mutParams = [[NSMutableDictionary alloc] initWithDictionary:commonParam];
#ifndef TTModule
       
        [mutParams setValue:[TTLocationManager sharedManager].city forKey:@"city"];
        
//#warning test code
//        [mutParams setObject:[NSNumber numberWithInt:1] forKey:@"force"];
        
        CLLocationCoordinate2D coordinate = [TTLocationManager sharedManager].placemarkItem.coordinate;
        if (coordinate.latitude * coordinate.longitude > 0) {
            [mutParams setObject:@(coordinate.latitude) forKey:@"latitude"];
            [mutParams setObject:@(coordinate.longitude) forKey:@"longitude"];
        }
#endif

        [self.task cancel];
        
        NSString *getUrl = [TTNetworkUtil URLString:tURL appendCommonParams:mutParams];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:getUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        [request setHTTPMethod:@"GET"];
        
        __weak typeof(self) wself = self;
        
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (!error && data) {
                
                NSError *jsonError = nil;
                id jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                
                [wself handleResult_:(NSDictionary *)jsonDict error:jsonError];
            } else {
                // retry
                [wself requestURLDomains];
            }
            
        }];
        
        [task resume];
        
        self.task = task;
        
        _repeatCount ++;
    }
    else {
        _repeatCount = 0;
        [[TTMonitor shareManager] trackService:@"get_domain_error" status:1 extra:nil];
    }
}

- (void)refactorRequestURLDomains {
    
//    NSArray *requestDomainURLs = @[@"https://dm.toutiao.com/get_domains/v4/", @"https://dm.bytedance.com/get_domains/v4/", @"https://dm.pstatp.com/get_domains/v4/"];
        NSArray *requestDomainURLs = @[@"https://dm.haoduofangs.com/get_domains/v4/"];

    if (_repeatCount < [requestDomainURLs count]) {
        NSString *tURL = [requestDomainURLs objectAtIndex:_repeatCount];
        
        NSDictionary *commonParam = [TTNetworkUtilities commonURLParameters];
        
        NSMutableDictionary *mutParams = [NSMutableDictionary dictionaryWithDictionary:commonParam];
        
#ifndef TTModule
        [mutParams setValue:[TTLocationManager sharedManager].city forKey:@"city"];
        
        //#warning test code
        //        [mutParams setObject:[NSNumber numberWithInt:1] forKey:@"force"];
        
        CLLocationCoordinate2D coordinate = [TTLocationManager sharedManager].placemarkItem.coordinate;
        if (coordinate.latitude * coordinate.longitude > 0) {
            [mutParams setObject:@(coordinate.latitude) forKey:@"latitude"];
            [mutParams setObject:@(coordinate.longitude) forKey:@"longitude"];
        }
#endif
        [self.task cancel];
        
        NSString *getUrl = [TTNetworkUtil URLString:tURL appendCommonParams:mutParams];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:getUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        [request setHTTPMethod:@"GET"];
        
        __weak typeof(self) wself = self;
        
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (!error && data) {
                
                NSError *jsonError = nil;
                id jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                
                [wself refactorHandleResult:(NSDictionary *)jsonDict error:jsonError];
            } else {
                [wself refactorRequestURLDomains];
            }
            
        }];
        
        [task resume];
        
        self.task = task;
        
        _repeatCount ++;
    }
    else {
        _repeatCount = 0;
        [[TTMonitor shareManager] trackService:@"get_domain_error" status:1 extra:nil];
    }
}


- (void)handleResult_:(NSDictionary *)result error:(NSError *)error
{
    if (!error  && [result isKindOfClass:NSDictionary.class]) {
        _repeatCount = 0;
        
        NSDictionary *data = [result objectForKey:@"data"];
        if ([data.allKeys containsObject:@"mapping"]) {
            
            NSDictionary *mapping = [data objectForKey:@"mapping"];
            if (mapping && [mapping isKindOfClass:[NSDictionary class]]) {
                
                NSMutableDictionary *tDomains = [NSMutableDictionary dictionaryWithDictionary:baseURLDomains()];
                BOOL needUpdate = NO;
                
                if ([mapping.allKeys containsObject:kNormalBaseURLDomainKey]) {
                    
                    NSString *tDomain = [mapping objectForKey:kNormalBaseURLDomainKey];
                    if (![tDomain isEqualToString:baseURLDomainForKey(kNormalBaseURLDomainKey)]) {
                        [tDomains setObject:tDomain forKey:kNormalBaseURLDomainKey];
                        needUpdate = YES;
                    }
                    [ExploreExtenstionDataHelper saveSharedBaseURLDomain:[tDomain copy]];
                }
                
                if ([mapping.allKeys containsObject:kSecurityBaseURLDomainKey]) {
                    
                    NSString *tDomain = [mapping objectForKey:kSecurityBaseURLDomainKey];
                    if (![tDomain isEqualToString:baseURLDomainForKey(kSecurityBaseURLDomainKey)]) {
                        [tDomains setObject:tDomain forKey:kSecurityBaseURLDomainKey];
                        needUpdate = YES;
                    }
                    [ExploreExtenstionDataHelper saveSharedBaseURLDomain:[tDomain copy]];
                }
                
                if ([mapping.allKeys containsObject:kChannelBaseURLDomainKey]) {
                    
                    NSString *tDomain = [mapping objectForKey:kChannelBaseURLDomainKey];
                    if (![tDomain isEqualToString:baseURLDomainForKey(kChannelBaseURLDomainKey)]) {
                        [tDomains setObject:tDomain forKey:kChannelBaseURLDomainKey];
                        needUpdate = YES;
                    }
                }
                
                if ([mapping.allKeys containsObject:kSNSBaseURLDomainKey]) {
                    
                    NSString *tDomain = [mapping objectForKey:kSNSBaseURLDomainKey];
                    if (![tDomain isEqualToString:baseURLDomainForKey(kSNSBaseURLDomainKey)]) {
                        [tDomains setObject:tDomain forKey:kSNSBaseURLDomainKey];
                        needUpdate = YES;
                    }
                }
                
                if ([mapping.allKeys containsObject:kLogBaseURLDomainKey]) {
                    
                    NSString *tDomain = [mapping objectForKey:kLogBaseURLDomainKey];
                    if (![tDomain isEqualToString:baseURLDomainForKey(kLogBaseURLDomainKey)]) {
                        [tDomains setObject:tDomain forKey:kLogBaseURLDomainKey];
                        needUpdate = YES;
                    }
                }
                
                if ([mapping.allKeys containsObject:kAppMonitorBaseURLDomainKey]) {
                    
                    NSString *tDomain = [mapping objectForKey:kAppMonitorBaseURLDomainKey];
                    if (![tDomain isEqualToString:baseURLDomainForKey(kAppMonitorBaseURLDomainKey)]) {
                        [tDomains setObject:tDomain forKey:kAppMonitorBaseURLDomainKey];
                        needUpdate = YES;
                    }
                }
                
                if (needUpdate) {
                    setBaseURLDomains([tDomains copy]);
                }
            }

        }
        
//        NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        [dic setValue:@"is.snssdk.com/video/play/" forKey:@"origin"];
//        [dic setValue:@"ib.365yg.com/video/play/" forKey:@"target"];
//        [array addObject:dic];
        
        setBaseURLDomainMapping([data objectForKey:@"url_replace_mapping"]);
        
        //处理开关
        if ([data objectForKey:@"use_dns_mapping"]) {
            [SSCommonLogic setEnabledDNSMapping:[[data objectForKey:@"use_dns_mapping"] integerValue]];
        }
        //0开启1关闭
        if ([data objectForKey:@"disable_encrypt_switch"]) {
            [SSCommonLogic setUseEncrypt:![[data objectForKey:@"disable_encrypt_switch"] boolValue]];
        }
        
        if ([data objectForKey:@"use_monitor_log"]) {
            [SSCommonLogic setMonitorLog:[[data objectForKey:@"use_monitor_log"] boolValue]];
        }
        
        if ([data objectForKey:@"should_check_log"]) {
            [SSCommonLogic setCheckLog:[[data objectForKey:@"should_check_log"] boolValue]];
        }
        
        //处理dns mapping
        NSArray *dns_mapping = [data objectForKey:@"dns_mapping"];
        if (dns_mapping && [dns_mapping isKindOfClass:[NSArray class]]) {
           
            [DNSManager setDNSMapping:[data objectForKey:@"dns_mapping"]];

        }
        
        //处理 https的切换
        [[TTHttpsControlManager sharedInstance_tt] configWithParameters:data];
        
        //读取长连接配置
        // [[TTLCSServerConfig sharedTTLCSServerConfig] updateUrls:data];
        [[TTLCSServerConfig sharedInstance] resetServerConfigUrls:[data tt_arrayValueForKey:kTTLCSServerConfigUrlArrayKey]];
        
        //读取选路配置
        [[TTRouteSelectionServerConfig sharedTTRouteSelectionServerConfig] updateServerConfig:data];

    }
    else {
        // retry
        [self requestURLDomains];
    }
}

- (void)refactorHandleResult:(NSDictionary *)jsonObj error:(NSError *)error {
    TTGetDomainsResponseModel *responseModel = nil;
    NSError *parseError;
    
    if([jsonObj isKindOfClass:[NSDictionary class]]) {
        responseModel = [[TTGetDomainsResponseModel alloc] initWithDictionary:jsonObj error:&parseError];
    }
    
    if (!error && !parseError && responseModel && [responseModel.message isEqualToString:@"success"]) {
        _repeatCount = 0;
        NSDictionary *mapping = responseModel.data.mapping;
        if (mapping && [mapping isKindOfClass:[NSDictionary class]]) {
            
            NSMutableDictionary *tDomains = [NSMutableDictionary dictionaryWithDictionary:baseURLDomains()];
            BOOL needUpdate = NO;
            
            if ([mapping.allKeys containsObject:kNormalBaseURLDomainKey]) {
                
                NSString *tDomain = [mapping objectForKey:kNormalBaseURLDomainKey];
                if (![tDomain isEqualToString:baseURLDomainForKey(kNormalBaseURLDomainKey)]) {
                    [tDomains setObject:tDomain forKey:kNormalBaseURLDomainKey];
                    needUpdate = YES;
                }
                [ExploreExtenstionDataHelper saveSharedBaseURLDomain:[tDomain copy]];
            }
            
            if ([mapping.allKeys containsObject:kSecurityBaseURLDomainKey]) {
                
                NSString *tDomain = [mapping objectForKey:kSecurityBaseURLDomainKey];
                if (![tDomain isEqualToString:baseURLDomainForKey(kSecurityBaseURLDomainKey)]) {
                    [tDomains setObject:tDomain forKey:kSecurityBaseURLDomainKey];
                    needUpdate = YES;
                }
                [ExploreExtenstionDataHelper saveSharedBaseURLDomain:[tDomain copy]];
            }
            
            if ([mapping.allKeys containsObject:kChannelBaseURLDomainKey]) {
                
                NSString *tDomain = [mapping objectForKey:kChannelBaseURLDomainKey];
                if (![tDomain isEqualToString:baseURLDomainForKey(kChannelBaseURLDomainKey)]) {
                    [tDomains setObject:tDomain forKey:kChannelBaseURLDomainKey];
                    needUpdate = YES;
                }
            }
            
            if ([mapping.allKeys containsObject:kSNSBaseURLDomainKey]) {
                
                NSString *tDomain = [mapping objectForKey:kSNSBaseURLDomainKey];
                if (![tDomain isEqualToString:baseURLDomainForKey(kSNSBaseURLDomainKey)]) {
                    [tDomains setObject:tDomain forKey:kSNSBaseURLDomainKey];
                    needUpdate = YES;
                }
            }
            
            if ([mapping.allKeys containsObject:kLogBaseURLDomainKey]) {
                
                NSString *tDomain = [mapping objectForKey:kLogBaseURLDomainKey];
                if (![tDomain isEqualToString:baseURLDomainForKey(kLogBaseURLDomainKey)]) {
                    [tDomains setObject:tDomain forKey:kLogBaseURLDomainKey];
                    needUpdate = YES;
                }
            }
            
            if ([mapping.allKeys containsObject:kAppMonitorBaseURLDomainKey]) {
                
                NSString *tDomain = [mapping objectForKey:kAppMonitorBaseURLDomainKey];
                if (![tDomain isEqualToString:baseURLDomainForKey(kAppMonitorBaseURLDomainKey)]) {
                    [tDomains setObject:tDomain forKey:kAppMonitorBaseURLDomainKey];
                    needUpdate = YES;
                }
            }
            
            if (needUpdate) {
                setBaseURLDomains([tDomains copy]);
            }
        }
        
        //处理开关
        if (responseModel.data.useDNSMapping) {
            [SSCommonLogic setEnabledDNSMapping:[responseModel.data.useDNSMapping integerValue]];
        }
        if (responseModel.data.disableEncryptAppLog) {
            [SSCommonLogic setUseEncrypt:![responseModel.data.disableEncryptAppLog boolValue]];
        }
        
        if (responseModel.data.useMonitorLog) {
            [SSCommonLogic setMonitorLog:[responseModel.data.useMonitorLog boolValue]];
        }
        
        if (responseModel.data.shouldCheckLog) {
            [SSCommonLogic setCheckLog:[responseModel.data.shouldCheckLog boolValue]];
        }
        
        //处理dns mapping
        NSArray *dns_mapping = responseModel.data.DNSMapping;
        if (dns_mapping && [dns_mapping isKindOfClass:[NSArray class]]) {
            [DNSManager setDNSMapping:dns_mapping];
        }
        
        //处理 https的切换
        [[TTHttpsControlManager sharedInstance_tt] configWithResponseModel:responseModel];
        
        //读取长连接配置
        // [[TTLCSServerConfig sharedTTLCSServerConfig] updateURLsWithResponseModel:responseModel];
        [[TTLCSServerConfig sharedInstance] resetServerConfigUrls:responseModel.data.frontierURLs];
        
        //读取选路配置
        [[TTRouteSelectionServerConfig sharedTTRouteSelectionServerConfig] updateServerConfigWithResponseModel:responseModel];
        
    }
    else {
        // retry
        [self refactorRequestURLDomains];
    }
}

#pragma mark - domains

+ (NSString*)baseURL
{
    return baseURLForKey(kNormalBaseURLDomainKey);
}

+ (NSString*)baseURLWithKey:(NSString *)key
{
    return baseURLForKey(key);
}

+ (NSString*)securityURL
{
    return baseURLForKey(kSecurityBaseURLDomainKey);
}

+ (NSString *)channelBaseURL
{
    return baseURLForKey(kChannelBaseURLDomainKey);
}

+ (NSString*)SNSBaseURL
{
    return baseURLForKey(kSNSBaseURLDomainKey);
}

+ (NSString*)logBaseURL
{
    return baseURLForKey(kLogBaseURLDomainKey);
}

+ (NSString*)monitorBaseURL
{
    return baseURLForKey(kAppMonitorBaseURLDomainKey);
}

+ (NSArray *)defaultArticleDetailURLHosts {
    return @[@"a3.bytecdn.cn", @"a3.pstatp.com"];
}
#pragma mark - Base URLs

/**
 *  4.9增加，用于通过tab方式获取评论列表，另外评论列表增加如下字段：
 *  cellType区分类型，增加嵌入式广告和话题；
 *  评论增加additional_info显示手机品牌等；
 *  增加forum_link字段（sslocal形式）表示话题scheme
 **/
+ (NSString*)tabCommentURLString
{
    return [NSString stringWithFormat:@"%@/article/v1/tab_comments/", [self baseURL]];
}

+ (NSString *)tabCommentURLStringV2
{
    return [NSString stringWithFormat:@"%@/article/v2/tab_comments/", [self baseURL]];
}
/**
 *  Deprecated 4.9开始统一使用tab_comments
 **/
+ (NSString*)allCommentURLString
{
    return [NSString stringWithFormat:@"%@/2/article/v4/all_comments/", [self baseURL]];
}

+ (NSString*)appLogoutURLString
{
    return [NSString stringWithFormat:@"%@/service/1/app_logout/", [self baseURL]];
}

+ (NSString*)recommendAppInfoURLString
{
    return [NSString stringWithFormat:@"%@/service/1/app_list/", [self baseURL]];
}

+ (NSString*)recommendAppAcountURLString
{
    return [NSString stringWithFormat:@"%@/service/1/app_update_count/", [self baseURL]];
}

+ (NSString*)categoryURLString
{
    return [NSString stringWithFormat:@"%@/article/category/get/v2/", [self baseURL]];
}


+ (NSString*)subscribedCategoryURLString
{
    return [NSString stringWithFormat:@"%@/article/category/get_subscribed/v2/", [self baseURL]];
}

+ (NSString*)unsubscribedCategoryURLString
{
    return [NSString stringWithFormat:@"%@/article/category/get_extra/v1/", [self baseURL]];
}

+ (NSString*)videoCategoryURLString
{
    return [NSString stringWithFormat:@"%@/video_api/get_category/v1/", [self baseURL]];
}

+ (NSString*)shortVideoCategoryURLString
{
    return [NSString stringWithFormat:@"%@/category/get_ugc_video/1/", [self baseURL]];
}

+ (NSString*)appRecommendURLString
{
    return [NSString stringWithFormat:@"%@/service/3/app_components/", [self baseURL]];
}

// 目前只有头条详情页用到，之后可能在视频应用用到
+ (NSString*)loadVideoURLString
{
    return [NSString stringWithFormat:@"%@/2/article/video/url/2/", [self baseURL]];
}

+ (NSString*)appUpdateURLString
{
    return [NSString stringWithFormat:@"%@/service/1/update_apps/", [self baseURL]];
}

+ (NSString*)appNoUpdateNotifyURLString
{
    return [NSString stringWithFormat:@"%@/service/1/app_no_update_notify/", [self baseURL]];
}

+ (NSString*)appNoticeStatusURLString
{
    return [NSString stringWithFormat:@"%@/service/1/app_notice_status/", [self baseURL]];
}

+ (NSString *)appSettingsURLString
{
    return [NSString stringWithFormat:@"%@/service/settings/v2/", [self baseURL]];
}

+ (NSString *)reportURLString
{
    return [NSString stringWithFormat:@"%@/feedback/2/report/", [self baseURL]];
}

+ (NSString *)reportUserURLString
{
    return [NSString stringWithFormat:@"%@/feedback/1/report_user/", [self baseURL]];
}

+ (NSString *)reportVideoURLString
{
    return [NSString stringWithFormat:@"%@/video_api/report/", [self baseURL]];
}

+ (NSString *)feedbackFAQURLString
{
    return [NSString stringWithFormat:@"%@/faq/v2/", [self baseURL]];
}

+ (NSString *)listEntityWordCareURLString
{
    return [NSString stringWithFormat:@"%@/concern/v1/commit/care/", [self baseURL]];
}

+ (NSString *)listEntityWordDiscareURLString
{
    return [NSString stringWithFormat:@"%@/concern/v1/commit/discare/", [self baseURL]];
}

+ (NSString *)channelRefreshADImageURLString
{
    return [NSString stringWithFormat:@"%@/service/1/refresh_ad/", [self baseURL]];
}

+ (NSString *)articlePositionUploadURLString
{
    return [NSString stringWithFormat:@"%@/article/read_position/v1/", [self baseURL]];
}
#pragma mark - LiveBase URLs
+ (NSString *)liveTalkURLString
{
//#warning test
    return [NSString stringWithFormat:@"%@/live_talk", [self baseURL]];
    // TODO : delete . test
//    return @"http://10.6.131.78:9981/live_talk";
//    return @"http://10.6.131.78:9866/live_talk";
//    return @"http://10.6.131.78:9987/live_talk";
//    return @"http://10.6.131.78:9876/live_talk";
}


#pragma mark - ChannelBase URLs

+ (NSString*)appAlertURLString
{
    return [NSString stringWithFormat:@"%@/service/2/app_alert/", [self channelBaseURL]];
}

+ (NSString*)appAlertActionURLString
{
    return [NSString stringWithFormat:@"%@/service/1/app_alert_action/", [self channelBaseURL]];
}

+ (NSString*)checkVersionURLString
{
    return [NSString stringWithFormat:@"%@/check_version/v3/", [self baseURL]];
}

+ (NSString*)feedbackFetch
{
    return [NSString stringWithFormat:@"%@/feedback/2/list/", [self channelBaseURL]];
}

+ (NSString *)feedbackPostMsg
{
    return [NSString stringWithFormat:@"%@/feedback/1/post_message/", [self channelBaseURL]];
}


#pragma mark - SNSBase URLs

+ (NSString *)adItemActionUnDislikeURLString
{
    return [NSString stringWithFormat:@"%@/2/ad/action/undislike/v1/", [self SNSBaseURL]];
}

+ (NSString *)adItemActionDislikeURLString
{
    return [NSString stringWithFormat:@"%@/2/ad/action/dislike/v1/", [self SNSBaseURL]];
}

+ (NSString *)wapAuthSyncURLString
{
    return [NSString stringWithFormat:@"%@/2/wap/auth/", [self SNSBaseURL]];
}

#pragma mark - SNSBase URLs

+ (NSString *)wapAppURLString
{
    return [NSString stringWithFormat:@"%@/2/wap/app/", [self SNSBaseURL]];
}

+ (NSString *)sharePGCUserURLString
{
    return [NSString stringWithFormat:@"%@/2/pgc/share_media_account/", [self SNSBaseURL]];
}

+ (NSString *)likePGCUserURLString
{
    return [NSString stringWithFormat:@"%@/2/pgc/like/", [self SNSBaseURL]];
}

+ (NSString *)unlikePGCUserURLString
{
    return [NSString stringWithFormat:@"%@/2/pgc/unlike/", [self SNSBaseURL]];
}


+ (NSString*)favoriteUsersURLString
{
    return [NSString stringWithFormat:@"%@/2/data/favorite_users/", [self SNSBaseURL]];
}


+ (NSString*)shareMessageURLString
{
    return [NSString stringWithFormat:@"%@/2/data/share_message/", [self SNSBaseURL]];
}

+ (NSString*)actionURLString
{
    return [NSString stringWithFormat:@"%@/2/data/item_action/", [self SNSBaseURL]];
}

+ (NSString*)commentActionURLString
{
    return [NSString stringWithFormat:@"%@/2/data/comment_action/", [self baseURL]];
}

+ (NSString*)favoriteActionURLString
{
    return [NSString stringWithFormat:@"%@/2/data/favorite_action/", [self SNSBaseURL]];
}

// 短文章中使用该URL获取评论
+ (NSString *)essayCommentsURLString
{
    return [NSString stringWithFormat:@"%@/2/data/get_essay_comments/", [self SNSBaseURL]];
}

+ (NSString*)postMessageURLString
{
    return [NSString stringWithFormat:@"%@/2/data/v4/post_message/", [self baseURL]];
}

+ (NSString*)userInfoURLString
{
    return [NSString stringWithFormat:@"%@/2/user/info/", [self baseURL]];
}

+ (NSString*)loginURLString
{
    return [NSString stringWithFormat:@"%@/2/auth/login/v2/", [self SNSBaseURL]];
}

+ (NSString*)logoutURLString
{
    return [NSString stringWithFormat:@"%@/2/user/logout/", [self SNSBaseURL]];
}

+ (NSString*)logoutAccountURLString
{
    return [NSString stringWithFormat:@"%@/2/auth/logout/", [self SNSBaseURL]];
}

+ (NSString*)loginContinueURLString
{
    return [NSString stringWithFormat:@"%@/2/auth/login_continue/", [self SNSBaseURL]];
}

+ (NSString*)updateUserURLString
{
    return [NSString stringWithFormat:@"%@/2/user/update/v3/", [self SNSBaseURL]];
}

+ (NSString*)sinaSSOLoginURLString//该API，所有SSO都在使用
{
    return [NSString stringWithFormat:@"%@/2/auth/sso_callback/v2/", [self SNSBaseURL]];
}

+ (NSString*)switchBindURLString//该API，所有SSO都在使用
{
    return [NSString stringWithFormat:@"%@/2/auth/sso_switch_bind/", [self SNSBaseURL]];
}

+ (NSString*)appShare
{
    return [NSString stringWithFormat:@"%@/2/data/v2/app_share/", [self SNSBaseURL]];
}

+ (NSString*)batchItemAction
{
    return [NSString stringWithFormat:@"%@/2/data/batch_item_action/", [self SNSBaseURL]];
}

+ (NSString*)getUpdatesURLString
{
    return [NSString stringWithFormat:@"%@/2/data/get_updates/", [self SNSBaseURL]];
}

+ (NSString*)getFavouriteStatus
{
    return [NSString stringWithFormat:@"%@/2/data/get_favorite_status/", [self SNSBaseURL]];
}

+ (NSString*)getHotUpdates
{
    return [NSString stringWithFormat:@"%@/2/data/get_hot_updates/", [self SNSBaseURL]];
}

+ (NSString*)updateRecent
{
    return [NSString stringWithFormat:@"%@/10/update/recent/", [self SNSBaseURL]];
}

+ (NSString*)myFollowURLString
{
    return [NSString stringWithFormat:@"%@/concern/v2/follow/my_follow/", [self baseURL]];
}

+ (NSString*)newFollowingURLString
{
    return [NSString stringWithFormat:@"%@/concern/v2/follow/list/v2/", [self baseURL]];
}

+ (NSString*)userSearchPageURLString
{
    return [NSString stringWithFormat:@"%@/mytab_search/search_page/", [self baseURL]];
}

+ (NSString*)updateCountURLString
{
    return [NSString stringWithFormat:@"%@/10/update/count/", [self SNSBaseURL]];
}

+ (NSString*)updateUserListURLString
{
    return [NSString stringWithFormat:@"%@/13/update/user/", [self SNSBaseURL]];
}

+ (NSString*)uploadUserPhotoURLString
{
    return [NSString stringWithFormat:@"%@/2/user/upload_photo/", [self SNSBaseURL]];
}

+ (NSString *)uploadCertificationURLString
{
    return [NSString stringWithFormat:@"%@/user/profile/auth/apply/v2/",[CommonURLSetting baseURL]];
}

+ (NSString *)uploadModifyCertificationURLString
{
    return [NSString stringWithFormat:@"%@/user/profile/auth/modify_auth_info/",[CommonURLSetting baseURL]];
}

+ (NSString *)uploadUserImageURLString
{
    return [NSString stringWithFormat:@"%@/2/user/upload_image/", [self SNSBaseURL]];
}

//+ (NSString*)setCatgegoryURLString
//{
//    return [NSString stringWithFormat:@"%@/2/data/set_category/v2/", [self SNSBaseURL]];
//}

+ (NSString *)uploadImageString
{
    return [NSString stringWithFormat:@"%@/2/data/upload_image/", [self baseURL]];
}

+ (NSString *)deleteCommentString
{
    return [NSString stringWithFormat:@"%@/2/data/delete_comment/", [self baseURL]];
}

+ (NSString*)wapActivityURLString
{
    return [NSString stringWithFormat:@"%@/2/wap/activity/", [self SNSBaseURL]];
}

+ (NSString*)deleteUGCMovieURLString
{
    return [NSString stringWithFormat:@"%@/ttdiscuss/v2/ugc_video/delete_video/", [self baseURL]];
}

#pragma mark - LogBase URLs

+ (NSString*)appLogConfigURLString
{
    return [NSString stringWithFormat:@"%@/service/2/app_log_config/", [self logBaseURL]];
}

+ (NSString*)appLogV3ConfigURLString
{
    return [NSString stringWithFormat:@"%@/service/3/app_log_config/", [self logBaseURL]];
}

+ (NSString*)appLogV2ConfigURLString
{
    return [NSString stringWithFormat:@"%@/collect/applog/v3/settings/", [self logBaseURL]];
}

+ (NSString*)appLogV2URLString
{
    return [NSString stringWithFormat:@"%@/collect/v2/app_log/", [self logBaseURL]];
}

+ (NSString*)appLogURLString
{
    return [NSString stringWithFormat:@"%@/service/2/app_log/", [self logBaseURL]];
}

+ (NSString*)requestNewSessionURLString
{
    return [NSString stringWithFormat:@"%@/auth/chain_login/", [self SNSBaseURL]];
}

+ (NSString*)CDNLogURLString
{
    return [NSString stringWithFormat:@"%@/cdn/", [self baseURL]];
}

+ (NSString*)continuousCDNLogURLString
{
    return [NSString stringWithFormat:@"%@/cdn_error/", [self baseURL]];
}

#pragma mark - Auth URLs

// 新浪微博sso的回调API，不能使用动态域名服务
+ (NSString*)authLoginSuccessURLString
{
#if SS_IS_I18N // 国际版
    return @"http://api.gsnssdk.com/auth/login_success/";
#else
    return @"http://api.snssdk.com/auth/login_success/";
#endif
}

#pragma mark - Real-name Auth URLs

+ (NSString *)imageIDPicUploadURLString
{
    return [NSString stringWithFormat:@"%@/pgcui/media_ocr/upload_identity_pic/", [self baseURL]];
}

+ (NSString *)imageIDVideoUploadURLString
{
    return [NSString stringWithFormat:@"%@/pgcui/media_ocr/upload_live_video/", [self baseURL]];
}

+ (NSString *)imageOcrUploadURLString
{
    return [NSString stringWithFormat:@"%@/pgcui/media_ocr/ocr_upload/", [self baseURL]];
}

+ (NSString *)imageOcrInfoSubmitURLString
{
    return [NSString stringWithFormat:@"%@/pgcui/media_ocr/edit_ocr_info/", [self baseURL]];
}

+ (NSString *)imageOcrInfoStatusURLString
{
    return [NSString stringWithFormat:@"%@/pgcui/media_ocr/get_ocr_submit_status/", [self baseURL]];
}

+ (NSString*)reportUserConfigurationString
{
    return [NSString stringWithFormat:@"%@/service/1/collect_settings/", [self baseURL]];
}

+ (NSString*)exceptionURLString
{
    return [NSString stringWithFormat:@"%@/service/2/app_log_exception/", [self logBaseURL]];
}

+ (NSString*)appListFileURLString
{
    return @"http://s0.pstatp.com/site/zaxiang/app_list_full.zip";
}

+ (NSString*)APIErrorReportURLString
{
    return [NSString stringWithFormat:@"%@/api_error/", [self baseURL]];
}

+ (NSString*)appMonitorConfigURLString
{
    return [NSString stringWithFormat:@"%@/monitor/settings/", [self monitorBaseURL]];
}

+ (NSString*)appMonitorCollectURLString
{
    return [NSString stringWithFormat:@"%@/monitor/collect/", [self monitorBaseURL]];
}

+ (NSString*)version2DislikeURLString
{
    return [NSString stringWithFormat:@"%@/user_data/batch_action/", [self SNSBaseURL]];
}

#pragma mark - subscribed category
+ (NSString *)subscribeURLString
{
    return [NSString stringWithFormat:@"%@/entry/subscription_list/v1/", [self baseURL]];
}

#pragma mark - post moment
+ (NSString *)postMomentURLString
{
    return [NSString stringWithFormat:@"%@/dongtai/publish/", [self baseURL]];
}

#pragma mark - forward moment
+ (NSString *)forwardMomentURLString
{
    return [NSString stringWithFormat:@"%@/dongtai/forward/", [self baseURL]];
}

+ (NSString*)wapStoreURLString
{
    return [NSString stringWithFormat:@"%@/2/wap/mall/", [self baseURL]];
}

+ (NSString*)luaURLString
{
    return @"http://s0.pstatp.com/site/lib/lua/";
}

+ (NSString*)jsAuthConfigURLString
{
    return [NSString stringWithFormat:@"%@/client_auth/js_sdk/config/v1/", [self baseURL]];
}

#pragma mark - forum base URL
+ (NSString *)moiveCommentBaseURL {
    return @"http://ic.snssdk.com";
}

+ (NSString *)yangGuangBaseURL
{
    return kibYangGuangURLDomain;
}
@end

@implementation CommonURLSetting (TTLocationManager)

+ (NSString *)uploadLocationURLString {
    return [NSString stringWithFormat:@"%@/location/suloin/", [self baseURL]];
}

+ (NSString *)uploadUserCityURLString {
    return [NSString stringWithFormat:@"%@/location/suusci/", [self baseURL]];
}

+ (NSString *)locationCancelURLString {
    return [NSString stringWithFormat:@"%@/location/cancel/", [self baseURL]];
}

@end

@implementation CommonURLSetting (TTGuide)

+ (NSString *)confWordsURLString {
    return [NSString stringWithFormat:@"%@/stream/widget/interest/1/conf_words", [self baseURL]];
}

@end

@implementation CommonURLSetting (TTAd)
///...
+ (NSString*)appADURLString
{
    return [NSString stringWithFormat:@"%@/service/15/app_ad/", [self baseURL]]; // 升级15支持iPad开屏广告
}

//分享版广告
+ (NSString*)shareAdURLString
{
    return [NSString stringWithFormat:@"%@/api/ad/share/v1/", [self baseURL]];
}

//下拉刷新广告
+ (NSString *)refreshADURLString{
    
    return [NSString stringWithFormat:@"%@/api/ad/refresh/v1/", [self baseURL]];
}

//三方广告落地页预加载
+ (NSString*)preloadAdURLString
{
    return [NSString stringWithFormat:@"%@/api/ad/preload_ad/v1/", [self baseURL]];
}

//三方广告落地页预加载
+ (NSString*)adPreloadV2URLString
{
    return [NSString stringWithFormat:@"%@/api/ad/preload_ad/v2/", [self baseURL]];
}

//沉浸式广告
+ (NSString*)canvasAdURLString
{
    return [NSString stringWithFormat:@"%@/api/ad/canvas/preload/v2/", [self baseURL]];
}

//沉浸式视频
+ (NSString*)canvasAdLiveURLString
{
    return [NSString stringWithFormat:@"%@/video/api/live/query_live_status/ad/", [self baseURL]];
}

@end

@implementation CommonURLSetting (TTPrivateLetter)

+ (NSString *)userInfoURL {
    return [NSString stringWithFormat:@"%@/private_message/user/get_user_info/", [self baseURL]];
}

+ (NSString *)plLoginUrl {
    return [NSString stringWithFormat:@"%@/private_message/account/login_notify/", [self baseURL]];
}

+ (NSString *)plLogoutUrl {
    return [NSString stringWithFormat:@"%@/private_message/account/logout_notify/", [self baseURL]];
}

@end

@implementation CommonURLSetting (TTMessageNotification)

// 新消息通知列表
+ (NSString *)messageNotificationListURLString
{
    return [NSString stringWithFormat:@"%@/api/msg/v3/list/", [self baseURL]];
}

// 新消息通知未读提示
+ (NSString*)messageNotificationUnreadURLString
{
    return [NSString stringWithFormat:@"%@/api/msg/v1/unread/", [self baseURL]];
}

@end

@implementation CommonURLSetting (TTFlowStatistics)

+ (NSString *)queryResidualFlowURLString
{
    return [NSString stringWithFormat:@"%@/activity/carrier_flow/query_flow/",[self baseURL]];
}

+ (NSString *)updateResidualFlowURLString
{
    return [NSString stringWithFormat:@"%@/activity/carrier_flow/update_flow/",[self baseURL]];
}

@end

@implementation CommonURLSetting (TTCommonweal)

+ (NSString *)uploadUsingTimeURLString
{
    return [NSString stringWithFormat:@"%@/welfare/api/v1/enough_time/",[self baseURL]];
}

@end

@implementation CommonURLSetting (TTGuideAmount)

+ (NSString *)guideAmountUrlString
{
    return [NSString stringWithFormat:@"%@/weasel/app_promotion_material/",[self baseURL]];
}

@end

@implementation CommonURLSetting (TTRecordMusic)

+ (NSString *)getSongInfomationURLString; {
    return [NSString stringWithFormat:@"%@/toutiao/music/song/infomation",[self baseURL]];
}

+ (NSString *)getSongCollectionListURLString {
    return [NSString stringWithFormat:@"%@/toutiao/music/collection/list", [self baseURL]];
}

+ (NSString *)getSongListURLString {
    return [NSString stringWithFormat:@"%@/toutiao/music/collection/songs", [self baseURL]];
}

+ (NSString *)searchSongListURLString {
    return [NSString stringWithFormat:@"%@/toutiao/music/search/songs", [self baseURL]];
}


@end


NSString * baseUrl(void)
{
    return [CommonURLSetting  baseURL];
}

NSString* SNSBaseURL(void)
{
    return [CommonURLSetting SNSBaseURL];
}

NSString* securityURL(void)
{
    return [CommonURLSetting securityURL];
}

NSArray *baseUrlMapping(void)
{
    return [CommonURLSetting urlMapping];
}

NSString * logBaseURL(void)
{
    return [CommonURLSetting logBaseURL];
}
