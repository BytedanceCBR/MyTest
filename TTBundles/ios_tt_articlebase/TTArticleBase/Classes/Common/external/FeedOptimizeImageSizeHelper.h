//
//  FeedOptimizeImageSizeHelper.h
//  Article
//
//  Created by tyh on 2017/11/27.
//

#import <Foundation/Foundation.h>

@interface FeedOptimizeImageSizeHelper : NSObject

//图片等比缩放至控件 AscpetFill
+ (void)cropEqualScaleImage:(UIImage *)image toSize:(CGSize)size completeBlock:(void(^)(UIImage *targetImage))completeBlock ;

@end
