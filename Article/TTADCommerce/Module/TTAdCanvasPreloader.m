//
//  TTAdCanvasPreloader.m
//  Article
//
//  Created by carl on 2017/5/31.
//
//

#import "TTAdCanvasPreloader.h"

#import "TTAdCanvasManager.h"
#import "TTAdCanvasModel.h"
#import "TTAdFeedModel.h"
#import "TTAdLog.h"
#import "TTAdPreloadCanvasResourceModel.h"
#import "TTAdResourceDownloader.h"
#import "TTNetworkManager.h"
#import "ExploreOrderedData+TTAd.h"

static NSString * const canvasPreloadErrorDomain = @"canvas.preload";

@interface TTAdCanvasPreloader ()
@property (nonatomic, copy) TTAdPreloaderCompletedBlock successBlock;
@end

@implementation TTAdCanvasPreloader

+ (instancetype)sharedPreloader {
    static dispatch_once_t onceToken;
    static id sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

+ (BOOL)needPreloadResource:(ExploreOrderedData *)orderData {
    return [TTAdCanvasManager filterCanvas:orderData];
}

- (void)preloadResource:(ExploreOrderedData *)orderData completed:(TTAdPreloaderCompletedBlock _Nullable)successBlock {
    
    DLog(@"CANVAS %s ad_id = %@",__PRETTY_FUNCTION__, orderData.raw_ad.ad_id);
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:orderData.raw_ad.ad_id forKey:@"creative_id"];
    [params setValue:orderData.raw_ad_data[@"site_id"] forKey:@"site_id"];
    
    __weak typeof(self) weakSelf = self;
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[CommonURLSetting adPreloadV2URLString] params:[params copy] method:@"GET" needCommonParams:YES callback:^(NSError *error, NSDictionary *jsonObj) {
        __strong typeof(self) strongSelf = weakSelf;
        if (![jsonObj isKindOfClass:[NSDictionary class]] && error) {
            if (successBlock) {
                NSError *preloadError = [NSError errorWithDomain:canvasPreloadErrorDomain code:1 userInfo:error.userInfo];
                successBlock(NO, preloadError);
            }
            return;
        }
        NSDictionary *data = [jsonObj tt_dictionaryValueForKey:@"data"];
        NSError *jsonModelError;
        TTAdPreloadCanvasResourceModel *model = [[TTAdPreloadCanvasResourceModel alloc] initWithDictionary:data error:&jsonModelError];
        if (!model) {
            if (successBlock) {
                NSError *preloadError = [NSError errorWithDomain:canvasPreloadErrorDomain code:2 userInfo:jsonModelError.userInfo];
                successBlock(NO, preloadError);
            }
            return;
        }
        [strongSelf makeCanvasMetaInfo:(ExploreOrderedData *)orderData preloadModel:model];
        [[TTAdResourceDownloader sharedManager] preloadResource:[model.preload_data copy] timeout:model.expire_seconds];
        if (successBlock) {
            successBlock(YES, nil);
        }
    }];
}

- (void)makeCanvasMetaInfo:(ExploreOrderedData *)orderData  preloadModel:(TTAdPreloadCanvasResourceModel *)model {
    
    TTAdCanvasProjectModel *projectModel = [TTAdCanvasProjectModel new];
    TTAdPreloadCanvasSettingModel *canvas = model.canvas;
    
    NSSet *must_urlSet = [NSSet setWithArray:canvas.must_url];
    
    projectModel.end_time = (NSInteger)([[NSDate date] timeIntervalSince1970]) + model.expire_seconds;
    
    projectModel.ad_ids = [model.ad_id copy];  //NSNumber
    
    TTAdCanvasResourceModel *projectResource = [TTAdCanvasResourceModel new];
   
    if (canvas.layout_url) {
        projectResource.json = @[canvas.layout_url].copy;
    }
    if (canvas.root_color) {
        projectResource.rootViewColor = @[canvas.root_color].copy;
    }
    if (canvas.anim_style) {
        projectResource.anim_style = @[canvas.anim_style];
    }
    if (canvas.hasCreatedata) {
        projectResource.hasCreatedata = @[canvas.hasCreatedata];
    }
    
    NSMutableArray<NSDictionary *> *images = [NSMutableArray array];
    NSMutableArray<NSDictionary *> *videos = [NSMutableArray array];
    [model.preload_data enumerateObjectsUsingBlock:^(TTAdResourceModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL isRequireResource = [must_urlSet containsObject:obj.uri];
        if(isRequireResource) {
            NSMutableDictionary *resource = obj.resource.mutableCopy;
            resource[@"preloading_flag"] = @1;
            obj.resource = resource.copy;
        }
        if ([obj.contentType hasPrefix:@"image"]) {
            [images addObject:obj.resource]; // fuck url uri
        } else if ([obj.contentType hasPrefix:@"video"]) {
            [videos addObject:obj.resource];
        } else {
            //json html css
        }
    }];
    
    projectResource.video = [videos copy];
    projectResource.image = [images copy];
    projectModel.resource = projectResource;
    [TTAdCanvasManager mergeProject:projectModel];
}

@end
