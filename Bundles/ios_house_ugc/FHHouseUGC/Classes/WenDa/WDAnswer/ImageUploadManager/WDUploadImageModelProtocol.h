//
//  WDUploadImageModelProtocol.h
//  TTWenda
//
//  Created by 延晋 张 on 2017/12/22.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WDUploadImageSourceType)  {
    WDUploadImageSourceTypePath,   //本地Path上传
    WDUploadImageSourceTypeImage,  //内存中的UIImage方式上传
};

@protocol WDUploadImageModelProtocol <NSObject>

@required

@property (nonatomic, copy)   NSString *remoteImgUri;          //上传图片的uri，如果有则表示上传成功，必须实现
@property (nonatomic, readonly, assign) WDUploadImageSourceType sourceType;

@optional

/*
 本地Path上传必须实现的方法
 */
@property (nonatomic, copy, readonly) NSString *thirdImgUri; //第三方的图片路径（必要时候使用它下载图片并且上传）
@property (nonatomic, copy) NSString *compressImgUri;        //压缩后的图片在沙盒中的路径

/*
 内存图片上传必须实现的方法
 */
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSData *webpImage;

@end
