//
//  TTImagePickerCacheImage.h
//  Article
//
//  Created by tyh on 2017/4/23.
//
//

#import <Foundation/Foundation.h>

@interface TTImagePickerCacheImage : NSObject

@property (nonatomic, strong,readonly) UIImage *image;
@property (nonatomic, strong,readonly) NSString *assetID;
/// cache大小
@property (nonatomic, assign,readonly) UInt64 totalBytes;
/// 上次cache日期
@property (nonatomic, strong,readonly) NSDate *lastCacheDate;

/// 初始化
- (instancetype)initWithImage:(UIImage *)image assetID:(NSString *)assetID;

/// 获取的时候刷新cache日期
- (UIImage *)refreshCacheAndGetImage;

@end
