//
//  TTADImageDownloadManager.m
//  Article
//
//  Created by ranny_90 on 2017/3/21.
//
//

#import "TTADImageDownloadManager.h"
#import "SSSimpleCache.h"
#import "TTNetworkManager.h"
#import "TTAdMonitorManager.h"

@implementation TTADImageDownloadManager

+ (instancetype)sharedManager{
    static TTADImageDownloadManager *_adDownloadManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _adDownloadManager = [[self alloc] init];
    });
    return _adDownloadManager;
}

-(void)startDownloadImageWithImageInfoModel:(TTImageInfosModel *)imageInfoModel{
    
    if (!imageInfoModel || !imageInfoModel.urlWithHeader || imageInfoModel.urlWithHeader.count <= 0) {
        return;
    }
    
    [self startDownloadImageWithImageInfoModel:imageInfoModel index:0];
    
}


- (void)startDownloadImageWithImageInfoModel:(TTImageInfosModel *)imageInfoModel index:(NSUInteger)index {
    
    NSString *urlString = [imageInfoModel urlStringAtIndex:index];
    if (!urlString || urlString.length <= 0) {
        
        NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:3];
        [extra setValue:imageInfoModel.URI forKey:@"image_uri"];
        
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:imageInfoModel.urlWithHeader options:0 error:&error];
        NSString *urlsJSON = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [extra setValue:urlsJSON forKey:@"image_urls"];
        [extra setValue:@"ad_refresh" forKey:@"source"];
        
        [TTAdMonitorManager trackService:@"adrefresh_get_adimagedata_error" status:0 extra:extra];
        return;
    }
    if ([[SSSimpleCache sharedCache] isImageInfosModelCacheExist:imageInfoModel]) {
        return;
    }
    __block NSUInteger _index = index;
    
    [[TTNetworkManager shareInstance] requestForBinaryWithURL:urlString params:nil method:@"GET" needCommonParams:NO callback:^(NSError *error, id obj) {
        
        if (error) {
            [self startDownloadImageWithImageInfoModel:imageInfoModel index:++_index];
            return;
        }
        
        if (obj && [obj isKindOfClass:[NSData class]]) {
            [[SSSimpleCache sharedCache] setData:(NSData *)obj forImageInfosModel:imageInfoModel];
        }
    }];
}


@end
