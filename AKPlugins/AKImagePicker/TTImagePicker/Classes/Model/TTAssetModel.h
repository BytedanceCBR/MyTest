//
//  TTAssetModel.h
//  Article
//
//  Created by SongChai on 2017/4/9.
//
//

#import <Foundation/Foundation.h>

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

@property (nonatomic, strong) NSURL *imageURL; //图片的url，当asset为空时生效，用于展示不在相册中的图片
@property (nonatomic, copy) NSString *imageURI; //不在相册中图片的uri

@property (nonatomic, assign) NSUInteger width;
@property (nonatomic, assign) NSUInteger height;
/// Init a photo dataModel With a asset
/// 用一个PHAsset/ALAsset实例，初始化一个照片模型
+ (instancetype)modelWithAsset:(id)asset type:(TTAssetModelMediaType)type;
+ (instancetype)modelWithAsset:(id)asset type:(TTAssetModelMediaType)type timeLength:(NSString *)timeLength;
+ (instancetype)modelWithImage:(UIImage*)image;
+ (instancetype)modelWithImageWidth:(NSUInteger)width height:(NSUInteger)height url:(NSString *)url uri:(NSString *)uri;

//得到视频时间为 xx:xx格式字符串
+ (NSString *)getNewTimeFromDurationSecond:(NSInteger)duration;


@end
