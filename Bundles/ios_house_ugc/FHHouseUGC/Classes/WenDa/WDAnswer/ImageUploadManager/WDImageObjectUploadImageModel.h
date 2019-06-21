//
//  WDImageObjectUploadImageModel.h
//  Article
//
//  Created by 延晋 张 on 16/7/20.
//
//

#import <Foundation/Foundation.h>
#import "WDUploadImageModelProtocol.h"

@interface WDImageObjectUploadImageModel : NSObject <NSCoding, WDUploadImageModelProtocol>

@property (nonatomic, copy) NSString *remoteImgUri; //上传图片的uri，注意是uri不是url，持久化属性
@property (nonatomic, readonly, assign) WDUploadImageSourceType sourceType;

@property (nonatomic, strong) UIImage *image;  // 持久化属性
@property (nonatomic, copy) NSData *webpImage;  // 压缩成webp格式的图片数据

@property (nonatomic, copy) NSString *thirdImgUri; //第三方的图片路径，用来允许加载网络图。对于图片上传Manager本身不关心这个属性，这个其实是完整的url，持久化属性
@property (nonatomic, copy) NSString *compressImgUri; // 压缩后的图片在沙盒中的路径。对于图片上传Manager本身不关心这个属性，只有当这个内存上传图片模型，需要往沙盒中写入的时候，可以用这个属性记录，这个其实是完整的url，非持久化属性

- (instancetype)initWithcompressImg:(UIImage *)image NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

- (BOOL)imageReady;

/** 异步加载图片，加载完成后会写入image属性，支持fileURL和HTTP */
- (void)loadImageWithURL:(NSURL *)imageURL;

@end
