//
//  TTAdCanvasDownloadManager.m
//  Article
//
//  Created by yin on 2016/12/18.
//
//

#import "TTAdCanvasDownloadManager.h"

#import "NetworkUtilities.h"
#import "SSSimpleCache.h"
#import "TTAdManager.h"
#import "TTNetworkManager.h"

@implementation TTAdCanvasDownloadManager

#pragma mark --Download Resource

+ (void)downloadResource:(TTAdCanvasModel*)model
{
    if (model.data.ad_projects.count == 0) {
        return;
    }
    TTNetworkFlags flag = TTAdNetworkGetFlags();
    if (!(flag & model.data.predownload.integerValue)){
        return;
    }
    [model.data.ad_projects enumerateObjectsUsingBlock:^(TTAdCanvasProjectModel  *_Nonnull projectObj, NSUInteger idx, BOOL * _Nonnull stop) {

        TTAdCanvasProjectModel* projectModel = (TTAdCanvasProjectModel*)projectObj;
        
        if (!isEmptyString(projectModel.resource.jsonString)) {
            [TTAdCanvasDownloadManager downloadJsonWithStr:projectModel.resource.jsonString resourceModel:projectModel];
        }
        
        if (projectModel.resource.image.count > 0) {
            [projectModel.resource.image enumerateObjectsUsingBlock:^(NSDictionary  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [TTAdCanvasDownloadManager downloadImageWithModel:obj resourceModel:projectModel index:0];
            }];
        }
    }];
}

+ (void)downloadImageWithModel:(NSDictionary *)imageinfo resourceModel:(TTAdCanvasProjectModel*)projectModel index:(NSUInteger)index
{
    
    TTImageInfosModel* infoModel = [[TTImageInfosModel alloc] initWithDictionary:imageinfo];
    if (!infoModel||![infoModel isKindOfClass:[TTImageInfosModel class]]) {
        return;
    }
    
    NSString *urlString = [infoModel urlStringAtIndex:index];
    if (isEmptyString(urlString)) {
        return;
    }
    
    if ([[SSSimpleCache sharedCache] isImageInfosModelCacheExist:infoModel]) {
        
        return;
    }
    __block NSUInteger _index = index;

    [self requestForBinary:urlString callBack:^(NSError *error, id obj) {
        
        if (error) {
            [TTAdCanvasDownloadManager downloadImageWithModel:imageinfo resourceModel:projectModel index:++_index];
            return;
        }
        
        if (obj && [obj isKindOfClass:[NSData class]]) {
            
            NSTimeInterval timeInterval = projectModel.end_time - [[NSDate date]timeIntervalSince1970];
            [[SSSimpleCache sharedCache] setData:(NSData *)obj forImageInfosModel:infoModel withTimeoutInterval:timeInterval];
        }
    }];
}

+ (void)downloadJsonWithStr:(NSString *)jsonStr resourceModel:(TTAdCanvasProjectModel*)projectModel
{
    if (isEmptyString(jsonStr)) {
        return;
    }
    if ([[SSSimpleCache sharedCache] fileCachePathIfExist:jsonStr]) {
        return;
    }
    
    [self requestForBinary:jsonStr callBack:^(NSError *error, id obj) {
        if (!error) {
            if (obj && [obj isKindOfClass:[NSData class]]) {
                NSTimeInterval timeInterval = projectModel.end_time - [[NSDate date]timeIntervalSince1970];
                [[SSSimpleCache sharedCache] setData:(NSData *)obj forKey:jsonStr withTimeoutInterval:timeInterval];
            }
        }
    }];
}

+ (void)requestForBinary:(NSString*)urlString callBack:(TTNetworkObjectFinishBlock)block
{
    [[TTNetworkManager shareInstance] requestForBinaryWithURL:urlString params:nil method:@"GET" needCommonParams:NO callback:^(NSError *error, id obj) {
        if (block) {
            block(error, obj);
        }
    }];
}

@end
