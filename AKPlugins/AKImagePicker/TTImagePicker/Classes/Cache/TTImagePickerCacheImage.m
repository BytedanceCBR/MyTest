//
//  TTImagePickerCacheImage.m
//  Article
//
//  Created by tyh on 2017/4/23.
//
//

#import "TTImagePickerCacheImage.h"

@implementation TTImagePickerCacheImage

- (instancetype)initWithImage:(UIImage *)image assetID:(NSString *)assetID
{
    if (self = [self init]) {
        _image = image;
        _assetID = assetID;
        CGSize imageSize = CGSizeMake(image.size.width * image.scale, image.size.height * image.scale);
        CGFloat bytesPerPixel = 4.0;
        CGFloat bytesPerSize = imageSize.width * imageSize.height;
        _totalBytes = (UInt64)bytesPerPixel * (UInt64)bytesPerSize;
        _lastCacheDate = [NSDate date];
    }
    return self;
}

- (UIImage *)refreshCacheAndGetImage
{
    //每次获取Image,都刷新缓存时间
    _lastCacheDate = [NSDate date];
    return _image;


}

@end
