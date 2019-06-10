//
//  WDImagePathUploadImageModel.h
//  Article
//
//  Created by 王霖 on 15/12/21.
//
//

#import <Foundation/Foundation.h>
#import "WDUploadImageModelProtocol.h"

@interface WDImagePathUploadImageModel : NSObject<NSCoding, NSCopying, WDUploadImageModelProtocol>

@property (nonatomic, copy) NSString *remoteImgUri;
@property (nonatomic, readonly, assign) WDUploadImageSourceType sourceType;

@property (nonatomic, copy) NSString *compressImgUri;//压缩后的图片在沙盒中的路径
@property (nonatomic, copy, readonly) NSString *thirdImgUri;//第三方的图片路径（必要时候使用它下载图片并且上传）

/**
 *  指定初始化器
 *
 *  @param thirdImgUri 第三方图片的uri
 *
 *  @return 上传图片实例
 */
- (instancetype)initWithThirdImgUri:(NSString *)thirdImgUri NS_DESIGNATED_INITIALIZER;
/**
 *  置顶初始化器
 *
 *  @param compressImgUri 压缩图片在沙盒中的路径
 *
 *  @return 上传图片实例
 */
- (instancetype)initWithcompressImgUri:(NSString *)compressImgUri NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

+ (BOOL)isToutiaoUrl:(NSURL *)url;

@end
 
