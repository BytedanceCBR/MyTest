//
//  TTAsset+FBusiness.h
//  FHHouseBase
//
//  Created by wangzhizhou on 2020/4/16.
//

#import <TTImagePickerBase/TTAsset.h>
#import <TTImagePicker/TTAsset+BaseBusiness.h>
#import <TTImagePicker/TTAssetModel.h>


NS_ASSUME_NONNULL_BEGIN

@interface TTAsset(FBusiness)
+ (TTAsset *)convertFromTTAssetModel:(TTAssetModel *)assetModel;
@end

@interface TTAssetModel(FBusiness)
+ (TTAssetModel *)convertFromTTAsset:(TTAsset *)asset;
@end

@interface NSArray(TTAssetModel)
- (NSArray<TTAsset *> *)convertToTTAssetArray;
@end

@interface NSArray(TTAsset)
- (NSArray<TTAssetModel *> *)convertToTTAssetModelArray;
@end
NS_ASSUME_NONNULL_END
