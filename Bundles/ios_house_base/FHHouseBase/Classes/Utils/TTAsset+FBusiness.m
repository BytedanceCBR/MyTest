//
//  TTAsset+FBusiness.m
//  FHHouseBase
//
//  Created by wangzhizhou on 2020/4/16.
//

#import "TTAsset+FBusiness.h"

@implementation TTAsset(FBusiness)
+ (TTAsset *)convertFromTTAssetModel:(TTAssetModel *)assetModel {
    TTAsset *asset = [TTAsset generateWithAsset:assetModel.asset type:(TTAssetMediaType)assetModel.type];
    asset.cacheImage = assetModel.cacheImage;
    asset.thumbImage = assetModel.thumbImage;
    asset.cutImage = assetModel.cutImage;
    asset.imageURL = assetModel.imageURL;
    asset.localCacheFilePath = assetModel.localCacheFilePath;
    asset.type = assetModel.type;
    asset.width = assetModel.width;
    asset.height = assetModel.height;
    return asset;
}
@end

@implementation TTAssetModel(FBusiness)
+ (TTAssetModel *)convertFromTTAsset:(TTAsset *)asset {
    TTAssetModel *assetModel = [TTAssetModel modelWithAsset:asset.asset type:(TTAssetModelMediaType)asset.type];
    assetModel.cacheImage = asset.cacheImage;
    assetModel.thumbImage = asset.thumbImage;
    assetModel.cutImage = asset.cutImage;
    assetModel.imageURL = asset.imageURL;
    assetModel.localCacheFilePath = asset.localCacheFilePath;
    assetModel.type = asset.type;
    assetModel.width = asset.width;
    assetModel.height = asset.height;
    return assetModel;
}
@end

@implementation NSArray(TTAssetModel)
- (NSArray<TTAsset *> *)convertToTTAssetArray {
    NSMutableArray *assets = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj isKindOfClass:TTAssetModel.class]) {
            TTAsset *asset = [TTAsset convertFromTTAssetModel:obj];
            [assets addObject:asset];
        }
    }];
    return assets;
}
@end
 
@implementation NSArray(TTAsset)
- (NSArray<TTAssetModel *> *)convertToTTAssetModelArray {
    NSMutableArray *assetModels = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj isKindOfClass:TTAsset.class]) {
            TTAssetModel *assetModel = [TTAssetModel convertFromTTAsset:obj];
            [assetModels addObject:assetModel];
        }
    }];
    return assetModels;
}
@end
