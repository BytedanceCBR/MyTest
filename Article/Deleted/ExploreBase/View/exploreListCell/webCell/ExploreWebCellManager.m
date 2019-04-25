//
//  ExploreWebCellManager.m
//  Article
//
//  Created by Chen Hong on 15/3/4.
//
//

#import "ExploreWebCellManager.h"
#import "NSDictionary+TTAdditions.h"
#import "TTNetworkManager.h"
//#import "WebResourceManager.h"

@implementation ExploreWebCellManager {
    //NSOperationQueue *_operationQueue;
//    NSMutableSet *_templateChangedIDSet;
}

static ExploreWebCellManager *s_manager;
+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[ExploreWebCellManager alloc] init];
    });
    
    return s_manager;
}

- (id)init {
    self = [super init];
    if (self) {
        //_templateChangedIDSet = [NSMutableSet set];
    }
    return self;
}

- (void)startGetTemplateFromWapData:(WapData *)wapData completion:(void(^)(WapData *wapData, NSString *htmlStr, NSError *error))completion {
    
    // 请求最新wap模板数据
    NSString *templateUrl = wapData.templateUrl;
    
    if (isEmptyString(templateUrl)) {
        NSError *error = [NSError errorWithDomain:@"error" code:0 userInfo:nil];
        completion(wapData, nil, error);
        return;
    }
    
    //templateUrl = [TTDeviceHelper customURLStringFromString:templateUrl];
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:templateUrl params:nil method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        NSError *err = nil;
        NSString *html = nil;
        
        if ([jsonObj isKindOfClass:[NSDictionary class]] && [jsonObj objectForKey:@"data"]) {
            //NSDictionary *resultDict = [result dictionaryValueForKey:@"result" defalutValue:nil];
            NSDictionary *dataDict = [jsonObj dictionaryValueForKey:@"data" defalutValue:nil];
            html = [dataDict stringValueForKey:@"template_html" defaultValue:nil];
            NSString *md5 = [dataDict stringValueForKey:@"template_md5" defaultValue:nil];
            NSString *baseUrl = [dataDict stringValueForKey:@"base_url" defaultValue:nil];
            [wapData updateWithTemplateContent:html templateMD5:md5 baseUrl:baseUrl];
            
            //[self removeTemplateChangedForID:@(wapData.uniqueID)];
        } else {
            if ([error.domain isEqualToString:NSURLErrorDomain]) {
                if (error.code != NSURLErrorNotConnectedToInternet &&
                    error.code != NSURLErrorCancelled) {
                    NSMutableDictionary *extra = [NSMutableDictionary dictionary];
                    [extra setValue:templateUrl forKey:@"URI"];
                    [extra setValue:@(error.code) forKey:@"code"];
                    [[TTMonitor shareManager] trackService:@"error_widget_url" status:1 extra:extra];
                }
            }

            err = [NSError errorWithDomain:@"error" code:0 userInfo:nil];
        }
        
        if (completion) {
            completion(wapData, html, err);
        }
    }];
}

- (void)startGetDataFromWapData:(WapData *)wapData completion:(void(^)(WapData *wapData, NSDictionary *data, NSError *error))completion {
    
    // 请求最新wap模板数据
    NSString *dataUrl = wapData.dataUrl;
    
    if (isEmptyString(dataUrl)) {
        NSError *error = [NSError errorWithDomain:@"error" code:0 userInfo:nil];
        completion(wapData, nil, error);
        return;
    }
    
    //dataUrl = [TTDeviceHelper customURLStringFromString:dataUrl];
    
    [[TTNetworkManager shareInstance] requestForJSONWithURL:dataUrl params:nil method:@"GET" needCommonParams:YES callback:^(NSError *err, id jsonObj) {
        NSError *error;
        NSDictionary *data;
        //NSLog(@"err: %@ result: %@", err, result);
        if (!err) {
            NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:jsonObj];
            [mDict setValue:@"success" forKey:@"message"];
            [wapData updateWithDataContentObj:mDict];
        } else {
            error = [NSError errorWithDomain:@"error" code:0 userInfo:nil];
            wapData.lastUpdateTime = [NSDate date];
        }
        
        if (completion) {
            completion(wapData, data, error);
        }
    }];
}

//- (void)addTemplateChangedForID:(id)uniqueID
//{
//    @synchronized(self) {
//        if (uniqueID) {
//            [_templateChangedIDSet addObject:uniqueID];
//        }
//    }
//}
//
//- (void)removeTemplateChangedForID:(id)uniqueID
//{
//    @synchronized(self) {
//        if (uniqueID) {
//            [_templateChangedIDSet removeObject:uniqueID];
//        }
//    }
//}
//
//- (BOOL)hasTemplateChangedForID:(id)uniqueID
//{
//    @synchronized(self) {
//        if (uniqueID) {
//            return [_templateChangedIDSet containsObject:uniqueID];
//        }
//    }
//    return NO;
//}

@end
