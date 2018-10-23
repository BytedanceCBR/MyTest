//
//  TTAssetModel.h
//  Article
//
//  Created by SongChai on 2017/4/9.
//
//

typedef enum : NSUInteger {
    TTAssetModelMediaTypePhoto = 0,
    TTAssetModelMediaTypeLivePhoto,
    TTAssetModelMediaTypePhotoGif,
    TTAssetModelMediaTypeVideo,
    TTAssetModelMediaTypeAudio
} TTAssetModelMediaType;

@interface TTAssetModel : NSObject

@property (nonatomic, strong) id asset;             ///< PHAsset or ALAsset
@property (nonatomic, copy) NSString* assetID;             ///唯一标识

@property (nonatomic, assign) TTAssetModelMediaType type;
@property (nonatomic, copy) NSString *timeLength;


@property (nonatomic, strong) UIImage *cacheImage; //默认为空，如果不为空，会优先读取Image -- > 用于待发布部分数据

@property (nonatomic, strong) UIImage *thumbImage; //图片选择器列表里的小尺寸图
/// Init a photo dataModel With a asset
/// 用一个PHAsset/ALAsset实例，初始化一个照片模型
+ (instancetype)modelWithAsset:(id)asset type:(TTAssetModelMediaType)type;
+ (instancetype)modelWithAsset:(id)asset type:(TTAssetModelMediaType)type timeLength:(NSString *)timeLength;
+ (instancetype)modelWithImage:(UIImage*)image;

//得到视频时间为 xx:xx格式字符串
+ (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration;


@end
