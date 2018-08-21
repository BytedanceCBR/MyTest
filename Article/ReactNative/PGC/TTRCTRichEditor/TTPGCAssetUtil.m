//
//  TTPGCAssetUtil.m
//  Article
//
//  Created by liaozhijie on 2017/7/21.
//
//

#import <Photos/PHAssetResource.h>
#import <Photos/PHImageManager.h>

#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetRepresentation.h>

#import "TTPGCAssetUtil.h"

@implementation TTPGCAssetUtil

// 根据asset(PHAsset | ALAsset) 获取asset url
+ (NSURL *)getURLStringFromAsset:(id)asset {
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset * phAsset = (PHAsset *)asset;
        if (!phAsset.localIdentifier || phAsset.localIdentifier.length < 7) {
            return nil;
        }
        NSString* assetID = [phAsset.localIdentifier substringToIndex:(phAsset.localIdentifier.length - 7)];
        NSURL* url = [NSURL URLWithString:
                      [NSString stringWithFormat:@"assets-library://asset/asset.%@?id=%@&ext=%@", @"JPG", assetID, @"JPG"]
                      ];
        return url;
    } else if ([asset isKindOfClass:[ALAsset class]]){
        return ((ALAsset *)asset).defaultRepresentation.url;
    }
    return nil;
}

// 根据asser url 获取图片
+ (void)getImageDataFromURL:(NSURL*)url
              resultHandler:(void(^)(NSData *__nullable imageData, NSString *__nullable dataUTI, UIImageOrientation orientation, NSDictionary *__nullable info))resultHandler {
    PHFetchResult * fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
    if (!fetchResult || !fetchResult.firstObject) {
        resultHandler(nil, nil, UIImageOrientationUp, nil);
        return;
    }
    PHAsset * phAsset = fetchResult.firstObject;
    [self getImageDataFromPHAsset:phAsset resultHandler:resultHandler];
}

// 根据 PHAsset 获取图片
+ (void)getImageDataFromPHAsset:(PHAsset *)asset
                  resultHandler:(void(^)(NSData *__nullable imageData, NSString *__nullable dataUTI, UIImageOrientation orientation, NSDictionary *__nullable info))resultHandler {
    if (asset.mediaType == PHAssetMediaTypeImage) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                          options:options
                                                    resultHandler: resultHandler];
    }
}

@end
