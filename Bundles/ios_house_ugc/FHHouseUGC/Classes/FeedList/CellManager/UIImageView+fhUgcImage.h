//
//  UIImageView+fhUgcImage.h
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2020/6/22.
//

#import <UIKit/UIKit.h>
#import "UIImageView+BDWebImage.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (fhUgcImage)

- (nullable BDWebImageRequest *)fh_setImageWithURL:(nonnull NSURL *)imageURL placeholder:(nullable UIImage *)placeholder;

- (nullable BDWebImageRequest *)fh_setImageWithURLs:(nonnull NSArray *)imageURLs placeholder:(nullable UIImage *)placeholder;

- (nullable BDWebImageRequest *)fh_setImageWithURLs:(nonnull NSArray *)imageURLs placeholder:(nullable UIImage *)placeholder reSize:(CGSize)reSize;

- (nullable BDWebImageRequest *)fh_setImageWithURL:(nonnull NSURL *)imageURL placeholder:(nullable UIImage *)placeholder reSize:(CGSize)reSize;

@end

NS_ASSUME_NONNULL_END
