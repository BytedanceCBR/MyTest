//
//  NSData+Compression.m
//  Pods
//
//  Created by 延晋 张 on 16/6/6.
//
//

#import "NSData+TTShareCompression.h"
#import "UIImage+Activity.h"

@implementation NSData (TTShareCompression)

+ (NSData *)dataWithCompressionImage:(UIImage *)image limitedLength:(NSUInteger)length
{
    if (image) {
        CGSize contentSize = image.size;
        UIImage *contentImage = image;
        NSData  *contentData = UIImageJPEGRepresentation(image, 1.0);
        while (contentData.length > (length * 1024)) { //图片不能超过5M
            contentSize =CGSizeMake(contentSize.width/1.5, contentSize.height/1.5);
            contentImage = [contentImage ttShareActivity_resizedImage:contentSize interpolationQuality:kCGInterpolationDefault];
            contentData = UIImageJPEGRepresentation(contentImage, 1.0);
        }
        
        return contentData;
    } else {
        return nil;
    }
    
}

@end
