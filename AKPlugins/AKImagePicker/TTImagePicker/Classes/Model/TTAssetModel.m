//
//  TTAssetModel.m
//  Article
//
//  Created by SongChai on 2017/4/9.
//
//

#import "TTAssetModel.h"
#import "TTImagePickerManager.h"

@implementation TTAssetModel

+ (instancetype)modelWithAsset:(id)asset type:(TTAssetModelMediaType)type{
    TTAssetModel *model = [[TTAssetModel alloc] init];
    model.asset = asset;
    model.assetID = [[TTImagePickerManager manager] getAssetIdentifier:asset];
    model.type = type;
    return model;
}

+ (instancetype)modelWithAsset:(id)asset type:(TTAssetModelMediaType)type timeLength:(NSString *)timeLength {
    TTAssetModel *model = [self modelWithAsset:asset type:type];
    model.timeLength = timeLength;
    return model;
}

+ (instancetype)modelWithImage:(UIImage *)image {
    TTAssetModel *model = [[TTAssetModel alloc] init];
    model.cacheImage = image;
    model.type = TTAssetModelMediaTypePhoto;
    return model;
}

+ (instancetype)modelWithImageWidth:(NSUInteger)width height:(NSUInteger)height url:(NSString *)url uri:(NSString *)uri {
    TTAssetModel *model = [[TTAssetModel alloc] init];
    model.width = width;
    model.height = height;
    model.imageURL = [NSURL URLWithString:url];
    model.imageURI = uri;
    return model;
}

- (NSUInteger)hash {
    if (self.assetID) {
        return self.assetID.hash;
    }
    if (self.cacheImage) {
        return self.cacheImage.hash;
    }
    return [super hash];
}

- (BOOL)isEqual:(TTAssetModel *)rawItem {
    if (rawItem == self) return YES;
    if (![rawItem isKindOfClass:[self class]]) return NO;
    if (self.assetID) {
        return [rawItem.assetID isEqual:self.assetID];
    }
    if (self.cacheImage) {
        return self.cacheImage == rawItem.cacheImage;
    }
    return [super isEqual:rawItem];
}


//格式化成xx:xx
+ (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration {
    NSString *newTime;
    if (duration < 10) {
        newTime = [NSString stringWithFormat:@"0:0%zd",duration];
    } else if (duration < 60) {
        newTime = [NSString stringWithFormat:@"0:%zd",duration];
    } else {
        NSInteger min = duration / 60;
        NSInteger sec = duration - (min * 60);
        if (sec < 10) {
            newTime = [NSString stringWithFormat:@"%zd:0%zd",min,sec];
        } else {
            newTime = [NSString stringWithFormat:@"%zd:%zd",min,sec];
        }
    }
    return newTime;
}

@end
