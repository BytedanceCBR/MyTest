//
//  TTAdThirdPreloader.m
//  Article
//
//  Created by carl on 2017/5/31.
//
//


#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreOrderedData+TTAd.h"
#import "TTAdResPreloadModel.h" // adapter model
#import "TTAdResourceDownloader.h"
#import "TTAdResourceModel.h"
#import "TTAdThirdPreloader.h"
#import "TTAdWebResPreloadManager.h"
#import "TTNetworkManager.h"

@implementation TTAdThirdPreloader

+ (instancetype)sharedPreloader {
    static dispatch_once_t onceToken;
    static id sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

+ (BOOL)needPreloadResource:(ExploreOrderedData *_Nullable)orderData; {
    return YES;
}

- (void)preloadResource:(ExploreOrderedData *)orderData completed:(TTAdPreloaderCompletedBlock _Nullable)successBlock {
    NSString* urlString = [CommonURLSetting adPreloadV2URLString];//固定预加载接口
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:1];
    [param setValue:orderData.ad_id forKey:@"creative_id"];
    WeakSelf;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:urlString params:param method:@"GET" needCommonParams:YES callback:^(NSError *error,id jsonObj){
        StrongSelf;
        if (error && !jsonObj) {
            return ;
        }
        NSDictionary *data = [jsonObj tt_dictionaryValueForKey:@"data"];
        NSArray *resourcesDict = [data tt_arrayValueForKey:@"preload_data"];
        NSError *jsonModelError;
        NSArray<TTAdResourceModel *> *resources = [TTAdResourceModel arrayOfModelsFromDictionaries:resourcesDict error:&jsonModelError];
        
        [self resolveMetaInfo:orderData preloadModel:data  resourece:resources];
        
        NSInteger expire_seconds = [data tt_integerValueForKey:@"expire_seconds"];
        [[TTAdResourceDownloader sharedManager] preloadResource:resources timeout:expire_seconds];
    }];
}

- (void)resolveMetaInfo:(ExploreOrderedData *)orderData  preloadModel:(NSDictionary *)data resourece:(NSArray<TTAdResourceModel *> *)resources {
    NSArray *ad_ids = [data tt_arrayValueForKey:@"ad_id"]; // NSNumber
    NSArray *mapping = [data tt_arrayValueForKey:@"mapping"];
    
    NSMutableDictionary *indexDict = [NSMutableDictionary dictionaryWithCapacity:resources.count];
    [resources enumerateObjectsUsingBlock:^(TTAdResourceModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [indexDict setValue:obj forKey:obj.uri];
    }];
    
    for (NSDictionary *obj in mapping) {
        if (![obj isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        
        NSString *source_url = [obj tt_stringValueForKey:@"source_url"];
        NSString *resource_url = [obj tt_stringValueForKey:@"resource_url"];
        TTAdResourceModel *resourceModel = indexDict[resource_url];
        
        if (!resourceModel || !source_url) {
            continue;
        }
        
        TTAdResPreloadDataModel *thirdPreloadModel = [TTAdResPreloadDataModel new];
        thirdPreloadModel.content_type = resourceModel.contentType;
        thirdPreloadModel.preload_data = resourceModel.resource;
        thirdPreloadModel.source_url = source_url;
        thirdPreloadModel.ad_id = [ad_ids copy];
        
        [[TTAdWebResPreloadManager sharedManager] synchronizeReourceModel:thirdPreloadModel];

    }
}

@end
