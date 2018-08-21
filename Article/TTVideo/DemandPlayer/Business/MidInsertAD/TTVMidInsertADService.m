//
//  TTVMidInsertADService.m
//  Article
//
//  Created by lijun.thinker on 05/09/2017.
//
//

#import "TTVMidInsertADService.h"
#import "TTVMidInsertADModel.h"
#import <TTNetworkManager/TTNetworkManager.h>
#import <YYMemoryCache.h>

#pragma mark - TTVMidInsertADModelManager
@class TTVMidInsertADModel;
@interface TTVMidInsertADModelManager : NSObject

@property (nonatomic, strong) YYMemoryCache *cache;

+ (instancetype)sharedManager;

- (void)setObject:(NSArray <TTVMidInsertADModel *> *)obj forKey:(NSString *)key;

- (NSArray <TTVMidInsertADModel *> *)objectForKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;

@end

@implementation TTVMidInsertADModelManager

+ (instancetype)sharedManager {
    
    static TTVMidInsertADModelManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    
    if (self = [super init]) {
        
        _cache = [[YYMemoryCache alloc] init];
        _cache.countLimit = 2;
    }
    
    return self;
}

- (void)setObject:(NSArray<TTVMidInsertADModel *> *)obj forKey:(NSString *)key {
    
    if (isEmptyString(key) || ![obj isKindOfClass:[NSArray class]]) {
        return;
    }
    
    [_cache setObject:obj forKey:key];
}

- (NSArray<TTVMidInsertADModel *> *)objectForKey:(NSString *)key {
    
    if (isEmptyString(key)) {
        return nil;
    }
    
    return [[_cache objectForKey:key] copy];
}

- (void)removeObjectForKey:(NSString *)key {
    
    if (isEmptyString(key)) {
        return ;
    }
    
    [_cache removeObjectForKey:key];
}

@end

#pragma mark - TTVMidInsertADService

@interface TTVMidInsertADService()

@property (nonatomic, strong) fetchMidInsertADInfoCompletion completion;

@end

@implementation TTVMidInsertADService

- (void)fetchMidInsertADInfoWithRequestInfo:(NSDictionary *)requestInfo completion:(fetchMidInsertADInfoCompletion)completion {
    
    self.completion = completion;
    
    id obj = [[TTVMidInsertADModelManager sharedManager] objectForKey:requestInfo[@"group_id"]];
    if ([obj isKindOfClass:[NSArray class]]) {
        
        (!completion) ?: completion(obj, nil);
        
        return;
    }
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[self p_getAPIPrefix] params:requestInfo method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        
        if (!error && jsonObj) {
            [self p_handleMidInsertADRequestFinished:jsonObj[@"data"] forRequestInfo:requestInfo];
            
        } else {
            
            (!completion) ?: completion(nil, error);
        }
    }];
}

- (NSString *)p_getAPIPrefix {
    
    return [NSString stringWithFormat:@"%@/api/ad/mid_patch/v1/", [CommonURLSetting baseURL]];
}

- (void)p_handleMidInsertADRequestFinished:(NSDictionary *)result forRequestInfo:(NSDictionary *)requestInfo {
    
    if (![result isKindOfClass:[NSDictionary class]]) {
        
        return;
    }
    
    NSArray *ADItem = [result arrayValueForKey:@"ad_item" defaultValue:nil];
    
    NSMutableArray <TTVMidInsertADModel *> *items = [NSMutableArray arrayWithCapacity:2];
    
    for (NSDictionary *item in ADItem) {
        
        if (![item isKindOfClass:[NSDictionary class]]) {
            
            continue;
        }
        
        TTVMidInsertADInfoModel *midInsertADInfoModel = [[TTVMidInsertADInfoModel alloc] initWithDictionary:item error:nil];
        
        TTVMidInsertADModel *midInsertADModel = [[TTVMidInsertADModel alloc] init];
        midInsertADModel.midInsertADInfoModel = midInsertADInfoModel;
        
        if (![midInsertADInfoModel.adStartTime isKindOfClass:[NSNumber class]]) {
            midInsertADInfoModel.adStartTime = nil;
        }
        
        if (![midInsertADInfoModel.displayType isKindOfClass:[NSNumber class]]) {
            midInsertADInfoModel.displayType = nil;
        }
        
        if (![midInsertADInfoModel.displayTime isKindOfClass:[NSNumber class]]) {
            midInsertADInfoModel.displayTime = nil;
        }
        
        if (![midInsertADInfoModel.skipTime isKindOfClass:[NSNumber class]]) {
            midInsertADInfoModel.skipTime = nil;
        }
        
        if (midInsertADInfoModel.videoInfo &&
            midInsertADInfoModel.displayType.integerValue == 5) {
            midInsertADModel.style = TTVMidInsertADStyleVideo;
            
        } else if (midInsertADInfoModel.imageList.count > 0 &&
                   midInsertADInfoModel.displayType.integerValue == 2) {
            midInsertADModel.style = TTVMidInsertADStyleMarkImage;
        } else {
            midInsertADModel.style = TTVMidInsertADStyleNone;
        }
        
        if (!isEmptyString(midInsertADInfoModel.type) &&
            [midInsertADInfoModel.type isEqualToString:@"web"]) {
            midInsertADModel.type = TTVMidInsertADPageTypeWeb;
            
        } else if (!isEmptyString(midInsertADInfoModel.type) &&
                   [midInsertADInfoModel.type isEqualToString:@"app"]) {
            midInsertADModel.type = TTVMidInsertADPageTypeAPP;
        }
        
        if (midInsertADModel) {
            
            [items addObject:midInsertADModel];
        }
    }
    
    if (items.count > 0) {
        
        [[TTVMidInsertADModelManager sharedManager] setObject:[items copy] forKey:requestInfo[@"group_id"]];
    }
    
    (!self.completion) ?: self.completion(items, nil);
}

@end



